

%% 
% downloaded the file Video1.WMV  
% reading the file and separate into frames and audio
clear, close all , clc;

vid = vision.VideoFileReader('Video1.WMV', 'AudioOutputPort' , true);
N = 60 ;
Audio2 = [] ;
eof = false;
while (~eof)
    [I, audio, eof] = step(vid) ;
    Audio2 = [ Audio2; audio] ;
end

Audio2 = double(Audio2) ;

%%
X = Audio2 ;
NFFT = 1024 ;
Fs = 44000 ;
%S = spectrogram(X,hamming(128),128,NFFT,Fs) ;
% spectrogram(X,hamming(128),128,NFFT,Fs) ;

figure, spectrogram(X,hamming(128),120,128,Fs,'yaxis')

S = abs(spectrogram(X,hamming(128),120,128,Fs)) ;


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

%%