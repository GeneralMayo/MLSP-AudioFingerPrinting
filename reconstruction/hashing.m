function [Address ] = hashing( peaks, target_zone_size, anchor_position, id)
    % this function does the hashing tha will facilite the matching
    % input here is the vector of peak from the spectrogram
    % and the output will be the  feature vector of the audio or recording file
    %
    % the idea here is to use the target zone concept to come up with
    % a efficient way to compare or match the file

%     target_size = 5;

    % give each point an address
    ind = 1:length(peaks) ;
    indexing = [ind', peaks] ;
    % generating target zone,
    target_zone = [] ;
    zone = zeros(1, target_zone_size);
    for i = 1: (size(indexing, 1)- target_zone_size +1)
        zone = ind(i:i+target_zone_size-1);
        target_zone = [target_zone ; zone] ;
    end
    % we need to create anchor points per target zone.
    % let this anchor point be the xth (x > target_size), for example
    % the 3rd point before the zone.
%     anchor_pos = 3 ;
    anchors = zeros(size(target_zone,1) ,1) ;
    anchors(anchor_position+1: end)  = 1: (size(target_zone,1)- anchor_position) ;

    % anchor_target_zone have the anchor as the first colum vector
    % the following vector are the element of the target zone.
    anchor_target_zone = [anchors, target_zone] ;

    % let's calculate the address for each target zone
    % each point will have multiple addresses and this is relative to
    % what target zone it belong to . as we know a point could be member of up
    % to 5 target zone  . this mean that a point might have up to 5 addresse.
    % an address look something like  [freq anchor ; freq point ; delta time
    % between the anchor and and the point] and this will be taged to an
    % absolute addresse value like [absolute anchor time , soung ID]
    % so [f_a , f_p , Dt ] --> [a_time, soung_id]


    % let addressing be the function that return the address of all points in a
    % zone relative to the anchor point
    Address = [] ;
    for k = 1: size(anchor_target_zone,1)
        zone = anchor_target_zone(k,:) ;
        if zone(1) == 0
            continue
        end
        zone_addr = addressing(zone,indexing, id) ;
        % Convert each address into a 32 bit int
        % [9bits = f_a 9bits = f_p 14bits = Dt]
        new_addr = [];
        for x=1:size(zone_addr,1)
            hash_value = int32(0);
            hash_value = zone_addr(x,3);
            hash_value = hash_value + bitshift(zone_addr(x,2), 14);
            hash_value = hash_value + bitshift(zone_addr(x,1), 14 + 9);
            new_addr = [new_addr; hash_value, zone_addr(x,4:5)];
        end
        Address = [Address ; new_addr] ;
    end
end

