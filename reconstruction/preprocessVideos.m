
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preprocessVideos: Pre-process the video files in the global data dir
%
% PARAMS:
%   file_data: 1xN cell of video file input. N = number of source
%              files
%
% RETURNS:
%   audio_recordings: 1xN cell of sound data
%   video_recordings: 1xN array representing the video data corresponding
%                     to the sound files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [audio_recordings, video_recordings] = preprocessVideos(video_data)
    sample_data = cell(1, NUM_SPLITS*size(sound_file_data,2));
    data_components = cell(1,size(sound_file_data,2));
    fs_list = []; % Keep track of the sampling rates
    
    for k=1:size(sound_file_data,2)
        sample = sound_file_data(k);
        m = sample{1}{1};
        fs = sample{1}{2};
        sound_len = size(m,1);
        last_len = 0;
        last_end = 0;
        for i=1:NUM_SPLITS
            sample_idx = (k-1)*NUM_SPLITS + i;
            if i==0
                % Initialize the list in the components cell array
                data_components{k} = [];
            end

            % Add the components to the component list
            data_components{k} = [data_components{k}; sample_idx];

            % TODO: improve how segments are chosen
            % Select a starting point that overlaps with the last chosen segment
            start_pos = int64(last_end - (last_len/2)*rand() + 1);

            if i == NUM_SPLITS
                end_pos = sound_len;
            else
                end_pos = int64(start_pos + (sound_len - start_pos)*rand());
            end

            % TODO: Add noise to the segment
            sample_data{sample_idx} = cell(2,1);
            sample_data{sample_idx}{1} = m(start_pos:end_pos); %+rand(size(m(start_pos:end_pos)))/10;
            sample_data{sample_idx}{2} = fs;
            fs_list = [fs_list; fs];
       end
    end
    
    % Find the mode of the audio sampling rates
    selected_fs = mode(fs_list);
    
    % Resample the audio data to the selected sampling rate
    for i=1:size(sample_data,2)
        if sample_data{i}{2} ~= selected_fs
            sample_data{i}{1} = resample(sample_data{i}{1}, selected_fs, sample_data{i}{2});
            sample_data{i}{2} = selected_fs;
        end
    end
end
    global DATA_DIR
end