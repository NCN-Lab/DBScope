function plotBandpowerPerStimulationLevel(obj, bounds, varargin)
% PLOTBANDPOWERPERSTIMULATIONLEVEL Computes and plots power in given band as a
% function of stimulation amplitude
%
% Syntax:
%   PLOTBANDPOWERPERSTIMULATIONLEVEL( obj, bounds, varargin );
%
% Input parameters (mandatory):
%    * obj          DBScope object containg streaming data.
%    * bounds       Frequency band bounds.
%
% Example:
%   PLOTBANDPOWERPERSTIMULATIONLEVEL( obj, bounds);
%
% PLOTBANDPOWERPERSTIMULATIONLEVEL(..., 'PARAM1', val1, 'PARAM2', val2, ...)
%   specifies optional name/value pairs:
%     'DataType'            Type of input data. Can be of two types: 'Raw'
%                           or 'ECG Cleaned'.
%                           Defaults to 'Raw'
%     'RecordingIndices'    Indices of recordings to include in analysis.
%                           Defaults to all indices
%     'EpochDuration'       Duration of the epoch in seconds.
%                           Defaults to 5
%     'EpochOverlap'        Ratio of epoch duration that is common in each step.
%                           Defaults to 0.5
%     'Statistics'          Whether to show statistical significance.
%                           Defaults to true
%
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Create an input parser object
parser = inputParser;

% Define the optional input parameters and their default values
addOptional(parser, 'DataType', 'Raw'); % Default value is 'Raw'
addOptional(parser, 'RecordingIndices', 1:numel(obj.streaming_parameters.time_domain.data)); % Default All
addOptional(parser, 'EpochDuration', 5); % Default value is 5 seconds
addOptional(parser, 'EpochOverlap', 0.5); % Default value is half the duration
addOptional(parser, 'Statistics', true); % Default value is true

% Parse the input arguments
parse(parser, varargin{:});

% Access the values of the optional inputs
data_type = parser.Results.DataType;
recording_indx = parser.Results.RecordingIndices;
epoch_duration = parser.Results.EpochDuration;
epoch_step = epoch_duration*(1-parser.Results.EpochOverlap);
show_statistics = parser.Results.Statistics;

% Streaming variables
streaming_fs                = obj.streaming_parameters.time_domain.fs;
streaming_stim_freq         = obj.streaming_parameters.stim_amp.fs;

switch data_type
    case 'Raw'
        LFP_selected = obj.streaming_parameters.time_domain.data;
    case 'ECG Cleaned'
        LFP_selected = obj.streaming_parameters.time_domain.ecg_clean;
end

streaming_data_levels               = cell(numel(recording_indx), 1);
streaming_time_levels               = cell(numel(recording_indx), 1);
streaming_data_levels_amplitudes    = cell(numel(recording_indx), 1);
streaming_time_levels_amplitudes    = cell(numel(recording_indx), 1);
titration_levels                    = cell(numel(recording_indx), 1);
unique_titration_levels             = cell(2,1);
unique_channel_names                = {};

% Get stimultation amplitude levels
for r = recording_indx

    % Get recording
    streaming_data = LFP_selected{r};
    streaming_time = obj.streaming_parameters.time_domain.time{r};
    streaming_stim_data = obj.streaming_parameters.stim_amp.data{r};
    streaming_stim_time = obj.streaming_parameters.stim_amp.time{r};

    unique_channel_names = unique([unique_channel_names{:}, obj.streaming_parameters.time_domain.channel_names{r}]);
    
    num_channels = numel(obj.streaming_parameters.time_domain.channel_names{r});
    streaming_data_levels{r}               = cell(num_channels, 1);
    streaming_time_levels{r}               = cell(num_channels, 1);
    streaming_data_levels_amplitudes{r}    = cell(num_channels, 1);
    streaming_time_levels_amplitudes{r}    = cell(num_channels, 1);

    for channel = 1:num_channels

        % Get titration levels
        steps = [];
        data = streaming_stim_data(:, channel);
        L = length(data);
        amp = mode(data);
        while sum(data == amp) >= L / 10 % We defined that each level should be at least 10% of the recording
            steps(end+1) = amp;
            data(data == amp) = [];
            amp = mode(data);
        end
        steps = sort(steps);
        unique_titration_levels{channel} = unique([unique_titration_levels{channel}, steps]);

        titration_levels{r}{channel} = steps;

        stim_data = round([streaming_stim_data(:, channel); -1.0], 1); % Add final value
        level_start = 1;
        level_end = 0;
        for i = 1:numel(steps)
            indx_level_end = find(~ismember(stim_data, round(steps,1)),1,'first') - 1;
            level_end = level_start + indx_level_end - 1;            
            
            if (level_end-1)*streaming_fs/streaming_stim_freq > length(streaming_data)
                indx_end = length(streaming_data);
            else
                indx_end = (level_end-1)*streaming_fs/streaming_stim_freq;
            end
            streaming_data_levels{r}{channel}{end+1} = streaming_data((level_start-1)*streaming_fs/streaming_stim_freq+1:indx_end,channel);
            streaming_time_levels{r}{channel}{end+1} = streaming_time((level_start-1)*streaming_fs/streaming_stim_freq+1:indx_end);
            streaming_data_levels_amplitudes{r}{channel}{end+1} = streaming_stim_data(level_start:level_end,channel);
            streaming_time_levels_amplitudes{r}{channel}{end+1} = streaming_stim_time(level_start:level_end);

            stim_data = stim_data(indx_level_end+1:end);
            indx_level_start = find(ismember(stim_data, round(steps,1)),1,'first');
            stim_data = stim_data(indx_level_start:end);
            level_start = level_end + indx_level_start;

        end

    end

