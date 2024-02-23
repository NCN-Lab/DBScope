classdef NCNPERCEPT_FILE < handle
    % Object with properties and methods to analyse PerceptPC json file at NCN lab
    %
    % Available at: https://github.com/NCN-Lab/DBScope
    % For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
    % a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
    %
    % Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
    % INEB/i3S 2022
    % pauloaguiar@i3s.up.pt
    % -----------------------------------------------------------------------

    properties ( SetAccess = private )
        parameters
        survey_obj
        indefinite_obj 
        setup_obj
        streaming_obj
        chronic_obj
        wearables_obj
        status
    end

    properties ( SetAccess = public )
        recording_mode
        fname
    end

    methods
        function obj = NCNPERCEPT_FILE() % constructor
            disp('Initialization of NCNPERCEPT_FILE class');

            % Initiate all defined properties as NaN
            obj.recording_mode.mode = nan;
            obj.recording_mode.n_channels = nan;
            obj.recording_mode.channel_map = nan;

            obj.fname = nan;

            obj.parameters.session_date = nan;
            obj.parameters.save_pathname = nan;
            obj.parameters.correct4_missing_samples = nan;
            obj.parameters.programmer_version = nan;
            obj.parameters.fs = nan;
            obj.parameters.annotations = nan;

            obj.parameters.impedance.monopolar.hemispheres.results = nan;
            obj.parameters.impedance.bipolar.hemispheres.results = nan;

            obj.parameters.system_information.battery_percentage = nan;
            obj.parameters.system_information.battery_status = nan;
            obj.parameters.system_information.neurostimulator = nan;
            obj.parameters.system_information.model = nan;
            obj.parameters.system_information.location = nan;
            obj.parameters.system_information.device_date = nan;
            obj.parameters.system_information.accumulated_therapy_on_time_since_implant = nan;
            obj.parameters.system_information.accumulated_therapy_on_time_since_followup = nan;
            obj.parameters.system_information.lead_location_left_hemisphere = nan;
            obj.parameters.system_information.lead_location_right_hemisphere = nan;
            obj.parameters.system_information.lead_electrode_number_left_hemisphere = nan;
            obj.parameters.system_information.lead_electrode_number_right_hemisphere = nan;
            obj.parameters.system_information.lead_orientation_in_degrees_left_hemisphere = nan;
            obj.parameters.system_information.lead_orientation_in_degrees_right_hemisphere = nan;
            obj.parameters.system_information.clinical_notes = nan;
            obj.parameters.system_information.diagnosis = nan;
            obj.parameters.system_information.start_of_session = nan;
            obj.parameters.system_information.end_of_session = nan;
            obj.parameters.system_information.initial_stimulation_status = nan;
            obj.parameters.system_information.final_stimulation_status = nan;
            obj.parameters.system_information.medication_state = nan;

            obj.parameters.programsettings = nan;
            obj.parameters.mode = nan;

            obj.parameters.mostrecent.artifactstatus = nan;

            obj.status.events = nan;
            obj.status.events_FFT = nan;
            obj.status.chronic = nan;
            obj.status.setup_on = nan;
            obj.status.setup_off = nan;
            obj.status.survey = nan;
            obj.status.streaming = nan;

            %Initialize classes
            obj.survey_obj = RECORDINGMODE_SURVEY;
            obj.indefinite_obj = RECORDINGMODE_INDEFINITE;
            obj.setup_obj = RECORDINGMODE_SETUP;
            obj.streaming_obj = RECORDINGMODE_STREAMING;
            obj.chronic_obj = RECORDINGMODE_CHRONIC;
            obj.wearables_obj = WEARABLE_EXTERNAL;

        end

        % Load data from single json 
        [status, text] = loadFile( obj, file_pathname, filename )

        % Export methods
        exportFieldtrip( obj )

        % Get session information
        [ text ] = getBatteryInformation( obj )
        [ text ] = getDeviceInformation( obj )
        [ text ] = getLeadConfig( obj )
        [ text ] = getPatientInformation( obj )
        [ text ] = getSessionInformation( obj )
        [ text ] = getStimStatus( obj )
        [ text ] = getGroupsInformation( obj )
        [ text ] = plotImpedance( obj, varargin )
        status = getImpedance( obj, data )
        loadWearables( obj )

    end

end