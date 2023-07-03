function plotFiltDataSurvey( obj, varargin )
% Plots previously filtered data from Survey recordings.
%
% Syntax:
%    PLOTFILTDATASURVEY( obj );
%    PLOTFILTDATASURVEY( obj, rec );
%    PLOTFILTDATASURVEY( obj, rec, channel );
%    PLOTFILTDATASURVEY( obj, ax, rec, channel );
%
% Input parameters:
%    * obj - object containg survey data
%    * ax (optional) - axis where you want to plot
%    * rec (optional) - recording (i.e., electrode combination)
%    * channel (optional) - hemisphere
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Confirm if the data was filtered
if isempty ( obj.survey_parameters.filtered_data.data )
    disp( 'Data is not filtered' );
    return
end
disp( 'Data is filtered' );
disp( ['Filter type: ' cell2mat(obj.survey_parameters.filtered_data.filter_type{end}), newline...
    'Lower bound: ', num2str(obj.survey_parameters.filtered_data.low_bound{end}), newline,...
    'Upper bound: ', num2str(obj.survey_parameters.filtered_data.up_bound{end})] );

% Get data & sampling frequency
LFP_raw = obj.survey_parameters.time_domain.data;
time = obj.survey_parameters.time_domain.time;
LFP_filtered = obj.survey_parameters.filtered_data.data{end};
sampling_freq_Hz = cell2mat(obj.survey_parameters.time_domain.fs(1)); % In survey mode, sampling frequency is the same for all recordings.
Nyquist = 0.5*sampling_freq_Hz;

