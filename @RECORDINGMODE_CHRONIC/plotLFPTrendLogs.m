function h = plotLFPTrendLogs( obj, varargin )
% Plot LFP band power and stimulation amplitude accross time from LFPTrendLogs
% works as an auxiliar method to the extractTrendLogs.
%
% Syntax:
%   h = PLOTLFPTRENDLOGS( obj, ax );
%
% Input parameters:
%    * obj - object containg data
%    * ax (optional) - axis where you want to plot
%    * vw (optional) - accessing visualization window
%
% Example:
%   h = obj.plotLFPTrendLogs();
%   h = PLOTLFPTRENDLOGS( obj );
%   h = PLOTLFPTRENDLOGS( obj, ax );
%
% Adapted from Ameya Deoras (2023). Intelligent Dynamic Date Ticks 
% (https://www.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks), 
% MATLAB Central File Exchange. Retrieved June 12, 2023. 
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

LFP = obj.chronic_parameters.time_domain;
n_channels = LFP.n_channels;
stimAmp = obj.chronic_parameters.stim_amp;

if any(contains(LFP.hemispheres,'Left'))
    if contains(LFP.hemispheres(1),'Left')
        hemisphere_indx = [1, 2];
    else
        hemisphere_indx = [2, 1];
    end
end
lbl_subplot = ["Left Hemipshere", "Right Hemisphere"];

events_available = false;
if ~isempty(obj.chronic_parameters.events.lfp_frequency_snapshots_events)

    events_available = true;
    events_dummy = table(obj.chronic_parameters.events.event_name,....
        obj.chronic_parameters.events.date_time,...
        obj.chronic_parameters.events.event_id,...
        obj.chronic_parameters.events.lfp,...
        obj.chronic_parameters.events.lfp_frequency_snapshots_events,...
        'VariableNames',["event_name","date_time", "event_id", "lfp",...
        "lfp_frequency_snapshots_events"]);
    if ~isempty(obj.chronic_parameters.events.date_time)

        events = events_dummy(obj.chronic_parameters.events.date_time > obj.chronic_parameters.time_domain.time(1) & obj.chronic_parameters.events.date_time < obj.chronic_parameters.time_domain.time(end), :);
    
        %Plot all events of each type at once
        event_names = unique(events.event_name);
        colors = lines(2 + numel(event_names));

    end
    
end
% Parse input variables
if nargin == 2
    ax = varargin{1};
else
    figure;
    for i = 1:n_channels
        ax(i) = subplot(2,1,i);
    end
end


for i = 1:n_channels
    if nargin == 2
        cla(ax(hemisphere_indx(i)), 'reset');
    end
    yyaxis(ax(hemisphere_indx(i)), 'right');

%     plot(ax(hemisphere_indx(i)), datenum(stimAmp.time), stimAmp.data(:,hemisphere_indx(i)));
%     ylabel(ax(hemisphere_indx(i)), stimAmp.ylabel);
%     ylim(ax(hemisphere_indx(i)),[0 max(stimAmp.data(:,hemisphere_indx(i)))+0.5]);
%     yyaxis(ax(hemisphere_indx(i)), 'left');
%     plot(ax(hemisphere_indx(i)), datenum(LFP.time), LFP.data(:,hemisphere_indx(i)));
%     ylabel(ax(hemisphere_indx(i)), LFP.ylabel);
%     datetick(ax(hemisphere_indx(i)), 'x','dd-mmm-yy','keeplimits');
%     xlim(ax(hemisphere_indx(i)), [min(datenum(LFP.time)) max(datenum(LFP.time))]);
%     xtickangle(ax(hemisphere_indx(i)), 20);
%     ylim(ax(hemisphere_indx(i)),[0 1.1*max(LFP.data(:,hemisphere_indx(i)))]);
%     set(ax(hemisphere_indx(i)), 'XMinorTick','on');
%     ax(hemisphere_indx(i)).XAxis.MinorTickValues = [];


    plot(ax(hemisphere_indx(i)), stimAmp.time, stimAmp.data(:,hemisphere_indx(i)));
    ylabel(ax(hemisphere_indx(i)), stimAmp.ylabel);
    ylim(ax(hemisphere_indx(i)),[0 max(stimAmp.data(:,hemisphere_indx(i)))+0.5]);
    yyaxis(ax(hemisphere_indx(i)), 'left');
    plot(ax(hemisphere_indx(i)), LFP.time, LFP.data(:,hemisphere_indx(i)));
    ylabel(ax(hemisphere_indx(i)), LFP.ylabel);
    xl = xlim(ax(hemisphere_indx(i)));
    span = dateshift(LFP.time, 'start', 'day', 'nearest');
    tick_values = span(1):days(1):span(end);
    if numel(tick_values) < 3 
%         xtickformat(ax(hemisphere_indx(i)), 'dd-MMM-yy HH');
        span = dateshift(xl, 'start', 'hour', 'nearest');
        tick_values = span(1):hours(1):span(end);
        xticks(ax(hemisphere_indx(i)), tick_values);
    else
        scale_factor = floor( numel(tick_values) / 10);
%         xtickformat(ax(hemisphere_indx(i)), 'dd-MMM-yy');
        tick_values = span(1):scale_factor*days(1):span(end);
        xticks(ax(hemisphere_indx(i)), tick_values);
        set(ax(hemisphere_indx(i)), 'XMinorTick','on');
        xl = xlim(ax(hemisphere_indx(i)));
        xl = dateshift(xl, 'start', 'hour', 'nearest');
        ax(hemisphere_indx(i)).XAxis.MinorTickValues = xl(1):scale_factor*hours(1):xl(2);
    end
    xticks(ax(hemisphere_indx(i)), 'manual');
    xlim(ax(hemisphere_indx(i)), [min(LFP.time) max(LFP.time)]);
    xtickangle(ax(hemisphere_indx(i)), 20);
    ylim(ax(hemisphere_indx(i)),[0 1.1*max(LFP.data(:,hemisphere_indx(i)))]);


    title(ax(hemisphere_indx(i)), lbl_subplot(hemisphere_indx(i)) + " (CF: " + ...
        num2str(LFP.sensing.hemispheres(hemisphere_indx(i)).center_frequency,'%.2f') + " Hz)");
    hold(ax(hemisphere_indx(i)),'on');
    

    if events_available
        for eventId = 1:numel(event_names)
            event_DateTime = events.date_time(strcmp(events.event_name, event_names(eventId)));

%             hi = plot(datenum([event_DateTime event_DateTime]), [0 1.1*max(LFP.data(:,hemisphere_indx(i)))], '--', ...
%                 'Color', colors(2 + eventId, :), 'Parent', ax(hemisphere_indx(i)));
            
            hi = plot([event_DateTime event_DateTime], [0 1.1*max(LFP.data(:,hemisphere_indx(i)))], '--', ...
                'Color', colors(2 + eventId, :), 'Parent', ax(hemisphere_indx(i)));
            h(eventId) = hi(1);

        end
        xlabel(ax(hemisphere_indx(i)), LFP.xlabel);
        lgd = legend(ax(hemisphere_indx(i)), h, unique(events.event_name));
        ax(hemisphere_indx(i)).InteractionOptions.LimitsDimensions = "x";
        title(lgd,'Events');

    end

end

if n_channels == 2
    linkaxes(ax, 'x');
end


end