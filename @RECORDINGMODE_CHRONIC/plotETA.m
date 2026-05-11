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
%    * event_date (optional ) - specific event log to highlight
%
% -----------------------------------------------------------------------

% Get active channels
hemispheres_names  = obj.chronic_parameters.time_domain.hemispheres;

% Dynamically assign colors based on available channels 
color = lines(max(2, numel(hemispheres_names))); 

ax = [];
event_date = ''; % Initialize securely to avoid undefined variable errors

% Parse input variables
switch nargin
    case 5
        ax = varargin{1};
        n_timestamps = varargin{2};
        event_type = varargin{3};
        event_date = varargin{4};
    case 4
        ax = varargin{1};
        n_timestamps = varargin{2};
        event_type = varargin{3};
    case 3
        n_timestamps = varargin{1};
        event_type = varargin{2};
    case 2
        event_type = varargin{1};
        n_timestamps = 6;
    case 1
        error('Not enough input arguments. At least event_type must be provided.');
end

if isempty(n_timestamps)
    n_timestamps = 6;
else
    n_timestamps = n_timestamps + 1;
end

if isempty(ax)
    no_axes = 1;
else
    no_axes = 0;
end

% Get events data timestamps
events_timepoint = obj.chronic_parameters.events.date_time(strcmp(obj.chronic_parameters.events.event_name, event_type));

