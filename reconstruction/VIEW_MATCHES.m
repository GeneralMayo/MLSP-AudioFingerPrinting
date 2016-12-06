matchesMat = zeros(size(matches));

for i = 1:size(matches,1)-1
    for j=i+1:size(matches,2)
        confidence = matches{i,j}{1,1};
        matchesMat(i,j)  = confidence;
    end
end
matchesMat