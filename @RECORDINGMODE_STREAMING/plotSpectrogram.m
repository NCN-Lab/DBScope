function plotSpectrogram( obj, varargin )
% PLOTSPECTROGRAM Computes and plot standard spectrogram
% Use with LFP online streaming recordings
%
% Syntax:
%   PLOTSPECTROGRAM( obj, data_type, varargin );
%
% Input parameters:
%    * obj - object containg data
%    * data_type - type of input data (raw, ecg cleaned or filtered)
%    * ax (optional) - axis where you want to plot
%
% Example:
%   PLOTSPECTROGRAM(  data_type, varargin );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Parse input variables
switch nargin
    case 6
        ax          = varargin{1};
        data_type   = varargin{2};
        rec         = varargin{3};
        channel     = varargin{4};
        contrast    = varargin{5};

        switch data_type
            case 'Raw'
                LFP_selected = obj.streaming_parameters.time_domain.data;
            case 'ECG Cleaned'
                LFP_selected = obj.streaming_parameters.time_domain.ecg_clean;
            case 'Latest Filtered'
                LFP_selected = obj.streaming_parameters.filtered_data.data{end};
        end

        aux_plotSpectrogram( obj, ax, LFP_selected, rec, channel, contrast );

    case 5
        ax          = varargin{1};
        data_type   = varargin{2};
        rec         = varargin{3};
        channel     = varargin{4};
        contrast    = "normal";

        switch data_type
            case 'Raw'
                LFP_selected = obj.streaming_parameters.time_domain.data;
            case 'ECG Cleaned'
                LFP_selected = obj.streaming_parameters.time_domain.ecg_clean;
            case 'Latest Filtered'
                LFP_selected = obj.streaming_parameters.filtered_data.data{end};
        end
        
        aux_plotSpectrogram( obj, ax, LFP_selected, rec, channel, contrast );


    case 1 % No interface; returns at the end
        if isempty( obj.streaming_parameters.filtered_data.data )
            disp( 'Data is not filtered' );
            data_type = questdlg( 'Which data do you want to visualize?', ...
                '', 'Raw', 'ECG Cleaned', 'ECG Cleaned' );
        else
            disp( 'Data is filtered' );
            data_type = questdlg( 'Which data do you want to visualize?', ...
                '', 'Raw', 'ECG Cleaned', 'Latest Filtered', 'Latest Filtered' );
        end

        switch data_type
            case 'Raw'
                LFP_selected = obj.streaming_parameters.time_domain.data;
            case 'ECG Cleaned'
                LFP_selected = obj.streaming_parameters.time_domain.ecg_clean;
            case 'Latest Filtered'
                LFP_selected = obj.streaming_parameters.filtered_data.data{end};
        end

        for rec = 1:numel( LFP_selected )
            figure;
            for channel = 1:numel( LFP_selected{rec}(1,:) )
                ax(1) = subplot( numel( LFP_selected{rec}(1,:) ), 2, channel );
                ax(2) = subplot( numel( LFP_selected{rec}(1,:) ), 2, channel + 2 );

                plotSignalAndStimulation( obj, ax(1), data_type, rec, channel );
                aux_plotSpectrogram( obj, ax(2), LFP_selected, rec, channel, "normal" );
                    
                set(ax(2), 'PositionConstraint', 'innerposition');
                set(ax(1), 'PositionConstraint', 'innerposition');
                pos2 = get(ax(2), 'InnerPosition');
                pos1 = get(ax(1), 'InnerPosition');

                if pos1(3) ~= pos2(3)
                    pos1(1) = pos2(1);
                    pos1(3) = pos2(3);
                    set(ax(1),'InnerPosition', pos1);
                end
            end
        end
        return;
end

end

function aux_plotSpectrogram( obj, ax, LFP_selected, rec, channel, contrast )
% Get sampling frequency parameters
sampling_freq_Hz        = obj.streaming_parameters.time_domain.fs;

% Define spectrogram parameters
window                  = round(0.5*sampling_freq_Hz);
noverlap                = round(window/2);
fmin                    = 1; %Hz
fmax                    = 125; %Hz
normalizePower          = 0;

% Get data
LFP                     = LFP_selected{rec}(:, channel);
[~, f, t, p]            = spectrogram( LFP, window, noverlap, fmin:0.5:fmax, sampling_freq_Hz, 'yaxis' );
if normalizePower == 1
    power2plot          = 10 * log10( p ./ mean(p, 2) );
else
    power2plot          = 10 * log10( p );
end

% Plot data
cla( ax, 'reset' );
imagesc( ax, t, f, power2plot );
xlabel( ax, 'Time [sec]' );
set( ax, 'YDir','normal' )
ylabel( ax, 'Frequency [Hz]' );
rec = colorbar( ax );
rec.Label.String = 'Power/Frequency [dB/Hz]';
switch contrast
    case "normal"
        dmax = max( quantile(power2plot, 0.9) );
    case "high"
        dmax = min( 5 * ( floor( max(quantile(power2plot, 0.9), [], 'all' ) / 5 ) - 1 ), 10 );
end
dmin = -40;
clim( ax, [dmin dmax] );
title( ax, 'Spectrogram' );

end


