%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% video_main: Constructs a set of timelines by stitching together files
%             from the video_data_dir
% 
% INPUT:
%     video_data_dir: string of the directory of data
%     video_file_extension: extension of the video files ex. '.mp4', '.WMV'
%     expected_timelines: int, The expected number of timelines
%
% OUTPUT:
%     timelines: 1xN array of final reconstructed videos
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [timelines] = video_main(video_data_dir, video_file_extension, expected_timelines)
    if video_data_dir(length(video_data_dir)) ~= '/'
        video_data_dir = [video_data_dir '/'];
    end
    %initialize global variables
    global TARGET_ZONE_SIZE ANCHOR_POSITION WINDOW NOVERLAP NFFT NUM_SPLITS DATA_DIR PSR_THRESHOLD;
    TARGET_ZONE_SIZE = 5;
    ANCHOR_POSITION = 3;
    WINDOW = 1028;
    NOVERLAP = 128;
    NFFT = 1028;
    NUM_SPLITS = 3;
    DATA_DIR = video_data_dir;
    PSR_THRESHOLD = 3.5;

    % Load video data
    disp('Loading data...')
    [audio_recordings, video_recordings] = parseVideoFiles(video_file_extension);

    % Reconstruct a set of timelines from sample recordings
    disp('Reconstructing timelines...')
    [timelines] = constructAudioTimelines(audio_recordings);

    if size(timelines,2) ~= expected_timelines
        disp(['Tried to reconstruct the events of ' num2str(expected_timelines)])
        disp(['Reconstruction resulted in ' num2str(size(timelines,2)) ' timelines'])
    else
        disp('Was able to successfully reconstruct the expected number of timelines')
    end
    toc;
end