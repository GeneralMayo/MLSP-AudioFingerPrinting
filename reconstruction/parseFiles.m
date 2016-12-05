function [names,data] = parseFiles()
%parses directory struct into file names and file data
%input: directory struct
%output: names - cell of names
%        data - cell of file data. Row 1 is the data and row 2 is the fs

global DATA_DIR
files = dir([DATA_DIR '*.wav']);
names = cell(1,size(files,1));
data = cell(2,size(files,1));
for i=1:size(files,1)
    file = files(i);
    names{i} = file.name;
    
    [m, fs] = audioread([DATA_DIR names{i}]);
    
     %convert m to mono
    if size(m,2) == 2
        m = mean(m,2);
    end
    
    data{i} = cell(2,1);
    data{i}{1} = m;
    data{i}{2} = fs; 
end

end

