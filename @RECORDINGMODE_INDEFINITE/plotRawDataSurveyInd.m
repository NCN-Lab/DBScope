function plotRawDataSurveyInd( obj, varargin )
% plot Indefinite Streaming raw data 
%
% Syntax:
%   PLOTRAWDATASURVEYIND( obj );
%
% Input parameters:
%    * obj - object containg data
%    * ax (optional) - axis where you want to plot
%
% Example:
%   PLOTRAWDATASURVEYIND( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

LFP_indefinite = obj.indefinite_parameters.time_domain.data;
time = obj.indefinite_parameters.time_domain.time';

switch nargin
    case 4
        ax = varargin{1};
        record = varargin{2};
        channel = varargin{3};

        plot(ax, time{record}, LFP_indefinite{record}(:,channel));
        ylabel(ax, 'Amplitude [\muVp]')
        xlabel(ax, 'Time [sec]')
        title(ax, 'Raw signal Indefinite Streaming ')

    case 1
    for c = 1:numel(LFP_indefinite(1,:)) 

        figure
        plot(time, LFP_indefinite(:,c));
        ylabel('Amplitude [\muVp]')
        xlabel('Time [sec]')
        title('Raw signal Indefinite Streaming ')
        subtitle( char(obj.indefinite_parameters.time_domain.channel_names{c}) , 'Interpreter', 'none');

    end

end
