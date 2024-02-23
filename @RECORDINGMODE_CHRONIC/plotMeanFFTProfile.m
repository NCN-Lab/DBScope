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
color = lines(4);

% Get active channels
hemispheres_names  = obj.chronic_parameters.time_domain.hemispheres;

% Parse input variables
switch nargin
    case 4
        % Get and plot FFT profiles in specified data range from the specified event in specified axis
        ax = varargin{1};
        event_type = varargin{2};
        date_range = varargin{3};

        for channel = 1:numel(hemispheres_names)
            temp_FFT = {};
            isFreqSet = false;
            datetimes = obj.chronic_parameters.events.date_time;
            for evnt = 1:length(obj.chronic_parameters.events.lfp_frequency_snapshots_events)
                if strcmp( obj.chronic_parameters.events.event_name{evnt}, event_type ) && ...
                        ~isempty(obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}) && ...
                        datetimes(evnt) >= date_range(1) && datetimes(evnt) <= date_range(2) + caldays(1)
                    temp_FFT{end+1} = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.FFTBinData(:,channel);
                    % Get frequency bins (equal for every fft)
                    if ~isFreqSet
                        freq = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.Frequency;
                        isFreqSet = true;
                    end
                end
            end
            
            cla(ax(channel), 'reset'); % reset axis
            if ~isempty(temp_FFT)
                plot(ax(channel), freq, [temp_FFT{:}], 'Color', [color(1,:), 0.3], 'HandleVisibility', 'off');
                hold(ax(channel), 'on');
            end
            % Plot mean FFT
%             plot(ax(channel), freq, mean([temp_FFT{:}], 2), 'black', 'LineWidth', 1, 'DisplayName', 'Mean FFT');
            plot(ax(channel), freq, median([temp_FFT{:}], 2), 'black', 'LineWidth', 1, 'DisplayName', 'Median FFT');
            xticks(ax(channel), [0, 13, 35, 60, floor(max(freq))]);
            xlabel(ax(channel), 'Frequency [Hz]');
            xlim(ax(channel), [0 ceil(max(freq))]);
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
            isFreqSet = false;
            for evnt = 1:length(obj.chronic_parameters.events.lfp_frequency_snapshots_events)
                if strcmp( obj.chronic_parameters.events.event_name{evnt}, event_type ) && ...
                        ~isempty(obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1})
                    temp_FFT{end+1} = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.FFTBinData(:,channel);
                    % Get frequency bins (equal for every fft)
                    if ~isFreqSet
                        freq = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.Frequency;
                        isFreqSet = true;
                    end
                end
            end
            
            cla(ax(channel), 'reset'); % reset axis
            if ~isempty(temp_FFT)
                plot(ax(channel), freq, [temp_FFT{:}], 'Color', [color(1,:), 0.3], 'HandleVisibility', 'off');
                hold(ax(channel), 'on');
            end
            % Plot mean FFT
%             plot(ax(channel), freq, mean([temp_FFT{:}], 2), 'black', 'LineWidth', 1, 'DisplayName', 'Mean FFT');
            plot(ax(channel), freq, median([temp_FFT{:}], 2), 'black', 'LineWidth', 1, 'DisplayName', 'Median FFT');
            xticks(ax(channel), [0, 13, 35, 60, floor(max(freq))]);
            xlabel(ax(channel), 'Frequency [Hz]');
            xlim(ax(channel), [0 ceil(max(freq))]);
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
            isFreqSet = false;
            for evnt = 1:length(obj.chronic_parameters.events.lfp_frequency_snapshots_events)
                if strcmp( obj.chronic_parameters.events.event_name{evnt}, event_type ) && ...
                        ~isempty(obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1})
                        temp_FFT{end+1} = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.FFTBinData(:,channel);
                    if ~isFreqSet
                        freq = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.Frequency;
                        isFreqSet = true;
                    end
                end
            end

            subplot(1,numel(hemispheres_names),channel);
            if ~isempty(temp_FFT)
                plot(freq, [temp_FFT{:}], 'Color', [color(channel,:), 0.3], 'HandleVisibility', 'off');
                hold('on');
            end
            % Plot mean FFT
%             plot(freq, mean([temp_FFT{:}], 2), 'black', 'LineWidth', 1, 'DisplayName', 'Mean FFT');
            plot(freq, median([temp_FFT{:}], 2), 'black', 'LineWidth', 1, 'DisplayName', 'Median FFT');
            xticks([0, 13, 35, 60, floor(max(freq))]);
            xlabel('Frequency [Hz]');
            xlim([0 ceil(max(freq))]);
            ylabel('Magnitude [\muVp]');
            if contains(hemispheres_names(channel,:), 'Left')
                title('Left Hemisphere' );
            else
                title('Right Hemisphere' );
            end

        end

    case 1
        % Get and plot FFT profiles
        isFreqSet = false;
        events_names = unique(obj.chronic_parameters.events.event_name);

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
                        if ~isFreqSet
                            freq = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.Frequency;
                            isFreqSet = true;
                        end
                    end
                end
                type_FFT.(['evnt' num2str(type)]) = [temp_FFT{:}];

                temp_magnitude = max([temp_FFT{:}], [], 'all', 'omitnan');
                if temp_magnitude > max_magnitude
                    max_magnitude = temp_magnitude;
                end
            end

            figure;
            if contains(hemispheres_names(channel,:), 'Left')
                sgtitle('Left Hemisphere' );
            else
                sgtitle('Right Hemisphere' );
            end

            for type = 1:length(events_names)
                if ~isempty(type_FFT.(['evnt' num2str(type)]))
                    ax(type) = subplot(2,2,type);
                    plot(freq, [type_FFT.(['evnt' num2str(type)])], 'Color', [color(type,:), 0.3], 'HandleVisibility', 'off');
                    hold on;
                    % Plot mean FFT
%                     plot( freq, mean([type_FFT.(['evnt' num2str(type)])], 2), 'black', 'LineWidth', 1, 'DisplayName', 'Mean FFT');
                    plot( freq, median([type_FFT.(['evnt' num2str(type)])], 2), 'black', 'LineWidth', 1, 'DisplayName', 'Median FFT');
                    xlabel(' Frequency [Hz]');
                    ylabel( ' Magnitude [\muVp]');
                    xticks([0, 13, 35, 60, floor(max(freq))]);
                    xlim([0 ceil(max(freq))]);
                    ylim([0 ceil(max_magnitude)]);
                    title(events_names{type});
                    legend('show');
                end
            end
           
            linkaxes(ax,'xy');

        end

    otherwise
        error('Too much input arguments. For reference: plotMeanFFTProfile( obj, event_type, date_range, ax )')
end

end