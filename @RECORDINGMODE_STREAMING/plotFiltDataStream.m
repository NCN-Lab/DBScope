function plotFiltDataStream( obj, filter_indx, varargin )
% Plot filtered LFP online streaming recordings
%
%Syntax:
%   PLOTFILTDATASTREAM( obj, filter_indx, varargin );
%
% Input parameters:
%    * obj - object containg data
%    * filter_indx
%    * ax (optional) - axis where you want to plot
%
% Example:
%   PLOTFILTDATASTREAM( filter_indx, varargin )
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Get sampling frequency
sampling_freq_Hz =  obj.streaming_parameters.time_domain.fs;
Nyquist = 0.5 * sampling_freq_Hz;
window = round(0.5*sampling_freq_Hz);
noverlap = round(window/2);
fmin = 1; %Hz
fmax = 125; %Hz
normalizePower = 0;

% % Check if data is filtered
% if isempty (obj.streaming_parameters.filtered_data.data)
%     disp('Data is not filtered')
%     return
% else
%     disp('Data is filtered')
% end

% Get LFP data
if iscell(obj.streaming_parameters.time_domain.data)
    channel_names =  obj.streaming_parameters.time_domain.channel_names;

    switch nargin
        case 6
            ax = varargin{1};
            rec = varargin{2};
            channel = varargin{3};
            contrast = varargin{4};

        case 5
            ax = varargin{1};
            rec = varargin{2};
            channel = varargin{3};
            contrast = "normal";

        case 1
            LFP_raw = obj.streaming_parameters.time_domain.data;
            for c = 1:numel(LFP_raw)

                if length(LFP_raw{c}(1,:)) == 2

                    tms = (0:numel(LFP_raw{c}(:,1))-1)/sampling_freq_Hz;
                    tms_right = (0:numel(LFP_raw{c}(:,2))-1)/sampling_freq_Hz;

                    [~, f_raw, t_raw, p_raw] = spectrogram(LFP_raw{c}(:,1), window, noverlap, fmin:0.5:fmax, sampling_freq_Hz, 'yaxis');
                    if normalizePower == 1
                        power2plot_raw = 10*log10(p_raw./mean(p_raw, 2));
                    else
                        power2plot_raw = 10*log10(p_raw);
                    end

                    [~, f_filtered, t_filtered, p_filtered] = spectrogram(LFP_raw{c}(:,2), window, noverlap, fmin:0.5:fmax, sampling_freq_Hz, 'yaxis');
                    if normalizePower == 1
                        power2plot_filtered = 10*log10(p_filtered./mean(p_filtered, 2));
                    else
                        power2plot_filtered = 10*log10(p_filtered);
                    end

                    [~, f_3, t_3, p_3] = spectrogram(LFP_filtered{c}(:,1), window, noverlap, fmin:0.5:fmax, sampling_freq_Hz, 'yaxis');
                    if normalizePower == 1
                        power2plot_3 = 10*log10(p_3./mean(p_3, 2));
                    else
                        power2plot_3 = 10*log10(p_3);
                    end

                    [~, f_4, t_4, p_4] = spectrogram(LFP_filtered{c}(:,2), window, noverlap, fmin:0.5:fmax, sampling_freq_Hz, 'yaxis');
                    if normalizePower == 1
                        power2plot_4 = 10*log10(p_4./mean(p_4, 2));
                    else
                        power2plot_4 = 10*log10(p_4);
                    end

                    %figure
                    fig = figure;
                    new_position = [16, 48, 1425, 727];
                    set(fig, 'position', new_position);
                    subplot(2,4,1);
                    plot(tms, LFP_raw{c}(:,1));
                    ylabel( ' Magnitude [\muVp]' );
                    title('Raw Signal channel: ' );
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
                    xlabel('Time [sec]');
                    ax1 = gca;
                    subplot(2,4,2)
                    %filtered left
                    plot(tms,LFP_filtered{c}(:,1));
                    ylabel( ' Magnitude [\muVp]' );
                    title('Filtered signal channel: ' );
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
                    xlabel('Time [sec]');
                    subplot(2,4,3);
                    %spectogram left raw
                    imagesc( t_raw, f_raw, power2plot_raw)
                    xlabel( 'Time [s]')
                    ylabel('Frequency [Hz]')
                    set(gca, 'YDir','normal')
                    c = colorbar;
                    c.Label.String = 'Power/Frequency [dB/Hz]';
                    dmax = max( quantile(power2plot_raw, 0.9));
                    dmin = min( quantile(power2plot_raw, 0.1));
                    caxis([dmin dmax])
                    title('Spectrogram Raw Signal')
                    subplot(2,4,4);
                    %spectogram left filt
                    imagesc( t_3, f_3, power2plot_3)
                    xlabel( 'Time [s]')
                    ylabel('Frequency [Hz]')
                    set(gca, 'YDir','normal')
                    c = colorbar;
                    c.Label.String = 'Power/Frequency [dB/Hz]';
                    dmax = max( quantile(power2plot_3, 0.9));
                    dmin = min( quantile(power2plot_3, 0.1));
                    caxis([dmin dmax])
                    title('Spectogram Filtered Signal')
                    subplot(2,4,5);
                    plot(tms_right, LFP_raw{c}(:,2));
                    ylabel( ' Magnitude [\muVp]' );
                    title('Raw signal channel: ' );
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,2)), 'Interpreter', 'none' );
                    xlabel('Time [sec]');
                    ax1 = gca;
                    subplot(2,4,6);
                    %filtered right
                    plot(tms_right,LFP_filtered{c}(:,2));
                    ylabel( ' Magnitude [\muVp]' );
                    title('Filtered signal channel: ' );
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,2)), 'Interpreter', 'none' );
                    xlabel('Time [sec]');
                    subplot(2,4,7)
                    %spectogram right raw
                    imagesc( t_filtered, f_filtered, power2plot_filtered)
                    xlabel( 'Time [s]')
                    ylabel('Frequency [Hz]')
                    set(gca, 'YDir','normal')
                    c = colorbar;
                    c.Label.String = 'Power/Frequency [dB/Hz]';
                    dmax = max( quantile(power2plot_filtered, 0.9));
                    dmin = min( quantile(power2plot_filtered, 0.1));
                    caxis([dmin dmax])
                    title('Spectogram Raw Signal')
                    subplot(2,4,4);
                    %spectogram right filt
                    imagesc( t_4, f_4, power2plot_4)
                    xlabel( 'Time [s]')
                    ylabel('Frequency [Hz]')
                    set(gca, 'YDir','normal')
                    c = colorbar;
                    c.Label.String = 'Power/Frequency [dB/Hz]';
                    dmax = max( quantile(power2plot_4, 0.9));
                    dmin = min( quantile(power2plot_4, 0.1));
                    caxis([dmin dmax])
                    title('Spectrogram Filtered Signal')

                elseif length(LFP_raw{c}(1,:)) == 1
                    disp('Only one hemisphere was available');
                    % x axis available hemisphere
                    tms = (0:numel(LFP_raw{c}(:,1))-1)/sampling_freq_Hz;

                    [~, f_raw, t_raw, p_raw] = spectrogram(LFP_raw{c}(:,1), window, noverlap, fmin:0.5:fmax, sampling_freq_Hz, 'yaxis');
                    if normalizePower == 1
                        power2plot_raw = 10*log10(p_raw./mean(p_raw, 2));
                    else
                        power2plot_raw = 10*log10(p_raw);
                    end

                    [~, f_3, t_3, p_3] = spectrogram(LFP_filtered{c}(:,1), window, noverlap, fmin:0.5:fmax, sampling_freq_Hz, 'yaxis');
                    if normalizePower == 1
                        power2plot_3 = 10*log10(p_3./mean(p_3, 2));
                    else
                        power2plot_3 = 10*log10(p_3);
                    end

                    %figure
                    fig = figure;
                    new_position = [16, 48, 1425, 727];
                    set(fig, 'position', new_position);
                    subplot(1,4,1);
                    plot(tms, LFP_raw{c}(:,1));
                    ylabel( ' Magnitude [\muVp]' );
                    axis tight;
                    title('Raw signal of available Hem ' );
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
                    xlabel('Time [sec]');
                    ax1 = gca;
                    disp(['Available channel:' channel_names]);
                    subplot(1,4,2);
                    plot(tms,LFP_filtered{c}(:,1));
                    ylabel( ' Magnitude [\muVp]' );
                    title('Filtered signal channel: ' );
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
                    xlabel('Time [sec]');
                    subplot(1,4,3);
                    imagesc( t_raw, f_raw, power2plot_raw)
                    xlabel( 'Time [s]')
                    ylabel('Frequency [Hz]')
                    set(gca, 'YDir','normal')
                    c = colorbar;
                    c.Label.String = 'Power/Frequency [dB/Hz]';
                    dmax = max( quantile(power2plot_raw, 0.9));
                    dmin = min( quantile(power2plot_raw, 0.1));
                    caxis([dmin dmax])
                    title('Spectrogram Raw Signal')
                    subplot(1,4,4);
                    %spectogram left filt
                    imagesc( t_3, f_3, power2plot_3)
                    xlabel( 'Time [s]')
                    ylabel('Frequency [Hz]')
                    set(gca, 'YDir','normal')
                    c = colorbar;
                    c.Label.String = 'Power/Frequency [dB/Hz]';
                    dmax = max( quantile(power2plot_3, 0.9));
                    dmin = min( quantile(power2plot_3, 0.1));
                    caxis([dmin dmax])
                    title('Spectrogram Filtered Signal')

                end

            end
            disp(['Filter type: ' cell2mat(obj.streaming_parameters.filtered_data.filter_type{end}), newline...
                'Lower bound: ', num2str(obj.streaming_parameters.filtered_data.low_bound{end}), newline,...
                'Upper bound: ', num2str(obj.streaming_parameters.filtered_data.up_bound{end})]);
    end

