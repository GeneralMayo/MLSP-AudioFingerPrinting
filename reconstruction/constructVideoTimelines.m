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
end

