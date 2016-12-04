function [names,data] = parseFiles(data_dir)
%parses directory struct into file names and file data
%input: directory struct
%output: names - cell of names
%        data - cell of file data

files = dir([data_dir '*.wav']);
names = cell(1,size(files,1));
data = cell(1,size(files,1));
for i=1:size(files,1)
    file = files(i);
    names{i} = file.name;
    [m, fs] = audioread([data_dir names{i}]);
    data{i} = cell(2,1);
    data{i}{1} = mean(m,2);
    data{i}{2} = fs; 
end

end

