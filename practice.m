

%% Loading the audio file
clear, close all, clc ;

[ m, fs ] = audioread('piano.mp3') ;
m = mean(m,2) ;
% let turn piano file into mono
%% Generate the spectrogram
window = 1028;
noverlap = 128;
nfft = 1028;
[S,~,~] = spectrogram(m, window, noverlap, nfft, fs);

%% Get the peaks
peaks = get_peaks(S);

%figure, scatter(peaks(:,1), peaks(:,2))

%% Hashing

% this address has 4 columns vectors, the first 3 represent the address of
% the  point and the last represent the absolute time of the anchor.
target_zone_size = 5;
anchor_position = 3 ;
Address = hashing(peaks,target_zone_size,anchor_position);

%% Matching

%get seconds 2-4 from piano recording
mRecording = m(fs*2+1:fs*4,:);
[Srecording,~,~] = spectrogram(mRecording, window, noverlap, nfft, fs);
peaksRecording = get_peaks(Srecording);
AddressRecording = hashing(peaksRecording,target_zone_size,anchor_position);
max_delta = find_delta(Address,AddressRecording);

%music samples per spectrogram sample
sampleRatio = size(m,1)/size(S,2);
fspectrogram = fs/sampleRatio;
%This should be approximately 2sec... and it is!
display(max_delta/fspectrogram)