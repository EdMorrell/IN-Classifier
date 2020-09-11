function [spike_times, spike_timesIN, Cell_ID, Cell_ID_IN] = Auto_IN_Classifier(fn,...
    spike_times,Cell_ID, plt)

%   ---  Auto_IN_Classifier
%         - Function classifies INs using hierarchical clustering (Ward's
%           Method; On basis of spike-width, peak-valley ratio and firing
%           rate)
% Inputs:
%        - fn: File path (to find .wv files)
%        - spike_times: Spike time cell array
%        - Cell_ID: Cell array whereby each cell contains a string giving
%          the cluster name (eg. TT1_05.t64) to compare against .wv files
%        - plt: 1 - Plots cluster output
%               0 - No plotting (Default = 0)
% Outputs:
%         - spike_times: As inputted with INs removed
%         - spike_timesIN: Cell array of INs
%         - Cell_ID: New cell ID cell array
%         - Cell_ID: IN cell ID cell array

if nargin < 4
    plt = 0;
end

A = dir([fn filesep '*','All','*', 'wv.mat']);

mWV_Struct = cell(size(spike_times,1),1);
for iCell = 1:size(A,1) 
    cell_name = A(iCell).name;
    cell_name = cell_name(1:(strfind(cell_name, '-wv.mat'))-1);
    search_str = [cell_name '.t64'];
    
    str_loc = find(strcmp(search_str, Cell_ID));
    if ~isempty(str_loc)
        load([fn filesep A(iCell).name]);    
        mWV_Struct{str_loc,1} = mWV;
    end
end

for iCell = 1:size(mWV_Struct,1)
    
    for iCol = 1:4
        if ~isempty(mWV_Struct{iCell,1}(:,iCol))
            [peak_height,peak_pos] = max(mWV_Struct{iCell,1}(:,iCol));
            [trough_height,trough_pos] = max(-mWV_Struct{iCell,1}(:,iCol));
            
            col_pvr = peak_height / trough_height;
            col_pvw = trough_pos - peak_pos;
            
            pv_r(iCol) = col_pvr;
            pv_w(iCol) = col_pvw;
        else
            pv_h(iCol) = NaN;
            pv_w(iCol) = NaN;
        end
    end
    pv_ratio = nanmean(pv_r);
    pv_width = nanmean(pv_w);
    
    pv_ratio_array(iCell) = pv_ratio;
    pv_width_array(iCell) = pv_width;
    
    fr_array(iCell) = 1 / mean(diff(spike_times{iCell,1}));
end
%% Run Clustering
X = [zscore(fr_array)', zscore(pv_width_array)', ...
    zscore(pv_ratio_array)'];
Z = linkage(X,'ward', 'euclidean'); 
c = cluster(Z,'maxclust',2);
%% Split files
%Find which number corresponds to pyr cells (should be more of them)
if size(find(c == 1),1) > size(find(c == 2),1)
    p_cell = 1;
else
    p_cell = 2;
end

p_cells = find(c == p_cell);
i_cells = find(c ~= p_cell);

for iCell = 1:size(p_cells)
    spike_timesp{iCell,1} = spike_times{p_cells(iCell)};
    Cell_ID_p{iCell,1} = Cell_ID{p_cells(iCell)};
end
for iCell = 1:size(i_cells)
    spike_timesIN{iCell,1} = spike_times{i_cells(iCell)};
    Cell_ID_IN{iCell,1} = Cell_ID{i_cells(iCell)};
end

clear spike_times Cell_ID

spike_times = spike_timesp;
Cell_ID = Cell_ID_p;

%% Plotter
if plt == 1
    colour = 'rbgcmy';
    figure
    for type = 1:2
        for j = 1:length(c)
            if c(j) == type
                subplot(1,2,1)
                hold on
                plot(pv_width_array, pv_ratio_array, [colour(type), '.'])
            end
        end
        subplot(1,2,2)
        bar(type, mean(fr_array(c==type)));
        hold on
        errorbar(type, mean(fr_array(c==type)), ...
            std(fr_array(c==type))/sqrt(sum(c==type)))
    end

    subplot(1,2,1)
    xlabel('spike width')
    ylabel('PeakValleyAmplRatio')

    subplot(1,2,2)
    ylabel('Firing rate (Hz)')
    suptitle('CA1')
end

end