end


LFP_raw = obj.streaming_parameters.time_domain.data{rec}(:,channel);

if filter_indx == -1
    LFP_filtered = obj.streaming_parameters.filtered_data.data{end};
else
    LFP_filtered = obj.streaming_parameters.filtered_data.data{filter_indx};
end
LFP_filtered = LFP_filtered{rec}(:,channel);

tms = (0:numel( LFP_raw )-1)/sampling_freq_Hz;

[~, f_raw, t_raw, p_raw] = spectrogram(LFP_raw, window, noverlap, fmin:0.5:fmax, sampling_freq_Hz, 'yaxis');
if normalizePower == 1
    power2plot_raw = 10*log10(p_raw./mean(p_raw, 2));
else
    power2plot_raw = 10*log10(p_raw);
end

[~, f_filtered, t_filtered, p_filtered] = spectrogram(LFP_filtered, window, noverlap, fmin:0.5:fmax, sampling_freq_Hz, 'yaxis');
if normalizePower == 1
    power2plot_filtered = 10*log10(p_filtered./mean(p_filtered, 2));
else
    power2plot_filtered = 10*log10(p_filtered);
end

cla( ax(1), 'reset');
plot( ax(1), tms, LFP_raw);
ylabel( ax(1), ' Magnitude [\muVp]' );
title(ax(1), 'Raw Signal ' );
xlabel( ax(1), 'Time [sec]');

