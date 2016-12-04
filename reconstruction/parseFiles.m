function [names,data] = parseFiles(files)
%parses directory struct into file names and file data
%input: directory struct
%output: names - cell of names
%        data - cell of file data
names = cell(1,size(files,1));
data = cell(1,size(files,1));
for i=1:size(files,1)
    file = files(i,:);
    names{i} = file.name;
    data{i} = audioread(names{i});
end

end

