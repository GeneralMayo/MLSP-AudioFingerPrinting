

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
peaks = get_peaks(S) ;

%figure, scatter(peaks(:,1), peaks(:,2))

%% Hashing

% this address has 4 columns vectors, the first 3 represent the address of
% the  point and the last represent the absolute time of the anchor.
target_zone_size = 5;
anchor_position = 3 ;
Address = hashing(peaks,target_zone_size,anchor_position);

%%