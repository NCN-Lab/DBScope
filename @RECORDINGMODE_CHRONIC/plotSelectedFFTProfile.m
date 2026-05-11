function plotSelectedFFTProfile ( obj, varargin )
% Plot selected FFT profile
%
% Syntax:
%   PLOTSELECTEDFFTPROFILE( obj, ax, event_date );
%
% Input parameters:
%    * obj - object containg data
%    * ax (optional) - axis where you want to plot
%    * event_date (optional) 
%
% Example:
%   PLOTSELECTEDFFTPROFILE( obj, ax, event_date );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
color = lines(2);
% Get active channels
hemispheres_names  = obj.chronic_parameters.time_domain.hemispheres;

% Parse input variables
switch nargin
    case 3
        ax = varargin{1};
        event_date = varargin{2};
        
        for channel = 1:numel(hemispheres_names)
            current_FFT = [];
            freq = [];
            
            for evnt = 1:length(obj.chronic_parameters.events.lfp_frequency_snapshots_events)
                if strcmp( event_date, datestr(obj.chronic_parameters.events.date_time(evnt,:)) )
                    % Ensure the snapshot actually exists before extracting
                    if ~isempty(obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1})
                        current_FFT = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.FFTBinData(:,channel);
                        freq = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.Frequency;
                    else
                        % Warning pushed to console, but we will also handle it visually below
                        warning('DBScope:MissingSnapshot', 'The event logged at %s does not contain an FFT snapshot.', event_date);
                    end
                end
            end
            
            % Left-side axis
            % --- CHANGE 1: Safer child deletion to prevent UI crashes ---
            % Only delete the top line if there is more than just the base Mean profile
            if ~isempty(ax(channel).Children) && length(ax(channel).Children) > 1
                delete(ax(channel).Children(1));
            end
            
            % --- CHANGE 2: Dynamic Legend Update for Missing/NaN Data ---
            hold(ax(channel), 'on');
            
            if isempty(current_FFT) || all(isnan(current_FFT))
                % Data is either missing entirely or was padded with NaNs in extractTrendLogs
                % Plot an invisible line across the current X-axis limits
                dummy_x = xlim(ax(channel));
                plot(ax(channel), dummy_x, [NaN NaN], 'Color', [0.5 0.5 0.5], 'LineStyle', ':', ...
                    'LineWidth', 1.5, 'DisplayName', 'Selected: NO SNAPSHOT DATA');
            else
                % Normal valid data plot
                plot(ax(channel), freq, current_FFT, 'Color', [color(2,:), 1], ...
                    'LineWidth', 1.5, 'DisplayName', 'Selected FFT');
            end
            
            legend(ax(channel));
            ax(channel).Interactions = [panInteraction('Dimensions','x') zoomInteraction('Dimensions','x')];
            hold(ax(channel), 'off');
        end
        linkaxes(ax,'x');
    otherwise
        error('Incorrect inputs. For reference: plotSelectedFFTProfile ( obj, ax, event_date )')
end
end