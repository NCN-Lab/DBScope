function plotSpectrogram( obj, varargin )
% PLOTSPECTROGRAM Computes and plot standard spectrogram
% Use with LFP online streaming recordings
%
% Syntax:
%   PLOTSPECTROGRAM( obj, varargin );
%
% Input parameters:
%    * obj              DBScope object containg streaming data.
%    * (optional) ax    Axis where to plot.
%    * rec              Index of recording.
%    * channel          Index of channel.
%
% Example:
%   PLOTSPECTROGRAM( obj, rec, channel );
%   PLOTSPECTROGRAM( obj, ax, rec, channel );
%
%
% PLOTSPECTROGRAM(..., 'PARAM1', val1, 'PARAM2', val2, ...)
%   specifies optional name/value pairs:
%     'DataType'            Type of input data. Can be of three types: 
%                           'Raw', 'ECG Cleaned' or 'Latest Filtered'.
%                           Defaults to 'Raw'
%     'Contrast'            Type of constrast in plot. Can be of two types:
%                           'normal' or 'high'. High contrast reduces the
%                           the upper limit of the colorbar.
%                           Defaults to 'normal'
%     'NormalizePower'      Whether to normalize the power of the
%                           spectrogram.
%                           Defaults to false
%     'Window'              Number of samples per segment.
%                           Defaults to half the sampling frequency
%     'Overlap'             Number of samples that overlap adjoining
%                           segments.
%                           Defaults to a quarter of the sampling frequency
%     'Frequencies'         Cyclical frequencies
%                           Defaults to 1:0.5:sampling_frequency/2
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

sampling_frequency = obj.streaming_parameters.time_domain.fs;

% Create an input parser object
parser = inputParser;

validScalarNum  = @(x) isnumeric(x) && isscalar(x) && (x > 0);
defaultDataType = 'Raw';
validDataType   = {'Raw','ECG Cleaned','Latest Filtered'};
defaultContrast = 'normal';
validContrast   = {'normal','high'};

% Define input parameters and their default values
% Data parameters
addRequired(parser, 'Recording', validScalarNum);
addRequired(parser, 'Channel');
addParameter(parser, 'DataType', defaultDataType, @(x) any(validatestring(x,validDataType))); % Default value is 'Raw'
% Spectrogram parameters
addParameter(parser, 'Contrast', defaultContrast, @(x) any(validatestring(x,validContrast))); % Default value is 'normal'
addParameter(parser, 'NormalizePower', false); % Default value is false
addParameter(parser, 'Window', round(0.5*sampling_frequency)); % Default value is half the sampling frequency
addParameter(parser, 'Overlap', round(0.25*sampling_frequency)); % Default value is a quarter of the sampling frequency
addParameter(parser, 'Frequencies', 1:0.5:sampling_frequency/2);

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
contrast        = parser.Results.Contrast;
normalize_power = parser.Results.NormalizePower;
window          = parser.Results.Window;
noverlap        = parser.Results.Overlap;
f               = parser.Results.Frequencies;


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
LFP                     = LFP_selected{rec}(:, LFP_indx);
tms                     = obj.streaming_parameters.time_domain.time{rec};
[~, freq, t, p]         = spectrogram( LFP, window, noverlap, f, sampling_frequency, 'yaxis' );
if normalize_power
    power2plot          = 10 * log10( p ./ mean(p, 2) );
else
    power2plot          = 10 * log10( p );
end

% Plot data
cla( ax, 'reset' );
imagesc( ax, tms, freq, power2plot );
xlabel( ax, 'Time (s)' );
set( ax, 'YDir','normal' );
ylabel( ax, 'Frequency (Hz)' );
rec = colorbar( ax );
rec.Label.String = 'Power/Frequency [dB/Hz]';
switch contrast
    case "normal"
        dmax = prctile(power2plot, 99, "all");
    case "high"
        dmax = min( 5 * ( floor( prctile(power2plot, 99, "all") / 5 ) - 1 ), 10 );
end
dmin = -25;
clim( ax, [dmin dmax] );
title( ax, 'Spectrogram' );
axtoolbar( ax, {'export'} );

end




