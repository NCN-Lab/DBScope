classdef RECORDINGMODE_SETUP < RECORDINGMODE_COMMONMETHODS
    % Object with properties and methods to analyse setup fields from
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
        setup_parameters
    end

    methods
        function obj = RECORDINGMODE_SETUP() % constructor
            disp('Initialization of RECORDINGMODE_SETUP class');

            % Initiate all defined properties for time domain LFP with stimulation off as NaN
            obj.setup_parameters.stim_off.recording_mode = nan;
            obj.setup_parameters.stim_off.nchannels = nan;
            obj.setup_parameters.stim_off.channel_map = nan;
            obj.setup_parameters.stim_off.channel_names = nan;
            obj.setup_parameters.stim_off.data = nan;
            obj.setup_parameters.stim_off.fs = nan;
            obj.setup_parameters.stim_off.time = nan;
            obj.setup_parameters.stim_off.xlabel = nan;
            obj.setup_parameters.stim_off.ylabel = nan;
            obj.setup_parameters.stim_off.stimulationstatus = nan;

            % Initiate all defined properties for time domain LFP with stimulation on as NaN
            obj.setup_parameters.stim_on.recording_mode = nan;
            obj.setup_parameters.stim_on.nchannels = nan;
            obj.setup_parameters.stim_on.channel_map = nan;
            obj.setup_parameters.stim_on.channel_names = nan;
            obj.setup_parameters.stim_on.fs = nan;
            obj.setup_parameters.stim_on.time = nan;
            obj.setup_parameters.stim_on.xlabel = nan;
            obj.setup_parameters.stim_on.ylabel = nan;
            obj.setup_parameters.stim_on.stimulationstatus = nan;
            obj.setup_parameters.stim_on.data = nan;
        end

        % Plot methods
        [ LFP_OFF ] = fillSetupParametersOFF( obj, data, fname, obj_file )
        [ LFP_ON ] = fillSetupParametersON( obj, data, fname, obj_file )
        plotRawDataSetupOFF( obj, varargin )
        plotRawDataSetupON( obj, varargin )
    end

    methods ( Hidden )
        [ lfp ] = extractStimAmp( obj, data, obj_file )
        plotFiltData_ordered( obj, data, obj_file )
        channelsFig = plotChannels(obj, data, channelParams)
    end

end