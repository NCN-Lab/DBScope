function [ status_timeline, status_events, status_events_FFT ] = fillChronicParameters( obj, data )
% Extract and visualize LFPs from chronic LFP data.
%
% Syntax:
%   [ status_timeline, status_events, status_events_fft ] = FILLCHRONICPARAMETERS( obj, data );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%
% Output parameters:
%    * status_timeline
%    * status_events
%    * status_events_FFT
%
% Example:
%   [ status_timeline, status_events, status_events_FFT ] = FILLCHRONICPARAMETERS( obj, data );
%
% Adapted from Yohann Thenaisie 02.09.2020 - Lausanne University Hospital
% (CHUV) https://github.com/YohannThenaisie/PerceptToolbox
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

status_timeline     = 0;
status_events       = 0;
status_events_FFT   = 0;

% Extract LFPs
if isfield( data, 'DiagnosticData' ) && isfield( data.DiagnosticData, 'LFPTrendLogs' ) % Timeline

    parameters.mode         = 'LFPTrendLogs';
    [ LFPTrendLogs ]        = obj.extractTrendLogs( data, parameters );

    % Fill parameters for time domain
    obj.chronic_parameters.time_domain.recording_mode = 'LFPTrendLogs';
    obj.chronic_parameters.time_domain.n_channels = LFPTrendLogs.LFP.nChannels;

    % If there was a change of active BrainSense group within the period 
    % of DiagnosticData (check EventLogs) divide data in different 
    % structs [maybe have the Visualization Window with a field to
    % alternate between periods].
    % To get the information on sensing channels and center frequency, use
    % GroupHistory (stores last 5 changes in group settings).

    if isfield(data.Groups.Initial([data.Groups.Initial.ActiveGroup]).ProgramSettings, 'SensingChannel' )
        temp = {data.Groups.Initial([data.Groups.Initial.ActiveGroup]).ProgramSettings.SensingChannel.Channel};
        temp = strrep(temp, '_AND_', ' ');
        temp = strrep(temp, 'SensingElectrodeConfigDef.', '');
        obj.chronic_parameters.time_domain.sensing = temp';
        obj.chronic_parameters.time_domain.center_frequency = cellfun(@(h) h.FrequencyInHertz, {data.Groups.Initial([data.Groups.Initial.ActiveGroup]).ProgramSettings.SensingChannel.SensingSetup});
    elseif ~isempty(data.GroupHistory)
        aux_endtime_timeline = LFPTrendLogs.LFP.time(end);
        aux_GroupHistory_SessionDates = arrayfun(@(x) datetime(x.SessionDate, ...
            'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss''Z'''), data.GroupHistory);
        aux_idx_groups_in_past_post_end_timeline = find(aux_GroupHistory_SessionDates > aux_endtime_timeline);
        aux_idx_groups_in_past_post_end_timeline = sort(aux_idx_groups_in_past_post_end_timeline,"descend");

        i = 1; 
        is_idx_closest_post_end_timeline_with_sensing_found = false;
        idx_group_sensing = 0;

        while i <= numel(aux_idx_groups_in_past_post_end_timeline) && ~is_idx_closest_post_end_timeline_with_sensing_found
            aux_idx_GroupHistory_entry_tested = aux_idx_groups_in_past_post_end_timeline(i) ;
            aux_data_groups = data.GroupHistory(aux_idx_GroupHistory_entry_tested).Groups;

            for j = 1:numel(aux_data_groups)
                aux_group = aux_data_groups{j};
                if isfield(aux_group, 'ProgramSettings') 
                    if isfield(aux_group.ProgramSettings, 'SensingChannel')
                        if (aux_group.ProgramSettings.SensingChannel(1).SensingSetup.FrequencyInHertz > 0) && (aux_group.ProgramSettings.SensingChannel(2).SensingSetup.FrequencyInHertz > 0)
                            is_idx_closest_post_end_timeline_with_sensing_found = true;
                            idx_group_sensing = j;
                        end
                    end
                end
            end

            i = i + 1;
        end

        temp = data.GroupHistory(aux_idx_GroupHistory_entry_tested).Groups{idx_group_sensing}.ProgramSettings.SensingChannel.Channel;
        temp = strrep(temp, '_AND_', ' ');
        temp = strrep(temp, 'SensingElectrodeConfigDef.', '');
        obj.chronic_parameters.time_domain.sensing = temp';
        obj.chronic_parameters.time_domain.center_frequency = cellfun(@(h) h.FrequencyInHertz, {data.GroupHistory(aux_idx_GroupHistory_entry_tested).Groups{idx_group_sensing}.ProgramSettings.SensingChannel.SensingSetup});

    else
        obj.chronic_parameters.time_domain.sensing = {};
        obj.chronic_parameters.time_domain.center_frequency = [];
    end

    obj.chronic_parameters.time_domain.hemispheres = LFPTrendLogs.LFP.hemispheres;
    obj.chronic_parameters.time_domain.data = LFPTrendLogs.LFP.data;
    obj.chronic_parameters.time_domain.time = LFPTrendLogs.LFP.time;
    obj.chronic_parameters.time_domain.xlabel = LFPTrendLogs.LFP.xlabel;
    obj.chronic_parameters.time_domain.ylabel = LFPTrendLogs.LFP.ylabel;

    %obj.chronic_parameters.time_domain.fs = 2; % adapt to PERCEPT specifications

    if isfield(data.DiagnosticData.LFPTrendLogs,'HemisphereLocationDef_Left' )
        datetime_list = fieldnames(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Left);
    else
        datetime_list = fieldnames(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Right);
    end

    %datetime_list = obj.chronic_parameters.time_domain.days.datetime_list;

    if isfield(data.DiagnosticData.LFPTrendLogs,'HemisphereLocationDef_Left' )
        nr_days = length (fieldnames(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Left));
    else
        nr_days = length (fieldnames(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Right));
    end
    obj.chronic_parameters.time_domain.days.number = nr_days;

    if isfield(data.DiagnosticData.LFPTrendLogs,'HemisphereLocationDef_Left' )
        for i=1:nr_days
            day_left = getfield(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Left, datetime_list{i});
        end
    end
    if isfield(data.DiagnosticData.LFPTrendLogs,'HemisphereLocationDef_Right' )
        for i=1:nr_days
            day_right = getfield(data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Right, datetime_list{i});
        end
    end

    % Fill parameters for stimulation amplitude
    obj.chronic_parameters.stim_amp.data = LFPTrendLogs.stimAmp.data;
    obj.chronic_parameters.stim_amp.time = LFPTrendLogs.stimAmp.time;
    obj.chronic_parameters.stim_amp.xlabel = LFPTrendLogs.stimAmp.xlabel;
    obj.chronic_parameters.stim_amp.ylabel = LFPTrendLogs.stimAmp.ylabel;
    if isfield(data.Groups.Initial([data.Groups.Initial.ActiveGroup]).ProgramSettings, 'SensingChannel' )
        temp = {data.Groups.Initial([data.Groups.Initial.ActiveGroup]).ProgramSettings.SensingChannel.ProgramId};
        temp = strrep(temp, 'ProgramIdDef.', ' ');
        obj.chronic_parameters.stim_amp.channel_names = temp';
    else
        obj.chronic_parameters.stim_amp.channel_names = {};
    end
    obj.chronic_parameters.stim_amp.n_channels = LFPTrendLogs.stimAmp.nChannels;
    obj.chronic_parameters.stim_amp.fs = 2; % adapt to PERCEPT specifications

    % Fill parameters for events
    if isfield(LFPTrendLogs, 'events')
        status_events = 1;
        obj.chronic_parameters.type_events = [];
        for i = 1:length(data.PatientEvents.Initial)
            obj.chronic_parameters.type_events{i} = [data.PatientEvents.Initial(i).EventName];
        end
        obj.chronic_parameters.events.date_time = table2array(LFPTrendLogs.events(:,1));
        obj.chronic_parameters.events.event_id = table2array(LFPTrendLogs.events(:,2));
        obj.chronic_parameters.events.event_name = table2array(LFPTrendLogs.events(:,3));
        obj.chronic_parameters.events.lfp = table2array(LFPTrendLogs.events(:,4));
        obj.chronic_parameters.events.cycling = table2array(LFPTrendLogs.events(:,5));
        obj.chronic_parameters.events.lfp_frequency_snapshots_events = table2array(LFPTrendLogs.events(:,6));
        obj.chronic_parameters.events.eventslist = {data.PatientEvents.Initial.EventName};
        obj.chronic_parameters.events.amp_summary = data.EventSummary.LfpAndAmplitudeSummary;
        obj.chronic_parameters.events.type_event = {data.PatientEvents.Initial.EventName};
    else
        obj.chronic_parameters.events.date_time = [];
        obj.chronic_parameters.events.event_id = [];
        obj.chronic_parameters.events.event_name = [];
        obj.chronic_parameters.events.lfp = [];
        obj.chronic_parameters.events.cycling = [];
        obj.chronic_parameters.events.lfp_frequency_snapshots_events = [];
        obj.chronic_parameters.events.eventslist = [];
        obj.chronic_parameters.events.amp_summary = [];
        obj.chronic_parameters.events.type_event = [];
    end

    % Check available hemispheres
    LFP_ordered = obj.chronic_parameters.time_domain.data;
    % for c = 1:numel(LFP_ordered(1,:))
    %     if length(LFP_ordered(1,:)) == 2
    %         disp('Two hemispheres available')
    %     elseif length(LFP_ordered(1,:)) == 1
    %         disp('Only one hemispheres available')
    %     end
    % end

    if ~isempty(obj.chronic_parameters.events.lfp_frequency_snapshots_events)
        status_events_FFT = 1;
    end
    
    status_timeline = 1;

end


end

