function [sampleData] = generateData(soundFileData)
%generates sample recordings from sound files
%input: 1xN cell of sound file input, where N = number of source files
%output: 1xM cell of audio recordings, where M = number of recordings
    NUM_SPLITS = 3;
    sampleData = cell(1, NUM_SPLITS*size(soundFileData,2));
    
    for soundFileIdx=1:size(soundFileData,1)
        sample = soundFileData{soundFileIdx};
        m = sample{1};
        fs = sample{2};
        sound_len = size(m,1);
        last_len = 0;
        last_end = 0;
        for i=1:NUM_SPLITS
            % TODO: improve how segments are chosen
            % Select a starting point that overlaps with the last chosen segment
            start_pos = int64(last_end - (last_len/2)*rand() + 1);
            
            if i == NUM_SPLITS
                end_pos = sound_len;
            else
                end_pos = int64(start_pos + (sound_len - start_pos)*rand());
            end
            
            % TODO: Add noise to the segment
            sampleData{i} = cell(2,1);
            sampleData{i}{1} = m(start_pos:end_pos);
            sampleData{i}{2} = fs;
       end
    end
end

