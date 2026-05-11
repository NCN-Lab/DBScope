function h = plotCircadian( obj, varargin )
% Plot the circadian mean power.
%
% Syntax:
%   h = PLOTCIRCADIAN( obj, ax );
%
% Input parameters:
%    * obj - object containg data
%    * ax (optional) - axis where you want to plot
%
% Example:
%   h = obj.PlotCircadian();
%   h = PLOTCIRCADIAN( obj );
%   h = PLOTCIRCADIAN( obj, ax );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
color = lines(4);
LFP = obj.chronic_parameters.time_domain;
n_channels = LFP.n_channels;

% Parse input variables
if nargin == 3
    ax = varargin{1};
    utc = varargin{2};
elseif nargin == 2
    ax = varargin{1};
    utc = 0;
else
    figure;
    utc = 0;
    for i = 1:n_channels
        ax(i) = subplot(2,1,i);
    end
end

switch n_channels
    case 1
        hemisphere_indx = 1;
        if contains(LFP.hemispheres,'Left')
            lbl_subplot = "Left Hemisphere";
            ax(2).Visible = false;
            ax = ax(1);
        else
            lbl_subplot = "Right Hemisphere";
            ax(1).Visible = false;
            ax = ax(2);
        end
    case 2
        for i = 1:n_channels
            ax(i).Visible = true;
        end
        lbl_subplot = ["Left Hemisphere", "Right Hemisphere"];
        if contains(LFP.hemispheres(1),'Left')
            hemisphere_indx = [1, 2];
        else
            hemisphere_indx = [2, 1];
        end
end

if ~isempty(LFP.sensing)
    cfs = [LFP.center_frequency];
end

for i = 1:n_channels
    curr_hemi = hemisphere_indx(i);
    
    if nargin >= 2
        cla(ax(i), 'reset');
    end
    
    % --- Extract specific cell data first ---
    curr_time = LFP.time{curr_hemi};
    curr_data = LFP.data{curr_hemi};
    
    % Safety check: skip if this hemisphere has no data
    if isempty(curr_time) || isempty(curr_data)
        title(ax(i), lbl_subplot(curr_hemi) + " (No Data Available)");
        continue;
    end
    
    % --- Time processing moved INSIDE the loop ---
    temp_time = datevec(curr_time + hours(utc));
    temp_time(:, 5) = 10 * floor(temp_time(:, 5) / 10);
    rounded_time = duration([temp_time(:, 4:5) zeros(size(temp_time,1), 1)]);
    x = unique(rounded_time);
    
    % Proper pre-allocation (fixes old bug where it was initialized to a scalar length)
    median_circadian_power = zeros(1, numel(x));
    upper_qrtl_power = zeros(1, numel(x));
    lower_qrtl_power = zeros(1, numel(x));
    
    for j = 1:numel(x)
        % Extract all LFP data points that match this 10-minute circadian bin
        bin_data = curr_data(rounded_time == x(j));
        
        median_circadian_power(j) = prctile(bin_data, 50, 'all');
        upper_qrtl_power(j) = prctile(bin_data, 75, 'all');
        lower_qrtl_power(j) = prctile(bin_data, 25, 'all');
    end
    
    % Ensure x is a column vector for fill coordinates
    if isrow(x), x = x'; end
    
    xfill = [x; flipud(x)];
    yfill = [lower_qrtl_power'; flipud(upper_qrtl_power')];
    
    % Plot the shaded percentile area
    fill(ax(i), xfill, yfill, color(i,:), 'linestyle', 'none');
    alpha(ax(i), 0.4);
    hold(ax(i), 'on');
    
    % Plot the median line
    plot(ax(i), x, median_circadian_power, 'Color', color(i,:), 'LineWidth', 1);
    
    ylabel(ax(i), LFP.ylabel);
    xlabel(ax(i), "Time of the day");
    
    % --- NEW: Safe Y-Limits ---
    max_y = 1.3 * max(upper_qrtl_power, [], 'omitnan');
    if isempty(max_y) || isnan(max_y) || max_y == 0
        max_y = 1; % Fallback so it doesn't crash on flat/empty arrays
    end
    ylim(ax(i), [0 max_y]);
    
    % Title handling
    if ~isempty(LFP.sensing) && length(cfs) >= curr_hemi
        title(ax(i), lbl_subplot(curr_hemi) + " (Sensing band centered @" + ...
            num2str(cfs(curr_hemi),'%.2f') + " Hz)");
    else
        title(ax(i), lbl_subplot(curr_hemi));
    end
    
    legend(ax(i), '25th, 50th and 75th percentiles');
    hold(ax(i),'on');
end

if n_channels == 2
    linkaxes(ax, 'x');
end
end