cla( ax(2), 'reset');
plot( ax(2), tms, LFP_filtered);
ylabel( ax(2), ' Magnitude [\muVp]' );
title( ax(2), 'Filtered signal ' );
xlabel( ax(2), 'Time [sec]');

cla(ax(3), 'reset');
imagesc( ax(3), t_raw, f_raw, power2plot_raw);
xlabel( ax(3), 'Time [sec]');
set(ax(3), 'YDir','normal')
ylabel( ax(3), 'Frequency [Hz]');
rec = colorbar( ax(3) );
rec.Label.String = 'Power/Frequency [dB/Hz]';
switch contrast
    case "normal"
        dmax = max(quantile(power2plot_raw, 0.9));
    case "high"
        dmax = min(5*(floor(max(quantile(power2plot_raw, 0.9),[],'all')/5)-1), 10);
end
dmin = -40;
clim( ax(3), [dmin dmax]);
title( ax(3), 'Spectrogram Raw Signal');

cla(ax(4), 'reset');
imagesc( ax(4), t_filtered, f_filtered, power2plot_filtered);
xlabel( ax(4), 'Time [sec]');
set(ax(4), 'YDir','normal')
ylabel( ax(4), 'Frequency [Hz]');
rec = colorbar( ax(4) );
rec.Label.String = 'Power/Frequency [dB/Hz]';
switch contrast
    case "normal"
        dmax = max(quantile(power2plot_filtered, 0.9));
    case "high"
        dmax = min(5*(floor(max(quantile(power2plot_filtered, 0.9),[],'all')/5)-1), 10);
end
dmin = -40;
clim( ax(4), [dmin dmax]);
title( ax(4), 'Spectrogram Filtered Signal');

end