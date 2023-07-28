function plotRawDataSetupOFF( obj, varargin )
% PLOTRAWDATASETUPOFF Plot setup OFF LFP recordings raw data and fourier transform
%
% Syntax:
%   PLOTRAWDATASETUPOFF( obj, ax, channel );
%
% Input parameters:
%    * obj - object containg data
%    * ax (optional) - axis where you want to plot
%    * channel
%
% Example:
%   obj.PlotRawDataSetupOFF();
%   PLOTRAWDATASETUPOFF( obj );
%   PLOTRAWDATASETUPOFF( obj, channel );
%   PLOTRAWDATASETUPOFF( obj, ax, channel );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: https://doi.org/10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Stim OFF
LFP_originalData_OFF = obj.setup_parameters.stim_off.data;
time_OFF = obj.setup_parameters.stim_off.time';
sampling_freq_Hz = obj.setup_parameters.stim_off.fs(1); % In survey mode, sampling frequency is the same for all recordings.
Nyquist = 0.5*sampling_freq_Hz;

% Parse input variables
switch nargin
    case 3
        % Get and plot setup OFF recording of a specified channel in specified axis
        ax = varargin{1};
        channel = varargin{2};

        y =  LFP_originalData_OFF(:,channel);
        
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

        cla( ax(1), 'reset');
        plot(ax(1), time_OFF, LFP_originalData_OFF(:,channel));
        ylabel(ax(1), 'Amplitude [\muVp]');
        xlabel(ax(1), 'Time [s]');
        title(ax(1), 'Raw signal Stim OFF ');

        cla( ax(2), 'reset');
        plot( ax(2), freqs, signal_FFT_abs );
        xlabel( ax(2), 'Frequency [Hz]' );
        ylabel( ax(2), 'Amplitude [\muVp]' );
        title( ax(2), 'FFT Stim OFF' );

    case 2
        % Get and plot setup OFF recording of a specified channel
        channel = varargin{1};

        y =  LFP_originalData_OFF(:,channel);
        y_clean = detrend(y);
        Y = fft( y_clean );
        L = round( length(Y)/2 );
        signal_FFT_abs   = abs( Y(1:L) )/L; % CORRECTION: "/L"
        freqs   = linspace( 0, Nyquist, L );
        
        figure;
        subplot(2,1,1)
        plot(time_OFF, LFP_originalData_OFF(:,channel));
        ylabel('Amplitude [\muVp]');
        xlabel('Time [s]');
        title('Raw signal Stim OFF ');
        sgtitle( char(obj.setup_parameters.stim_off.channel_names{channel}), 'Interpreter', 'none' );
        subplot(2,1,2)
        plot( freqs, signal_FFT_abs );
        xlabel( 'Frequency [Hz]' );
        ylabel( 'Amplitude [\muVp]' );
        title( 'FFT Stim OFF ' );

    case 1
        % Plot all setup OFF recordings
        for channel = 1:numel(LFP_originalData_OFF(1,:))

            y =  LFP_originalData_OFF(:,channel);
            y_clean = detrend(y);
            Y = fft( y_clean );
            L = round( length(Y)/2 );
            signal_FFT_abs   = abs( Y(1:L) )/L; % CORRECTION: "/L"
            freqs   = linspace( 0, Nyquist, L );

            figure;
            subplot(2,1,1)
            plot(time_OFF, LFP_originalData_OFF(:,channel));
            ylabel('Amplitude [\muVp]');
            xlabel('Time [s]');
            title('Raw signal Stim OFF ');
            subtitle( char(obj.setup_parameters.stim_off.channel_names{channel}) , 'Interpreter', 'none');
            subplot(2,1,2)
            plot( freqs, signal_FFT_abs );
            xlabel( 'Frequency [Hz]' );
            ylabel( 'Amplitude [\muVp]' );
            title( 'FFT Stim OFF ' );
            
        end
    otherwise
end

end