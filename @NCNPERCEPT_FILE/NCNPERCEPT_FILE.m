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
            obj.parameters.session_date = nan;
            obj.parameters.save_pathname = nan;
            obj.parameters.programmer_version = nan;
            obj.parameters.annotations = nan;
            obj.parameters.group_history = nan;

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

            obj.status.events       = 0;
            obj.status.events_FFT   = 0;
            obj.status.chronic      = 0;
            obj.status.setup_on     = 0;
            obj.status.setup_off    = 0;
            obj.status.survey       = 0;
            obj.status.streaming    = 0;
            obj.status.external     = 0;

            %Initialize classes
            obj.survey_obj = RECORDINGMODE_SURVEY;
            obj.indefinite_obj = RECORDINGMODE_INDEFINITE;
            obj.setup_obj = RECORDINGMODE_SETUP;
            obj.streaming_obj = RECORDINGMODE_STREAMING;
            obj.chronic_obj = RECORDINGMODE_CHRONIC;
            obj.wearables_obj = WEARABLE_EXTERNAL;

        end

        % Parsing methods
        [status, text] = loadFile( obj, file_pathname, filename )
        status = fillPatientInformation( obj, data )
        status = fillSystemInformation( obj, data )
        status = fillGroupsInformation( obj, data )
        loadWearables( obj )

        % Set methods
        setExternalStatus( obj, value )

        % Export methods
        exportFieldtrip( obj )

        % Get Information
        [ text ] = getBatteryInformation( obj )
        [ text ] = getDeviceInformation( obj )
        [ text ] = getLeadConfig( obj )
        [ text ] = getPatientInformation( obj )
        [ text ] = getSessionInformation( obj )
        [ text ] = getStimStatus( obj )
        [ text ] = getGroupsInformation( obj )
        [ text ] = plotImpedance( obj, varargin )
        status = getImpedance( obj, data )

    end

    methods (Access = private)

        group_obj = extractGroupsInformation( obj, data )
        
    end

end