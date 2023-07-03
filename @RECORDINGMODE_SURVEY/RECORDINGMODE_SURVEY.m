classdef RECORDINGMODE_SURVEY < RECORDINGMODE_COMMONMETHODS
    % Object with properties and methods to analyse survey fields from
    % PerceptPC json file at NCN lab
    %
    % Available at: https://github.com/NCN-Lab/DBScope
    % For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
    % a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
    %
    % Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
    % INEB/i3S 2022
    % pauloaguiar@i3s.up.pt
    % -----------------------------------------------------------------------

    properties ( SetAccess = private )
        survey_parameters
    end

    methods

        function obj = RECORDINGMODE_SURVEY() % constructor
            disp('Initialization of RECORDINGMODE_SURVEY class');

            % Initiate all defined properties for time domain as NaN
            obj.survey_parameters.time_domain.recording_mode = nan;
            obj.survey_parameters.time_domain.n_channels = nan;
            obj.survey_parameters.time_domain.channel_map = nan;
            obj.survey_parameters.time_domain.channel_names = nan;
            obj.survey_parameters.time_domain.data = nan;
            obj.survey_parameters.time_domain.fs = nan;
            obj.survey_parameters.time_domain.time = nan;
            obj.survey_parameters.time_domain.xlabel = nan;
            obj.survey_parameters.time_domain.ylabel = nan;

            % Initiate all defined properties for frequency domain as NaN
            obj.survey_parameters.frequency_domain.hemisphere = nan;
            obj.survey_parameters.frequency_domain.channel_names = nan;
            obj.survey_parameters.frequency_domain.frequency  = nan;
            obj.survey_parameters.frequency_domain.magnitude = nan;
            obj.survey_parameters.frequency_domain.artifact_status = nan;

            % Initiate all defined properties for filtered data as NaN
            obj.survey_parameters.filtered_data.filter_type = nan;
            obj.survey_parameters.filtered_data.up_bound = nan;
            obj.survey_parameters.filtered_data.low_bound = nan;
            obj.survey_parameters.filtered_data.data = nan;
            obj.survey_parameters.filtered_data.typeofdata = nan;

            obj.survey_parameters.stimulation_status = 'off';

        end

        % Fill methods
        lfp_time_domain = fillSurveyParametersMontage( obj, data, fname, obj_file  )

        % Extract LFPs
        [ lfp_montage ] = extractLFPMontage( obj, data )

        % Plot raw data
        plotRawDataLFPMontage( obj, varargin )

        % Filter data
        [ pks, locs ] = getPeaksurveyFreqDomain( obj )
        plotFFTSurvey( obj, varargin )
        status = filtSurvey( obj,  fs, filterType, order, bounds )
        plotFiltDataSurvey ( obj, varargin )
        cleanECGsurvey( obj, fs )

    end

    methods ( Hidden )
        [ lfp ] = extractStimAmp( obj, data, obj_file )
        channelsFig = plotChannels(obj, channelParams)
    end

end