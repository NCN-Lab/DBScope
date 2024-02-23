function plotEventHistograms (obj, varargin )
% Plot circadian distribution of events
%
% Syntax:
%   PLOTEVENTHISTOGRAMS(obj, event_date, event_type, ax );
%
% Input parameters:
%    * obj - object containg data
%    * event_type ( optional ) - type of event to plot
%    * date_range (optional ) - period of events logs to plot
%    * ax (optional) - axis where you want to plot
%
% Example:
%   PLOTEVENTHISTOGRAMS( obj, event_date, event_type, ax );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN INEB/i3S 2021
% pauloaguiar@ineb.up.pt
% -----------------------------------------------------------------------
color = lines(2);

TEMPORAL_WINDOW = 4; % hours

% Parse input variables, indicating event date, event type and axes
switch nargin
    case 5
        event_date = varargin{1};
        event_type = varargin{2};
        ax = varargin{3};
        utc = varargin{4};
    case 4
        event_date = varargin{1};
        event_type = varargin{2};
        ax = varargin{3};
        utc = 0;

    otherwise

end

% Get other event types
events_names = obj.chronic_parameters.type_events;
other_events_names = events_names(~strcmp(events_names, event_type));

% Get all events datetimes and selected event type datetimes
events_datetimes = obj.chronic_parameters.events.date_time + hours(utc);
selected_eventtype_datetimes = events_datetimes(strcmp( obj.chronic_parameters.events.event_name, event_type ));

t = timeofday(selected_eventtype_datetimes);

% Plot hour of the day histogram
cla(ax(1), 'reset');
H = histogram(ax(1), hours(t), 'BinEdges', 0:0.5:24);
hold(ax(1), 'on');

% Highlight bin of selected event
hh = hours(timeofday(datetime(event_date,'Format','dd-MMM-yyyy HH:mm:ss')));
indx_bin = find(H.BinEdges <= hh, 1, 'last');
temp_x = H.BinEdges([indx_bin indx_bin + 1]);
temp_x = [temp_x fliplr(temp_x)];
temp_y = [0 0 repmat(H.Values(indx_bin), 1, 2)];
patch(ax(1), temp_x, temp_y, color(2,:));

xlabel(ax(1), "Hour of the day");
xlim(ax(1), [-0.5, 24.5]);
ylabel(ax(1), "Number of occurences");
ylim(ax(1), [0, max(H.Values)+2]);
xt = 0:4:24;
xticks(ax(1), xt);
xticklabels(ax(1), string(xt));
ax(1).XAxis.MinorTick = 'on';
ax(1).XAxis.MinorTickValues = 0:1:24;
set(ax(1), 'TickDir', 'out')
title(ax(1), [event_type ' distribution throughout the day']);

% Plot elapsed time histograms
for i = 2:4
    dt_event = events_datetimes(strcmp( obj.chronic_parameters.events.event_name, other_events_names{i-1} ));
    

    diff_in_window = calendarDuration(1,0,0);
    temp_elapsed_dt = [];
    for evnt = 1:numel(selected_eventtype_datetimes)
        all_diff = abs(dt_event - selected_eventtype_datetimes(evnt));
        mask_in_window = all_diff <= hours(TEMPORAL_WINDOW);
        diff_in_window = [diff_in_window; between(dt_event(mask_in_window),selected_eventtype_datetimes(evnt))];  
        temp_elapsed_dt = [temp_elapsed_dt, repelem(selected_eventtype_datetimes(evnt),sum(mask_in_window))];

    end
    diff_in_window = diff_in_window(2:end);
    
    [y, m, d, t] = split(diff_in_window, {'years', 'months', 'days', 'time'});

    cla(ax(i), 'reset');
    temp_elapsed = y*24*365 + m*24*30 + d*24 + hours(t);
    bin_step = 0.25;
    bin_edges = -TEMPORAL_WINDOW:bin_step:TEMPORAL_WINDOW;
    H = histogram(ax(i), temp_elapsed, 'BinEdges', bin_edges);
    set(ax(i), 'TickDir', 'out')    
    hold(ax(i), 'on');
    
    % Highlight bins of selected event
    hh = temp_elapsed(strcmp(datestr(temp_elapsed_dt), string(event_date)));
    for t = 1:numel(hh)
        if ~isnan(hh(t)) && (hh(t)>bin_edges(1)-bin_step/2 && hh(t)<bin_edges(end)+bin_step/2)
            indx_bin = find(H.BinEdges <= hh(t), 1, 'last');
            temp_x = H.BinEdges([indx_bin indx_bin + 1]);
            temp_x = [temp_x fliplr(temp_x)];
            temp_y = [0 0 repmat(H.Values(indx_bin), 1, 2)];
            patch(ax(i), temp_x, temp_y, color(2,:));
        end
    end


    xlabel(ax(i), "Hours");
    xlim(ax(i), [bin_edges(1)-bin_step/2, bin_edges(end)+bin_step/2]);
    ticks = ceil(bin_edges(1)):1:floor(bin_edges(end));
    xticks(ax(i), ticks);
    xticklabels(ax(i), cellstr(string(ticks)));
    ax(i).XAxis.MinorTick = 'on';
    ax(i).XAxis.MinorTickValues = -TEMPORAL_WINDOW:bin_step:TEMPORAL_WINDOW;
    ylabel(ax(i), "Number of occurences");
    ylim(ax(i), [0, max(H.Values)+2]);
    title(ax(i), ['Relative to ' other_events_names{i-1}]);

end

end

