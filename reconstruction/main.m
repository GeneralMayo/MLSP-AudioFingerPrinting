%initialize global variables
global TARGET_ZONE_SIZE ANCHOR_POSITION WINDOW NOVERLAP NFFT NUM_SPLITS DATA_DIR;
TARGET_ZONE_SIZE = 5;
ANCHOR_POSITION = 3;
WINDOW = 1028;
NOVERLAP = 128;
NFFT = 1028;
NUM_SPLITS = 3;
DATA_DIR = 'data/';

%seed the rng
SEED = 42;
rng(SEED);

%load sound data
disp('Loading sound data...')
[soundFileNames,soundFileData] = parseFiles();

%generate sample data
disp('Generating sample data...')
[recordings, recording_components] = generateData(soundFileData);

%reconstruct a set of timelines from sample recordings
disp('Reconstructing timelines...')
[timelines, timeline_components] = constructTimelines(recordings);

%compute errors and output
disp('Computing error...')
error = computeError(recording_components,timeline_components);

%output results
figure
plot(errors);
title('Error in Audio Signal Reconstruction');
set(gca,'XTickLabel',soundFileNames);
xlabel('Source File');
ylabel('Error');