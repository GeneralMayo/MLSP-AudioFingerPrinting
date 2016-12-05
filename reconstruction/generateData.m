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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sample_data, data_components] = generateData(sound_file_data)
    global NUM_SPLITS;

    sample_data = cell(1, NUM_SPLITS*size(sound_file_data,2));
    data_components = cell(1,size(sound_file_data,2));

    for k=1:size(sound_file_data,2)
        sample = sound_file_data(k);
        m = sample{1}{1};
        fs = sample{1}{2};
        sound_len = size(m,1);
        last_len = 0;
        last_end = 0;
        for i=1:NUM_SPLITS
            if i=0
                % Initialize the list in the components cell array
                data_components(k) = [];
            end

            % Add the components to the component list
            data_components(k) = [data_components(k); (k-1)*NUM_SPLITS + i];

            % TODO: improve how segments are chosen
            % Select a starting point that overlaps with the last chosen segment
            start_pos = int64(last_end - (last_len/2)*rand() + 1);

            if i == NUM_SPLITS
                end_pos = sound_len;
            else
                end_pos = int64(start_pos + (sound_len - start_pos)*rand());
            end

            % TODO: Add noise to the segment
            sample_data{i} = cell(2,1);
            sample_data{i}{1} = m(start_pos:end_pos);
            sample_data{i}{2} = fs;
       end
    end
end

