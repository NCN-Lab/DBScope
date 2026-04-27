function plotMeanFFTProfile ( obj, varargin )
% Plot mean FFT profile for the selected event types
%
% Syntax:
%   PLOTMEANFFTPROFILE( obj, event_type, date_range, ax );
%
% Input parameters:
%    * obj - object containg data
%    * event_type ( optional ) - type of event to plot
%    * date_range (optional ) - period of events logs to plot
%    * ax (optional) - axis where you want to plot
%
% Example:
%   obj.plotMeanFFTProfile;
%   PLOTMEANFFTPROFILE( obj );
%   PLOTMEANFFTPROFILE( obj, event_type );
%   PLOTMEANFFTPROFILE( obj, ax, event_type );
%   PLOTMEANFFTPROFILE( obj, ax, event_type, date_range );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Get active channels
hemispheres_names  = obj.chronic_parameters.time_domain.hemispheres;

% --- 1. SNAPSHOT VALIDATION & WARNINGS ---
% Identify all unique event types logged in the history
all_events_names = unique(obj.chronic_parameters.events.event_name);

% Identify which specific event instances actually contain snapshots
has_snapshot = ~cellfun(@isempty, obj.chronic_parameters.events.lfp_frequency_snapshots_events);

% Get the global frequency bins early (since it is identical for all snapshots)
ind_first_snapshot = find(has_snapshot, 1);
if isempty(ind_first_snapshot)
    warning('DBScope:NoSnapshotsAtAll', 'No FFT snapshots found in the entire dataset. Analysis aborted.');
    return; 
end
base_freq = obj.chronic_parameters.events.lfp_frequency_snapshots_events{ind_first_snapshot,1}.Frequency;

% Filter the master list to ONLY include events that have at least one snapshot
events_names = unique(obj.chronic_parameters.events.event_name(has_snapshot));

% Assign colors dynamically based ONLY on valid events to avoid bounds errors
color = lines(max(1, numel(events_names))); 

