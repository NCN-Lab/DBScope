function plotRawDataLFPMontage( obj, varargin )
% Plots LFPMontage recordings.
%
% Syntax:
%    PLOTRAWDATALFPMONTAGE( obj );
%    PLOTRAWDATALFPMONTAGE( obj, type );
%    PLOTRAWDATALFPMONTAGE( obj, type, rec );
%    PLOTRAWDATALFPMONTAGE( obj, ax, type, rec, channel );
%
% Input parameters:
%    * obj - object containg survey data
%    * ax (optional) - axis where you want to plot
%    * type (optional) - 'Raw' or 'Latest Filtered'
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

LFP_raw = obj.survey_parameters.time_domain.data;
time = obj.survey_parameters.time_domain.time;
sampling_freq_Hz = cell2mat(obj.survey_parameters.time_domain.fs(1)); % In survey mode, sampling frequency is the same for all recordings.
Nyquist = 0.5*sampling_freq_Hz;


if ~isempty(obj.survey_parameters.filtered_data.data)
    LFP_filtered = obj.survey_parameters.filtered_data.data{end};
end

% Parse input variables
switch nargin
    case 5
        % Get and plot data in specified axes from the specified
        % record and channel
        ax = varargin{1};
        type = varargin{2};
        record = varargin{3};
        channel = varargin{4};

        switch type
            case 'Raw'
                LFP = LFP_raw;
            case 'Latest Filtered'
                LFP = LFP_filtered;
                disp( ['Filter type: ' cell2mat(obj.survey_parameters.filtered_data.filter_type{end}), newline...
                    'Lower bound: ', num2str(obj.survey_parameters.filtered_data.low_bound{end}), newline,...
                    'Upper bound: ', num2str(obj.survey_parameters.filtered_data.up_bound{end})] );
        end

        y = LFP{record}(:,channel);

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
        plot( ax(1), time{record}, LFP{record}(:,channel));
        ylabel( ax(1),'Amplitude [\muVp]' );
        xlabel( ax(1),'Time [s]' );
        title( ax, [type ' signal '] );

        cla( ax(2), 'reset');
        plot( ax(2), freqs, signal_FFT_abs );
        xlabel( ax(2), 'Frequency [Hz]' );
        ylabel( ax(2), 'Amplitude [\muVp]' );
        title( ax(2), 'FFT Survey' );


    case 3
        % Get and plot data from the specified record
        type = varargin{1};
        record = varargin{2};

        switch type
            case 'Raw'
                LFP = LFP_raw;
            case 'Latest Filtered'
                LFP = LFP_filtered;
                disp( ['Filter type: ' cell2mat(obj.survey_parameters.filtered_data.filter_type{end}), newline...
                    'Lower bound: ', num2str(obj.survey_parameters.filtered_data.low_bound{end}), newline,...
                    'Upper bound: ', num2str(obj.survey_parameters.filtered_data.up_bound{end})] );
        end

        for channel = 1:numel( LFP{record}(1,:) )

            y = LFP{record}(:,channel);

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

            figure;
            sgtitle( char(obj.survey_parameters.time_domain.channel_names{record}{channel}), 'Interpreter', 'none' );
            subplot(2,1,1);
            plot( time{record}, LFP{record}(:,channel) );
            xlabel( 'Time [s]' );
            ylabel( 'Amplitude [\muVp]' );
            title( [type ' signal '] );
            subplot(2,1,2)
            plot( freqs, signal_FFT_abs );
            xlabel( 'Frequency [Hz]' );
            ylabel( 'Amplitude [\muVp]' );
            title( 'FFT Survey' );
        end

    case 2
        % Get and plot all data
        type = varargin{1};

        switch type
            case 'Raw'
                LFP = LFP_raw;
            case 'Latest Filtered'
                LFP = LFP_filtered;
                disp( ['Filter type: ' cell2mat(obj.survey_parameters.filtered_data.filter_type{end}), newline...
                    'Lower bound: ', num2str(obj.survey_parameters.filtered_data.low_bound{end}), newline,...
                    'Upper bound: ', num2str(obj.survey_parameters.filtered_data.up_bound{end})] );
        end
        
        for record = 1:numel( LFP )
            for channel = 1:numel( LFP{record}(1,:) )

                y = LFP{record}(:,channel);

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

                figure;
                sgtitle( char(obj.survey_parameters.time_domain.channel_names{record}{channel}), 'Interpreter', 'none' );
                subplot(2,1,1);
                plot( time{record}, LFP{record}(:,channel) );
                xlabel( 'Time [s]' );
                ylabel( 'Amplitude [\muVp]' );
                title( [type ' signal '] );
                subplot(2,1,2)
                plot( freqs, signal_FFT_abs );
                xlabel( 'Frequency [Hz]' );
                ylabel( 'Amplitude [\muVp]' );
                title( 'FFT Survey' );

            end
        end

end


end

