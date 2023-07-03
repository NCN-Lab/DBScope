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
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN INEB/i3S 2021
% pauloaguiar@ineb.up.pt
% -----------------------------------------------------------------------
color = lines(2);

% Parse input variables, indicating event date, event type and axes
switch nargin
    case 4
        event_date = varargin{1};
        event_type = varargin {2};
        ax = varargin {3};
        
        % Get other event types
        events_names = obj.chronic_parameters.type_events;
        other_events_names = events_names(~strcmp(events_names, event_type));
        
        % Get all events datetimes and selected event type datetimes
        events_datetimes = obj.chronic_parameters.events.date_time;
        selected_eventtype_datetimes = events_datetimes(strcmp( obj.chronic_parameters.events.event_name, event_type ));
        
        % Plot hour of the day histogram
        cla(ax(1), 'reset');
        H = histogram(ax(1), hour(selected_eventtype_datetimes), 'BinMethod', 'integers');
        hold(ax(1), 'on');

        % Highlight bin of selected event
        hh = hour(datetime(event_date,'Format','dd-MMM-yyyy HH:mm:ss'));
        temp_x = H.BinEdges(H.BinEdges==hh-0.5 | H.BinEdges==hh+0.5);
        temp_x = [temp_x fliplr(temp_x)];
        temp_y = [0 0 repmat(H.Values(H.BinEdges==hh-0.5), 1, 2)];
        patch(ax(1), temp_x, temp_y, color(2,:));

        xlabel(ax(1), "Hour of the day");
        xlim(ax(1), [-.5, 23.5]);
        ylabel(ax(1), "Frequency");
        ylim(ax(1), [0, max(H.Values)+2]);
        title(ax(1), [event_type ' distribution throughout the day']);
        
        % Plot elapsed time histograms
        for i = 2:4
            dt_event = events_datetimes(strcmp( obj.chronic_parameters.events.event_name, other_events_names{i-1} ));

            dt_since = calendarDuration(1,0,0);
            for evnt = 1:numel(selected_eventtype_datetimes)
                if sum(selected_eventtype_datetimes(evnt)>=dt_event(:))>0
                    temp = dt_event(selected_eventtype_datetimes(evnt)>=dt_event);
                    dt_since(end+1) = between(temp(end),selected_eventtype_datetimes(evnt));
                else
                    dt_since(end+1) = NaN;
                end

            end
            dt_since = dt_since(2:end);

%             disp("Number of " + event_type + " co-registered (<3 min) with " + other_events_names{i-1} + ": " + ...
%                 num2str(numel(dt_since(time(dt_since)<minutes(3)))));

            cla(ax(i), 'reset');
            temp_elapsed = caldays(dt_since)*24 + hms(time(dt_since));
            temp_elapsed(temp_elapsed>24) = 24;
            H = histogram(ax(i), temp_elapsed, 'BinMethod', 'integers');
            hold(ax(i), 'on');

            % Highlight bins of selected event
            hh = caldays(dt_since(strcmp(datestr(selected_eventtype_datetimes), string(event_date))))*24 + ...
                hms(time(dt_since(strcmp(datestr(selected_eventtype_datetimes), string(event_date)))));
            if hh>24
                hh = 24;
            end
            if ~isnan(hh)
                temp_x = H.BinEdges(H.BinEdges==hh-0.5 | H.BinEdges==hh+0.5);
                temp_x = [temp_x fliplr(temp_x)];
                temp_y = [0 0 repmat(H.Values(H.BinEdges==hh-0.5), 1, 2)];
                patch(ax(i), temp_x, temp_y, color(2,:));
            end

            xlabel(ax(i), "Hours");
            xlim(ax(i), [-.5, 24.5]);
            xticks(ax(i), 0:6:24);
            xticklabels(ax(i), {'0','6','12','18','24+'});
            ylabel(ax(i), "Frequency");
            ylim(ax(i), [0, max(H.Values)+2]);
            title(ax(i), ['Elapsed time since last ' other_events_names{i-1}]);

        end

    otherwise

end

end

