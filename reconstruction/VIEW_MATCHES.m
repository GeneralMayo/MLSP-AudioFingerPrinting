matchesMat = zeros(6,6);

for i = 1:5
    for j=i+1:6
        confidence = matches{i,j}{1,1};
        matchesMat(i,j)  = confidence;
    end
end

disp(matchesMat)