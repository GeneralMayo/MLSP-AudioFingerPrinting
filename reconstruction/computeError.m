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
    
    % Check to see that the number of predicted groupings is correct
    if size(recording_components,2) ~= size(timeline_components,2)
        disp(['Number of timelines was off by ' num2str(size(timeline_components,2) - size(recording_components,2))])
        error = [error; 0];
    else 
        error = [error; 1];
    end
    
    % Check that the correct components make up each grouping
    components_found = zeros(size(recording_components,2),1);
    for i=1:size(timeline_components,1)
        for j=1:size(recording_components,1)
            if sort(recording_components{j}) == sort(timeline_components{j})
                if components_found{j} == 1
                    disp('Found duplicate for timeline')
                end
                components_found(j) = 1;
            end
        end
    end
end