% --- 2. PLOTTING LOGIC ---
switch nargin
    case 4
        % Get and plot FFT profiles in specified data range from the specified event in specified axis
        ax = varargin{1};
        event_type = varargin{2};
        date_range = varargin{3};
        
        for channel = 1:numel(hemispheres_names)
            temp_FFT = {};
            datetimes = obj.chronic_parameters.events.date_time;
            for evnt = 1:length(obj.chronic_parameters.events.lfp_frequency_snapshots_events)
                if strcmp( obj.chronic_parameters.events.event_name{evnt}, event_type ) && ...
                        ~isempty(obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}) && ...
                        datetimes(evnt) >= date_range(1) && datetimes(evnt) <= date_range(2) + caldays(1)
                    
                    temp_FFT{end+1} = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.FFTBinData(:,channel);
                end
            end
            
            cla(ax(channel), 'reset'); % reset axis
            if ~isempty(temp_FFT)
                plot(ax(channel), base_freq, [temp_FFT{:}], 'Color', [color(1,:), 0.3], 'HandleVisibility', 'off');
                hold(ax(channel), 'on');
                plot(ax(channel), base_freq, median([temp_FFT{:}], 2), 'black', 'LineWidth', 1, 'DisplayName', 'Median FFT');
            else
                % Plot an empty zero-line placeholder if no snapshots exist in this range
                placeholder_fft = zeros(size(base_freq));
                plot(ax(channel), base_freq, placeholder_fft, 'Color', [color(1,:), 0.3], 'HandleVisibility', 'off');
            end
            
            % Universal Labels
            xticks(ax(channel), [0, 13, 35, 60, floor(max(base_freq))]);
            xlabel(ax(channel), 'Frequency [Hz]');
            xlim(ax(channel), [0 ceil(max(base_freq))]);
            ylabel(ax(channel), 'Magnitude [\muVp]');
            if contains(hemispheres_names(channel,:), 'Left')
                title(ax(channel), 'Left Hemisphere' );
            else
                title(ax(channel), 'Right Hemisphere' );
            end
        end
        
    case 3
        % Get and plot FFT profiles from the specified event in specified axis
        ax = varargin{1};
        event_type = varargin{2};
        
        for channel = 1:numel(hemispheres_names)
            temp_FFT = {};
            for evnt = 1:length(obj.chronic_parameters.events.lfp_frequency_snapshots_events)
                if strcmp( obj.chronic_parameters.events.event_name{evnt}, event_type ) && ...
                        ~isempty(obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1})
                    temp_FFT{end+1} = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.FFTBinData(:,channel);
                end
            end
            
            cla(ax(channel), 'reset'); % reset axis
            if ~isempty(temp_FFT)
                plot(ax(channel), base_freq, [temp_FFT{:}], 'Color', [color(1,:), 0.3], 'HandleVisibility', 'off');
                hold(ax(channel), 'on');
                plot(ax(channel), base_freq, median([temp_FFT{:}], 2), 'black', 'LineWidth', 1, 'DisplayName', 'Median FFT');
            else
                warning('DBScope:EmptyRequestedEvent', 'Requested event "%s" has no snapshots.', event_type);
            end
            
            xticks(ax(channel), [0, 13, 35, 60, floor(max(base_freq))]);
            xlabel(ax(channel), 'Frequency [Hz]');
            xlim(ax(channel), [0 ceil(max(base_freq))]);
            ylabel(ax(channel), 'Magnitude [\muVp]');
            if contains(hemispheres_names(channel,:), 'Left')
                title(ax(channel), 'Left Hemisphere' );
            else
                title(ax(channel), 'Right Hemisphere' );
            end
        end
        
    case 2
        % Get and plot FFT profiles from the specified event
        event_type = varargin{1};
        figure;
        for channel = 1:numel(hemispheres_names)
            temp_FFT = {};
            for evnt = 1:length(obj.chronic_parameters.events.lfp_frequency_snapshots_events)
                if strcmp( obj.chronic_parameters.events.event_name{evnt}, event_type ) && ...
                        ~isempty(obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1})
                    temp_FFT{end+1} = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.FFTBinData(:,channel);
                end
            end
            
            subplot(1,numel(hemispheres_names),channel);
            if ~isempty(temp_FFT)
                plot(base_freq, [temp_FFT{:}], 'Color', [color(channel,:), 0.3], 'HandleVisibility', 'off');
                hold('on');
                plot(base_freq, median([temp_FFT{:}], 2), 'black', 'LineWidth', 1, 'DisplayName', 'Median FFT');
            else
                warning('DBScope:EmptyRequestedEvent', 'Requested event "%s" has no snapshots.', event_type);
            end
            
            xticks([0, 13, 35, 60, floor(max(base_freq))]);
            xlabel('Frequency [Hz]');
            xlim([0 ceil(max(base_freq))]);
            ylabel('Magnitude [\muVp]');
            if contains(hemispheres_names(channel,:), 'Left')
                title('Left Hemisphere' );
            else
                title('Right Hemisphere' );
            end
        end
        
    case 1
        % Get and plot FFT profiles for all valid events
        % Get max magnitude of FFT profile to align the limits of the subplots
        max_magnitude = 0;
        for channel = 1:numel(hemispheres_names)
            type_FFT = struct;
            for type = 1:numel(events_names)
                temp_FFT = {};
                for evnt = 1:length(obj.chronic_parameters.events.lfp_frequency_snapshots_events)
                    if strcmp( obj.chronic_parameters.events.event_name{evnt}, events_names{type} ) && ...
                            ~isempty(obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1})
                        temp_FFT{end+1} = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.FFTBinData(:,channel);
                    end
                end
                type_FFT.(['evnt' num2str(type)]) = [temp_FFT{:}];
                temp_magnitude = max([temp_FFT{:}], [], 'all', 'omitnan');
                if temp_magnitude > max_magnitude
                    max_magnitude = temp_magnitude;
                end
            end
            
            figure;
            t = tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact'); 
            
            if contains(hemispheres_names(channel,:), 'Left')
                title(t, 'Left Hemisphere'); 
            else
                title(t, 'Right Hemisphere');
            end
            
            ax = gobjects(0); 
            
            for type = 1:length(events_names)
                if ~isempty(type_FFT.(['evnt' num2str(type)]))
                    ax(end+1) = nexttile; 
                    
                    plot(base_freq, [type_FFT.(['evnt' num2str(type)])], 'Color', [color(type,:), 0.3], 'HandleVisibility', 'off');
                    hold on;
                    
                    plot( base_freq, median([type_FFT.(['evnt' num2str(type)])], 2), 'black', 'LineWidth', 1, 'DisplayName', 'Median FFT');
                    xlabel('Frequency [Hz]');
                    ylabel('Magnitude [\muVp]');
                    xticks([0, 13, 35, 60, floor(max(base_freq))]);
                    xlim([0 ceil(max(base_freq))]);
                    ylim([0 ceil(max_magnitude)]);
                    title(events_names{type});
                    legend('show');
                end
            end
           
            if ~isempty(ax)
                linkaxes(ax,'xy');
            end
        end
    otherwise
        error('Too much input arguments. For reference: plotMeanFFTProfile( obj, event_type, date_range, ax )')
end
end