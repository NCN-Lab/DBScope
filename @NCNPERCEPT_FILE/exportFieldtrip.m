function exportFieldtrip( obj )
% EXPORTFIELDTRIP Exports streaming data to .mat file that is readable by
% the fieldtrip toolbox.
%
% NOTE: To export everything in the same file, we opted to consider all
% used channels. This means that if a channel is only used in one of the
% recordings, it will still be present in the other recordings but with NaN
% in the 'trial' field.
%
% Syntax:
%   EXPORTFIELDTRIP( obj, filename );
%
% Input parameters:
%    * obj          DBScope object containg streaming data.
%    * filename     Name of the file to be generated.
%
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Prompt the user to select a directory
selectedDir = uigetdir();

% Check if cancelled
if isequal(selectedDir, 0)
    disp('Exportation cancelled.');
    return;
end

session_date = obj.parameters.session_date;
session_date.Format = 'yyyyMMdd''T''HHmmss';
patient_id = obj.parameters.patient_information.patient_id;
filename_prefix = patient_id + "_" + string(session_date);

%% SURVEY

if obj.status.survey == 1

    % Get variables
    survey_data              = obj.survey_obj.survey_parameters.time_domain.data;
    survey_time              = obj.survey_obj.survey_parameters.time_domain.time;
    survey_channel_names     = obj.survey_obj.survey_parameters.time_domain.channel_names;
    
    % Create headers
    hdr_survey = obj.survey_obj.survey_parameters.time_domain;
    hdr_survey = rmfield(hdr_survey, {'data', 'time'});
    
    survey   = struct("hdr", hdr_survey, "trial", {survey_data}, "time", {survey_time}, "label", {survey_channel_names});
    
    % Save the data to a .mat file
    filename = selectedDir + "\" + filename_prefix + "_Survey_fieldtrip.mat";
    fprintf('Writing %s as FieldTrip file.\n', filename);
    save(filename, 'survey');

else
    fprintf('%s has no Survey data.\n', filename_prefix);
end

%% SETUP

if obj.status.setup_off == 1 || obj.status.setup_on == 1
    
    if obj.status.setup_off == 1
        % Get variables
        setup_off_data              = obj.setup_obj.setup_parameters.stim_off.data;
        setup_off_time              = obj.setup_obj.setup_parameters.stim_off.time;
        setup_off_channel_names     = obj.setup_obj.setup_parameters.stim_off.channel_names;

        % Create headers
        hdr_off = obj.setup_obj.setup_parameters.stim_off;
        hdr_off = rmfield(hdr_off, {'data', 'time'});

        % Get trials/recordings
        trial_off   = {};
        for r = 1:size(setup_off_data,2)
            trial_off{end+1}    = setup_off_data(:,r);
        end

        setup_off   = struct("hdr", hdr_off, "trial", {trial_off}, "time", {setup_off_time}, "label", {setup_off_channel_names});

    end

    if obj.status.setup_on == 1
        % Get variables
        setup_on_data               = obj.setup_obj.setup_parameters.stim_on.data;
        setup_on_time               = obj.setup_obj.setup_parameters.stim_on.time;
        setup_on_channel_names      = obj.setup_obj.setup_parameters.stim_on.channel_names;

        % Create headers
        hdr_on = obj.setup_obj.setup_parameters.stim_on;
        hdr_on = rmfield(hdr_on, {'data', 'time'});

        setup_on    = struct("hdr", hdr_on, "trial", {setup_on_data}, "time", {setup_on_time}, "label", {setup_on_channel_names});
    end

    % Save the data to a .mat file
    filename = selectedDir + "\" + filename_prefix + "_Setup_fieldtrip.mat";
    fprintf('Writing %s as FieldTrip file.\n', filename);
    if obj.status.setup_off == 0
        save(filename, 'setup_on');
    elseif obj.status.setup_on == 0
        save(filename, 'setup_off');
    else
        save(filename, 'setup_off', 'setup_on');
    end

else
    fprintf('%s has no Setup data.\n', filename_prefix);
end

%% STREAMING

