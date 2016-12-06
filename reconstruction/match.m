function [coefficient,offset] = match(A,B)
% matches set of addresses A and B
%input: addresses for recordings A and B
%output: coefficient - strength of match, from [0,1]
%        offset - offset added to B to line up with matched portion of A
%           i.e A(t) ~ B(t + offset)
    global PSR_THRESHOLD;
    
    %cell to mat conversion
    A = A{1};
    B = B{1};
    
    %hashmap for address "database"
    AHM = java.util.HashMap;
    %make AHM
    for i = 1:size(A,1)
        key = A(i,1);
        
        if(AHM.containsKey(key))
            AHM.put(key,[AHM.get(key);A(i,2)]);
        else
            AHM.put(key,A(i,2));
        end
    end
    
    %hashmap of "delta frequencies"
    deltaHM = java.util.HashMap;
    
    totalMatches = 0;
    %look for matching addresses
    for i = 1:size(B,1)
        %get hash made using data from the "snippet"
        key = B(i,1);
        
        %if key from "snippet" matches one from timeline
        if(AHM.containsKey(key))
            %found a match
            totalMatches = totalMatches + 1;
            
            %get all anchor values corresponding to key in timeline
            absolute_times = AHM.get(key);
                     
            %iterate through these anchor values
            for j = 1:size(absolute_times,1)
                %compute delta
                delta = absolute_times(j,1) - B(i,2);
                
                %increment values of hashmaps if they exist add them if
                %they don't
                if(deltaHM.containsKey(delta))
                    deltaHM.put(delta,deltaHM.get(delta)+1);
                else
                    deltaHM.put(delta,1);
                end
            end
            
        end
    end
    
    %find max delta and sum of all delta frequencies
    maxDelta = -inf;
    maxDeltaFreq = -inf;
    deltas = cell2mat(deltaHM.keySet.toArray.cell);
    freqTotal = 0;
    allDeltaFreqs = zeros(size(deltas,1),1);
    maxDeltaIdx = 0;
    for i = 1:size(deltas,1)
        deltaFreq = deltaHM.get(deltas(i));
        allDeltaFreqs(i,1) = deltaFreq;
        freqTotal = freqTotal+deltaFreq;
        if(deltaFreq>maxDeltaFreq)
            maxDeltaIdx = i;
            maxDelta = deltas(i);
            maxDeltaFreq = deltaFreq;
        end
    end
    
    % Threshold the values
    PSR = (max(allDeltaFreqs) - mean(allDeltaFreqs))/(std(allDeltaFreqs));
    if PSR < PSR_THRESHOLD
        confidence = 0;
    else
        confidence = PSR;
    end
    
    coefficient = confidence;
    offset = maxDelta;
    
    keyboard;
    sampleRatio = 902.1277;
    fs = 44100;
    fspectrogram = fs/sampleRatio;
    offset = offset/fspectrogram;
end

