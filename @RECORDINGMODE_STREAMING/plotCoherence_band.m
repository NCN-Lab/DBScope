function plotCoherence_band ( obj, varargin )
% Plot coherence for LFP online streaming mode
%
% Syntax:
%   PLOTCOHERENCE_BAND( obj, data_type, varargin );
%
% Input parameters:
%    * obj - object containg data
%    * data_type - type of input data (raw, ecg cleaned or filtered)
%    * ax (optional) - axis where you want to plot
%
% Example:
%   PLOTCOHERENCE_BAND( data_type, varargin );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

switch nargin
    case 4
        ax = varargin{1};
        data_type = varargin{2};
        rec = varargin{3};
        
        t = obj.streaming_parameters.time_domain.time{rec};
        switch data_type
            case 'Raw'
                LFP_ordered = obj.streaming_parameters.time_domain.data;
            case 'Latest Filtered'
                LFP_ordered = obj.streaming_parameters.filtered_data.data{end};
            case 'ECG Cleaned'
                LFP_ordered = obj.streaming_parameters.time_domain.ecg_clean;
        end

        LFP_raw = {};
        for d = 1:numel(LFP_ordered{rec}(1,:))
            LFP_raw{end+1} = LFP_ordered{rec}(:,d);
        end

        if numel(LFP_ordered{rec}(1,:)) == 2

            [Cxy,f] = mscohere( LFP_raw{1}, LFP_raw{2}, hann(256));

            plot( ax, 125*f/pi, Cxy)
            xlabel( ax, 'Frequency [Hz]')
            ylabel( ax, 'Magnitude-Squared Coherence' )
            xlim( ax, [125*min(f/pi) 125*max(f/pi)])
            title( ax, 'Coherence LFP' )


            disp( [ 'channel 1: ' char(obj.streaming_parameters.time_domain.channel_names{rec}(:,1)),...
                ', channel 2: ' char(obj.streaming_parameters.time_domain.channel_names{rec}(:,2))]);

        else
            disp ('Only one hemisphere available')

        end

    case 1
        channel_names  = obj.streaming_parameters.time_domain.channel_names;
        sampling_freq_Hz = obj.streaming_parameters.time_domain.fs;

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

                    % Apply and plot coherence
                    fig = figure;
                    new_position = [16, 48, 1425, 727];
                    set(fig, 'position', new_position)
                    mscohere( LFP_ordered{c}(:,1), LFP_ordered{c}(:,2) );
                    title('Coherence LFP channels: ' )
                    subtitle( [channel_names{c}(:,1) ' & '  channel_names{c}(:,2) ], 'Interpreter', 'none');

                    disp( [ 'channel 1: ' char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)),...
                        'channel 2: ' char(obj.streaming_parameters.time_domain.channel_names{c}(:,2))])

                elseif length(LFP_ordered{c}(1,:)) == 1
                    disp('Only one hemispheres available')
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

                            % Apply and plot coherence
                            fig = figure;
                            new_position = [16, 48, 1425, 727];
                            set(fig, 'position', new_position)
                            mscohere( LFP_ordered{c}(:,1), LFP_ordered{c}(:,2) );
                            title('Coherence LFP channels: ' )
                            subtitle( [channel_names{c}(:,1) ' & '  channel_names{c}(:,2) ], 'Interpreter', 'none');

                            disp( [ 'channel 1: ' char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)),...
                                'channel 2: ' char(obj.streaming_parameters.time_domain.channel_names{c}(:,2))])

                        elseif length(LFP_ordered{c}(1,:)) == 1
                            disp('Only one hemispheres available')
                        end
                    end

                case 'Latest Filtered'
                    LFP_ordered = obj.streaming_parameters.filtered_data.data{end};

                    for c = 1:numel(LFP_ordered)
                        if length(LFP_ordered{c}(1,:)) == 2

                            % Apply and plot coherence
                            fig = figure;
                            new_position = [16, 48, 1425, 727];
                            set(fig, 'position', new_position)
                            mscohere( LFP_ordered{c}(:,1), LFP_ordered{c}(:,2) );
                            title('Coherence LFP channels: ' )
                            subtitle( [channel_names{c}(:,1) ' & '  channel_names{c}(:,2) ], 'Interpreter', 'none');

                            disp( [ 'channel 1: ' char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)),...
                                'channel 2: ' char(obj.streaming_parameters.time_domain.channel_names{c}(:,2))])

                        elseif length(LFP_ordered{c}(1,:)) == 1
                            disp('Only one hemispheres available')
                        end
                    end

            end
        end

end
end