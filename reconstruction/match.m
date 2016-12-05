function [coefficient,offset] = match(A,B)
% matches set of addresses A and B
%input: addresses for recordings A and B
%output: coefficient - strength of match, from [0,1]
%        offset - offset added to B to line up with matched portion of A
%           i.e A(t) ~ B(t + offset)
    global TARGET_ZONE_SIZE;
    
    %cell to mat conversion
    A = A{1};
    B = B{1};
    
    %hashmap for address "database"
    %AHM = containers.Map('KeyType','int32','ValueType','char');
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
    deltaHM = containers.Map('KeyType','int32','ValueType','int32');
    
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
                if(isKey(deltaHM,delta)) 
                    deltaHM(delta) = deltaHM(delta)+1; 
                else
                    deltaHM(delta) = 1;
                end
            end
        end
    end
    
    %find max delta and sum of all delta frequencies
    maxDelta = -inf;
    maxDeltaFreq = -inf;
    deltas = cell2mat(keys(deltaHM));
    freqTotal = 0;
    allDeltaFreqs = zeros(size(deltas));
    maxDeltaIdx = 0;
    for i = 1:size(deltas,2)
        deltaFreq = deltaHM(deltas(i));
        allDeltaFreqs(1,i) = deltaFreq;
        freqTotal = freqTotal+deltaFreq;
        if(deltaFreq>maxDeltaFreq)
            maxDeltaIdx = i;
            maxDelta = deltas(i);
            maxDeltaFreq = deltaFreq;
        end
    end
    
    %threshold
    if(max(allDeltaFreqs)<10*TARGET_ZONE_SIZE)
        confidence = 0;
    else
        %allDeltaFreqs(maxDeltaIdx) = [];
        confidence = 1-median(double(allDeltaFreqs))/double(maxDeltaFreq);
        %confidence = double(maxDeltaFreq)/double(freqTotal);
    end
    
    coefficient = confidence;
    offset = maxDelta;
end

