function maxDelta = find_delta(Addr,AddrR)
    %hashmap of "delta frequencies"
    deltaHM = containers.Map('KeyType','int32','ValueType','int32');
    %hashmap for address "database"
    AddrHM = containers.Map('KeyType','char','ValueType','char');
    %make AddrHM
    for i = 1:size(Addr,1)
        key = [num2str(Addr(i,1)),num2str(Addr(i,2)),num2str(Addr(i,3))];
        if(isKey(AddrHM,key))
            AddrHM(key) = [AddrHM(key),'_',num2str(Addr(i,4))];
        else
            AddrHM(key) = num2str(Addr(i,4));
        end
    end
    
    %look for matching addresses
    for i = 1:size(AddrR,1)
        key = [num2str(AddrR(i,1)),num2str(AddrR(i,2)),num2str(AddrR(i,3))];
        if(isKey(AddrHM,key))
            absolute_times_char = AddrHM(key);
            absolute_times_cell = strsplit(absolute_times_char,'_');
            for j = 1:size(absolute_times_cell,2)
                absolute_time = str2num(char(absolute_times_cell(1,j)));
                delta = absolute_time - AddrR(i,4);
                if(isKey(deltaHM,delta)) 
                    deltaHM(delta) = deltaHM(delta)+1;
                else
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
end

