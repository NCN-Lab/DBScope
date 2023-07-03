function  plotAutoCorrVar( obj, varargin )
% Plot autocorrelation and autocovariance for LFP online streaming mode
% recording
%
% Syntax:
%   PLOTAUTOCORRVAR( obj, data_type, varargin );
%
% Input parameters:
%    * obj - object containg data
%    * data_type - type of input data (raw, ecg cleaned or filtered)
%    * ax (optional) - axis where you want to plot
%
% Example:
%   PLOTAUTOCORRVAR(  data_type, varargin );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
channel_names  = obj.streaming_parameters.time_domain.channel_names;
sampling_freq_Hz = obj.streaming_parameters.time_domain.fs;

switch nargin
    case 5
        ax = varargin{1};
        data_type = varargin{2};
        record = varargin{3};
        indx = varargin{4};

        switch data_type
            case 'Raw'
                LFP_ordered = obj.streaming_parameters.time_domain.data;
            case 'Latest Filtered'
                LFP_ordered = obj.streaming_parameters.filtered_data.data{end};
            case 'ECG Cleaned'
                LFP_ordered = obj.streaming_parameters.time_domain.ecg_clean;
        end

        LFP_aux = {};
        for d = 1:numel(LFP_ordered{record}(1,:))
            LFP_aux{end+1} = LFP_ordered{record}(:,d);
        end

        if indx == 1 % if two sides available, indx 1 = left, indx 2 = right

            [c1,lags1] = xcov( LFP_aux{1}, 'normalized'  );
            [c2,lags2]= xcorr ( LFP_aux{1}, 'normalized'  );

            cla( ax(1), 'reset');
            plot( ax(1), lags1./sampling_freq_Hz,c1, 'r' )
            title( ax(1), 'Autocovariance LFP ' )
            ylabel( ax(1), 'Amplitude [\muVp]' )
            xlabel( ax(1), 'Time [sec]' )

            cla( ax(2), 'reset');
            plot( ax(2), lags2./sampling_freq_Hz,c2, 'r' )
            title( ax(2), 'Autocorrelation LFP ' )
            ylabel( ax(2), 'Amplitude [\muVp]' )
            xlabel( ax(2), 'Time [sec]' )


        elseif indx == 2

            [c3,lags3] = xcov(  LFP_aux{2}, 'normalized' );
            [c4,lags4]= xcorr ( LFP_aux{2}, 'normalized'  );

            cla( ax(1), 'reset');
            plot( ax(1), lags3./sampling_freq_Hz,c3, 'r' )
            title( ax(1),'Autocovariance LFP ' )
            ylabel( ax(1), 'Amplitude [\muVp]' )
            xlabel( ax(1), 'Time [sec]' )

            cla( ax(2), 'reset');
            plot( ax(2), lags4./sampling_freq_Hz,c4, 'r' )
            title( ax(2), 'Autocorrelation LFP ' )
            ylabel( ax(2), 'Amplitude [\muVp]' )
            xlabel( ax(2), 'Time [sec]' )


        end

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
                [c1,lags1] = xcov( LFP_ordered{c}(:,1), 'normalized'   );
                [c2,lags2]= xcorr ( LFP_ordered{c}(:,1), 'normalized'   );
                [c3,lags3] = xcov(  LFP_ordered{c}(:,2), 'normalized'  );
                [c4,lags4]= xcorr (  LFP_ordered{c}(:,2), 'normalized'  );

                % Plot results
                figure
                subplot (2,2,1)
                plot( lags1./sampling_freq_Hz,c1, 'r' )
                title('Autocovariance LFP channel: ' )
                subtitle( channel_names{c}(:,1), 'Interpreter', 'none' );
                ylabel( 'Amplitude [\muVp]' )
                xlabel( 'Time [sec]' )
                subplot(2,2,2)
                plot( lags2./sampling_freq_Hz,c2, 'r' )
                title('Autocorrelation LFP channel: ' )
                subtitle( channel_names{c}(:,1), 'Interpreter', 'none' );
                ylabel( 'Amplitude [\muVp]' )
                xlabel( 'Time [sec]' )
                subplot (2,2,3)
                plot( lags3./sampling_freq_Hz,c3 )
                title('Autocovariance LFP channel: ' )
                subtitle( channel_names{c}(:,2), 'Interpreter', 'none' );
                ylabel( 'Amplitude [\muVp]' )
                xlabel( 'Time [sec]' )
                subplot(2,2,4)
                plot( lags4./sampling_freq_Hz,c4 )
                title('Autocorrelation LFP channel: ' )
                subtitle( channel_names{c}(:,2), 'Interpreter', 'none' );
                ylabel( 'Amplitude [\muVp]' )
                xlabel( 'Time [sec]' )

            elseif length(LFP_ordered{c}(1,:)) == 1
                [c1,lags1] = xcov( LFP_ordered{c}(:,1), 'normalized'   );
                [c2,lags2]= xcorr ( LFP_ordered{c}(:,1), 'normalized'   );

                % Plot results
                figure
                subplot (2,1,1)
                plot( lags1./sampling_freq_Hz,c1, 'r' )
                title('Autocovariance LFP channel: ' )
                subtitle( channel_names{c}(:,1), 'Interpreter', 'none' );
                ylabel( 'Amplitude [\muVp]' )
                xlabel( 'Time [sec]' )
                subplot(2,1,2)
                plot( lags2./sampling_freq_Hz,c2, 'r' )
                title('Autocorrelation LFP channel: ' )
                subtitle( channel_names{c}(:,1), 'Interpreter', 'none' );
                ylabel( 'Amplitude [\muVp]' )
                xlabel( 'Time [sec]' )

                disp('Only one hemispheres is available.')

            end

        end

    else
        disp('Data is filtered')
        answer = questdlg('Which data do you want to visualize?', ...
            '', ...
            'Raw/ECG clean data','Latest Filtered','Latest Filtered');
        % Handle response
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
                        [c1,lags1] = xcov( LFP_ordered{c}(:,1), 'normalized'   );
                        [c2,lags2]= xcorr ( LFP_ordered{c}(:,1), 'normalized'   );
                        [c3,lags3] = xcov(  LFP_ordered{c}(:,2), 'normalized'  );
                        [c4,lags4]= xcorr (  LFP_ordered{c}(:,2), 'normalized'  );

                        % Plot results
                        figure
                        subplot (2,2,1)
                        plot( lags1./sampling_freq_Hz,c1, 'r' )
                        title('Autocovariance LFP channel: ' )
                        subtitle( channel_names{c}(:,1), 'Interpreter', 'none' );
                        ylabel( 'Amplitude [\muVp]' )
                        xlabel( 'Time [sec]' )
                        subplot(2,2,2)
                        plot( lags2./sampling_freq_Hz,c2, 'r' )
                        title('Autocorrelation LFP channel: ' )
                        subtitle( channel_names{c}(:,1), 'Interpreter', 'none' );
                        ylabel( 'Amplitude [\muVp]' )
                        xlabel( 'Time [sec]' )
                        subplot (2,2,3)
                        plot( lags3./sampling_freq_Hz,c3 )
                        title('Autocovariance LFP channel: ' )
                        subtitle( channel_names{c}(:,2), 'Interpreter', 'none' );
                        ylabel( 'Amplitude [\muVp]' )
                        xlabel( 'Time [sec]' )
                        subplot(2,2,4)
                        plot( lags4./sampling_freq_Hz,c4 )
                        title('Autocorrelation LFP channel: ' )
                        subtitle( channel_names{c}(:,2), 'Interpreter', 'none' );
                        ylabel( 'Amplitude [\muVp]' )
                        xlabel( 'Time [sec]' )

                    elseif length(LFP_ordered{c}(1,:)) == 1

                        [c1,lags1] = xcov( LFP_ordered{c}(:,1), 'normalized'   );
                        [c2,lags2]= xcorr ( LFP_ordered{c}(:,1), 'normalized'   );

                        % Plot results
                        figure
                        subplot (2,1,1)
                        plot( lags1./sampling_freq_Hz,c1, 'r' )
                        title('Autocovariance LFP channel: ' )
                        subtitle( channel_names{c}(:,1), 'Interpreter', 'none' );
                        ylabel( 'Amplitude [\muVp]' )
                        xlabel( 'Time [sec]' )
                        subplot(2,1,2)
                        plot( lags2./sampling_freq_Hz,c2, 'r' )
                        title('Autocorrelation LFP channel: ' )
                        subtitle( channel_names{c}(:,1), 'Interpreter', 'none' );
                        ylabel( 'Amplitude [\muVp]' )
                        xlabel( 'Time [sec]' )

                        disp('Only one hemispheres available')

                    end

                end

            case 'Latest Filtered'
                LFP_ordered = obj.streaming_parameters.filtered_data.data{end};

                for c = 1:numel(LFP_ordered)
                    if length(LFP_ordered{c}(1,:)) == 2
                        [c1,lags1] = xcov( LFP_ordered{c}(:,1), 'normalized'   );
                        [c2,lags2]= xcorr ( LFP_ordered{c}(:,1), 'normalized'   );
                        [c3,lags3] = xcov(  LFP_ordered{c}(:,2), 'normalized'  );
                        [c4,lags4]= xcorr (  LFP_ordered{c}(:,2), 'normalized'  );

                        % Plot results
                        figure
                        subplot (2,2,1)
                        plot( lags1./sampling_freq_Hz,c1, 'r' )
                        title('Autocovariance LFP channel: ' )
                        subtitle( channel_names{c}(:,1), 'Interpreter', 'none' );
                        ylabel( 'Amplitude [\muVp]' )
                        xlabel( 'Time [sec]' )
                        subplot(2,2,2)
                        plot( lags2./sampling_freq_Hz,c2, 'r' )
                        title('Autocorrelation LFP channel: ' )
                        subtitle( channel_names{c}(:,1), 'Interpreter', 'none' );
                        ylabel( 'Amplitude [\muVp]' )
                        xlabel( 'Time [sec]' )
                        subplot (2,2,3)
                        plot( lags3./sampling_freq_Hz,c3 )
                        title('Autocovariance LFP channel: ' )
                        subtitle( channel_names{c}(:,2), 'Interpreter', 'none' );
                        ylabel( 'Amplitude [\muVp]' )
                        xlabel( 'Time [sec]' )
                        subplot(2,2,4)
                        plot( lags4./sampling_freq_Hz,c4 )
                        title('Autocorrelation LFP channel: ' )
                        subtitle( channel_names{c}(:,2), 'Interpreter', 'none' );
                        ylabel( 'Amplitude [\muVp]' )
                        xlabel( 'Time [sec]' )
                        disp( [ 'channel 1: ' char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)),...
                            'channel 2: ' char(obj.streaming_parameters.time_domain.channel_names{c}(:,2))])

                    elseif length(LFP_ordered{c}(1,:)) == 1

                        [c1,lags1] = xcov( LFP_ordered{c}(:,1), 'normalized'   );
                        [c2,lags2]= xcorr ( LFP_ordered{c}(:,1), 'normalized'   );

                        % Plot results
                        figure
                        subplot (2,1,1)
                        plot( lags1./sampling_freq_Hz,c1, 'r' )
                        title('Autocovariance LFP channel: ' )
                        subtitle( channel_names{c}(:,1), 'Interpreter', 'none' );
                        ylabel( 'Amplitude [\muVp]' )
                        xlabel( 'Time [sec]' )
                        subplot(2,1,2)
                        plot( lags2./sampling_freq_Hz,c2, 'r' )
                        title('Autocorrelation LFP channel: ' )
                        subtitle( channel_names{c}(:,1), 'Interpreter', 'none' );
                        ylabel( 'Amplitude [\muVp]' )
                        xlabel( 'Time [sec]' )
                        disp( [ 'channel 1: ' char(obj.streaming_parameters.time_domain.channel_names{c}(:,1))])

                        disp('Only one hemispheres available')

                    end
                end
        end
    end
end


