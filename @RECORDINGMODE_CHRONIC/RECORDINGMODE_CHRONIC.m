classdef RECORDINGMODE_CHRONIC < RECORDINGMODE_COMMONMETHODS
    % Object with properties and methods to analyse chronic fields from PerceptPC json data at NCN lab
    %
    % Available at: https://github.com/NCN-Lab/DBScope
    % For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
    % a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
    %
    % Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
    % INEB/i3S 2022
    % pauloaguiar@i3s.up.pt
    % -----------------------------------------------------------------------

    % Add folders to path!

    properties ( SetAccess = private )
        chronic_parameters
    end

    methods
        function obj = RECORDINGMODE_CHRONIC() % constructor
            disp('Initialization of RECORDINGMODE_CHRONIC class');

            % Initiate all defined properties for time domain LFP as NaN
            obj.chronic_parameters.time_domain.recording_mode = nan;
            obj.chronic_parameters.time_domain.n_channels = nan;
            obj.chronic_parameters.time_domain.channel_names = nan;
            obj.chronic_parameters.time_domain.data = nan;
            obj.chronic_parameters.time_domain.time = nan;
            obj.chronic_parameters.time_domain.days.datetime_list = nan;
            obj.chronic_parameters.time_domain.days.number = nan;
            obj.chronic_parameters.time_domain.days.left =  nan;
            obj.chronic_parameters.time_domain.days.right = nan;

            % Initiate all defined properties for stimulation as NaN
            obj.chronic_parameters.stim_amp.data = nan;
            obj.chronic_parameters.stim_amp.time = nan;
            obj.chronic_parameters.stim_amp.xlabel = nan;
            obj.chronic_parameters.stim_amp.ylabel = nan;
            obj.chronic_parameters.stim_amp.channel_names = nan;
            obj.chronic_parameters.stim_amp.n_channels = nan;
            obj.chronic_parameters.stim_amp.fs = nan;

            % Initiate all defined properties for events as NaN
            obj.chronic_parameters.events.date_time = nan;
            obj.chronic_parameters.events.event_id = nan;
            obj.chronic_parameters.events.event_name = nan;
            obj.chronic_parameters.events.lfp = nan;
            obj.chronic_parameters.events.cycling = nan;
            obj.chronic_parameters.events.lfp_frequency_snapshots_events = nan;

            % Format for events functions
            obj.chronic_parameters.events.eventslist = nan;
            obj.chronic_parameters.events.amp_summary = nan;


        end

        %Extract LFP methods
        [ status_timeline, status_events, status_events_FFT ] = fillChronicParameters( obj, data )
        h = plotLFPTrendLogs(obj, LFPTrendLogs, ActiveGroup)

        %%Event Analysis
        plotMeanFFTProfile ( obj, varargin )
        plotSelectedFFTProfile ( obj, varargin )
        plotEventHistograms ( obj, varargin )
        plotETA( obj, varargin )

        %LFPs
        plotAutoCorrVarChronic( obj, varargin )
        plotCrossCorrVarChronic( obj, varargin )

    end

    methods ( Access = private )
        [ LFPTrendLogs ] = extractTrendLogs( obj, data, parameters  )
    end

    methods ( Hidden )
        [ stimAmp ] = extractStimAmp( obj, data, parameters )
        [ LFP ] = extractLFP( obj, data, parameters )
    end

end