classdef RECORDINGMODE_INDEFINITE < RECORDINGMODE_COMMONMETHODS
    % Object with properties and methods to analyse indefinite fields from
    %
    % PerceptPC json file at NCN lab
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
        indefinite_parameters
    end

    methods

        function obj = RECORDINGMODE_INDEFINITE()
            disp('Initialization of RECORDINGMODE_INDEFINITE class');

            obj.indefinite_parameters.time_domain.recording_mode = nan;
            obj.indefinite_parameters.time_domain.n_channels = nan;
            obj.indefinite_parameters.time_domain.channel_map = nan;
            obj.indefinite_parameters.time_domain.channel_names = nan;
            obj.indefinite_parameters.time_domain.data = nan;
            obj.indefinite_parameters.time_domain.fs = nan;
            obj.indefinite_parameters.time_domain.time = nan;

            obj.indefinite_parameters.stimulation_status = 'off';

        end

        % Fill methods
        lfp_indefinite = fillSurveyParametersIndStr( obj, data, fname, obj_file )

        % Plot raw data
        plotRawDataSurveyInd( obj, varargin )

    end

    methods ( Hidden )
        [ lfp ] = extractStimAmp( obj, data, obj_file )
        channelsFig = plotChannels(obj, channelParams)
    end

end