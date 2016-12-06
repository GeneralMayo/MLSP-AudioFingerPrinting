function [timelines, timelineCompositionCell] = merge(matches,recordings,audioRate)
%merges recordings together based on matchings with other recordings
%input: matches - NxN upper right triangular cell matrix of matches
%       recordings - 1xM cell array of recordings, where each entry
%       is a 2x1 cell consiting of (1) data and (2) samplingRate
%       audioRate - the sampling rate to scale the match offsets by, or -1
%       to compute indices exactly
%       rescale offsets and treats recordings as video
%output: 1xN cell array of merged audio files, where N = number of unique
%        samples as found by our algorithm

global PSR_THRESHOLD;
MATCH_THRESHOLD = PSR_THRESHOLD;

%parse the matrix into match pairs 
matchTuples = [];
for i=1:size(matches,1)
   for j=i+1:size(matches,2)
       match = matches{i,j};
       coef = match{1};
       offset = match{2};
       %scale the offset if we're using video files
       if (coef >= MATCH_THRESHOLD)
            if audioRate < 0
                audioSampling = recording{j};
                audioSampling = audioSampling{2};
                offset = offset / audioSampling;
            end
            matchTuples = [matchTuples ; i,j,coef,offset];
       end
   end
end

%sort matches based on coefficient strength
matchTuples = sortrows(matchTuples,[-3;]);

%run merging algorithm

%set up initial data structures
timelines = cell(1,size(recordings,2));

%initialize timelines to empty matrices
for i=1:length(timelines)
    timelines{i} = [];
end
numTimelines = 0;
timelineOffsets = containers.Map('KeyType','int32','ValueType','any');
timelineCompositions = containers.Map('KeyType','int32','ValueType','any');
for i=1:size(matchTuples,1)
    match = matchTuples(i,:);
    matchA = match(1);
    matchB = match(2);
    offset = match(4);   
    if (isKey(timelineOffsets,matchA) && ~isKey(timelineOffsets,matchB))
        %merge B into A's timeline
        timelines = addRecordingToTimeline(matchB,matchA,offset,timelineOffsets,timelineCompositions,timelines,recordings,audioRate);
    elseif (~isKey(timelineOffsets,matchA) && isKey(timelineOffsets,matchB))
        %merge A into B's timeline
        timelines = addRecordingToTimeline(matchA,matchB,-1*offset,timelineOffsets,timelineCompositions,timelines,recordings,audioRate);
    elseif (isKey(timelineOffsets,matchA) && isKey(timelineOffsets,matchB))
        %merge two timelines together
        [timelines,numTimelines] = addTimelineToTimeline(matchB,matchA,offset,timelineOffsets,timelineCompositions,timelines,numTimelines,audioRate);
    else
        %create a new timeline
        numTimelines = numTimelines + 1;
        A = recordings{matchA};
        A = A{1};
        timelines{numTimelines} = A; %TODO arbitrary choice
        timelineOffsets(matchA) = {numTimelines,1};
        timelineCompositions(numTimelines) = [matchA];
        timelines = addRecordingToTimeline(matchB,matchA,offset,timelineOffsets,timelineCompositions,timelines,recordings,audioRate);
    end
end

    timelineCompositionCell = cell(1,numTimelines);
    for i=1:numTimelines
        timelineCompositionCell{i} = timelineCompositions(i);
    end
    
    %add elements that were not in any match to the timeline
    matched = keys(timelineOffsets); 
    for i=1:length(recordings)
        found = 0;
        for j=1:length(matched)
            if (matched{j} == i)
                found = 1;
                break;
            end
        end
        
        if (~found)
            numTimelines = numTimelines + 1;
            A = recordings{i};
            A = A{1};
            timelines{numTimelines} = A;
        end
    end
    
    %change timelines to be cell array of only length numTimelines
    newTimelines = cell(1,numTimelines);
    for i=1:numTimelines
       newTimelines{i} = timelines{i}; 
    end
    timelines = newTimelines;
end

