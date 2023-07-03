function plotSummaryStreaming( obj, varargin )
% Computes and plot summary of visualizations for LFP streaming recordings
% Raw data, spectrogram, and Scalogram
%
% Syntax:
% PLOTSUMMARYSTREAMING( obj, data_type, varargin );
%
% Input parameters:
%    * obj - object containg data
%    * data_type - type of input data (raw, ecg cleaned or filtered)
%    * ax (optional) - axis where you want to plot
%
% Example:
%   PLOTSUMMARYSTREAMING(  data_type, varargin );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

stimAmp = obj.streaming_parameters.stim_amp;
sampling_freq_Hz =  obj.streaming_parameters.time_domain.fs;
sampling_freq_stimAmp = obj.streaming_parameters.stim_amp.fs;
window = round(0.5*sampling_freq_Hz);
noverlap = round(window/2);
fmin = 1; %Hz
fmax = 125; %Hz
normalizePower = 0;

switch nargin
    case 6
        ax = varargin{1};
        data_type = varargin{2};
        rec = varargin{3};
        channel = varargin{4};
        contrast = varargin{5};

    case 5
        ax = varargin{1};
        data_type = varargin{2};
        rec = varargin{3};
        channel = varargin{4};

    case 2 % No interface; returns at the end
        rec = varargin{1};

        if isempty (obj.streaming_parameters.filtered_data.data)
            disp('Data is not filtered');
            answer = questdlg('Which data do you want to visualize?', ...
                '', ...
                'Raw', 'ECG clean data', 'ECG clean data');
        else
            disp('Data is filtered');
            answer = questdlg('Which data do you want to visualize?', ...
                '', ...
                'Raw', 'ECG clean data', 'Latest Filtered', 'Latest Filtered');
        end

        switch answer
            case 'Raw'
                LFP_ordered = obj.streaming_parameters.time_domain.data;
            case 'ECG clean data'
                LFP_ordered = obj.streaming_parameters.time_domain.ecg_clean;
            case 'Latest Filtered'
                LFP_ordered = obj.streaming_parameters.filtered_data.data{end};
        end

        fig = figure;
        set(fig, 'position', [16, 48, 1425, 727]);
        for channel = 1:numel(LFP_ordered{rec}(1,:))
            % Raw & Stimulation
            tms = (0:numel(LFP_ordered{rec}(:,channel))-1)/sampling_freq_Hz;
            tms_stim = (0:numel(stimAmp.data{rec}(:,channel))-1)/sampling_freq_stimAmp;

            ax1 = subplot(3,numel(LFP_ordered{rec}(1,:)), channel);
            yyaxis(ax1, 'left');
            plot( ax1, tms,  LFP_ordered{rec}(:,channel) );
            ylabel( ax1,'LFP [\muVp]');
            yyaxis(ax1, 'right');
            plot( ax1, tms_stim, stimAmp.data{rec}(:,channel), 'LineWidth', 2);
            ylabel( ax1, 'Stimulation Amplitude [mA]');
            title( 'Signal & Stimulation channel');
            subtitle(char(obj.streaming_parameters.time_domain.channel_names{rec}(:,channel)), 'Interpreter', 'none' );
            xlabel( ax1, 'Time [sec]');
            xlim(ax1, [min(tms) max(tms)]);

            % Spectogram
            [~, f, t, p] = spectrogram(LFP_ordered{rec}(:,channel), window, noverlap, fmin:0.5:fmax, sampling_freq_Hz, 'yaxis');
            if normalizePower == 1
                power2plot = 10*log10(p./mean(p, 2));
            else
                power2plot = 10*log10(p);
            end

            ax2 = subplot(3,numel(LFP_ordered{rec}(1,:)), channel+2);
            imagesc( ax2, t, f, power2plot);
            xlabel( ax2, 'Time [sec]');
            ylabel(ax2, 'Frequency [Hz]');
            xlim( ax2, [min(tms) max(tms)]);
            c = colorbar( ax2 );
            c.Label.String = 'Power/Frequency [dB/Hz]';
            set( ax2, 'YDir', 'normal');
            dmax = max(quantile(power2plot, 0.9));
            dmin = -40;
            clim(ax2, [dmin dmax]);
            title(ax2, 'Spectrogram');

            % Scalogram
            wname = 'amor';
            [ cfs, frq ] = cwt( LFP_ordered{rec}(:,channel) , sampling_freq_Hz, wname );

            ax3 = subplot(3,numel(LFP_ordered{rec}(1,:)), channel+4);
            colormap( ax3, 'hot');
            s = pcolor( ax3, tms, frq, abs(cfs));
            s.EdgeColor = 'none';
            s.FaceColor = 'flat';
            xlabel( ax3, 'Time [sec]');
            ylabel( ax3, 'Frequency [Hz]');
            c = colorbar( ax3 );
            colormap( ax3, 'hot');
            c.Label.String = 'Power/Frequency [dB/Hz]';
            yticks( ax3, [0, 10, floor(max(frq))]);
            set( ax3, 'YDir', 'normal', 'YScale', 'log');
            title( ax3, 'Scalogram' );
            
            set(ax3, 'PositionConstraint', 'innerposition');
            set(ax2, 'PositionConstraint', 'innerposition');
            set(ax1, 'PositionConstraint', 'innerposition');

        end
        return;
