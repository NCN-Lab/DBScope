function plotETA( obj, varargin )
% Plot Event Triggered average profile for the selected events
%
% Syntax:
%   PLOTETA( obj, ax, n_timestamps, event_type, event_date );
%
% Input parameters:
%    * obj - object containg data
%    * ax (optional) - axis where you want to plot
%    * n_timestamps (optional)
%    * event_type ( optional ) - type of event to plot
%    * date_range (optional ) - period of events logs to plot
%
% Example:
%   obj.plotETA;
%   PLOTETA( obj );
%   PLOTETA( obj, n_timestamps, event_type );
%   PLOTETA( obj, ax, n_timestamps, event_type, event_date );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
color = lines(4);
ax = [];

% Get active channels
hemispheres_names  = obj.chronic_parameters.time_domain.hemispheres;

% Parse input variables
switch nargin
    case 5
        ax = varargin{1};
        n_timestamps = varargin{2};
        event_type = varargin{3};
        event_date = varargin{4};

        if isempty(n_timestamps)
            n_timestamps = 6;
        else
            n_timestamps = n_timestamps + 1;
        end

    case 3
        n_timestamps = varargin{1};
        event_type = varargin{2};
        if isempty(n_timestamps)
            n_timestamps = 6;
        else
            n_timestamps = n_timestamps + 1;
        end

    case 1
        n_timestamps = 6;
end

if isempty(ax)
    no_axes = 1;
else
    no_axes = 0;
end

%% Get chronic data timestamps
chronic_time = obj.chronic_parameters.time_domain.time;

%% Get events data timestamps
events_timepoint = obj.chronic_parameters.events.date_time(strcmp(obj.chronic_parameters.events.event_name, event_type));

for channel = 1:numel(hemispheres_names)
    chronic_LFP = [];
    chronic_timestamps = [];
    for evnt = 1:numel(events_timepoint)
        if strcmp( event_date, datestr(events_timepoint(evnt)) )
            evnt_indx = evnt;
        end
        chronic_indx = find(events_timepoint(evnt)<chronic_time(:), 1)-1;
        if chronic_indx < n_timestamps
            LFP_before(1:n_timestamps) = NaN;
            LFP_before(end-chronic_indx+1:end) = ...
                obj.chronic_parameters.time_domain.data(1:chronic_indx,channel);
            timestamps_before(1:n_timestamps) = datetime(1900,0,0,0,0,0);
            timestamps_before(end-chronic_indx+1:end) = chronic_time(1:chronic_indx);
        else
            LFP_before(1:n_timestamps) = ...
                obj.chronic_parameters.time_domain.data(chronic_indx+1-n_timestamps:chronic_indx,channel);
            timestamps_before(1:n_timestamps) = chronic_time(chronic_indx+1-n_timestamps:chronic_indx);
        end
        if numel(chronic_time) - chronic_indx+1 < n_timestamps
            LFP_after(1:n_timestamps) = NaN;
            LFP_after(1:numel(chronic_time)-chronic_indx) = ...
                obj.chronic_parameters.time_domain.data(chronic_indx+1:numel(chronic_time),channel);
            timestamps_after(1:n_timestamps) = datetime(3100,0,0,0,0,0);
            timestamps_after(1:numel(chronic_time)-chronic_indx) = chronic_time(chronic_indx+1:numel(chronic_time));
        else
            LFP_after(1:n_timestamps) = ...
                obj.chronic_parameters.time_domain.data(chronic_indx+1:chronic_indx+n_timestamps,channel);
            timestamps_after(1:n_timestamps) = chronic_time(chronic_indx+1:chronic_indx+n_timestamps);
        end

        chronic_LFP = [chronic_LFP; LFP_before, LFP_after];
        chronic_timestamps = [chronic_timestamps; between(events_timepoint(evnt), timestamps_before), ...
            between(events_timepoint(evnt), timestamps_after)];

    end
    
    if no_axes
        figure;
        ax(channel) = axes;
    else
        cla(ax(channel), 'reset'); % reset axis
    end
    if ~isempty(chronic_timestamps)
        t = split(chronic_timestamps,{'time'});
        total_min = minutes(t);
        xline(ax(channel), 0, 'HandleVisibility', 'off');
        hold(ax(channel), 'on');
        interp_LFP = [];
        for ii = 1:size(chronic_LFP, 1)
            [total_min_aux, indx, ~] = unique(total_min(ii,:));
            interp_LFP(ii,:) = interp1(total_min_aux, ...
                chronic_LFP(ii,indx), -n_timestamps*10:(n_timestamps+1)*10);
            plot(ax(channel), total_min_aux, chronic_LFP(ii,indx), 'Color',[color(channel,:), 0.2], 'HandleVisibility', 'off');
            hold(ax(channel), 'on');
        end
        plot(ax(channel), total_min(evnt_indx,:), chronic_LFP(evnt_indx,:), 'Color', [color(channel,:), 1], 'LineWidth', 1, 'DisplayName', 'Selected Event');
        plot(ax(channel), -n_timestamps*10:(n_timestamps+1)*10, mean(interp_LFP,1,'omitnan'),'Color','black','LineWidth',1, ...
            'DisplayName', 'Mean Power');
        xlabel(ax(channel), "Time [min]");
        ylabel(ax(channel), "LFP Power");
        xlim(ax(channel),[-(n_timestamps-1)*10-.5 (n_timestamps-1)*10+.5]);
        if contains(hemispheres_names(channel), 'Left')
            title(ax(channel), "Left Hemisphere" + " (CF: " + ...
                num2str(obj.chronic_parameters.time_domain.sensing.hemispheres(channel).center_frequency,'%.2f') + " Hz)" );
        else
            title(ax(channel), "Right Hemisphere" + " (CF: " + ...
                num2str(obj.chronic_parameters.time_domain.sensing.hemispheres(channel).center_frequency,'%.2f') + " Hz)" );
        end
        legend(ax(channel));
        hold(ax(channel), 'off');
        disableDefaultInteractivity(ax(channel));
    end
       
end

end
