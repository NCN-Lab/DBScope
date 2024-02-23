function plotFFTSetupOFF( obj, varargin )
% PLOTFFTSETUPOFF
% Plot setup OFF LFP recording fourier transform
%
% Syntax:
%   PLOTFFTSETUPOFF( obj, varargin );
%
% Input parameters:
%    * obj              DBScope object containg streaming data.
%    * (optional) ax    Axis where to plot.
%    * channel          Index of channel.
%
% Example:
%   PLOTFFTSETUPOFF( obj, channel );
%   PLOTFFTSETUPOFF( obj, ax, channel );
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

% Calculate FFT
y = raw_signal{channel};
s1 = length(y);
n = 250;
m  = s1 - mod(s1, n);
freq_set = 0;
window_overlap = 2;
window_welch = hann(sampling_frequency);
window_fft = zeros(window_overlap*m/n-(window_overlap-1), (n+6)/2);
for i = 1:window_overlap*m/n-(window_overlap-1)
    y_clean = detrend(y((i-1)*n/window_overlap+1:(i-1)*n/window_overlap+n));
    Y = fft( [y_clean.*window_welch', zeros(1,6)]);
    L = round( length(Y)/2 );
    window_fft(i,:) = abs( Y(1:L) )/L; % CORRECTION: "/L"
    if ~freq_set
        freqs = linspace( Nyquist/L, Nyquist, L ) - Nyquist/L;
        freq_set = 1;
    end
end
signal_FFT_abs = 2.3*mean(window_fft, 1); % Correction to match tablet amplitudes

% Plot 
color = lines(2);
cla( ax, 'reset' );
area( ax, [13 35], [1.3*max(signal_FFT_abs) 1.3*max(signal_FFT_abs)], 'FaceColor', color(1,:), ...
    'FaceAlpha', 0.2, 'EdgeColor', 'none', 'PickableParts', 'none');
hold( ax, 'on');
plot( ax, freqs, signal_FFT_abs, 'Color', color(1,:));
xticks( ax, [0, 13, 35, 60, ceil(max(freqs))]);
xlim( ax, [0 ceil(max(freqs))]);
ylim( ax, [0 1.3*max(signal_FFT_abs)]);
xlabel( ax, 'Frequency (Hz)' );
ylabel( ax, 'Amplitude (\muVp)' );
title( ax, 'Frequency Domain' );

end

