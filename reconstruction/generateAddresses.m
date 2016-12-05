function [ addresses ] = generateAddresses(audio, id)
% given an audio file, generates the set of addresses for that file
%input: 2x1 Audio cell, where Row 1 is the data, Row 2 is sfs
%output: Nx1 matrix of addresses, where each addresses is a 32 bit int

global TARGET_ZONE_SIZE ANCHOR_POSITION WINDOW NOVERLAP NFFT;

%generate spectrogram
m = audio{1};
fs = audio{2};
[S,~,~] = spectrogram(m, WINDOW, NOVERLAP, NFFT, fs);

%get high energy peaks
peaks = get_peaks(S);

%hash peaks to addresses
addresses = hashing(peaks,TARGET_ZONE_SIZE,ANCHOR_POSITION, id);
end

