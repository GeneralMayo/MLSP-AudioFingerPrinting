function [coefficient,offset] = match(Addr,AddrR)
% matches set of addresses A and B
%input: addresses for recordings A and B
%output: coefficient - strength of match, from [0,1]
%        offset - offset added to B to line up with matched portion of A
%           i.e A(t) ~ B(t + offset)


    %hashmap for address "database"
    AddrHM = containers.Map('KeyType','int32','ValueType','char');
    %make AddrHM
    for i = 1:size(Addr,1)
        key = Addr(i,1);
        if(isKey(AddrHM,key))
            AddrHM(key) = [AddrHM(key),'_',num2str(Addr(i,2))];
        else
            AddrHM(key) = [num2str(Addr(i,2))];
        end
    end
    
    %Hashmap of form
    %delta --> absoluteTime --> count
    %Note: if for a particular delta and absoluteTime count >= targetZoneSize 
    %then an entire target zone was probably matched for a particular delta
    delta2AbsTime2Count = java.util.HashMap;

    %hashmap of "delta frequencies"
    deltaHM = containers.Map('KeyType','int32','ValueType','int32');
    
    %will store the anchor values for all target zones of the "snippit"
    targetZoneTimes = containers.Map('KeyType','int32','ValueType','int32');
    %look for matching addresses
    for i = 1:size(AddrR,1)
        %get hash made using data from the "snippet"
        key = AddrR(i,1);
        
        %add anchor of target zone to set
        %Note: "1" is just a dummy value
        targetZoneTimes(AddrR(i,2)) = 1;
        
        %if key from "snippet" matches one from timeline
        if(isKey(AddrHM,key))
            %get all anchor values corresponding to key in timeline
            absolute_times_char = AddrHM(key);
            absolute_times_cell = strsplit(absolute_times_char,'_');
            
            %iterate through these anchor values
            for j = 1:size(absolute_times_cell,2)
                %convert anchor value to an integer
                absolute_time = str2num(char(absolute_times_cell(1,j)));
                %compute delta
                delta = absolute_time - AddrR(i,2);
                
                
                %increment values of hashmaps if they exist add them if
                %they don't
                if(isKey(deltaHM,delta)) 
                    deltaHM(delta) = deltaHM(delta)+1;
                    
                    if(delta2AbsTime2Count.get(delta).containsKey(AddrR(i,2)))
                        newCount = delta2AbsTime2Count.get(delta).get(AddrR(i,2))+1;
                        delta2AbsTime2Count.get(delta).put(AddrR(i,2),newCount);
                    else
                        delta2AbsTime2Count.get(delta).put(AddrR(i,2),1);
                    end              
                else
                    delta2AbsTime2Count.put(delta,java.util.HashMap);
                    delta2AbsTime2Count.get(delta).put(AddrR(i,2),1);
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
    for i = 1:size(deltas,2)
        deltaFreq = deltaHM(deltas(i)); 
        freqTotal = freqTotal+deltaFreq;
        if(deltaFreq>maxDeltaFreq)
            maxDelta = deltas(i);
            maxDeltaFreq = deltaFreq;
        end
    end
    confidence = double(maxDeltaFreq)/double(freqTotal);
    
    coefficient = confidence;
    offset = maxDelta;
end

