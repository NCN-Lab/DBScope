function plotRawDataSurvey( obj, varargin )
% PLOTRAWDATASURVEY
% Plot Survey LFP recordings raw data
%
% Syntax:
%   PLOTRAWDATASURVEY( obj, varargin );
%
% Input parameters:
%    * obj              DBScope object containg streaming data.
%    * (optional) ax    Axis where to plot.
%    * rec              Index of recording.
%    * channel          Index of channel.
%
% Example:
%   PLOTRAWDATASURVEY( obj, rec, channel );
%   PLOTRAWDATASURVEY( obj, ax, rec, channel );
%
% PLOTRAWDATASURVEY(..., 'PARAM1', val1, 'PARAM2', val2, ...)
%   specifies optional name/value pairs:
%     'DataType'            Type of input data. Can be of two types: 
%                           'Raw' or 'Latest Filtered'.
%                           Defaults to 'Raw'
%
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Create an input parser object
parser = inputParser;

validScalarNum  = @(x) isnumeric(x) && isscalar(x) && (x > 0);
defaultDataType = 'Raw';
validDataType   = {'Raw', 'Latest Filtered'};

% Define input parameters and their default values
addRequired(parser, 'Recording', validScalarNum);
addRequired(parser, 'Channel', validScalarNum);
addParameter(parser, 'DataType', defaultDataType, @(x) any(validatestring(x,validDataType))); % Default value is 'Raw'

% Parse the input arguments
if isa(varargin{1}, 'matlab.ui.control.UIAxes') || isa(varargin{1}, 'matlab.graphics.axis.Axes')
    ax = varargin{1};
    parse(parser, varargin{2:end});
else
    ax = [];
    parse(parser, varargin{:});
end

% Access the values of inputs
rec             = parser.Results.Recording;
channel         = parser.Results.Channel;
data_type       = parser.Results.DataType;

switch data_type
    case 'Raw'
        signal = obj.survey_parameters.time_domain.data;
    case 'Latest Filtered'
        signal = obj.survey_parameters.filtered_data.data{end};
        if isempty(signal)
            warning(['To visualize a filtered recording, you have to create' ...
                ' a new filter.']);
            return
        end
end

% Get data
time                = obj.survey_parameters.time_domain.time;
sampling_frequency  = cell2mat(obj.survey_parameters.time_domain.fs(1)); % In survey mode, sampling frequency is the same for all recordings.
Nyquist             = 0.5*sampling_frequency;

if isempty(ax)
    figure("Position", [100 300 1200 300]);
    ax = axes();
end

% Plot
cla( ax, 'reset');
plot( ax, time{rec}, signal{rec}(:, channel));
xlim( ax, [0 time{rec}(end)]);
ylabel( ax, 'Amplitude (\muVp)');
xlabel( ax, 'Time (s)');
title( ax, 'Raw Signal');

end