for channel = 1:numel(hemispheres_names)

    % --- Extract independent timeline grids from the cell array ---
    curr_chronic_time = obj.chronic_parameters.time_domain.time{channel};
    curr_chronic_data = obj.chronic_parameters.time_domain.data{channel};

    % Store extracted data in cells to avoid NaN padding issues
    chronic_LFP_cells = cell(numel(events_timepoint), 1);
    chronic_time_cells = cell(numel(events_timepoint), 1);
    evnt_indx = [];
    
    for evnt = 1:numel(events_timepoint)
        % Check if this is the specific event to highlight
        if ~isempty(event_date) && strcmp( event_date, datestr(events_timepoint(evnt)) )
            evnt_indx = evnt;
        end
        
        % --- Compare against the specific hemisphere's time vector ---
        chronic_indx = find(curr_chronic_time <= events_timepoint(evnt), 1, 'last');
        
        % Skip if event happens before any recorded timeline data
        if isempty(chronic_indx)
            continue; 
        end
        
        % Define safe bounds for extraction
        idx_start = max(1, chronic_indx - n_timestamps + 1);
        idx_end   = min(numel(curr_chronic_time), chronic_indx + n_timestamps);
        
        % --- Extract from the specific hemisphere's data vector ---
        ext_time = curr_chronic_time(idx_start:idx_end);
        ext_LFP  = curr_chronic_data(idx_start:idx_end);
        
        % Calculate real time difference in minutes
        rel_time_min = minutes(ext_time - events_timepoint(evnt));
        
        % Ensure uniqueness for the interpolation grid
        [rel_time_min, unique_idx] = unique(rel_time_min);
        ext_LFP = ext_LFP(unique_idx);
        
        % Save to cells
        chronic_time_cells{evnt} = rel_time_min;
        chronic_LFP_cells{evnt} = ext_LFP;
    end
    
    if no_axes
        figure;
        ax(channel) = axes;
    else
        cla(ax(channel), 'reset'); % reset axis
    end
    
    % Prepare the interpolation grid for the mean profile
    query_times = -n_timestamps*10 : 10 : (n_timestamps+1)*10;
    interp_LFP = nan(numel(events_timepoint), numel(query_times));
    
    xline(ax(channel), 0, 'HandleVisibility', 'off');
    hold(ax(channel), 'on');
    
    valid_indices = []; % Track which events actually have plotted data
    
    for evnt = 1:numel(events_timepoint)
        if isempty(chronic_time_cells{evnt}) || numel(chronic_time_cells{evnt}) < 2
            continue; % Skip events with insufficient data
        end
        
        valid_indices(end+1) = evnt;
        
        % Plot individual valid traces natively (no NaN breaks)
        plot(ax(channel), chronic_time_cells{evnt}, chronic_LFP_cells{evnt}, ...
            'Color',[color(channel,:), 0.2], 'HandleVisibility', 'off');
        
        % Interpolate over the query grid for accurate mean alignment
        interp_LFP(evnt,:) = interp1(chronic_time_cells{evnt}, chronic_LFP_cells{evnt}, ...
            query_times, 'linear', NaN);
    end
    
    % Only attempt to draw Selected and Median lines if data exists
    if ~isempty(valid_indices)
        % Overlay the highlighted event if requested and if it contains valid data
        if ~isempty(evnt_indx) && ismember(evnt_indx, valid_indices)
            plot(ax(channel), chronic_time_cells{evnt_indx}, chronic_LFP_cells{evnt_indx}, ...
                'Color', [color(channel,:), 1], 'LineWidth', 2, 'DisplayName', 'Selected Event');
        end
        
        % EXACT MATCH FIX: If there's only 1 valid trace, map the median directly to the raw data
        if numel(valid_indices) == 1
            the_idx = valid_indices(1);
            plot(ax(channel), chronic_time_cells{the_idx}, chronic_LFP_cells{the_idx}, ...
                'Color', 'black', 'LineWidth', 2, 'DisplayName', 'Median Power');
            valid_medians = chronic_LFP_cells{the_idx}; % Store for limit calculation
        else
            % Plot Median Power via the interpolated grid for multiple events
            valid_medians = median(interp_LFP(valid_indices, :), 1, 'omitnan');
            plot(ax(channel), query_times, valid_medians, 'Color', 'black', 'LineWidth', 2, ...
                'DisplayName', 'Median Power');
        end
        
        legend(ax(channel));
        
        % ==========================================================
        % --- ROBUST Y-AXIS LIMITS FOR ETA (SMALL N DATA) ---
        % ==========================================================
        
        % 1. Start by finding the peak of the Median trace
        max_median = max(valid_medians, [], 'omitnan');
        
        % 2. Calculate a much lower percentile (90th) of the background traces
        flat_data = interp_LFP(valid_indices, :);
        p90_lfp = prctile(flat_data(:), 90);
        
        % 3. Set the base limit to comfortably fit whichever is higher
        max_lfp = 1.5 * max(max_median, p90_lfp);
        
        % 4. If a specific event is clicked, ensure the axis expands to show its peak!
        if ~isempty(evnt_indx) && ismember(evnt_indx, valid_indices)
            max_selected = max(chronic_LFP_cells{evnt_indx}, [], 'omitnan');
            % Use 1.2x buffer so the selected line doesn't touch the very top edge
            max_lfp = max(max_lfp, 1.2 * max_selected);
        end
        
        % Safety fallback if data is perfectly flat or entirely NaN
        if isempty(max_lfp) || isnan(max_lfp) || max_lfp == 0
            max_lfp = 1; 
        end
        ylim(ax(channel), [0, max_lfp]);
        
    else
        % Default limits if no data was plotted
        ylim(ax(channel), [0, 1]);
    end
    
    % --- ALWAYS EXECUTE LABELS & TITLES (EVEN IF EMPTY) ---
    
    xlabel(ax(channel), "Time [min]");
    ylabel(ax(channel), "LFP Power");
    xlim(ax(channel),[-(n_timestamps-1)*10-.5 (n_timestamps-1)*10+.5]);
    
    % Base title generation
    if contains(hemispheres_names(channel), 'Left')
        title_str = "Left Hemisphere (Sensing band centered @" + ...
            num2str(obj.chronic_parameters.time_domain.center_frequency(channel),'%.2f') + " Hz)";
    else
        title_str = "Right Hemisphere (Sensing band centered @" + ...
            num2str(obj.chronic_parameters.time_domain.center_frequency(channel),'%.2f') + " Hz)";
    end
    
    % Append missing data warning if no valid traces were found
    if isempty(valid_indices)
        title_str = title_str + " - No peri-event Timeline Data";
    end
    
    title(ax(channel), title_str);
    
    hold(ax(channel), 'off');
    disableDefaultInteractivity(ax(channel));
end

if numel(ax) == 2
    linkaxes(ax, 'x');
end

end