end

switch data_type
    case 'Raw'
        LFP_ordered = obj.streaming_parameters.time_domain.data;
    case 'Latest Filtered'
        LFP_ordered = obj.streaming_parameters.filtered_data.data{end};
    case 'ECG Cleaned'
        LFP_ordered = obj.streaming_parameters.time_domain.ecg_clean;
end

%% Variables
%Raw & Scalogram
wname = 'amor';
[ cfs, frq ] = cwt( LFP_ordered{rec}(:,channel) , sampling_freq_Hz, wname );
tms = (0:numel(LFP_ordered{rec}(:,channel))-1)/sampling_freq_Hz;
tms_stim = (0:numel(stimAmp.data{rec}(:,channel))-1)/sampling_freq_stimAmp;

% Spectogram
[~, f, t, p] = spectrogram(LFP_ordered{rec}(:,channel), window, noverlap, fmin:0.5:fmax, sampling_freq_Hz, 'yaxis');
if normalizePower == 1
    power2plot = 10*log10(p./mean(p, 2));
else
    power2plot = 10*log10(p);
end

cla(ax(1), 'reset');
yyaxis(ax(1), 'left');
plot( ax(1), tms,  LFP_ordered{rec}(:,channel) );
ylabel( ax(1),'LFP [\muVp]');
yyaxis(ax(1), 'right');
plot( ax(1), tms_stim, stimAmp.data{rec}(:,channel), 'LineWidth', 2);
ylabel( ax(1), 'Stimulation Amplitude [mA]');
title( ax(1), 'Signal & Stimulation');
xlabel( ax(1), 'Time [sec]');
xlim( ax(1), [min(tms) max(tms)]);

cla(ax(2), 'reset');
imagesc( ax(2), t, f, power2plot);
xlabel( ax(2), 'Time [sec]');
ylabel(ax(2), 'Frequency [Hz]');
xlim( ax(2), [min(tms) max(tms)]);
c = colorbar( ax(2) );
c.Label.String = 'Power/Frequency [dB/Hz]';
set( ax(2), 'YDir', 'normal');
switch contrast
    case "normal"
        dmax = max(quantile(power2plot, 0.9));
    case "high"
        dmax = min(5*(floor(max(quantile(power2plot, 0.9),[],'all')/5)-1), 10);
end
dmin = -40;
clim(ax(2), [dmin dmax]);
title(ax(2), 'Spectrogram');

cla(ax(3), 'reset');
colormap( ax(3), 'hot');
s = pcolor( ax(3), tms, frq, abs(cfs));
s.EdgeColor = 'none';
s.FaceColor = 'flat';
xlabel( ax(3), 'Time [sec]');
ylabel( ax(3), 'Frequency [Hz]');
c = colorbar( ax(3) );
colormap( ax(3), 'hot');
c.Label.String = 'Power/Frequency [dB/Hz]';
yticks( ax(3), [0, 10, floor(max(frq))]);
set( ax(3), 'YDir', 'normal', 'YScale', 'log');
title( ax(3), 'Scalogram' );

set(ax(3), 'PositionConstraint', 'innerposition');
set(ax(2), 'PositionConstraint', 'innerposition');
set(ax(1), 'PositionConstraint', 'innerposition');
pos3 = get(ax(3), 'InnerPosition');
pos2 = get(ax(2), 'InnerPosition');
pos1 = get(ax(1), 'InnerPosition');

if pos1(3) ~= pos2(3)
    % set width of first and third axes equal to second
    pos1(1) = pos2(1);
    pos1(3) = pos2(3);
    pos3(1) = pos2(1);
    pos3(3) = pos2(3);
    set(ax(1),'InnerPosition', pos1);
    set(ax(3),'InnerPosition', pos3);
end
end

