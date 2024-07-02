classdef RECORDINGMODE_STREAMING < RECORDINGMODE_COMMONMETHODS
    % Object with properties and methods to analyse streaming fields from PerceptPC json data at NCN lab
    %
    % Available at: https://github.com/NCN-Lab/DBScope
    % For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
    % a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
    %
    % Andreia M. Oliveira, Beatriz Barros, Eduardo Carvalho & Paulo Aguiar - NCN
    % INEB/i3S 2022
    % pauloaguiar@i3S.up.pt
    % -----------------------------------------------------------------------

    % Add folders to path!

    properties ( SetAccess = private )
        streaming_parameters
    end

    methods
        function obj = RECORDINGMODE_STREAMING() % constructor
            disp('Initialization of RECORDINGMODE_STREAMING class');

            % Initiate all defined properties for time domain LFP as NaN
            obj.streaming_parameters.time_domain.recording_mode = nan;
            obj.streaming_parameters.time_domain.nchannels = nan;
            obj.streaming_parameters.time_domain.channel_names = nan;
            obj.streaming_parameters.time_domain.fs = nan;
            obj.streaming_parameters.time_domain.first_packet_datetimes = nan;
            obj.streaming_parameters.time_domain.global_packets_ID = nan;
            obj.streaming_parameters.time_domain.global_packets_size = nan;
            obj.streaming_parameters.time_domain.global_packets_ticks = nan;
            obj.streaming_parameters.time_domain.data = nan;
            obj.streaming_parameters.time_domain.time = nan;
            obj.streaming_parameters.time_domain.ecg_clean = nan;

            % Initiate all defined properties for stimulation as NaN
            obj.streaming_parameters.stim_amp.recording_mode = nan;
            obj.streaming_parameters.stim_amp.group = nan;
            obj.streaming_parameters.stim_amp.therapy_snapshot = nan;
            obj.streaming_parameters.stim_amp.stim_channel_names = nan;
            obj.streaming_parameters.stim_amp.sensing_channel_names = nan;
            obj.streaming_parameters.stim_amp.fs = nan;
            obj.streaming_parameters.stim_amp.global_packets_ID = nan;
            obj.streaming_parameters.stim_amp.global_packets_ticks = nan;
            obj.streaming_parameters.stim_amp.data = nan;
            obj.streaming_parameters.stim_amp.time = nan;

            % Initiate all defined properties for filtered data as NaN
            obj.streaming_parameters.filtered_data.filter_type = nan;
            obj.streaming_parameters.filtered_data.bounds = nan;
            obj.streaming_parameters.filtered_data.data = nan;
            obj.streaming_parameters.filtered_data.original_data_ID = nan;
            obj.streaming_parameters.filtered_data.data_ID = nan;

        end
        
        % Parsing method
        status = fillStreamingParameters( obj, data )

        % Data structure methods
        deleteRecordings( obj, indx )
        concatenateRecordings( obj, indx_alpha, indx_beta )
        reorderRecordings ( obj, order_indx )
        correctMissingSamples( obj, rec, new_lfp_time, new_stim_time )

        % Filtering methods
        filtStreaming( obj, fs, data_type, filterType, order, varargin )
        text = cleanECG( obj,  fs, varargin )
        deleteFilters( obj, indx )

        % Correlation, covariance and coherence methods
        plotCoherence ( obj, varargin )
        plotCoherence_band ( obj, varargin )
        plotAutoCorrVar( obj, varargin )
        plotCrossCrorrVar( obj, varargin )

        % Spectral analysis methods
        plotSignalAndStimulation( obj, varargin )
        plotPWelch( obj, varargin )
        plotScalogram( obj, varargin )
        plotSpectrogram( obj, varargin )
        plotSummaryStreaming( obj, varargin )

        % Plot methods
        plotRawDataStream( obj )
        plotFiltDataStream( obj, filter_indx, varargin )
        plotFiltDataStream_multi( obj, filter_indx, varargin )
        plotBandpowerPerStimulationLevel ( obj, bounds, varargin )


    end

end