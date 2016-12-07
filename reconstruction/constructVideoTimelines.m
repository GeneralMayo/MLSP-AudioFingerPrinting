%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% constructVideoTimelines: Constructs a set of timelines by stitching 
%                          together audio and video data.
% 
% INPUT:
%     audio_recordings: 1xN cell array of audio recordings
%                       Each item in the cell array is a 2x1 cell where
%                       Item 1 = sound data, Item 2 = fs
%     video_recordings: 1xN cell array of video recordings corresponding to
%                       audio recordings based on index.
%                       Each item in the cell array is a 2x1 cell where
%                       Item 1 = video data, Item 2 = frame rate
%
% OUTPUT:
%     timelines: 1xN array of final reconstructed videos
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ timelines ] = constructVideoTimelines( audio_recordings, video_recordings )
matches = cell(size(audio_recordings,2));
addresses = cell(1,size(audio_recordings,2));

%generate addresses for each input recording
for i=1:size(addresses,2)
   addresses{i} = generateAddresses(audio_recordings{i},i); 
end

%generate matching matrix
tic;
for i=1:size(audio_recordings,2)
   for j=i+1:size(audio_recordings,2)
       matchCell = cell(1,2);
       [coefficient,offset] = match(addresses(i),addresses(j));
       matchCell{1} = coefficient;
       matchCell{2} = offset;
       matches{i,j} = matchCell;
   end
end
toc;
VIEW_MATCHES

keyboard;

%get the audio sample rate
% A = audio_recordings{1};
% A = A{1};
% [timelines,timelineComponents] = merge(matches,video_recordings,A(2));
end

