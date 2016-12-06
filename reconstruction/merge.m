function [timelines, timelineCompositionCell] = merge(matches,recordings)
%merges recordings together based on matchings with other recordings
%input: matches - NxN upper right triangular cell matrix of matches
%       recordings - 1xM cell array of audio recordings
%output: 1xN cell array of merged audio files, where N = number of unique
%        samples as found by our algorithm


global MATCH_THRESHOLD;

%parse the matrix into match pairs 
matchTuples = [];
for i=1:size(matches,1)
   for j=i+1:size(matches,2)
       match = matches{i,j};
       coef = match{1};
       offset = match{2};
       if (coef >= MATCH_THRESHOLD)
            matchTuples = [matchTuples ; i,j,coef,offset];
       end
   end
end

%sort matches based on coefficient strength
matchTuples = sortrows(matchTuples,-3);

%run merging algorithm

%set up initial data structures
timelines = cell(1,size(recordings,2));
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
        timelines = addRecordingToTimeline(matchB,matchA,offset,timelineOffsets,timelineCompositions,timelines,recordings);
    elseif (~isKey(timelineOffsets,matchA) && isKey(timelineOffsets,matchB))
        %merge A into B's timeline
        timelines = addRecordingToTimeline(matchA,matchB,-1*offset,timelineOffsets,timelineCompositions,timelines,recordings);
        %assert(0);
    elseif (isKey(timelineOffsets,matchA) && isKey(timelineOffsets,matchB))
        %merge two timelines together
        timelines = addTimelineToTimeline(matchB,matchA,offset,timelineOffsets,timelineCompositions,timelines,recordings);
        numTimelines = numTimelines - 1;
    else
        %create a new timeline
        numTimelines = numTimelines + 1;
        timelines(numTimelines) = recordings(matchA); %TODO arbitrary choice
        timelineOffsets(matchA) = {numTimelines,1};
        timelineCompositions(numTimelines) = [matchA];
        timelines = addRecordingToTimeline(matchB,matchA,offset,timelineOffsets,timelineCompositions,timelines,recordings);
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
            timelines{numTimelines} = recordings{i};
        end
    end   
end

function [newTimelines] = addRecordingToTimeline(A,B,offset,timelineOffsets,timelineCompositions,timelines,recordings)
    %add recording A to recording B's timeline
    %offset is offset of A relative to B ie A(t + offset) = B(t)
    value = timelineOffsets(B);
    t_index = value{1};  
    B_offset = value{2};
    t = timelines{t_index};
    A_index = B_offset + offset;
    A_recording = recordings{A};
    if (A_index < 0)
        %prepend A to t, then append any leftovers if length(A) > length(t)
        A_index = abs(A_index) + 1;
        t = [A_recording(1:A_index) ; t];
        t = [t ; A_recording(length(t)+1:length(A_recording))];
        new_AIndex = 1;
        shift = A_index;
    else
        %append A to t, or do nothing if length(A) + offset <= length(t)
        t = [t ; A_recording(length(A_index:length(t))+1:length(A_recording))];
        new_AIndex = A_index;
        shift = 0;
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
function [newTimelines] = addTimelineToTimeline(A,B,offset,timelineOffsets,timelineCompositions,timelines,recordings)
%add A's timeline to B's timeline with offset of A relative to B
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
    newTimeline = timelines;
    return
end
    
%trunctate the timeline being merged and add it to the other
A_t_index_in_B = B_offset + offset;
if (A_t_index_in_B < 0)
    A_t_index_in_B = abs(A_t_index_in_B) + 1;
    B_t = [A_t(1:A_t_index_in_B) ; B_t];
    B_t = [B_t ; A_t(length(B_t)+1:length(A_t))];
    
    %shift B't timeline to the right
    shiftTimeline(A_t_index_in_B,B_timeline_index,timelineCompositions,timelineOffsets);
else
    trunctateAmount = length(B_t) - A_t_index_in_B + 1;
    B_t = [B_t ; A_t(trunctateAmount:length(A_t))];
    
    %shift A's timeline to the right
    shiftTimeline(A_t_index_in_B,A_timeline_index,timelineCompositions,timelineOffsets)
end

%reorder the timeline indices appropriately

end

function [] = shiftTimeline(shift,t_index,timelineCompositions,timelineOffsets)
    composedRecordings = timelineCompositions(t_index);
    for i=1:length(composedRecordings)
        val = timelineOffsets(composedRecordings(i));
        val{2} = val{2} + shift;
        timelineOffsets(composedRecordings(i)) = val;
    end
end