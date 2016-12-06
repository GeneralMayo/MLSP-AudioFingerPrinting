%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generateData: Convert a list of sound files data into overlaping slices
%               of the sounds.
%
% PARAMS:
%   sound_file_data: 1xN cell of sound file input. N = number of source
%                    files
%
% RETURNS:
%   sample_data: 1xM cell of sliced sounds data. M = N*NUM_SPLITS
%   data_components: 1xN cell array representing the source of
%                     sample_data files.
%   selected_fs: the sampling rate that is applied to all of the sound
%                files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sample_data, data_components, selected_fs] = generateData(sound_file_data)
    global NUM_SPLITS;
    global WINDOW;

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
        
        segment_size = sound_len/NUM_SPLITS;
        
        for i=1:NUM_SPLITS
            sample_idx = (k-1)*NUM_SPLITS + i;
            if i==1
                % Initialize the list in the components cell array
                data_components{k} = [];
            end

            % Add the components to the component list
            data_components{k} = [data_components{k}; sample_idx];
            
            % Select a starting point that overlaps with the last chosen segment
            start_pos = int64(max(1,segment_size*(i-1) - segment_size/2));
            end_pos = int64(min(sound_len, segment_size*i + segment_size/3));
            last_end = end_pos;
            disp(start_pos)
            disp(end_pos)

            % TODO: Add noise to the segment
            sample_data{sample_idx} = cell(2,1);
            sample_data{sample_idx}{1} = m(start_pos:end_pos); %+rand(size(m(start_pos:end_pos)))/10;
            sample_data{sample_idx}{2} = fs;
            fs_list = [fs_list; fs];
            last_len = size(m(start_pos:end_pos),1);
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

