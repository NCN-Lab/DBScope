function plotFFTSurvey( obj, varargin )
% Plots FFT of the survey recordings.
% 
% Syntax:
%    PLOTFFTSURVEY( obj );
%    PLOTFFTSURVEY( obj, rec );
%    PLOTFFTSURVEY( obj, rec, channel );
%    PLOTFFTSURVEY( obj, ax, rec, channel );
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

% Get data & sampling frequency
LFP_ordered = obj.survey_parameters.time_domain.data;
sampling_freq_Hz = cell2mat(obj.survey_parameters.time_domain.fs(1)); % In survey mode, sampling frequency is the same for all recordings.
Nyquist = 0.5*sampling_freq_Hz;

% Parse input variables
switch nargin
    case 4
        % Get and plot FFT profile in specified axes from specfic
        % recording and channel
        ax = varargin{1};
        rec = varargin{2};
        channel = varargin{3};
        
        y =  LFP_ordered{rec}(:,channel);

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

        plot( ax, freqs, signal_FFT_abs );
        xlabel( ax, 'Frequency [Hz]' );
        ylabel( ax, 'Amplitude [\muVp]' );
        title( ax, 'Fourier Transform  ' );

    case 3
        % Get and plot FFT profile from specific recording and channel
        rec = varargin{1};
        channel = varargin{2};

        y =  LFP_ordered{rec}(:,channel);
        y_clean = detrend(y);
        Y = fft( y_clean );
        L = round( length(Y)/2 );
        signal_FFT_abs   = abs( Y(1:L) )/L; % CORRECTION: "/L"
        freqs   = linspace( 0, Nyquist, L );
        
        figure;
        plot( freqs, signal_FFT_abs );
        xlabel( 'Frequency [Hz]' );
        ylabel( 'Amplitude [\muVp]' );
        title( 'Fourier Transform  ' );
        subtitle( char(obj.survey_parameters.time_domain.channel_names{rec}{channel}), 'Interpreter', 'none' );

    case 2
        % Get and plot FFT profiles from specific recording
        rec = varargin{1};

        for channel = 1:numel(LFP_ordered{rec}(1,:))
            y =  LFP_ordered{rec}(:,channel);
            y_clean = detrend(y);
            Y = fft( y_clean );
            L = round( length(Y)/2 );
            signal_FFT_abs   = abs( Y(1:L) )/L; % CORRECTION: "/L"
            freqs   = linspace( 0, Nyquist, L );

            figure;
            plot( freqs, signal_FFT_abs );
            xlabel( 'Frequency [Hz]' );
            ylabel( 'Amplitude [\muVp]' );
            title( 'Fourier Transform  ' );
            subtitle( char(obj.survey_parameters.time_domain.channel_names{rec}{channel}), 'Interpreter', 'none' );
        end


    case 1
        % Plot FFT of all recordings
        for rec = 1:numel( LFP_ordered )
            for channel = 1:numel( LFP_ordered{rec}(1,:) )
                
                y =  LFP_ordered{rec}(:,channel);
                y_clean = detrend(y);
                Y = fft( y_clean );
                L = round( length(Y)/2 );
                signal_FFT_abs   = abs( Y(1:L) )/L; % CORRECTION: "/L"
                freqs   = linspace( 0, Nyquist, L );

                figure;
                plot( freqs, signal_FFT_abs );
                xlabel( 'Frequency [Hz]' );
                ylabel( 'Amplitude [\muVp]' );
                title( 'Fourier Transform  ' );
                subtitle( char(obj.survey_parameters.time_domain.channel_names{rec}{channel}), 'Interpreter', 'none' );

            end
        end
    
end

end