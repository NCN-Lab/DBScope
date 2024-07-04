function plotPWelch ( obj, varargin )
% PLOTWELCH Plot Pwelch (PSD along frequencies) for each channel
% Use LFP online streaming recordings
%
% Syntax:
%   PLOTWELCH( obj, varargin );
%
% Input parameters:
%    * obj - object containg data
%    * ax (optional) - axis where you want to plot
%    * data_type (optional) - type of input data (raw, ecg cleaned or filtered)
%    * rec (optional) - recording index
%    * channel (optional) - hemisphere
%
% Example:
%   PLOTWELCH( obj );
%   PLOTWELCH( obj, ax, data_type, rec, channel );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

color = lines(2);

% Get sampling frequency information
sampling_freq_Hz = obj.streaming_parameters.time_domain.fs;
window = round(2*sampling_freq_Hz); %default
noverlap = round(window*0.5); %default
freqResolution = 0.1; %Hz
fmin = 1; %Hz
fmax = sampling_freq_Hz/2; %Hz

switch nargin
    case 5
        ax          = varargin{1};
        data_type   = varargin{2};
        rec         = varargin{3};
        channel     = varargin{4};

        switch data_type
            case 'Raw'
                LFP_ordered = obj.streaming_parameters.time_domain.data;
            case 'Latest Filtered'
                LFP_ordered = obj.streaming_parameters.filtered_data.data{end};
            case 'ECG Cleaned'
                LFP_ordered = obj.streaming_parameters.time_domain.ecg_clean;
        end
        
        [Pxx, F] = pwelch(LFP_ordered{rec}(:,channel), window, noverlap, fmin:freqResolution:fmax, sampling_freq_Hz);
        
        cla( ax, 'reset' );
        area( ax, [13 35], [1.3*max(Pxx) 1.3*max(Pxx)], 'FaceColor', color(1,:), ...
            'FaceAlpha', 0.2, 'EdgeColor', 'none', 'PickableParts', 'none');
        hold( ax, 'on');
        plot( ax, F, Pxx, 'LineWidth', 1, 'Color', color(1,:));
        ylabel( ax, 'PSD [\muVp^{2}/Hz]');
        xlabel( ax, 'Frequency [Hz]');
        title( ax, 'Welch Power Spectral Density Estimate');
        xticks( ax, [0, 13, 35, 60, sampling_freq_Hz/2]);
        xlim( ax, [0 sampling_freq_Hz/2] );
        ylim( ax, [0 1.3*max(Pxx)] );
        
    case 1

        % Check if data is filtered and select data
        if isempty (obj.streaming_parameters.filtered_data.data)
            disp('Data is not filtered')
            answer = questdlg('Which data do you want to visualize?', ...
                '', ...
                'Raw','ECG clean data','ECG clean data');
            switch answer
                case 'Raw'
                    LFP_ordered = obj.streaming_parameters.time_domain.data;
                case 'ECG clean data'
                    LFP_ordered = obj.streaming_parameters.time_domain.ecg_clean;
            end


            for c = 1:numel(LFP_ordered)

                if length(LFP_ordered{c}(1,:)) == 2

                    % Apply PWELCH
                    [Pxx_left, F_left] = pwelch(LFP_ordered{c}(:,1), window, noverlap, fmin:freqResolution:fmax, sampling_freq_Hz);
                    [Pxx_right, F_right] = pwelch(LFP_ordered{c}(:,2), window, noverlap, fmin:freqResolution:fmax, sampling_freq_Hz);

                    figure
                    subplot(2,1,1)
                    plot(F_left, Pxx_left, 'LineWidth', 1)
                    ylabel('Amplitude [\muVp]')
                    xlabel('Frequency [Hz]')
                    title('PWelch channel: ' )
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
                    subplot(2,1,2)
                    plot(F_right, Pxx_right, 'LineWidth', 1)
                    ylabel('Amplitude [\muVp]')
                    xlabel('Frequency [Hz]')
                    title('PWelch channel: ' )
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,2)), 'Interpreter', 'none' );


                elseif length(LFP_ordered{c}(1,:)) == 1

                    % Apply PWELCH
                    [Pxx_left, F_left] = pwelch(LFP_ordered{c}(:,1), window, noverlap, fmin:freqResolution:fmax, sampling_freq_Hz);

                    figure % available hemisphere
                    plot(F_left, Pxx_left, 'LineWidth', 1)
                    ylabel('Amplitude [\muVp]')
                    xlabel('Frequency [Hz]')
                    title('PWelch channel: ' )
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );

                    disp('Only one hemispheres available')

                end

            end

        else
            disp('Data is filtered')
            answer = questdlg('Which data do you want to visualize?', ...
                '', ...
                'Raw/ECG clean data','Latest Filtered','Latest Filtered');
            %Handle response
            switch answer
                case'Raw/ECG clean data'
                    answer = questdlg('Which data do you want to visualize?', ...
                        '', ...
                        'Raw','ECG clean data','ECG clean data');
                    switch answer
                        case 'Raw'
                            LFP_ordered = obj.streaming_parameters.time_domain.data;
                        case 'ECG clean data'
                            LFP_ordered = obj.streaming_parameters.time_domain.ecg_clean;
                    end
                    for c = 1:numel(LFP_ordered)

                        if length(LFP_ordered{c}(1,:)) == 2

                            % Apply PWELCH
                            [Pxx_left, F_left] = pwelch(LFP_ordered{c}(:,1), window, noverlap, fmin:freqResolution:fmax, sampling_freq_Hz);
                            [Pxx_right, F_right] = pwelch(LFP_ordered{c}(:,2), window, noverlap, fmin:freqResolution:fmax, sampling_freq_Hz);

                            figure
                            subplot(2,1,1)
                            plot(F_left, Pxx_left, 'LineWidth', 1)
                            ylabel('Amplitude [\muVp]')
                            xlabel('Frequency [Hz]')
                            title('PWelch channel: ' )
                            subplot(2,1,2)
                            plot(F_right, Pxx_right, 'LineWidth', 1)
                            ylabel('Amplitude [\muVp]')
                            xlabel('Frequency [Hz]')
                            title('PWelch channel: ')
                            subtitle(char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );


                        elseif length(LFP_ordered{c}(1,:)) == 1

                            % Apply PWELCH
                            [Pxx_left, F_left] = pwelch(LFP_ordered{c}(:,1), window, noverlap, fmin:freqResolution:fmax, sampling_freq_Hz);

                            figure % available hemisphere
                            plot(F_left, Pxx_left, 'LineWidth', 1)
                            ylabel('Amplitude [\muVp]')
                            xlabel('Frequency [Hz]')
                            title('PWelch channel: ' )
                            subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );

                            disp('Only one hemispheres available')

                        end
                    end

                case 'Latest Filtered'
                    LFP_ordered = obj.streaming_parameters.filtered_data.data{end};

                    for c = 1:numel(LFP_ordered)

                        if length(LFP_ordered{c}(1,:)) == 2

                            % Apply PWELCH
                            [Pxx_left, F_left] = pwelch(LFP_ordered{c}(:,1), window, noverlap, fmin:freqResolution:fmax, sampling_freq_Hz);
                            [Pxx_right, F_right] = pwelch(LFP_ordered{c}(:,2), window, noverlap, fmin:freqResolution:fmax, sampling_freq_Hz);

                            figure
                            subplot(2,1,1)
                            plot(F_left, Pxx_left, 'LineWidth', 1)
                            ylabel('Amplitude [\muVp]')
                            xlabel('Frequency [Hz]')
                            title('PWelch channel: ' )
                            subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
                            subplot(2,1,2)
                            plot(F_right, Pxx_right, 'LineWidth', 1)
                            ylabel('Amplitude [\muVp]')
                            xlabel('Frequency [Hz]')
                            title('PWelch channel: ' )
                            subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );

                        elseif length(LFP_ordered{c}(1,:)) == 1

                            % Apply PWELCH
                            [Pxx_left, F_left] = pwelch(LFP_ordered{c}(:,1), window, noverlap, fmin:freqResolution:fmax, sampling_freq_Hz);

                            figure % available hemisphere
                            plot(F_left, Pxx_left, 'LineWidth', 1)
                            ylabel('Amplitude [\muVp]')
                            xlabel('Frequency [Hz]')
                            title('PWelch channel: ')
                            subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );

                            disp('Only one hemispheres available')

                        end
                    end
            end
        end

end

end
