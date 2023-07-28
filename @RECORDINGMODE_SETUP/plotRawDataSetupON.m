function plotRawDataSetupON( obj, varargin )
% PLOTRAWDATASETUPON Plot setup ON LFP recordings raw data and fourier transform
%
% Syntax:
%   PLOTRAWDATASETUPON( obj, ax, channel );
%
% Input parameters:
%    * obj - object containg data
%    * ax (optional) - axis where you want to plot
%    * channel
%
% Example:
%   obj.PlotRawDataSetupON();
%   PLOTRAWDATASETUPON( obj );
%   PLOTRAWDATASETUPON( obj, channel );
%   PLOTRAWDATASETUPON( obj, ax, channel );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: https://doi.org/10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

%Stim ON
LFP_originalData_ON = obj.setup_parameters.stim_on.data;
time_ON = obj.setup_parameters.stim_on.time';
sampling_freq_Hz = obj.setup_parameters.stim_on.fs(1); % In survey mode, sampling frequency is the same for all recordings.
Nyquist = 0.5*sampling_freq_Hz;

LFP_aux = {};
for channel = 1:numel(LFP_originalData_ON)
    for d = 1:numel(LFP_originalData_ON{channel}(1,:))
        LFP_aux{end+1} = LFP_originalData_ON{channel}(:,d);
    end
end

% Parse input variables
switch nargin
    case 3
        % Get and plot setup OFF recording of a specified channel in specified axis
        ax = varargin{1};
        channel = varargin{2};

        y = LFP_aux{channel};

        s1 = length(y);
        n = 250;
        m  = s1 - mod(s1, n);
        freq_set = 0;
        window_overlap = 2;
        window_welch = hann(sampling_freq_Hz);
        window_fft = zeros(window_overlap*m/n-(window_overlap-1), (n+6)/2);
        for i = 1:window_overlap*m/n-(window_overlap-1)
            y_clean = detrend(y((i-1)*n/window_overlap+1:(i-1)*n/window_overlap+n));
            Y = fft( [y_clean.*window_welch; zeros(6,1)]);
            L = round( length(Y)/2 );
            window_fft(i,:) = abs( Y(1:L) )/L; % CORRECTION: "/L"
            if ~freq_set
                freqs = linspace( Nyquist/L, Nyquist, L ) - Nyquist/L;
                freq_set = 1;
            end
        end
        signal_FFT_abs = 2.3*mean(window_fft, 1);

        %         figure;
        %         subplot(2,1,1);
        %         plot(freqs, signal_FFT_abs);
        %         xlabel('Frequency [Hz]');
        %         ylabel('Amplitude [\muVp]');
        %         title('FFT method');
        %
        %         y_clean = detrend(y);
        %         window_welch = hann(sampling_freq_Hz);
        %         [Pxx, F] = pwelch([y_clean], window_welch, 0.5*sampling_freq_Hz, 256, sampling_freq_Hz);
        %         signal_FFT_abs = Pxx;
        %         freqs = round(F,2);
        %
        %         subplot(2,1,2);
        %         plot(freqs, sqrt(signal_FFT_abs));
        %         xlabel('Frequency [Hz]');
        %         ylabel(ax(2), 'Amplitude [\muVp]');
        %         title('P-welch method');

        cla( ax(1), 'reset');
        plot(ax (1), time_ON{ceil(channel/2)}, LFP_aux{channel});
        ylabel(ax (1), 'Amplitude [\muVp]');
        xlabel(ax (1), 'Time [s]');
        title(ax (1), 'Raw signal Stim ON ');

        cla( ax(2), 'reset');
        plot( ax(2), freqs, signal_FFT_abs );
        xlabel( ax(2), 'Frequency [Hz]' );
        ylabel( ax(2), 'Amplitude [\muVp]' );
        title( ax(2), 'FFT Stim ON' );


    case 2
        % Get and plot setup OFF recording of a specified channel
        channel = varargin{1};

        y =  LFP_aux{channel};

        s1 = length(y);
        n = 250;
        m  = s1 - mod(s1, n);
        freq_set = 0;
        window_overlap = 2;
        window_welch = hann(sampling_freq_Hz);
        window_fft = zeros(window_overlap*m/n-(window_overlap-1), (n+6)/2);
        for i = 1:window_overlap*m/n-(window_overlap-1)
            y_clean = detrend(y((i-1)*n/window_overlap+1:(i-1)*n/window_overlap+n));
            Y = fft( [y_clean.*window_welch; zeros(6,1)]);
            L = round( length(Y)/2 );
            window_fft(i,:) = abs( Y(1:L) )/L; % CORRECTION: "/L"
            if ~freq_set
                freqs = linspace( Nyquist/L, Nyquist, L ) - Nyquist/L;
                freq_set = 1;
            end
        end
        signal_FFT_abs = 2.3*mean(window_fft, 1);

        %         y_clean = detrend(y);
        %         Y = fft( y_clean );
        %         L = round( length(Y)/2 );
        %         signal_FFT_abs   = abs( Y(1:L) )/L; % CORRECTION: "/L"
        %         freqs   = linspace( 0, Nyquist, L );

        figure;
        subplot(2,1,1)
        plot(time_ON{ceil(channel/2)}, LFP_aux{channel});
        ylabel('Amplitude [\muVp]');
        xlabel('Time [s]');
        title('Raw signal Stim ON');
        sgtitle( char(obj.setup_parameters.stim_on.channel_names{channel}), 'Interpreter', 'none' );
        subplot(2,1,2)
        plot( freqs, signal_FFT_abs );
        xlabel( 'Frequency [Hz]' );
        ylabel( 'Amplitude [\muVp]' );
        title( 'FFT Stim ON ' );

    case 1
        for channel = 1:numel(LFP_originalData_ON(1,:))

            y =  LFP_aux{channel};

            s1 = length(y);
            n = 250;
            m  = s1 - mod(s1, n);
            freq_set = 0;
            window_overlap = 2;
            window_welch = hann(sampling_freq_Hz);
            window_fft = zeros(window_overlap*m/n-(window_overlap-1), (n+6)/2);
            for i = 1:window_overlap*m/n-(window_overlap-1)
                y_clean = detrend(y((i-1)*n/window_overlap+1:(i-1)*n/window_overlap+n));
                Y = fft( [y_clean.*window_welch; zeros(6,1)]);
                L = round( length(Y)/2 );
                window_fft(i,:) = abs( Y(1:L) )/L; % CORRECTION: "/L"
                if ~freq_set
                    freqs = linspace( Nyquist/L, Nyquist, L ) - Nyquist/L;
                    freq_set = 1;
                end
            end
            signal_FFT_abs = 2.3*mean(window_fft, 1);
            %             y_clean = detrend(y);
            %             Y = fft( y_clean );
            %             L = round( length(Y)/2 );
            %             signal_FFT_abs   = abs( Y(1:L) )/L; % CORRECTION: "/L"
            %             freqs   = linspace( 0, Nyquist, L );

            figure;
            subplot(2,1,1)
            plot(time_ON{ceil(channel/2)}, LFP_aux{channel});
            ylabel('Amplitude [\muVp]');
            xlabel('Time [s]');
            title('Raw signal Stim ON ');
            subtitle( char(obj.setup_parameters.stim_on.channel_names{channel}) , 'Interpreter', 'none');
            subplot(2,1,2)
            plot( freqs, signal_FFT_abs );
            xlabel( 'Frequency [Hz]' );
            ylabel( 'Amplitude [\muVp]' );
            title( 'FFT Stim ON ' );

        end
    otherwise
end

end