if obj.status.streaming == 1

    % Get streaming variables
    streaming_data                  = obj.streaming_obj.streaming_parameters.time_domain.data;
    streaming_time                  = obj.streaming_obj.streaming_parameters.time_domain.time;
    streaming_channel_names         = obj.streaming_obj.streaming_parameters.time_domain.channel_names;
    streaming_stim_data             = obj.streaming_obj.streaming_parameters.stim_amp.data;
    streaming_stim_time             = obj.streaming_obj.streaming_parameters.stim_amp.time;
    streaming_stim_channel_names    = obj.streaming_obj.streaming_parameters.stim_amp.sensing_channel_names;

    % Create headers
    hdr_lfp = obj.streaming_obj.streaming_parameters.time_domain;
    hdr_lfp = rmfield(hdr_lfp, {'data', 'time', 'ecg_clean'});
    hdr_stim = obj.streaming_obj.streaming_parameters.stim_amp;
    hdr_stim = rmfield(hdr_stim, {'data', 'time'});

    % Get all the channels that were used to record
    unique_channels = [];
    for r = 1:numel(streaming_data)
        unique_channels = unique([unique_channels; categorical(streaming_channel_names{r}')]);
    end
    unique_channels = cellstr(unique_channels);

    % Get trials/recordings
    trial_lfp   = {};
    trial_stim  = {};
    for r = 1:numel(streaming_data)

        % LFP
        temp_lfp    = NaN*ones(numel(unique_channels), numel(streaming_time{r}));
        for channel = 1:numel(streaming_channel_names{r})
            indx_channel = cellfun(@(x) strcmp(x, streaming_channel_names{r}{channel}), unique_channels);
            temp_lfp(indx_channel, :) = streaming_data{r}(:, channel);
        end
        trial_lfp{end+1}    = temp_lfp;

        % Stimulation Amplitude
        temp_stim   = NaN*ones(numel(unique_channels), numel(streaming_stim_time{r}));
        for channel = 1:numel(streaming_stim_channel_names{r})
            indx_channel = cellfun(@(x) strcmp(x, streaming_stim_channel_names{r}{channel}), unique_channels);
            temp_stim(indx_channel, :) = streaming_stim_data{r}(:, channel);
        end
        trial_stim{end+1}   = temp_stim;

    end

    lfp_raw     = struct("hdr", hdr_lfp, "trial", {trial_lfp}, "time", {streaming_time}, "label", {unique_channels});
    stim_amp    = struct("hdr", hdr_stim, "trial", {trial_stim}, "time", {streaming_stim_time}, "label", {unique_channels});

    % Save the data to a .mat file
    filename = selectedDir + "\" + filename_prefix + "_Streaming_fieldtrip.mat";
    fprintf('Writing %s as FieldTrip file.\n', filename);
    save(filename, 'lfp_raw', 'stim_amp');

else
    fprintf('%s has no Streaming data.\n', filename_prefix);
end

%% INDEFINITE

% coming soon

%% CHRONIC


if obj.status.chronic == 1 || obj.status.events == 1

    if obj.status.chronic == 1

        % Get variables
        trend_data              = obj.chronic_obj.chronic_parameters.time_domain.data;
        trend_time              = obj.chronic_obj.chronic_parameters.time_domain.time;
        trend_channel_names     = obj.chronic_obj.chronic_parameters.time_domain.sensing;
        trend_hemispheres       = obj.chronic_obj.chronic_parameters.time_domain.hemispheres;
        trend_hemispheres       = strrep(trend_hemispheres, 'HemisphereLocationDef_', '');

        if isempty(trend_channel_names)
            trend_label = trend_hemispheres;
        else
            trend_label = strcat(trend_channel_names, " " + trend_hemispheres);
        end

        % Create header
        hdr_trend = obj.chronic_obj.chronic_parameters.time_domain;
        hdr_trend = rmfield(hdr_trend, {'data', 'time'});

        trendlogs   = struct("hdr", hdr_trend, "trial", {trend_data}, "time", {trend_time}, "label", {trend_label});

    end

    if obj.status.events == 1
        % Create header
        hdr_events = obj.chronic_obj.chronic_parameters.events;

        events      = struct("hdr", hdr_events);
    end

    % Save the data to a .mat file
    filename = selectedDir + "\" + filename_prefix + "_Chronic_fieldtrip.mat";
    fprintf('Writing %s as FieldTrip file.\n', filename);
    if obj.status.chronic == 0
        save(filename, 'events');
    elseif obj.status.events == 0
        save(filename, 'trendlogs');
    else
        save(filename, 'trendlogs', 'events');
    end

else
    fprintf('%s has no Chronic data.\n', filename_prefix);
end

end

