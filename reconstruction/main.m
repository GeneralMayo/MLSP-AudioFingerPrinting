%load sound data
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