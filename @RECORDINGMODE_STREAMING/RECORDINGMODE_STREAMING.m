classdef RECORDINGMODE_STREAMING < RECORDINGMODE_COMMONMETHODS
    % Object with properties and methods to analyse streaming fields from PerceptPC json data at NCN lab
    %
    % Available at: https://github.com/NCN-Lab/DBScope
    % For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
    % a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: https://doi.org/10.1101/2023.07.23.23292136.
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
            obj.streaming_parameters.time_domain.channel_map = nan;
            obj.streaming_parameters.time_domain.fs = nan;
            obj.streaming_parameters.time_domain.channel_names = nan;
            obj.streaming_parameters.time_domain.data = nan;
            obj.streaming_parameters.time_domain.time = nan;
            obj.streaming_parameters.time_domain.first_tick_in_sec = nan;
            obj.streaming_parameters.time_domain.xlabel = nan;
            obj.streaming_parameters.time_domain.ylabel = nan;
            obj.streaming_parameters.time_domain.ecg_clean = nan;
            obj.streaming_parameters.time_domain.wearables_sync = nan;
            obj.streaming_parameters.time_domain.ratiobands = nan;

            % Initiate all defined properties for stimulation as NaN
            obj.streaming_parameters.stim_amp.data = nan;
            obj.streaming_parameters.stim_amp.time = nan;
            obj.streaming_parameters.stim_amp.fs = nan;
            obj.streaming_parameters.stim_amp.ylabel = nan;
            obj.streaming_parameters.stim_amp.channel_names = nan;
            obj.streaming_parameters.stim_amp.first_tick_in_sec = nan;

            % Initiate all defined properties for filtered data as NaN
            obj.streaming_parameters.filtered_data.filter_type = nan;
            obj.streaming_parameters.filtered_data.up_bound = nan;
            obj.streaming_parameters.filtered_data.low_bound = nan;
            obj.streaming_parameters.filtered_data.data = nan;
            obj.streaming_parameters.filtered_data.original = {};

        end

        plotRawDataStream( obj )
        [LFP, stimAmp] = fillStreamingParameters( obj, data, fname, obj_file )
        plotFiltDataStream( obj, filter_indx, varargin )
        plotFiltDataStream_multi( obj, filter_indx, varargin )

        %filt
        %[ data_type ] = aux_batchStreaming_filt( obj )
        filtStreaming( obj, fs, data_type, filterType, order, varargin )
        text = cleanECG( obj,  fs, varargin )
        deleteFilter( obj, filt_list )

        %Correlation, covariance and coherence methods
        plotCoherence ( obj, varargin )
        plotCoherence_band ( obj, varargin )
        plotAutoCorrVar( obj, varargin )
        plotCrossCrorrVar( obj, varargin )

        %Spectral analysis methods
        plotSignalAndStimulation( obj, varargin )
        plotPWelch( obj, varargin )
        plotScalogram_CWT( obj, varargin )
        plotSpectrogram( obj, varargin )
        plotSummaryStreaming( obj, varargin )
        ratioBands( obj )

        %vw
        [ data_type ] = aux_batchStreaming_vw( obj )

    end

    methods ( Hidden )
        channelsFig = plotChannels(obj, data, channelParams)
    end

end