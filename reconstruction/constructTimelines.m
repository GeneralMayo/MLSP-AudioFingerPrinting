function [ timelines,a ] = constructTimelines( recordings )
%constructs a set of timelines by stiching recordings together
%input: 1xN cell of recordings
%output: 1xM cell of timelines, where M = number of unique timelines

%upper right triangular cell matrix where entry 
%   (i,j) = {coefficient,offset} for match between (i,j)
%upper right triangular since we do not need to redo matches

matches = cell(size(recordings,2));
addresses = cell(1,size(recordings,2));

%generate addresses for each input recording
for i=1:size(addresses,2)
   addresses{i} = generateAddresses(recordings{i},i); 
end

%generate matching matrix
for i=1:size(recordings,2)
   for j=i+1:size(recordings,2)
       matchCell = cell(1,2);
       [coefficient,offset] = match(addresses(i),addresses(j));
       matchCell{1} = coefficient;
       matchCell{2} = offset;
       matches{i,j} = matchCell;
   end
end
toc;
keyboard;

%construct timelines by merging recordings based on match matrix
timelines = merge(matches,recordings);

end

