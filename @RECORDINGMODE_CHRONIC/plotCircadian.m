function h = plotCircadian( obj, varargin )
% PLOTCIRCADIAN Plot the circadian mean power.
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
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: https://doi.org/10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
color = lines(4);

LFP = obj.chronic_parameters.time_domain;
n_channels = LFP.n_channels;

% Parse input variables
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
            lbl_subplot = "Left Hemipshere";
            ax(2).Visible = false;
            ax = ax(1);
        else
            lbl_subplot = "Right Hemipshere";
            ax(1).Visible = false;
            ax = ax(2);
        end
    case 2
        for i = 1:n_channels
            ax(i).Visible = true;
        end
        lbl_subplot = ["Left Hemipshere", "Right Hemisphere"];
        if contains(LFP.hemispheres(1),'Left')
            hemisphere_indx = [1, 2];
        else
            hemisphere_indx = [2, 1];
        end
end

cfs = [LFP.sensing.hemispheres.center_frequency];

temp_time = datevec(LFP.time + hours(utc));
temp_time(:, 5) = 10*floor(temp_time(:, 5)/10);
rounded_time = duration([temp_time(:, 4:5) zeros(size(temp_time,1), 1)]);
x = unique(rounded_time);

for i = 1:n_channels
    if nargin >= 2
        cla(ax(i), 'reset');
    end

    median_circadian_power = length(x);
    upper_qrtl_power = length(x);
    lower_qrtl_power = length(x);
    for j = 1:numel(x)
%         mean_circadian_power(j) = mean(LFP.data(rounded_time==x(j),i));
%         std_circadian(j) = std(LFP.data(rounded_time==x(j),i),1);
        median_circadian_power(j) = prctile(LFP.data(rounded_time==x(j), hemisphere_indx(i)),50,'all');
        upper_qrtl_power(j) = prctile(LFP.data(rounded_time==x(j), hemisphere_indx(i)),75,'all');
        lower_qrtl_power(j) = prctile(LFP.data(rounded_time==x(j), hemisphere_indx(i)),25,'all');
    end

    xfill = [x; flipud(x)];
    yfill = [lower_qrtl_power'; ...
        flipud(upper_qrtl_power')];
    fill(ax(i), xfill, yfill, color(i,:), 'linestyle', 'none');
    alpha(ax(i), 0.4);
    hold(ax(i), 'on');
    plot(ax(i), x, median_circadian_power,'Color', color(i,:),'LineWidth',1);
    ylabel(ax(i), LFP.ylabel);
    xlabel(ax(i), "Time of the day");
    ylim(ax(i),[0 1.3*max(upper_qrtl_power)]);
    title(ax(i), lbl_subplot(i));
    title(ax(i), lbl_subplot(hemisphere_indx(i)) + " (CF: " + ...
        num2str(cfs(hemisphere_indx(i)),'%.2f') + " Hz)");
    legend(ax(i), '25th, 50th and 75th percentiles');
    hold(ax(i),'on');

end

if n_channels == 2
    linkaxes(ax, 'x');
end

end