function [newTimelines] = addRecordingToTimeline(A,B,offset,timelineOffsets,timelineCompositions,timelines,recordings,audioRate)
    %add recording A to recording B's timeline
    %offset is offset of A relative to B ie A(t + offset) = B(t)
    value = timelineOffsets(B);
    t_index = value{1};  
    B_offset = value{2};
    if (audioRate > 0)
        B_fps = recordings{B};
        B_fps = B_fps{2};
        B_offset = B_offset / B_fps;
    end
    t = timelines{t_index};
    A_index = B_offset + offset;
    A_recording = recordings{A};
    A_recording = A_recording{1};
    
    if (A_index < 0)
        %prepend A to t, then append any leftovers if length(A) > length(t)
        if (audioRate < 0)
            A_index = abs(A_index) + 1;
            t = [A_recording(1:A_index) ; t];
            t = [t ; A_recording(length(t)+1:length(A_recording))];
            new_AIndex = 1;
            shift = A_index;
        else
            A_obj = recordings{A};
            A_obj = A_obj{1};
            A_obj.CurrentTime = 0;
            A_index = abs(A_index);
            count = 0;
            while (A_obj.CurrentTime < A_index)
                frame = readFrame(A_obj);
                t = [frame ; t];
                count = count + 1;
            end
            new_AIndex = 1;
            shift = count;
        end
    else
        %append A to t, or do nothing if length(A) + offset <= length(t)
        if (audioRate < 0)
            t = [t ; A_recording(length(A_index:length(t))+1:length(A_recording))];
            new_AIndex = A_index;
            shift = 0;
        else
            A_obj = recordings{A};
            A_fps = A_obj{2};
            A_obj = A_obj{1};
            A_time = length(A_index * A_fps:length(t)) / A_fps;
            A_obj.CurrentTime = A_time;
            while (hasFrame(A_obj))
                frame = readFrame(A_obj);
                t = [t ; frame];
            end
            new_AIndex = A_index * A_fps;
            shift = 0;
        end
    end
    
    %update timeline and maps
    timelines{t_index} = t;  
    if (shift > 0)
       shiftTimeline(shift,t_index,timelineCompositions,timelineOffsets); 
    end
    timelineCompositions(t_index) = [timelineCompositions(t_index) ; A];
    timelineOffsets(A) = {t_index,new_AIndex};
    
    newTimelines = timelines;
end
function [newTimelines,newNumTimelines] = addTimelineToTimeline(A,B,offset,timelineOffsets,timelineCompositions,timelines,numTimelines,audioRate)
%add A's timeline to B's timeline with offset of A relative to B

%turn offset back into index offset
if (audioRate > 0)
    offset = offset * audioRate;
end

val = timelineOffsets(A);
A_timeline_index = val{1};
A_offset = val{2};
A_t = timelines{A_timeline_index};

val = timelineOffsets(B);
B_timeline_index = val{1};
B_offset = val{2};
B_t = timelines{B_timeline_index};

%if timelines were already merged, return immediately
if (A_timeline_index == B_timeline_index)
    newTimelines = timelines;
    newNumTimelines = numTimelines;
    return
end
    
%trunctate the timeline being merged and add it to the other
newOffset = B_offset + offset - A_offset;
B_t = [ B_t ; A_t(length(B_t) - newOffset + 1 : length(A_t))];
B_t = [ A_t(1:-newOffset) ; B_t];
timelines{B} = B_t;
if (offset < 0)
   shiftTimeline(-newOffset,B_timeline_index,timelineCompositions,timelineOffsets);
else
   %shift A's timeline down appropriately
   shiftTimeline(newOffset,A_timeline_index,timelineCompositions,timelineOffsets);
end

%reorder the timeline indices so that A's timeline elements now refer to
%B's timeline
newTimelines = reorderTimeline(A_timeline_index,B_timeline_index,timelineCompositions,timelineOffsets,timelines);
newNumTimelines = numTimelines - 1;
end

function [newTimelines] = reorderTimeline(oldTimelineIndex,newTimelineIndex,timelineCompositions,timelineOffsets,timelines)
    oldTimelineComposition = timelineCompositions(oldTimelineIndex);
    newTimelineComposition = timelineCompositions(newTimelineIndex);
    for i=1:length(oldTimelineComposition)
        elem = oldTimelineComposition(i);
        val = timelineOffsets(elem);
        val{1} = newTimelineIndex;
        timelineOffsets(elem) = val;
        newTimelineComposition = [newTimelineComposition ; elem];
    end
    timelineCompositions(newTimelineIndex) = newTimelineComposition;
    
    %delete old timeline
    remove(timelineCompositions,oldTimelineIndex);
    
    %reorder timeline so that elements are contiguous by left shifiting
    newTimelines = timelines;
    for i=oldTimelineIndex+1:length(newTimelines)
        if (~isempty(newTimelines{i}))
            toMoveComposition = timelineCompositions(i);
            for j=1:length(toMoveComposition)
                elem = toMoveComposition(j);
                val = timelineOffsets(elem);
                val{1} = i-1;
                timelineOffsets(elem) = val;            
            end
            timelineCompositions(i-1) = toMoveComposition;
            remove(timelineCompositions,i);
            newTimelines{i-1} = newTimelines{i};
            newTimelines{i} = [];
        end
    end   
end

function [] = shiftTimeline(shift,t_index,timelineCompositions,timelineOffsets)
    composedRecordings = timelineCompositions(t_index);
    for i=1:length(composedRecordings)
        val = timelineOffsets(composedRecordings(i));
        val{2} = val{2} + shift;
        timelineOffsets(composedRecordings(i)) = val;
    end
end