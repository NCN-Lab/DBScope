classdef RECORDINGMODE_COMMONMETHODS < handle
    % Object with properties and auxiliar methods to analyse PerceptPC json data at NCN lab
    %
    % Available at: https://github.com/NCN-Lab/DBScope
    % For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
    % a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
    %
    % Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
    % INEB/i3S 2022
    % pauloaguiar@i3s.up.pt
    % -----------------------------------------------------------------------
    properties

    end

    methods
        function obj = RECORDINGMODE_COMMONMETHODS()

        end
    end

    methods (Access = public)
        % Auxiliar methods
        [ out ] = aux_afterPoint( obj, str )
        [ i,o ] = aux_perceive_sc( obj, vec, pts )
        [ pow,f,rpow,lpow ] = aux_perceive_fft( obj, data, fs, tw)
        spectroFig = aux_plotSpectrogram( obj, data, channelParams, varargin )
        channelsFig = plotChannels(obj, data, channelParams)

         % Extract methods
        [ LFP ] = extractLFP( obj, data, obj_file )
        [ stimAmp ] = extractStimAmp( obj, data, obj_file  )

        % Filter methods
        [ LFP_filtdata ] = applyFilt_ordered( obj, LFP_ordered, fs, filterType, order, varargin )
        [ LFP_ECGdata, text ]   = filterEcg( obj, data, fs )

    end

end

