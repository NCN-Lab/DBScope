function [ status, text ] = loadFile( obj, file_pathname, filename )
% Upload json data from file.
%
% Syntax:
%   LOADFILE(obj, file_pathname, filename);
%
% Input parameters:
%    * obj - object containg data
%    * file_pathname
%    * filename
%
% Output parameters:
%   status
%   text
%
% Example:
%    LOADFILE(file_pathname, filename);
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

text = [];

%% Load File

fname = [file_pathname, filename];
obj.fname = fname;
data = jsondecode( fileread( fname ) );

% Save obj parameters
obj.parameters.fname = fname;
obj.parameters.session_date = datetime( data.SessionDate, "InputFormat", 'yyyy-MM-dd''T''HH:mm:ss''Z''' );
obj.parameters.save_pathname = [ file_pathname filesep regexprep(data.SessionDate, {':', '-', 'Z'}, {''}) ];
obj.parameters.correct_4_missing_samples = false; %set as 'true' if device synchronization is required
obj.parameters.programmer_version = data.ProgrammerVersion;
obj.parameters.programmer_utc = data.ProgrammerUtcOffset;

obj.parameters.patient_information.patient_id = data.PatientInformation.Final.PatientId;
obj.parameters.patient_information.patient_gender = data.PatientInformation.Final.PatientGender;

moments = ["Initial", "Final"];
hemisphere_labels = ["LeftHemisphere", "RightHemisphere"];
for m = moments
    for group = 1:length(data.Groups.(m))
        obj.parameters.groups.(lower(m))(group).groupID = data.Groups.(m)(group).GroupId;
        obj.parameters.groups.(lower(m))(group).group_name = data.Groups.(m)(group).GroupName;
        obj.parameters.groups.(lower(m))(group).active = data.Groups.(m)(group).ActiveGroup;

        obj.parameters.groups.(lower(m))(group).stimulation = struct;
        for hemisphere = 1:length(hemisphere_labels)
            if isfield(data.Groups.(m)(group).ProgramSettings, hemisphere_labels(hemisphere))
                obj.parameters.groups.(lower(m))(group).stimulation.hemispheres(hemisphere).location = ...
                    data.Groups.(m)(group).ProgramSettings.(hemisphere_labels(hemisphere)).Programs.ProgramId;
                obj.parameters.groups.(lower(m))(group).stimulation.hemispheres(hemisphere).amplitude = ...
                    data.Groups.(m)(group).ProgramSettings.(hemisphere_labels(hemisphere)).Programs.AmplitudeInMilliAmps;
                obj.parameters.groups.(lower(m))(group).stimulation.hemispheres(hemisphere).pulse_width = ...
                    data.Groups.(m)(group).ProgramSettings.(hemisphere_labels(hemisphere)).Programs.PulseWidthInMicroSecond;
                switch obj.parameters.programmer_version(1)
                    case '2'
                        obj.parameters.groups.(lower(m))(group).stimulation.hemispheres(hemisphere).frequency = ...
                            data.Groups.(m)(group).ProgramSettings.RateInHertz;
                    case '3'
                        if isfield(data.Groups.(m)(group).ProgramSettings, "SensingChannel")
                            obj.parameters.groups.(lower(m))(group).sensing.hemispheres(hemisphere).frequency = ...
                                data.Groups.(m)(group).ProgramSettings.SensingChannel{hemisphere}.RateInHertz;
                        else
                            obj.parameters.groups.(lower(m))(group).sensing.hemispheres(hemisphere).frequency = ...
                                data.Groups.(m)(group).ProgramSettings.(hemisphere_labels(hemisphere)).Programs.RateInHertz;
                        end
                end
            else
                obj.parameters.groups.(lower(m))(group).stimulation = [];
            end
        end

        obj.parameters.groups.(lower(m))(group).sensing = struct;
        if isfield(data.Groups.(m)(group).ProgramSettings, "SensingChannel")
            for hemisphere = 1:length(data.Groups.(m)(group).ProgramSettings.SensingChannel)
                obj.parameters.groups.(lower(m))(group).sensing.hemispheres(hemisphere).location = ...
                    data.Groups.(m)(group).ProgramSettings.SensingChannel(hemisphere).HemisphereLocation;
                obj.parameters.groups.(lower(m))(group).sensing.hemispheres(hemisphere).channel = ...
                    strrep(data.Groups.(m)(group).ProgramSettings.SensingChannel(hemisphere).Channel, "SensingElectrodeConfigDef.", "");
                obj.parameters.groups.(lower(m))(group).sensing.hemispheres(hemisphere).status = ...
                    data.Groups.(m)(group).ProgramSettings.SensingChannel(hemisphere).BrainSensingStatus;
                obj.parameters.groups.(lower(m))(group).sensing.hemispheres(hemisphere).pulse_width = ...
                    data.Groups.(m)(group).ProgramSettings.SensingChannel(hemisphere).PulseWidthInMicroSecond;
                switch obj.parameters.programmer_version(1)
                    case '2'
                        obj.parameters.groups.(lower(m))(group).sensing.hemispheres(hemisphere).frequency = ...
                            data.Groups.(m)(group).ProgramSettings.RateInHertz;
                    case '3'
                        obj.parameters.groups.(lower(m))(group).sensing.hemispheres(hemisphere).frequency = ...
                            data.Groups.(m)(group).ProgramSettings.SensingChannel(hemisphere).RateInHertz;
                end
                obj.parameters.groups.(lower(m))(group).sensing.hemispheres(hemisphere).center_frequency = ...
                    data.Groups.(m)(group).ProgramSettings.SensingChannel(hemisphere).SensingSetup.FrequencyInHertz;
                obj.parameters.groups.(lower(m))(group).sensing.hemispheres(hemisphere).artifact_status = ...
                    data.Groups.(m)(group).ProgramSettings.SensingChannel(hemisphere).SensingSetup.ChannelSignalResult.ArtifactStatus;
            end
        else
            obj.parameters.groups.(lower(m))(group).sensing = [];
        end
    end
