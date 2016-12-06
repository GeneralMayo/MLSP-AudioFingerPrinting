%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parseVideoFiles: Get the video data file in the target directory
% 
% INPUT:
%     extension: extension of the video files
% 
% OUTPUT:
%   audio_recordings: 1xN cell array of sound data
%   video_recordings: 1xN cell array representing the video data 
%                     corresponding to the sound files
%                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [audio_recordings, video_recordings] = parseVideoFiles(extension)
    global DATA_DIR
    files = dir([DATA_DIR '*' extension]);
    num_files = size(files,1);
    
    audio_recordings = cell(1, num_files);
    video_recordings = cell(size(audio_recordings));
    for i=1:num_files
        file = files(i);

        % Read in the video file
        video_obj = VideoReader([DATA_DIR file.name]);
        
        % Get the framerate for the video file
        frame_rate = video_obj.FrameRate;
        
        % Save the video file in the cell array
        video_recordings{i} = cell(1,2);
        video_recordings{i}{1} = video_obj;
        video_recordings{i}{2} = frame_rate;
        
        % Extract the audio from the video file
        [audio, fs] = audioread([DATA_DIR file.name]);

        % Convert the audio to a mono source
        audio = mean(audio,2);
        
        % Save the audio recording in the cell array
        audio_recordings{i} = cell(1,2);
        audio_recordings{i}{1} = audio;
        audio_recordings{i}{2} = fs;
    end
    
end

