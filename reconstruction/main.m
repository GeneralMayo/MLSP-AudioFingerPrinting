%initialize global variables
global TARGET_ZONE_SIZE ANCHOR_POSITION WINDOW NOVERLAP NFFT NUM_SPLITS;
TARGET_ZONE_SIZE = 5;
ANCHOR_POSITION = 3;
WINDOW = 1028;
NOVERLAP = 128;
NFFT = 1028;
NUM_SPLITS = 3;

%seed the rng
SEED = 42;
rng(SEED);

%load sound data
clear;
soundFiles = dir('data/*.mp3');
[soundFileNames,soundFileData] = parseFiles(soundFiles);

%generate sample data
recordings = generateData(soundFileData);

%reconstruct a set of timelines from sample recordings
timelines = constructTimelines(recordings);

%compute errors and output
error = computeError(soundFileData,timelines);

%output results
figure
plot(errors);
title('Error in Audio Signal Reconstruction');
set(gca,'XTickLabel',soundFileNames);
xlabel('Source File');
ylabel('Error');