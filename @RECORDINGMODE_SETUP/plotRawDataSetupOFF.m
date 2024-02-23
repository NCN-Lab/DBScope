function plotRawDataSetupOFF( obj, varargin )
% PLOTRAWDATASETUPOFF
% Plot setup OFF LFP recordings raw data
%
% Syntax:
%   PLOTRAWDATASETUPOFF( obj, varargin );
%
% Input parameters:
%    * obj              DBScope object containg streaming data.
%    * (optional) ax    Axis where to plot.
%    * channel          Index of channel.
%
% Example:
%   PLOTRAWDATASETUPOFF( obj, channel );
%   PLOTRAWDATASETUPOFF( obj, ax, channel );
%
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Create an input parser object
parser = inputParser;

validScalarNum  = @(x) isnumeric(x) && isscalar(x) && (x > 0);

% Define input parameters and their default values
addRequired(parser, 'Channel', validScalarNum);

% Parse the input arguments
if isa(varargin{1}, 'matlab.ui.control.UIAxes') || isa(varargin{1}, 'matlab.graphics.axis.Axes')
    ax = varargin{1};
    parse(parser, varargin{2:end});
else
    ax = [];
    parse(parser, varargin{:});
end

% Access the values of inputs
channel         = parser.Results.Channel;

% Get data
raw_signal          = obj.setup_parameters.stim_off.data;
time                = obj.setup_parameters.stim_off.time';
sampling_frequency  = obj.setup_parameters.stim_off.fs(1); % In survey mode, sampling frequency is the same for all recordings.
Nyquist             = 0.5*sampling_frequency;

if isempty(ax)
    figure("Position", [100 300 1200 300]);
    ax = axes();
end

% Plot
cla( ax, 'reset');
plot( ax, time, raw_signal{channel} );
xlim( ax, [0 time(end)]);
ylabel( ax, 'Amplitude (\muVp)');
xlabel( ax, 'Time (s)');
title( ax, 'Raw Signal');

end