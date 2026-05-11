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
        error('Invalid number of arguments to draw the Event Histograms Plot');

end

% Remove any missing datetimes (NaT) from the analysis so math functions don't crash
all_dt = obj.chronic_parameters.events.date_time;
valid_idx = ~isnat(all_dt);

valid_event_names = obj.chronic_parameters.events.event_name(valid_idx);
events_datetimes = all_dt(valid_idx) + hours(utc);

% Get all events datetimes and selected event type datetimes safely
selected_eventtype_datetimes = events_datetimes(strcmp(valid_event_names, event_type));
t = timeofday(selected_eventtype_datetimes);

% Get other event types
events_names = obj.chronic_parameters.type_events;
other_events_names = events_names(~strcmp(events_names, event_type));
num_other_events = numel(other_events_names);

% Safely convert the target event_date string into a datetime object for comparisons
try
    target_event_dt = datetime(event_date);
catch
    target_event_dt = NaT; % Fallback if string is empty
end

if isa(ax(1), 'axes')

    % Plot hour of the day histogram
    cla(ax(1), 'reset');

    % Only attempt to plot if there is valid data
    if ~isempty(t)
        H = histogram(ax(1), hours(t), 'BinEdges', 0:0.5:24);

        % Highlight bin of selected event
        if ~isnat(target_event_dt)
            hh = hours(timeofday(target_event_dt));
            indx_bin = find(H.BinEdges <= hh, 1, 'last');
            if ~isempty(indx_bin) && indx_bin < length(H.BinEdges)
                temp_x = H.BinEdges([indx_bin indx_bin + 1]);
                temp_x = [temp_x fliplr(temp_x)];
                temp_y = [0 0 repmat(H.Values(indx_bin), 1, 2)];
                patch(ax(1), temp_x, temp_y, color(2,:));
            end
        end
        ylim(ax(1), [0, max(H.Values)+2]);
    end
   
    xlabel(ax(1), "Hour of the day");
    xlim(ax(1), [-0.5, 24.5]);
    ylabel(ax(1), "Number of occurences");

    xt = 0:4:24;
    xticks(ax(1), xt);
    xticklabels(ax(1), string(xt));
    ax(1).XAxis.MinorTick = 'on';
    ax(1).XAxis.MinorTickValues = 0:1:24;
    set(ax(1), 'TickDir', 'out')
    title(ax(1), [event_type ' distribution throughout the day']);
else

    if ~isa(ax(1), 'polaraxes')
        delete(ax(1).Children);
        pax = polaraxes(ax(1));
    else
        pax = ax(1);
    end

    if ~isempty(t)
        H = polarhistogram(pax, hours(t)/12*pi, 0:pi/12:2*pi, 'FaceAlpha', 0.5, 'EdgeAlpha', 0.4);
        hold(pax, 'on');

        % Highlight bin of selected event
        if ~isnat(target_event_dt)
            hh = hours(timeofday(target_event_dt));
            edges_hours = 0:1:24;
            indx_bin = find(edges_hours <= hh, 1, 'last');
            
            if ~isempty(indx_bin)
                highlight_counts = zeros(size(H.Values));
                highlight_counts(indx_bin) = H.Values(indx_bin);
                polarhistogram(pax, 'BinEdges', 0:pi/12:2*pi, 'BinCounts', highlight_counts, 'FaceAlpha', 0.7, 'EdgeAlpha', 0.2, 'FaceColor', color(2,:));
            end
        end

    end
    
    pax.RColor = [0, 0, 0];
    pax.ThetaColor = [0, 0, 0];
    pax.ThetaZeroLocation = "top";
    pax.RAxisLocation = 350;
    rlims = pax.RLim;
    pax.RTick = 0:floor(rlims(2)/4)+1:rlims(2);
    pax.ThetaDir = 'clockwise';
    thetaticklabels(pax, string(0:2:24)+"h");
    title(pax, sprintf('''%s'' throughout the day',event_type));
    axtoolbar( pax, {'export'} );

end

% Plot elapsed time histograms
for i = 2:4

    cla(ax(i),"reset");

    % Check if we actually have enough 'other' event types to plot in this axis
    if (i-1) <= num_other_events
        ax(i).Visible = 'on';
        
        dt_event = events_datetimes(strcmp(valid_event_names, other_events_names{i-1}));
        diff_in_window = calendarDuration(1,0,0);
        temp_elapsed_dt = [];
        
        for evnt = 1:numel(selected_eventtype_datetimes)
            all_diff = abs(dt_event - selected_eventtype_datetimes(evnt));
            mask_in_window = all_diff <= hours(TEMPORAL_WINDOW);
            diff_in_window = [diff_in_window; between(dt_event(mask_in_window),selected_eventtype_datetimes(evnt))];  
            temp_elapsed_dt = [temp_elapsed_dt, repelem(selected_eventtype_datetimes(evnt),sum(mask_in_window))];
        end
        diff_in_window = diff_in_window(2:end);
        
        [y, m, d, time_val] = split(diff_in_window, {'years', 'months', 'days', 'time'});
        temp_elapsed = y*24*365 + m*24*30 + d*24 + hours(time_val);
        bin_step = 0.25;
        bin_edges = -TEMPORAL_WINDOW:bin_step:TEMPORAL_WINDOW;
        
        if ~isempty(temp_elapsed)
            H = histogram(ax(i), temp_elapsed, 'BinEdges', bin_edges, 'FaceAlpha', 0.5, 'EdgeAlpha', 0.4);
            set(ax(i), 'TickDir', 'out')    
            hold(ax(i), 'on');
            
            % --- Clean datetime matching ---
            hh = temp_elapsed(temp_elapsed_dt == target_event_dt);
            
            for h_idx = 1:numel(hh)
                if ~isnan(hh(h_idx)) && (hh(h_idx)>bin_edges(1)-bin_step/2 && hh(h_idx)<bin_edges(end)+bin_step/2)
                    indx_bin = find(H.BinEdges <= hh(h_idx), 1, 'last');
                    temp_x = H.BinEdges([indx_bin indx_bin + 1]);
                    temp_x = [temp_x fliplr(temp_x)];
                    temp_y = [0 0 repmat(H.Values(indx_bin), 1, 2)];
                    patch(ax(i), temp_x, temp_y, color(2,:), 'FaceAlpha', 0.7, 'EdgeAlpha', 0.4);
                end
            end
            ylim(ax(i), [0, max(H.Values)+2]);
        end
        
        xlabel(ax(i), "Hours");
        xlim(ax(i), [bin_edges(1)-bin_step/2, bin_edges(end)+bin_step/2]);
        ticks = ceil(bin_edges(1)):1:floor(bin_edges(end));
        xticks(ax(i), ticks);
        xticklabels(ax(i), cellstr(string(ticks)));
        ax(i).XAxis.MinorTick = 'on';
        ax(i).XAxis.MinorTickValues = -TEMPORAL_WINDOW:bin_step:TEMPORAL_WINDOW;
        ylabel(ax(i), "Number of occurences");
        title(ax(i), sprintf('Relative to ''%s''', other_events_names{i-1}));
        
    else
        % If there are no more 'other' event types, hide the remaining empty axes
        ax(i).Visible = 'off';
        title(ax(i), '');
    end
end
end
