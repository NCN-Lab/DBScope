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
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Pedro Melo & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

LFP = obj.chronic_parameters.time_domain;
n_channels = LFP.n_channels;
stimAmp = obj.chronic_parameters.stim_amp;
events_available = false;

% --- Define visualization parameters ---
GAP_THRESHOLD = hours(3); % Break lines if gap is >= 3 hours
DEFAULT_VIEW_WINDOW = days(45); % Default zoom for X-axis (last 45 days)

% Determine global time limits for smart zooming
global_min_time = datetime('now');
global_max_time = datetime('now');
valid_times = LFP.time(~cellfun(@isempty, LFP.time));
if ~isempty(valid_times)
    global_min_time = min(cellfun(@min, valid_times));
    global_max_time = max(cellfun(@max, valid_times));
end

% --- NEW: Smart Window Logic & Warning Dialog ---
cutoff_time = global_max_time - DEFAULT_VIEW_WINDOW;
default_xlim_start = cutoff_time; % Fallback

if global_min_time < cutoff_time
    % 1. Find the earliest actual data point WITHIN the 45-day window
    earliest_in_window = global_max_time; 
    has_data_in_window = false;
    for k = 1:numel(valid_times)
        t_arr = valid_times{k};
        t_win = t_arr(t_arr >= cutoff_time);
        if ~isempty(t_win)
            if min(t_win) < earliest_in_window
                earliest_in_window = min(t_win);
            end
            has_data_in_window = true;
        end
    end
    
    if has_data_in_window
        % Snap the view to the first data point in the window
        default_xlim_start = earliest_in_window;
    end
    
    % 2. Pop the warning dialog about historical data
    date_str = char(global_min_time, 'MMMM dd, yyyy'); % e.g., July 30, 2025
    warn_msg = sprintf('There is data prior to the displayed 45-day window.\n\nEarliest recorded data point: %s.\n\nPlease use the Pan and Zoom tools in the toolbar to explore historical data.', date_str);
    warndlg(warn_msg, 'Historical Data Available');
else
    % All data fits within 45 days
    default_xlim_start = global_min_time;
end

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
        % --- Find absolute min/max times across cell arrays ---
        valid_times = LFP.time(~cellfun(@isempty, LFP.time));
        if ~isempty(valid_times)
            global_min_time = min(cellfun(@min, valid_times));
            global_max_time = max(cellfun(@max, valid_times));
            
            events = events_dummy(obj.chronic_parameters.events.date_time >= global_min_time & ...
                                  obj.chronic_parameters.events.date_time <= global_max_time, :);
        else
            events = events_dummy([]); % No valid times, empty table
        end
    
        %Plot all events of each type at once
        if ~isempty(events)
            event_names = unique(events.event_name);
            colors = lines(2 + numel(event_names));
        else
            events_available = false;
        end

    end
    
end

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

if ~isempty(LFP.sensing)
    cfs = [LFP.center_frequency];
else
    
end

