function [maxDelta, confidence] = find_delta(Addr,AddrR,targetZoneSize)
    %hashmap of "delta frequencies"
    deltaHM = containers.Map('KeyType','int32','ValueType','int32');
    %hashmap for address "database"
    AddrHM = containers.Map('KeyType','int32','ValueType','char');
    %make AddrHM
    for i = 1:size(Addr,1)
        %key = [num2str(Addr(i,1)),num2str(Addr(i,2)),num2str(Addr(i,3))];
        key = AddrHM(i,1);
        if(isKey(AddrHM,key))
            AddrHM(key) = [AddrHM(key),'_',num2str(Addr(i,2))];
        else
            AddrHM(key) = [num2str(Addr(i,2))];
        end
    end
    
    %struct of form
    %delta --> absoluteTime --> count
    %Note: if for a particular delta and absoluteTime count >= targetZoneSize 
    %then an entire target zone was matched for a particular delta
    delta2AbsTime2Count = struct();
    
    %will store the times of all target zones
    targetZoneTimes = containers.Map('KeyType','int32','ValueType','int32');
    
    %look for matching addresses
    for i = 1:size(AddrR,1)
        %key = [num2str(AddrR(i,1)),num2str(AddrR(i,2)),num2str(AddrR(i,3))];
        key = AddrR(i,1);
       
        targetZoneTimes(AddrR(i,2)) = 1;
        
        if(isKey(AddrHM,key))
            absolute_times_char = AddrHM(key);
            absolute_times_cell = strsplit(absolute_times_char,'_');
            for j = 1:size(absolute_times_cell,2)
                absolute_time = str2num(char(absolute_times_cell(1,j)));
                delta = absolute_time - AddrR(i,2);
                
                if(isKey(deltaHM,delta)) 
                    deltaHM(delta) = deltaHM(delta)+1;
                    
                    if(isfield(delta2AbsTime2Count.(num2str(delta)),num2str(AddrR(i,2))))
                        delta2AbsTime2Count.(num2str(delta)).(num2str(AddrR(i,2))) = delta2AbsTime2Count.(num2str(delta)).(num2str(AddrR(i,2)))+1;
                    else
                        delta2AbsTime2Count.(num2str(delta)).(num2str(AddrR(i,2))) = 1;
                    end              
                else
                    delta2AbsTime2Count.(num2str(delta)) = struct();
                    delta2AbsTime2Count.(num2str(delta)).(num2str(AddrR(i,2))) = 1;
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
    
    %find overlap times
    anchorTimesStruct = delta2AbsTime2Count.(num2str(maxDelta));
    overlapStart = inf;
    overlapStop = -inf;
    anchorTimesChar = fieldnames(anchorTimesStruct);
    totalMatchedTargetZones = 0;
    for atIdx = 1:numel(anchorTimesChar)
        %if a full target zone which started at point 
        if(anchorTimesStruct.(anchorTimesChar(atIdx))==targetZoneSize)
            totalMatchedTargetZones = totalMatchedTargetZones+1;
            
            anchorTime = str2num(anchorTimesChar(atIdx));
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
end



