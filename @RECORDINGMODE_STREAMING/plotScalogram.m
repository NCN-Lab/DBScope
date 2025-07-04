function plotScalogram( obj, varargin )
% PLOTSCALOGRAM Continuous 1-D wavelet transform using Morlet wavelet
% Use LFP online streaming recordings
%
% Syntax:
%   PLOTSCALOGRAM( obj, varargin );
%
% Input parameters:
%    * obj              DBScope object containg streaming data.
%    * (optional) ax    Axis where to plot.
%    * rec              Index of recording.
%    * channel          Index of channel.
%
% Example:
%   PLOTSCALOGRAM( obj, rec, channel );
%   PLOTSCALOGRAM( obj, ax, rec, channel );
%
%
% PLOTSCALOGRAM(..., 'PARAM1', val1, 'PARAM2', val2, ...)
%   specifies optional name/value pairs:
%     'DataType'            Type of input data. Can be of three types: 
%                           'Raw', 'ECG Cleaned' or 'Latest Filtered'.
%                           Defaults to 'Raw'
%
% Revision history:
%
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3S.up.pt
% -----------------------------------------------------------------------

sampling_frequency = obj.streaming_parameters.time_domain.fs;

% Create an input parser object
parser = inputParser;

validScalarNum  = @(x) isnumeric(x) && isscalar(x) && (x > 0);
validLimits     = @(x) isnumeric(x) && isvector(x) && length(x) == 2 && x(2) > x(1);
defaultDataType = 'Raw';
validDataType   = {'Raw','ECG Cleaned','Latest Filtered'};

% Define input parameters and their default values
addRequired(parser, 'Recording', validScalarNum);
addRequired(parser, 'Channel');
addParameter(parser, 'DataType', defaultDataType, @(x) any(validatestring(x,validDataType))); % Default value is 'Raw'
addParameter(parser, 'Limits', [1 92], validLimits); % Default value is [1 92]

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
limits          = parser.Results.Limits;

switch data_type
    case 'Raw'
        LFP_selected = obj.streaming_parameters.time_domain.data;
    case 'ECG Cleaned'
        LFP_selected = obj.streaming_parameters.time_domain.ecg_clean;
        if isempty(LFP_selected)
            warning(['To visualize an ECG clean recording, you have to apply' ...
                ' the cleanECG() function first.']);
            return
        end
    case 'Latest Filtered'
        LFP_selected = obj.streaming_parameters.filtered_data.data{end};
        if isempty(LFP_selected)
            warning(['To visualize a filtered recording, you have to create' ...
                ' a new filter.']);
            return
        end
end

if isempty(ax)
    figure("Position", [100 300 1200 300]);
    ax = axes();
end

% Get data
channel_names_LFP   = obj.streaming_parameters.time_domain.channel_names{rec};
if contains(channel, "left", "IgnoreCase", true)
    LFP_indx = find(contains(channel_names_LFP, "left", "IgnoreCase", true));
else
    LFP_indx = find(contains(channel_names_LFP, "right", "IgnoreCase", true));
end
LFP             = LFP_selected{rec}(:, LFP_indx);
[ cfs, frq ]    = cwt( LFP, 'amor', sampling_frequency );
tms             = obj.streaming_parameters.time_domain.time{rec};

% Plot data
cla( ax, 'reset' );
imagesc( ax, tms, frq, abs(cfs));
xlabel( ax, 'Time (s)');
ylim( ax, limits);
yticks( ax, [0.1, 1, 4, 13, 35, 60, floor(max(frq))] );
ylabel( ax, 'Frequency (Hz)');
c = colorbar( ax );
colormap( ax, 'hot');
c.Label.String = 'Power/Frequency (dB/Hz)';
% dmax = max( prctile(abs(cfs), 99, "all") );
clim( ax, [0 10] );
set( ax, 'YDir', 'normal', 'YScale', 'log');
title( ax, 'Scalogram' );
axtoolbar( ax, {'export'} );

end

