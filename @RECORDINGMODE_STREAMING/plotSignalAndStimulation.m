function plotSignalAndStimulation( obj, varargin )
% PLOTSIGNALANDSTIMULATION Computes and plot standard spectrogram
% Use with LFP online streaming recordings
%
% Syntax:
%   PLOTSIGNALANDSTIMULATION( obj, varargin );
%
% Input parameters:
%    * obj              DBScope object containg streaming data.
%    * (optional) ax    Axis where to plot.
%    * rec              Index of recording.
%    * channel          Index of channel.
%
% Example:
%   PLOTSIGNALANDSTIMULATION( obj, rec, channel );
%   PLOTSIGNALANDSTIMULATION( obj, ax, rec, channel );
%
%
% PLOTSIGNALANDSTIMULATION(..., 'PARAM1', val1, 'PARAM2', val2, ...)
%   specifies optional name/value pairs:
%     'DataType'            Type of input data. Can be of three types: 
%                           'Raw', 'ECG Cleaned' or 'Latest Filtered'.
%                           Defaults to 'Raw'
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

% Define input parameters and their default values
addRequired(parser, 'Recording', validScalarNum);
addRequired(parser, 'Channel');
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

% Get stimulation parameters
stim_amp_obj        = obj.streaming_parameters.stim_amp;
sampling_freq_stim  = obj.streaming_parameters.stim_amp.fs;

% Get data
channel_names_LFP   = obj.streaming_parameters.time_domain.channel_names{rec};
channel_names_stim  = obj.streaming_parameters.stim_amp.stim_channel_names{rec};
if contains(channel, "left", "IgnoreCase", true)
    LFP_indx = find(contains(channel_names_LFP, "left", "IgnoreCase", true));
    stim_indx = 1;
else
    LFP_indx = find(contains(channel_names_LFP, "right", "IgnoreCase", true));
    stim_indx = 2;
end
LFP         = LFP_selected{rec}(:, LFP_indx);
tms         = obj.streaming_parameters.time_domain.time{rec};
stim        = stim_amp_obj.data{rec}(:, stim_indx);
tms_stim    = stim_amp_obj.time{rec};

% Plot data
cla( ax, 'reset' );
yyaxis( ax, "left" );
plot( ax, tms, LFP);
ylabel( ax, 'LFP (\muVp)' );
yyaxis( ax, "right" );
plot( ax, tms_stim, stim, 'LineWidth', 2 );
ylabel( ax, "Amplitude (mA)");
title( ax, 'Signal & Stimulation' );
xlabel( ax, 'Time (s)' );
xlim( ax, [min(tms) max(tms)] );
ylim( ax, [0 ceil( max(stim) + 1)] );


end