for i = 1:n_channels

    curr_hemi = hemisphere_indx(i);

    if nargin >= 2
        cla(ax(hemisphere_indx(i)), 'reset');
    end

    % --- Cell Array Extraction ---
    curr_LFP_time = LFP.time{curr_hemi};
    curr_LFP_data = LFP.data{curr_hemi};
    curr_stim_time = stimAmp.time{curr_hemi};
    curr_stim_data = stimAmp.data{curr_hemi};

    % Safety check: If this hemisphere has no data, label it and skip plotting
    if isempty(curr_LFP_time) || isempty(curr_LFP_data)
        title(ax(curr_hemi), lbl_subplot(curr_hemi) + " (No Data Available)");
        continue; 
    end

    % --- Insert NaT/NaN to break continuous lines over large gaps ---
    [plot_stim_time, plot_stim_data] = insertDataGaps(curr_stim_time, curr_stim_data, GAP_THRESHOLD);
    [plot_LFP_time, plot_LFP_data]   = insertDataGaps(curr_LFP_time, curr_LFP_data, GAP_THRESHOLD);

    % Right Axis: Stimulation
    yyaxis(ax(curr_hemi), 'right');
    plot(ax(curr_hemi), plot_stim_time + hours(utc), plot_stim_data);
    ylabel(ax(curr_hemi), stimAmp.ylabel);

    % --- NaN-Safe Limits ---
    max_stim = max(curr_stim_data, [], 'omitnan');
    if isempty(max_stim) || isnan(max_stim), max_stim = 1; end
    ylim(ax(curr_hemi),[0, max_stim + 0.5]);

    % Left Axis: LFP
    yyaxis(ax(curr_hemi), 'left');
    plot(ax(curr_hemi), plot_LFP_time + hours(utc), plot_LFP_data);
    ylabel(ax(curr_hemi), LFP.ylabel);

    % --- Apply the smartly snapped limits with visual padding ---
    % We pad the left side by 1 day and right side by 12 hours so data doesn't clip the edges
    xlim(ax(curr_hemi), [default_xlim_start + hours(utc) - days(1), global_max_time + hours(utc) + hours(12)]);
    xtickangle(ax(curr_hemi), 20);

    % Prctile naturally ignores NaNs, but we must protect against empty/all-NaN arrays
    max_lfp = 1.5 * prctile(curr_LFP_data, 99);
    if isempty(max_lfp) || isnan(max_lfp) || max_lfp == 0, max_lfp = 1; end
    ylim(ax(curr_hemi),[0, max_lfp]);
    
    % Title handling
    if ~isempty(LFP.sensing) && length(cfs) >= curr_hemi
        title(ax(curr_hemi), lbl_subplot(curr_hemi) + " (Sensing band centered @" + ...
            num2str(cfs(curr_hemi),'%.2f') + " Hz)");
    else
        title(ax(curr_hemi), lbl_subplot(curr_hemi));
    end
    
    hold(ax(curr_hemi),'on');

    if events_available
        clear h % Clear handle array for each subplot to avoid dimension mismatches
        for eventId = 1:numel(event_names)
            event_DateTime = events.date_time(strcmp(events.event_name, event_names(eventId))) + hours(utc);

            if ~isempty(event_DateTime)
                hi = xline(ax(curr_hemi), event_DateTime, '--', 'Color', colors(2 + eventId, :), 'LineWidth', 1.5);
                h(eventId) = hi(1);
            end
        end

        if exist('h','var') && any(isgraphics(h))
            xlabel(ax(curr_hemi), LFP.xlabel);
            valid_h_idx = isgraphics(h);
            lgd = legend(ax(curr_hemi), h(valid_h_idx), event_names(valid_h_idx));
            ax(curr_hemi).InteractionOptions.LimitsDimensions = "x";
            title(lgd,'Events');
        end
    end
end

if n_channels == 2
    linkaxes(ax, 'x');
end

    % =========================================================================
    % HELPER FUNCTION: Insert NaT/NaN to break lines
    % =========================================================================
    function [t_out, d_out] = insertDataGaps(t_in, d_in, gap_duration)
        if isempty(t_in)
            t_out = t_in; d_out = d_in; return;
        end
        
        % Find where time jumps are greater than the threshold
        dt = diff(t_in);
        gaps = find(dt >= gap_duration);
        
        if isempty(gaps)
            t_out = t_in; d_out = d_in; return;
        end
        
        num_gaps = length(gaps);
        % Pre-allocate output arrays with extra space for the NaNs
        t_out = NaT(length(t_in) + num_gaps, 1);
        d_out = NaN(length(d_in) + num_gaps, 1);
        
        % Map original data into new expanded array
        shift = zeros(length(t_in), 1);
        shift(gaps + 1) = 1;
        shift = cumsum(shift);
        orig_pos = (1:length(t_in))' + shift;
        
        t_out(orig_pos) = t_in;
        d_out(orig_pos) = d_in;
    end

end