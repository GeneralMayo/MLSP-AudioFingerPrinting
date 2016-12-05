%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parseFiles: Get the sound recordings for each sound file in the target directory
% 
% INPUT:
%     none
% 
% OUTPUT:
%     names: Cell array of file names for the sound files - relative to the 
%            global DATA_DIR
%     data: Cell array of 2x1 cell arrays: 
%             {1} = data for the sound file
%             {2} = fs for the sound
%                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [names,data] = parseFiles()
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

