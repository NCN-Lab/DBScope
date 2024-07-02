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
            obj.setup_parameters.stim_off.num_channels = nan;
            obj.setup_parameters.stim_off.channel_names = nan;
            obj.setup_parameters.stim_off.fs = nan;
            obj.setup_parameters.stim_off.data = nan;
            obj.setup_parameters.stim_off.time = nan;

            % Initiate all defined properties for time domain LFP with stimulation on as NaN
            obj.setup_parameters.stim_on.recording_mode = nan;
            obj.setup_parameters.stim_on.num_channels = nan;
            obj.setup_parameters.stim_on.channel_names = nan;
            obj.setup_parameters.stim_on.fs = nan;
            obj.setup_parameters.stim_on.time = nan;
            obj.setup_parameters.stim_on.data = nan;
        end
        
        % Parsing methods
        status = fillSetupOFFParameters( obj, data )
        status = fillSetupONParameters( obj, data )

        % Plot methods
        plotRawDataSetupOFF( obj, varargin )
        plotRawDataSetupON( obj, varargin )
        plotFFTSetupOFF( obj, varargin )
        plotFFTSetupON( obj, varargin )
    end

    methods ( Hidden )
        [ stimAmp ] = extractStimAmp( obj, data, parameters )
        plotFiltData_ordered( obj, data, obj_file )
    end

end