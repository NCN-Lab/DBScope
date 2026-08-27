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
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Pedro Melo & Paulo Aguiar - NCN
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
        sensChan = data.Groups.Initial([data.Groups.Initial.ActiveGroup]).ProgramSettings.SensingChannel;
        
        % Check if MATLAB parsed it as a cell or struct array
        if iscell(sensChan)
            temp = cellfun(@(x) x.Channel, sensChan, 'UniformOutput', false);
            freqs = cellfun(@(x) x.SensingSetup.FrequencyInHertz, sensChan);
        else
            temp = {sensChan.Channel};
            freqs = arrayfun(@(x) x.SensingSetup.FrequencyInHertz, sensChan);
        end
        
        temp = strrep(temp, '_AND_', ' ');
        temp = strrep(temp, 'SensingElectrodeConfigDef.', '');
        obj.chronic_parameters.time_domain.sensing = temp';
        obj.chronic_parameters.time_domain.center_frequency = freqs;
    elseif ~isempty(data.GroupHistory)
        % --- COMPATIBILITY FIX: Get Max Time from Cell Array ---
        if iscell(LFPTrendLogs.LFP.time)
            valid_times = LFPTrendLogs.LFP.time(~cellfun(@isempty, LFPTrendLogs.LFP.time));
            if ~isempty(valid_times)
                aux_endtime_timeline = max(cellfun(@max, valid_times));
            else
                aux_endtime_timeline = datetime('now'); % Fallback
            end
        else
            aux_endtime_timeline = LFPTrendLogs.LFP.time(end);
        end
        
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
                if iscell(aux_data_groups)
                    aux_group = aux_data_groups{j};
                else 
                    aux_group = aux_data_groups(j);
                end
                
                if isfield(aux_group, 'ProgramSettings') && isfield(aux_group.ProgramSettings, 'SensingChannel')
                    % Safe frequency check for group history
                    sensChanHist = aux_group.ProgramSettings.SensingChannel;
                    if iscell(sensChanHist)
                        check_freq = sensChanHist{1}.SensingSetup.FrequencyInHertz;
                    else
                        check_freq = sensChanHist(1).SensingSetup.FrequencyInHertz;
                    end
                    
                    if check_freq > 0
                        is_idx_closest_post_end_timeline_with_sensing_found = true;
                        idx_group_sensing = j;
                    end
                end
            end
            i = i + 1;
        end
        
        % --- SAFE EXTRACTION: Group History ---
        if iscell(data.GroupHistory(aux_idx_GroupHistory_entry_tested).Groups)
            if idx_group_sensing > 0
                targetGroup = data.GroupHistory(aux_idx_GroupHistory_entry_tested).Groups{idx_group_sensing};
            end
        else
            if idx_group_sensing > 0
                targetGroup = data.GroupHistory(aux_idx_GroupHistory_entry_tested).Groups(idx_group_sensing);
            end
        end
        
        if exist("targetGroup","var")
            sensChanFinal = targetGroup.ProgramSettings.SensingChannel;
            if iscell(sensChanFinal)
                temp = cellfun(@(x) x.Channel, sensChanFinal, 'UniformOutput', false);
                freqs = cellfun(@(x) x.SensingSetup.FrequencyInHertz, sensChanFinal);
            else
                temp = {sensChanFinal.Channel};
                freqs = arrayfun(@(x) x.SensingSetup.FrequencyInHertz, sensChanFinal);
            end
            
            temp = strrep(temp, '_AND_', ' ');
            temp = strrep(temp, 'SensingElectrodeConfigDef.', '');
            obj.chronic_parameters.time_domain.sensing = temp';
            obj.chronic_parameters.time_domain.center_frequency = freqs;
        end
        
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

% --- SAFE EXTRACTION: Stim Amp Channel Names ---
    if isfield(data.Groups.Initial([data.Groups.Initial.ActiveGroup]).ProgramSettings, 'SensingChannel' )
        sensChan = data.Groups.Initial([data.Groups.Initial.ActiveGroup]).ProgramSettings.SensingChannel;
        if iscell(sensChan)
            temp = cellfun(@(x) x.ProgramId, sensChan, 'UniformOutput', false);
        else
            temp = {sensChan.ProgramId};
        end
        temp = strrep(temp, 'ProgramIdDef.', ' ');
        obj.chronic_parameters.stim_amp.channel_names = temp';
    else
        obj.chronic_parameters.stim_amp.channel_names = {};
    end
    
    obj.chronic_parameters.stim_amp.n_channels = LFPTrendLogs.stimAmp.nChannels;
    obj.chronic_parameters.stim_amp.fs = 2; % adapt to PERCEPT specifications
    
    % Fill parameters for events
    if isfield(LFPTrendLogs, 'events') && ~isempty(LFPTrendLogs.events)
        status_events = 1;
        
        obj.chronic_parameters.events.date_time = table2array(LFPTrendLogs.events(:,1));
        obj.chronic_parameters.events.event_id = table2array(LFPTrendLogs.events(:,2));
        obj.chronic_parameters.events.event_name = table2array(LFPTrendLogs.events(:,3));
        obj.chronic_parameters.events.lfp = table2array(LFPTrendLogs.events(:,4));
        obj.chronic_parameters.events.cycling = table2array(LFPTrendLogs.events(:,5));
        obj.chronic_parameters.events.lfp_frequency_snapshots_events = table2array(LFPTrendLogs.events(:,6));
        
        if isfield(data, 'EventSummary') && isfield(data.EventSummary, 'LfpAndAmplitudeSummary')
            obj.chronic_parameters.events.amp_summary = data.EventSummary.LfpAndAmplitudeSummary;
        else
            obj.chronic_parameters.events.amp_summary = [];
        end
        
        unique_ids = unique(obj.chronic_parameters.events.event_id);
        aux_list = cell(1, length(unique_ids));
        
        for k = 1:length(unique_ids)
            idx = find(obj.chronic_parameters.events.event_id == unique_ids(k), 1);
            if iscell(obj.chronic_parameters.events.event_name)
                aux_list{k} = obj.chronic_parameters.events.event_name{idx};
            else
                aux_list{k} = strtrim(obj.chronic_parameters.events.event_name(idx, :));
            end
        end
        
        obj.chronic_parameters.type_events = aux_list;
        obj.chronic_parameters.events.eventslist = aux_list;
        obj.chronic_parameters.events.type_event = aux_list;
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
    
    if ~isempty(obj.chronic_parameters.events.lfp_frequency_snapshots_events)
        status_events_FFT = 1;
    end
    
    status_timeline = 1;
end

end

