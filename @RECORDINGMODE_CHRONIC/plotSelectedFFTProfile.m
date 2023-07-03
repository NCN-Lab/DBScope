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
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
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
            current_FFT = {};
            for evnt = 1:length(obj.chronic_parameters.events.lfp_frequency_snapshots_events)
                if strcmp( event_date, datestr(obj.chronic_parameters.events.date_time(evnt,:)) )
                    current_FFT = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.FFTBinData(:,channel);
                    freq = obj.chronic_parameters.events.lfp_frequency_snapshots_events{evnt,1}.Frequency;
                end
            end

            % Left-side axis
            % Delete last selected FFT, if it exists
            if length(ax(channel).Children)==2
                delete(ax(channel).Children(1));
            end
            plot(ax(channel), freq, current_FFT, 'Color', [color(2,:), 1], 'LineWidth', 1.5, 'DisplayName', 'Selected FFT');
            legend(ax(channel));
            ax(channel).Interactions = [panInteraction('Dimensions','x') zoomInteraction('Dimensions','x')];
        end

        linkaxes(ax,'x');

    otherwise
        error('Incorrect inputs. For reference: plotSelectedFFTProfile ( obj, ax, event_date )')

end

end
