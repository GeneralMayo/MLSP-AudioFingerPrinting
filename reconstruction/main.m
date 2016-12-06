tic;
%initialize global variables
global TARGET_ZONE_SIZE ANCHOR_POSITION WINDOW NOVERLAP NFFT NUM_SPLITS DATA_DIR MATCH_THRESHOLD;
TARGET_ZONE_SIZE = 5;
ANCHOR_POSITION = 3;
WINDOW = 1028;
NOVERLAP = 128;
NFFT = 1028;
NUM_SPLITS = 3;
DATA_DIR = 'data/';
MATCH_THRESHOLD = .90;

%seed the rng
SEED = 42;
rng(SEED);

%load sound data
disp('Loading sound data...')
[soundFileNames,soundFileData] = parseAudioFiles();

%generate sample data
disp('Generating sample data...')
[recordings, recording_components] = generateData(soundFileData);

%reconstruct a set of timelines from sample recordings

disp('Reconstructing timelines...')
[timelines, timeline_components] = constructAudioTimelines(recordings);

%compute errors and output
disp('Computing error...')
error = computeError(recording_components,timeline_components);
toc;
fprintf('Number of original files: %d\n',size(recording_components,2));
fprintf('Number of reconstructed timelines: %d\n',size(timeline_components,2));
fprintf('Reconstruction Percent Correct Components: %f\n',error);