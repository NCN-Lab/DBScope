function [ status_events, status_fft, LFP_ordered ] = fillChronicParameters( obj, data, fname, obj_file  )
% Extract and visualize LFPs from chronic LFP data.
%
% Syntax:
%   [ LFP, stimAmp, LFPTrendLogs, status_fft ] = FILLCHRONICPARAMETERS(
%   obj, data, fname, obj_file  );
%
% Input parameters:
%   * data - data from json file(s)
%   * fname
%   * obj_file - object structure for data
%
% Output parameters:
%   LFP
%   stimAmp
%   LFPTrendLogs
%   status_events
%   status_fft
%
% Example:
%   FILLCHRONICPARAMETERS( data, fname, obj );
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

% Extract LFPs
if isfield( data, 'DiagnosticData' ) && isfield( data.DiagnosticData, 'LFPTrendLogs' ) %Timeline
    obj_file.recording_mode.mode = 'LFPTrendLogs';
    [ LFPTrendLogs ] = obj.extractTrendLogs( data, obj_file  );

end

status_events = 0;
status_fft = 0;

% Fill parameters for time domain
obj.chronic_parameters.time_domain.recording_mode = 'LFPTrendLogs';
obj.chronic_parameters.time_domain.n_channels = LFPTrendLogs.LFP.nChannels;
if isfield(data.Groups.Initial([data.Groups.Initial.ActiveGroup]).ProgramSettings, 'SensingChannel' )
    temp = {data.Groups.Initial([data.Groups.Initial.ActiveGroup]).ProgramSettings.SensingChannel.Channel};
    temp = strrep(temp, '_AND_', ' ');
    temp = strrep(temp, 'SensingElectrodeConfigDef.', '');
    obj.chronic_parameters.time_domain.channel_names = temp;
else
    obj.chronic_parameters.time_domain.channel_names = {};
end
obj.chronic_parameters.time_domain.hemispheres = LFPTrendLogs.LFP.hemispheres;
obj.chronic_parameters.time_domain.sensing = obj_file.parameters.groups.initial(find([obj_file.parameters.groups.initial.active], 1)).sensing;
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
obj.chronic_parameters.stim_amp.channel_names = LFPTrendLogs.stimAmp.channel_names;
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
elseif isfield(data.DiagnosticData, 'EventLogs')
    obj.chronic_parameters.events.date_time = [];
    obj.chronic_parameters.events.event_id = [];
    obj.chronic_parameters.events.event_name = [];
    obj.chronic_parameters.events.lfp = [];
    obj.chronic_parameters.events.cycling = [];
    obj.chronic_parameters.events.lfp_frequency_snapshots_events = [];
    obj.chronic_parameters.events.eventslist = [];
    obj.chronic_parameters.events.amp_summary = [];
    obj.chronic_parameters.events.type_event = [];
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
for c = 1:numel(LFP_ordered(1,:))
    if length(LFP_ordered(1,:)) == 2
        disp('Two hemispheres available')
    elseif length(LFP_ordered(1,:)) == 1
        disp('Only one hemispheres available')
    end
end

if ~isempty(obj.chronic_parameters.events.lfp_frequency_snapshots_events)
    status_fft = 1;
end

end

