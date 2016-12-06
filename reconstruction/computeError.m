%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computeError: Get error metrics for the reconstructed timelines.
%
% PARAMS:
%   recording_components: 1xX  cell array: The components that make up each 
%                         source audio file
%   timeline_components: 1xY cell array: The components that were predicted 
%                        to make up each source audio file
%
% RETURNS:
%   error: 1x2 Matrix - [ 1 if # of groups is correct, otherwise 0
%                        % of correct component groupings]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ error ] = computeError(recording_components,timeline_components)
    error = [];
    
    % Check that the correct components make up each grouping
    components_found = zeros(size(recording_components,2),1);
    for i=1:size(timeline_components,2)
        for j=1:size(recording_components,2)
            if isequal(sort(recording_components{j}), sort(timeline_components{i}))
                if components_found(j) == 1
                    disp('Found duplicate for timeline')
                end
                components_found(j) = 1;
            end
        end
    end
    error = [sum(components_found)/size(components_found,1)];
end

