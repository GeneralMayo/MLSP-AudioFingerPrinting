function zone_address = addressing(zone,indexing, id)
    %this function will take in the zone and return the address of all the
    %point in that zone relative to the anchor
    %indexing is a matrix with 3 colunms, the first being the index number,
    % the second being the time value and the last column is the frequency
    % value
    % so here zone is a row vector with the first element being the anchor
    % the rest of element are the point insite the target zone governed by that
    % anchor point.
     len = length(zone) ;

     zone_address = [] ;
 anchor_index = zone(1) ;
     for j = 2:len
         point_index = zone(j) ;

        addr_point = [indexing(anchor_index, 3) , indexing(point_index, 3) ,...
            (indexing(point_index,2) - indexing(anchor_index,2)),...
            indexing(anchor_index, 2), id] ;
        % anchor timimg = indexing(anchor_index, 2)


        zone_address = [zone_address ; addr_point] ;
     end

end

