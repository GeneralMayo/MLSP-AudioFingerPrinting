function [peak_values] = get_peaks(input)
out = [];
band_ranges = [1,10;11,20;21,40;41,80;81,160;161,511];
num_bands = size(band_ranges,1);

peak_values = [];
for t=1:size(input,2)
    % Create array to hold max value in each band + bin num
    band_maxes = zeros(num_bands,2);
    
    for x=1:num_bands
        % Get the max in each band
        band_lower = band_ranges(x,1);
        band_upper = band_ranges(x,2);
        [val,idx] = max(input(band_lower:band_upper,t));
        
        % Save the value and bin of the max
        band_maxes(x,1) = val;
        band_maxes(x,2) = idx + band_lower - 1;
    end
    
    % Get the mean value of the max in each band
    avg_val = mean(band_maxes(:,1));
    coeff = 1.0;
    
    % Select the points that pass the cutoff
    new_peaks = band_maxes(band_maxes(:,1)>(avg_val*coeff),:);
    for y=1:size(new_peaks,1)
        peak_values = [peak_values;t,new_peaks(y,2)];
    end
    
end
end