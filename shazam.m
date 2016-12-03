%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform the shazam algorithm to match up sound files
%
%  PARAMS:
%   data_dir: Directory of sound files to test on
%
%
%  RETURNS:
%   accuracy: accuracy of the matching algorithm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [accuracy] = shazam(data_dir)
    %% Seed the random number generator
    rng(42)

    %% Set the data directory
    DATA_DIR = '../data/'

    %% Initialize spectrogram params
    WINDOW = 1028;
    NOVERLAP = 128;
    NFFT = 1028;

    %% Initialize hashing params
    TARGET_ZONE = 5;
    ANCHOR_OFFSET = 3;

    %% TODO: Initialize the noise params


    %% Iterate over sound files in the data directory
    data_files = dir([DATA_DIR '*.wav');
    num_files = size(data_files,1);

    % Perform matching on each file in the sound files directory
    for target_file = data_files'
        % Read in the sound file
        [m, fs] = audioread([DATA_DIR target_file).name];

        % Merge the audio channels
        m = mean(m,2);

        % Split the sound file into consecutive overlapping random segments
        NUM_SPLITS = 3;
        sound_len = size(m,1);
        new_sounds = cell(1,NUM_SPLITS);
        last_end = 0;
        last_len = 0;
        last_end = 0;

        for i=1:NUM_SPLITS
            % TODO: improve how segments are chosen
            % Select a starting point that overlaps with the last chosen segment
            start_pos = int64(last_end - (last_len)*rand());
            end_pos = int64(start_pos + (sound_len - start_pos)*rand());

            % Keep track of how much of the sound file is used - need this value
            % later to check the accuracy of our reconstruction
            if end_pos > last_end
                last_end = end_pos;
            end

            % TODO: Add noise to the segment
            new_sounds{i} = m(start_pos:end_pos);
        end

        %% Generate the spectrogram for each sound
        spectros = cell(size(new_sounds));
        for i=1:size(new_sounds,2)
            [s,~,~] = spectrogram(m, window, noverlap, nfft, fs);
            spectros{i} = s;
        end

        %TODO: Remove super high frequencies

        %% Get the peaks
        peaks = cell(size(spectros));
        for i=1:size(spectros,2)
            peaks{i} = get_peaks(spectros{i});
        end

        %% Get the hashes
        hashes = cell(size(peaks));
        for i=1:size(peaks,2)
            hashes{i} = hashing(peaks{i}, TARGET_ZONE, ANCHOR_OFFSET);
        end

        reconstructed_hashes = [];
        reconstructed_sound = [];
        unmatched = [1:size(hashes,2)];
        while unmatched > 1
            % Loop over items in unmatched to try and find a match
            for m=unmatched
            end
            % Merge elements that match
            % Remove from unmatched
        end
    end

end
