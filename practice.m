

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
Address = hashing(peaks,target_zone_size,anchor_position,4);

%% Matching

%get seconds 2-4 from piano recording
mRecording = m(fs*2+1:fs*4,:);
[Srecording,~,~] = spectrogram(mRecording, window, noverlap, nfft, fs);
peaksRecording = get_peaks(Srecording);
AddressRecording = hashing(peaksRecording,target_zone_size,anchor_position,2);

sameDelta =0;
diffDelta = 0;
for i = 1:size(AddressRecording,1)
    for j = 1:size(Address,1)
        if(AddressRecording(i,1)==Address(j,1))
            %disp(AddressRecording(i,:))
            %disp(Address(j,:))
            if(AddressRecording(i,2) - Address(j,2) == 0)   
                sameDelta = sameDelta+1;
            else
                diffDelta = diffDelta+1;
            end
        end
    end
end


max_delta = find_delta(Address,AddressRecording,target_zone_size);


%music samples per spectrogram sample
sampleRatio = size(m,1)/size(S,2);
fspectrogram = fs/sampleRatio;
%This should be approximately 2sec... and it is!
display(max_delta/fspectrogram)