end

%% Check Recordings Modes & fill obj classes

survey = 0;
survey_str = ('Not available');
if isfield( data, 'LFPMontage' )
    lfp_time_domain = obj.survey_obj.fillSurveyParametersMontage( data, fname, obj );
    survey = 1;
    survey_str = ('Available');
    field = 1;
end

indefinite_streaming = 0;
indefinite_streaming_str = ('Not available');
if isfield( data, 'IndefiniteStreaming' ) % Survey Indefinite Streaming
    lfp_indefinite = obj.indefinite_obj.fillSurveyParametersIndStr( data, fname, obj );
    indefinite_streaming = 1;
    indefinite_streaming_str = ('Available');
    field = 2;
end

setup = 0;
setup_str = ('Not available');
if ~isempty( data.MostRecentInSessionSignalCheck ) % Setup
    setup = 1;
    setup_str = ('Available');
end

setup_off_stim_str = ('Not available');
setup_off_stim = 0;
if isfield( data, 'SenseChannelTests' ) % Setup OFF stimulation
    LFP_OFF = obj.setup_obj.fillSetupParametersOFF( data, fname, obj );
    setup_off_stim = 1;
    setup_off_stim_str = ('Available');
    field = 3;
end

setup_on_stim = 0;
setup_on_stim_str = ('Not available');
if isfield( data, 'CalibrationTests' ) % Setup ON stimulation
    LFP_ON  = obj.setup_obj.fillSetupParametersON( data, fname, obj );
    setup_on_stim = 1;
    setup_on_stim_str = ('Available');
    field = 4;
end

time_domain = 0;
time_domain_str = ('Not available');
if isfield( data, 'BrainSenseTimeDomain' ) % Streaming on-line ( in clinic ) after Setup
    obj.recording_mode.mode_stim = 'BrainSenseLFP'; 
    [LFP, stimAmp] = obj.streaming_obj.fillStreamingParameters( data, obj );
    time_domain = 1;
    time_domain_str = ('Available');
    field = 5;
end

timeline_events = 0;
events_present = 0;
events_FFT = 0;
timeline_events_str = ('Not available');
if isfield( data, 'DiagnosticData' ) && isfield( data.DiagnosticData, 'LFPTrendLogs' ) % Timeline and Events
    obj.recording_mode.mode = 'LFPTrendLogs';
    [ status_events, status_fft, LFP_ordered ]= obj.chronic_obj.fillChronicParameters( data, fname, obj );
    timeline_events = 1;
    timeline_events_str = ('Available');
    events_present = status_events;
    events_FFT = status_fft;
    field = 6;
end

