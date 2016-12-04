function [maxDelta, confidence] = find_delta(Addr,AddrR,targetZoneSize)
    %hashmap for address "database"
    AddrHM = containers.Map('KeyType','int32','ValueType','char');
    %make AddrHM
    for i = 1:size(Addr,1)
        %key = [num2str(Addr(i,1)),num2str(Addr(i,2)),num2str(Addr(i,3))];
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
    
    %find max delta
    maxDelta = -inf;
    maxDeltaFreq = -inf;
    deltas = cell2mat(keys(deltaHM));
    for i = 1:size(deltas,2)
        deltaFreq = deltaHM(deltas(i)); 
        if(deltaFreq>maxDeltaFreq)
            maxDelta = deltas(i);
            maxDeltaFreq = deltaFreq;
        end
    end
    keyboard;
    
    %find overlap times
    anchorTimesHM = delta2AbsTime2Count.get(double(maxDelta));
    overlapStart = inf;
    overlapStop = -inf;
    keyboard;
    anchorTimes = cell2mat(anchorTimesHM.keySet.toArray.cell);
    totalMatchedTargetZones = 0;
    for atIdx = 1:length(anchorTimes)
        %if a full target zone which started at point 
        if(anchorTimesHM.get(anchorTimes(atIdx))>=targetZoneSize)
            totalMatchedTargetZones = totalMatchedTargetZones+1;
            
            anchorTime = anchorTimes(atIdx);
            if(anchorTime<overlapStart)
                overlapStart = anchorTime;
            end
            
            if(anchorTime>overlapStop)
                overlapStop = anchorTime;
            end
        end
    end
    
    
    targetZoneTimes = cell2mat(keys(targetZoneTimes));
    targetZonesInOverlapPeriod = length(find(targetZoneTimes>=overlapStart & targetZoneTimes<=overlapStop));
    
    confidence = totalMatchedTargetZones/targetZonesInOverlapPeriod;
    keyboard;
end