end

%% Get epochs in each level

aux_recording   = [];
aux_time        = [];
aux_level       = [];
aux_channel     = [];
aux_power       = [];

for r = recording_indx
    for channel = 1:numel(streaming_data_levels{r})
        for level = 1:numel(streaming_data_levels{r}{channel})
            rem_level = rem(length(streaming_data_levels_amplitudes{r}{channel}{level}), epoch_step*streaming_stim_freq);
            for i = floor(rem_level/2)+1:epoch_step*streaming_stim_freq: ...
                    length(streaming_data_levels_amplitudes{r}{channel}{level}) - epoch_duration*streaming_stim_freq + 1

                j = (i-1) * streaming_fs / streaming_stim_freq + 1;

                if j <= length(streaming_data_levels{r}{channel}{level}) - epoch_duration*streaming_fs + 1

                    p = bandpower(streaming_data_levels{r}{channel}{level}(j:j+epoch_duration*streaming_fs-1,:), ...
                        streaming_fs, bounds);

                    aux_recording   = [aux_recording; r];
                    aux_time        = [aux_time; streaming_time_levels{r}{channel}{level}(j+(epoch_duration*streaming_fs)/2-1)];
                    aux_level       = [aux_level; titration_levels{r}{channel}(level)];
                    aux_channel     = [aux_channel; obj.streaming_parameters.time_domain.channel_names{r}(channel)];
                    aux_power       = [aux_power; p];

                end
            end
        end
    end

end

epochs_power_in_bands = table(aux_recording, aux_time, aux_level, aux_channel, aux_power, ...
    'VariableNames', {'Recording', 'Relative Time', 'Stimulation Amplitude', 'Channel', 'Power'});

%% Plot Power Per Level (referenced to the lowest stimulation amplitude)

figure('Position', [50, 200, 1300, 400]);
set(gcf,'color','w');

median_lower_stimulation = zeros(1,2);
for channel = 1:2
    
    % Get lowest stimulation median
    lower_stimulation_table = epochs_power_in_bands(epochs_power_in_bands.("Stimulation Amplitude") == unique_titration_levels{channel}(1) & ...
        strcmp(epochs_power_in_bands.("Channel"), unique_channel_names{channel}), :);
    median_lower_stimulation(channel) = median(lower_stimulation_table.Power);
    
    % Get stimulation amplitude ticks
    amp_ticks = unique_titration_levels{channel};

    % Get highest whisker (to accomodate for statistics) 
    max_whisker = 0;
    for level = 1:numel(amp_ticks)
        aux_table = epochs_power_in_bands(epochs_power_in_bands.("Stimulation Amplitude") == amp_ticks(level) & ...
            strcmp(epochs_power_in_bands.("Channel"), unique_channel_names{channel}), :);
        prctile_75_level_power = prctile(aux_table.Power, 75);
        if prctile_75_level_power > max_whisker
            max_whisker = prctile_75_level_power;
        end
    end
    aux_table = epochs_power_in_bands(strcmp(epochs_power_in_bands.("Channel"), unique_channel_names{channel}) & ...
        ismember(epochs_power_in_bands.("Stimulation Amplitude"), amp_ticks), :);

    % Boxchart of the power per level
    sgtitle(sprintf("%s: %d-%d Hz", data_type, bounds));
    h_sub = subplot(1,2,channel);
    boxchart(categorical(aux_table.("Stimulation Amplitude")), ...
        aux_table.Power./median_lower_stimulation(channel), ...
        'Notch','off', 'MarkerStyle', ".");
    ylabel("Relative Power");
    xlabel("Stimulation Amplitude (mA)");
    title(unique_channel_names{channel});
    max_lim = max_whisker/median_lower_stimulation(channel) * 2;
    ylim([0 max_lim]);
    
    % Calculate and plot statistics
    if show_statistics && numel(amp_ticks) > 1
        [~,~,stats] = anova1(aux_table.Power./median_lower_stimulation(channel), ...
            aux_table.("Stimulation Amplitude"), 'off');
        c1 = multcompare(stats, 'display','off');
        tbl1 = array2table(c1,"VariableNames", ...
            ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);

        hold on;
        xt = get(gca, 'XTick');

        % Plot statistical significance bars
        for k = 1:numel(amp_ticks)-1
            % Get statistical significance
            aux_stats = table2array(tbl1(~any(~ismember(tbl1{:,1:2},[k, k+1]),2),:));
            p_value = aux_stats(6);
            if p_value > 0.05
                str = 'ns';
            elseif p_value > 0.01
                str = '*';
            elseif p_value > 0.001
                str = '**';
            else
                str = '***';
            end

            plot(xt([k k+1]), [1 1]*max_lim-(k+1)*max_lim*0.04 - max_lim*0.1, '-k', 'LineWidth', 2);
            text(mean([k k+1])-0.05, max_lim-k*max_lim*0.04 - max_lim*0.1 , str);

            % To compare the last step with the last-2 step
            if k > numel(amp_ticks)-3 && k<numel(amp_ticks)-1
                % Get statistical significance
                aux_stats = table2array(tbl1(~any(~ismember(tbl1{:,1:2},[k, k+2]),2),:));
                p_value = aux_stats(6);
                if p_value > 0.05
                    str = 'ns';
                elseif p_value > 0.01
                    str = '*';
                elseif p_value > 0.001
                    str = '**';
                else
                    str = '***';
                end

                plot(xt([k k+2]), [1 1]*max_lim-(k-1)*max_lim*0.04 - max_lim*0.1, '-k', 'LineWidth', 2);
                text(mean([k k+2])-0.05, max_lim-(k-2)*max_lim*0.04 - max_lim*0.1, str);
            end

        end
    end
    
end


end