% Parse input variables
switch nargin
    case 4
        % Get and plot raw data and FFT profile in specified axes from the specified
        % record and channel
        ax = varargin{1};
        rec = varargin{2};
        channel = varargin{3};
        
        % Fourier Transform Raw Signal
        y = LFP_raw{rec}(:,channel);
        tms = time{rec};
        y_clean = detrend(y);
        Y = fft( y_clean );
        L = round( length(Y)/2 );
        signal_FFT_abs = abs( Y(1:L) )/L; % CORRECTION: "/L"
        freqs = linspace( 0, Nyquist, L );

        % Fourier Transform Filtered Signal
        y_filt = LFP_filtered{rec}(:,channel);
        y_clean_filt = detrend(y_filt);
        Y_filt = fft( y_clean_filt );
        L_filt = round( length(Y_filt)/2 );
        signal_FFT_abs_filt = abs( Y_filt(1:L_filt) )/L_filt; % CORRECTION: "/L"
        freqs_filt = linspace( 0, Nyquist, L_filt );

        plot( ax(1), tms, y );
        xlabel( ax(1), 'Time [s]' );
        ylabel( ax(1), 'Amplitude [\muVp]' );
        title( ax(1), 'Raw signal' );

        plot( ax(2), freqs, signal_FFT_abs );
        xlabel( ax(2), 'Frequency [Hz]' );
        ylabel( ax(2), 'Amplitude [\muVp]' );
        xlim( ax(2), [min(freqs) max(freqs)]);
        ylim( ax(2), [min(signal_FFT_abs) 1.1*max(signal_FFT_abs)]);
        title( ax(2), 'Fourier Transform Raw signal' );

        plot( ax(3), tms , y_filt );
        xlabel( ax(3), 'Time [s]' );
        ylabel( ax(3), 'Amplitude [\muVp]' );
        title( ax(3), 'Filtered signal' );

        plot( ax(4), freqs_filt , signal_FFT_abs_filt );
        xlabel( ax(4), 'Frequency [Hz]' );
        ylabel( ax(4), 'Amplitude [\muVp]' );
        title( ax(4), 'Fourier Transform Filtered signal' );

        linkaxes([ax(2) ax(4)], 'xy');

    case 3
        % Get and plot raw data and FFT profile from the specified record and channel
        rec = varargin{1};
        channel = varargin{2};

        % Fourier Transform Raw Signal
        y = LFP_raw{rec}(:,channel);
        tms = time{rec};
        y_clean = detrend(y);
        Y = fft( y_clean );
        L = round( length(Y)/2 );
        signal_FFT_abs = abs( Y(1:L) )/L; % CORRECTION: "/L"
        freqs = linspace( 0, Nyquist, L );

        % Fourier Transform Filtered Signal
        y_filt = LFP_filtered{rec}(:,channel);
        y_clean_filt = detrend(y_filt);
        Y_filt = fft( y_clean_filt );
        L_filt = round( length(Y_filt)/2 );
        signal_FFT_abs_filt = abs( Y_filt(1:L_filt) )/L_filt; % CORRECTION: "/L"
        freqs_filt = linspace( 0, Nyquist, L_filt );
        
        figure;
        sgtitle( char(obj.survey_parameters.time_domain.channel_names{rec}{channel}), 'Interpreter', 'none' );
        subplot(2,2,1);
        plot( tms, y );
        xlabel( 'Time [s]' );
        ylabel( 'Amplitude [\muVp]' );
        title( 'Raw signal' );
        
        subplot(2,2,2);
        plot( freqs, signal_FFT_abs );
        xlabel( 'Frequency [Hz]' );
        ylabel( 'Amplitude [\muVp]' );
        title( 'Fourier Transform Raw signal' );
        
        subplot(2,2,3);
        plot( tms , y_filt );
        xlabel( 'Time [s]' );
        ylabel( 'Amplitude [\muVp]' );
        title( 'Filtered signal' );
        
        subplot(2,2,4);
        plot( freqs_filt , signal_FFT_abs_filt );
        xlabel( 'Frequency [Hz]' );
        ylabel( 'Amplitude [\muVp]' );
        title( 'Fourier Transform Filtered signal' );

    case 2
        % Get and plot raw data and FFT profiles from the specified record
        rec = varargin{1};

        for channel = 1:numel(LFP_raw{rec}(1,:))
            % Fourier Transform Raw Signal
            y = LFP_raw{rec}(:,channel);
            tms = time{rec};
            y_clean = detrend(y);
            Y = fft( y_clean );
            L = round( length(Y)/2 );
            signal_FFT_abs = abs( Y(1:L) )/L; % CORRECTION: "/L"
            freqs = linspace( 0, Nyquist, L );

            % Fourier Transform Filtered Signal
            y_filt = LFP_filtered{rec}(:,channel);
            y_clean_filt = detrend(y_filt);
            Y_filt = fft( y_clean_filt );
            L_filt = round( length(Y_filt)/2 );
            signal_FFT_abs_filt = abs( Y_filt(1:L_filt) )/L_filt; % CORRECTION: "/L"
            freqs_filt = linspace( 0, Nyquist, L_filt );

            figure;
            sgtitle( char(obj.survey_parameters.time_domain.channel_names{rec}{channel}), 'Interpreter', 'none' );
            subplot(2,2,1);
            plot( tms, y );
            xlabel( 'Time [s]' );
            ylabel( 'Amplitude [\muVp]' );
            title( 'Raw signal' );

            subplot(2,2,2);
            plot( freqs, signal_FFT_abs );
            xlabel( 'Frequency [Hz]' );
            ylabel( 'Amplitude [\muVp]' );
            title( 'Fourier Transform Raw signal' );

            subplot(2,2,3);
            plot( tms, y_filt );
            xlabel( 'Time [s]' );
            ylabel( 'Amplitude [\muVp]' );
            title( 'Filtered signal' );

            subplot(2,2,4);
            plot( freqs_filt , signal_FFT_abs_filt );
            xlabel( 'Frequency [Hz]' );
            ylabel( 'Amplitude [\muVp]' );
            title( 'Fourier Transform Filtered signal' );
        end


    case 1
        % Get and plot raw data and FFT profiles from all channels
        for rec = 1:numel( LFP_raw )
            for channel = 1:numel( LFP_raw{rec}(1,:) )
                % Fourier Transform Raw Signal
                y = LFP_raw{rec}(:,channel);
                tms = time{rec};
                y_clean = detrend(y);
                Y = fft( y_clean );
                L = round( length(Y)/2 );
                signal_FFT_abs = abs( Y(1:L) )/L; % CORRECTION: "/L"
                freqs = linspace( 0, Nyquist, L );

                % Fourier Transform Filtered Signal
                y_filt = LFP_filtered{rec}(:,channel);
                y_clean_filt = detrend(y_filt);
                Y_filt = fft( y_clean_filt );
                L = round( length(Y_filt)/2 );
                signal_FFT_abs_filt = abs( Y_filt(1:L_filt) )/L_filt; % CORRECTION: "/L"
                freqs_filt = linspace( 0, Nyquist, L_filt );

                figure;
                sgtitle( char(obj.survey_parameters.time_domain.channel_names{rec}{channel}), 'Interpreter', 'none' );
                subplot(2,2,1);
                plot( tms, y );
                xlabel( 'Time [s]' );
                ylabel( 'Amplitude [\muVp]' );
                title( 'Raw signal' );

                subplot(2,2,2);
                plot( freqs, signal_FFT_abs );
                xlabel( 'Frequency [Hz]' );
                ylabel( 'Amplitude [\muVp]' );
                title( 'Fourier Transform Raw signal' );

                subplot(2,2,3);
                plot( tms, y_filt );
                xlabel( 'Time [s]' );
                ylabel( 'Amplitude [\muVp]' );
                title( 'Filtered signal' );

                subplot(2,2,4);
                plot( freqs_filt , signal_FFT_abs_filt );
                xlabel( 'Frequency [Hz]' );
                ylabel( 'Amplitude [\muVp]' );
                title( 'Fourier Transform Filtered signal' );

            end
        end
    
end
    
end
