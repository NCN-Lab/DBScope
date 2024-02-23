function plotRawDataStream( obj )
% plot LFP online streaming recordings: raw data or ECG cleaned data
%
% Syntax:
%   PLOTRAWDATASTREAM( obj );
%
% Input parameters:
%    * obj - object containg data
%
% Example:
%   PLOTRAWDATASTREAM( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Get sampling frequency
sampling_freq_Hz =  obj.streaming_parameters.time_domain.fs;
sampling_freq_stimAmp = obj.streaming_parameters.stim_amp.fs;

% Check if data is filtered, select data
if isempty (obj.streaming_parameters.filtered_data.data)
    disp('Data is not filtered')
    answer = questdlg('Which data do you want to visualize?', ...
        '', ...
        'Raw','ECG clean data','ECG clean data');
    switch answer
        case 'Raw'
            LFP_originalData = obj.streaming_parameters.time_domain.data;
        case 'ECG clean data'
            LFP_originalData = obj.streaming_parameters.time_domain.ecg_clean;
    end

    % Get LFP and Stim data
    Stim_originalData = obj.streaming_parameters.stim_amp.data;
    channel_name =  obj.streaming_parameters.time_domain.channel_names;
    LFP_ylabel = obj.streaming_parameters.time_domain.ylabel;
    stimAmp_ylabel = obj.streaming_parameters.stim_amp.ylabel;

    for c = 1:numel(LFP_originalData)

        if length(LFP_originalData{c}(1,:)) == 2

            % x axis left hemisphere
            tms_left = (0:numel(LFP_originalData{c}(:,1))-1)/sampling_freq_Hz;
            tms_stim_left = (0:numel( Stim_originalData{c}(:,1))-1)/sampling_freq_stimAmp;

            % x axis right hemisphere
            tms_right = (0:numel(LFP_originalData{c}(:,2))-1)/sampling_freq_Hz;
            tms_stim_right = (0:numel( Stim_originalData{c}(:,2))-1)/sampling_freq_stimAmp;

            figure
            subplot(2,1,1)
            %yyaxis left;
            plot(tms_left, LFP_originalData{c}(:,1));
            ylabel(LFP_ylabel)
            yyaxis right;
            plot(tms_stim_left, Stim_originalData{c}(:,1));
            ylabel(stimAmp_ylabel);
            axis tight
            title('Raw signal and Stimulation channel: ')
            subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
            xlabel('Time [sec]')
            ax1 = gca;
            subplot(2,1,2)
            yyaxis left;
            plot(tms_right, LFP_originalData{c}(:,2));
            ylabel(LFP_ylabel)
            yyaxis right;
            plot(tms_stim_right, Stim_originalData{c}(:,2));
            ylabel(stimAmp_ylabel);
            axis tight
            title('Raw signal and Stimulation channel: ')
            subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,2)), 'Interpreter', 'none' );
            xlabel('Time [sec]')
            ax1 = gca;


        elseif length(LFP_originalData{c}(1,:)) == 1

            disp('Only one hemisphere was available')
            % x axis available hemisphere
            tms = (0:numel(LFP_originalData{c}(:,1))-1)/sampling_freq_Hz;
            tms_stim = (0:numel( Stim_originalData{c}(:,1))-1)/sampling_freq_stimAmp;

            figure
            yyaxis left;
            plot(tms, LFP_originalData{c}(:,1));
            ylabel(LFP_ylabel)
            yyaxis right;
            plot(tms_stim, Stim_originalData{c}(:,1));
            ylabel(stimAmp_ylabel);
            axis tight
            title('Raw signal & Stimulation channel: ' )
            subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
            xlabel('Time [sec]')
            ax1 = gca;
            disp(['Available channel:' channel_name])


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
                    LFP_originalData = obj.streaming_parameters.time_domain.data;
                case 'ECG clean data'
                    LFP_originalData = obj.streaming_parameters.time_domain.ecg_clean;
            end

            % Get LFP and Stim data
            Stim_originalData = obj.streaming_parameters.stim_amp.data;
            channel_name =  obj.streaming_parameters.time_domain.channel_names;
            LFP_ylabel = obj.streaming_parameters.time_domain.ylabel;
            stimAmp_ylabel = obj.streaming_parameters.stim_amp.ylabel;

            for c = 1:numel(LFP_originalData)

                if length(LFP_originalData{c}(1,:)) == 2

                    % x axis left hemisphere
                    tms_left = (0:numel(LFP_originalData{c}(:,1))-1)/sampling_freq_Hz;
                    tms_stim_left = (0:numel( Stim_originalData{c}(:,1))-1)/sampling_freq_stimAmp;

                    % x axis right hemisphere
                    tms_right = (0:numel(LFP_originalData{c}(:,2))-1)/sampling_freq_Hz;
                    tms_stim_right = (0:numel( Stim_originalData{c}(:,2))-1)/sampling_freq_stimAmp;

                    figure
                    subplot(2,1,1)
                    yyaxis left;
                    plot(tms_left, LFP_originalData{c}(:,1));
                    ylim([-6,6])
                    ylabel(LFP_ylabel)
                    yyaxis right;
                    plot(tms_stim_left, Stim_originalData{c}(:,1));
                    ylabel(stimAmp_ylabel);
                    axis tight
                    title('Raw signal and Stimulation channel: ' )
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
                    xlabel('Time [sec]')
                    ax1 = gca;
                    subplot(2,1,2)
                    yyaxis left;
                    plot(tms_right, LFP_originalData{c}(:,2));
                    ylabel(LFP_ylabel)
                    yyaxis right;
                    plot(tms_stim_right, Stim_originalData{c}(:,2));
                    ylabel(stimAmp_ylabel);
                    axis tight
                    title('Raw signal and Stimulation channel: ' )
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,2)), 'Interpreter', 'none' );
                    xlabel('Time [sec]')
                    ax1 = gca;

                elseif length(LFP_originalData{c}(1,:)) == 1

                    disp('Only one hemisphere was available')
                    % x axis available hemisphere
                    tms = (0:numel(LFP_originalData{c}(:,1))-1)/sampling_freq_Hz;
                    tms_stim = (0:numel( Stim_originalData{c}(:,1))-1)/sampling_freq_stimAmp;

                    figure
                    yyaxis left;
                    plot(tms, LFP_originalData{c}(:,1));
                    ylabel(LFP_ylabel)
                    yyaxis right;
                    plot(tms_stim, Stim_originalData{c}(:,1));
                    ylabel(stimAmp_ylabel);
                    axis tight
                    title('Raw signal & Stimulation channel: ')
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
                    xlabel('Time [sec]')
                    ax1 = gca;
                    disp(['Available channel:' channel_name])

                end
            end

        case 'Latest Filtered'

            % Get LFP and stim data
            LFP_originalData = obj.streaming_parameters.filtered_data.data{end};
            Stim_originalData = obj.streaming_parameters.stim_amp.data;
            channel_name =  obj.streaming_parameters.time_domain.channel_names;
            LFP_ylabel = obj.streaming_parameters.time_domain.ylabel;
            stimAmp_ylabel = obj.streaming_parameters.stim_amp.ylabel;

            for c = 1:numel(LFP_originalData)

                if length(LFP_originalData{c}(1,:)) == 2

                    % x axis left hemisphere
                    tms_left = (0:numel(LFP_originalData{c}(:,1))-1)/sampling_freq_Hz;
                    tms_stim_left = (0:numel( Stim_originalData{c}(:,1))-1)/sampling_freq_stimAmp;

                    % x axis right hemisphere
                    tms_right = (0:numel(LFP_originalData{c}(:,2))-1)/sampling_freq_Hz;
                    tms_stim_right = (0:numel( Stim_originalData{c}(:,2))-1)/sampling_freq_stimAmp;

                    figure
                    subplot(2,1,1)
                    yyaxis left;
                    plot(tms_left, LFP_originalData{c}(:,1));
                    ylim([-7,7])
                    ylabel(LFP_ylabel)
                    yyaxis right;
                    plot(tms_stim_left, Stim_originalData{c}(:,1));
                    ylabel(stimAmp_ylabel);
                    axis tight
                    title('Filtered signal and Stimulation channel: ')
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
                    xlabel('Time [sec]')
                    ax1 = gca;
                    subplot(2,1,2)
                    yyaxis left;
                    plot(tms_right, LFP_originalData{c}(:,2));
                    ylabel(LFP_ylabel)
                    yyaxis right;
                    plot(tms_stim_right, Stim_originalData{c}(:,2));
                    ylabel(stimAmp_ylabel);
                    axis tight
                    title('Filtered signal and Stimulation channel: ' )
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,2)), 'Interpreter', 'none' );
                    xlabel('Time [sec]')
                    ax1 = gca;

                elseif length(LFP_originalData{c}(1,:)) == 1

                    disp('Only one hemisphere was available')
                    % x axis available hemisphere
                    tms = (0:numel(LFP_originalData{c}(:,1))-1)/sampling_freq_Hz;
                    tms_stim = (0:numel( Stim_originalData{c}(:,1))-1)/sampling_freq_stimAmp;

                    figure
                    yyaxis left;
                    plot(tms, LFP_originalData{c}(:,1));
                    ylabel(LFP_ylabel)
                    yyaxis right;
                    plot(tms_stim, Stim_originalData{c}(:,1));
                    ylabel(stimAmp_ylabel);
                    axis tight
                    title('Filtered signal & Stimulation channel: ')
                    subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
                    xlabel('Time [sec]')
                    ax1 = gca;
                    disp(['Available channel:' channel_name])

                end
            end

            disp(['Filter type: ' cell2mat(obj.streaming_parameters.filtered_data.filter_type{end}), newline...
                'Lower bound: ', num2str(obj.streaming_parameters.filtered_data.low_bound{end}), newline,...
                'Upper bound: ', num2str(obj.streaming_parameters.filtered_data.up_bound{end})]);
    end
end

end