disp([ 'File name: ', filename , newline...
    'BrainSense Survey: ', survey_str, newline...
    'BrainSense Survey Indefinite Streaming: ', indefinite_streaming_str, newline,...
    'BrainSense Setup: ', setup_str, newline,...
    'BrainSense Setup OFF Stimulation: ', setup_off_stim_str, newline,...
    'BrainSense Setup ON Stimulation: ', setup_on_stim_str, newline,...
    'BrainSense Timeline and Events: ', timeline_events_str,newline,...
    'BrainSense Streaming: ', time_domain_str ]);

text = [ '# File name: ', filename , newline...
    newline...
    '# BrainSense Survey: ', survey_str, newline...
    newline...
    '# BrainSense Survey Indefinite Streaming: ' , indefinite_streaming_str, newline,...
    newline...
    '# BrainSense Setup: ', setup_str, newline,...
    newline...
    '# BrainSense Setup OFF Stimulation: ', setup_off_stim_str, newline,...
    newline...
    '# BrainSense Setup ON Stimulation: ', setup_on_stim_str, newline,...
    newline...
    '# BrainSense Timeline and Events: ', timeline_events_str,newline,...
    newline...
    '# BrainSense Streaming: ', time_domain_str ];

%clean records of last recording mode
obj.recording_mode.mode = nan;
obj.recording_mode.n_channels = nan;
obj.recording_mode.channel_map = nan;
obj.recording_mode.mode_stim = nan;

%% Get parameters

status_impedance = obj.getImpedance( data );

obj.status.events = events_present;
obj.status.events_FFT = events_FFT;
obj.status.chronic = timeline_events;
obj.status.setup_on = setup_on_stim;
obj.status.setup_off = setup_off_stim;
obj.status.survey = survey;
obj.status.indefinite = indefinite_streaming;
obj.status.streaming = time_domain;
obj.status.impedance = status_impedance;

obj.parameters.system_information.battery_percentage = data.BatteryInformation.BatteryPercentage;
obj.parameters.system_information.battery_status = data.BatteryInformation.BatteryStatus;
obj.parameters.system_information.neurostimulator = data.DeviceInformation.Initial.Neurostimulator;
obj.parameters.system_information.model = data.DeviceInformation.Initial.NeurostimulatorModel;
obj.parameters.system_information.location = data.DeviceInformation.Initial.NeurostimulatorLocation;
obj.parameters.system_information.device_date = data.DeviceInformation.Initial.DeviceDateTime;
obj.parameters.system_information.implantation_date = data.DeviceInformation.Initial.ImplantDate;
obj.parameters.system_information.accumulated_therapy_on_time_since_implant = data.DeviceInformation.Initial.AccumulatedTherapyOnTimeSinceImplant;
obj.parameters.system_information.accumulated_therapy_on_time_since_followup = data.DeviceInformation.Initial.AccumulatedTherapyOnTimeSinceFollowup;
obj.parameters.system_information.lead_location_left_hemisphere = data.LeadConfiguration.Initial(1).LeadLocation;
obj.parameters.system_information.lead_location_right_hemisphere = data.LeadConfiguration.Initial(2).LeadLocation;
obj.parameters.system_information.lead_electrode_number_left_hemisphere = data.LeadConfiguration.Initial(1).ElectrodeNumber;
obj.parameters.system_information.lead_electrode_number_right_hemisphere = data.LeadConfiguration.Initial(2).ElectrodeNumber;
obj.parameters.system_information.clinical_notes = data.PatientInformation.Initial.ClinicianNotes;
obj.parameters.system_information.diagnosis = data.PatientInformation.Initial.Diagnosis;
obj.parameters.system_information.start_of_session = strrep(data.SessionDate(1:end-1),'T',' ');
obj.parameters.system_information.end_of_session = strrep(data.SessionEndDate(1:end-1),'T',' ');
obj.parameters.system_information.initial_stimulation_status = data.Stimulation.InitialStimStatus;
obj.parameters.system_information.final_stimulation_status = data.Stimulation.FinalStimStatus;
obj.parameters.system_information.medication_state = nan; % Clinician can add here information

if ~isempty(data.MostRecentInSessionSignalCheck)
    obj.parameters.mostrecent.artifactstatus = {data.MostRecentInSessionSignalCheck.ArtifactStatus};
else
    obj.parameters.mostrecent.artifactstatus = [];
end

status = 1;

end