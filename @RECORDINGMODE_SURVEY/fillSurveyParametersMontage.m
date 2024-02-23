function lfp_time_domain = fillSurveyParametersMontage( obj, data, fname, obj_file )
% Extract and visualize LFPs from Survey test mode
%
%   Syntax:
%       FILLSURVEYPARAMETERS( obj, data, fname, obj_file )
%
%   Input parameters:
%       obj
%       data
%       fname
%       obj_file
%
%   Example:
%       FILLSURVEYPARAMETERS(  data, fname, obj_file );
%
% Adapted from Yohann Thenaisie 02.09.2020 - Lausanne University Hospital
% (CHUV) https://github.com/YohannThenaisie/PerceptToolbox
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

if isfield( data, 'LFPMontage' )

    % Extract and save LFP Montage Power Spectral Density
    lfp_montage = obj.extractLFPMontage( data );

    obj.survey_parameters.frequency_domain.hemisphere = lfp_montage.hemisphere;
    obj.survey_parameters.frequency_domain.channel_names = lfp_montage.channel_names;
    obj.survey_parameters.frequency_domain.frequency  = lfp_montage.frequency;
    obj.survey_parameters.frequency_domain.magnitude = lfp_montage.magnitude;
    obj.survey_parameters.frequency_domain.artifact_status = lfp_montage.artifact_status;

    % Extract and save LFP Montage Time Domain
    obj_file.recording_mode.mode = 'LfpMontageTimeDomain';
    obj_file.recording_mode.num_channels = 6;
    obj_file.recording_mode.channel_map = [1 2 3 ; 4 5 6];
    lfp_time_domain = obj.extractLFP( data, obj_file );

    % Store data extracted
    obj.survey_parameters.time_domain.recording_mode = {lfp_time_domain.recordingMode};
    obj.survey_parameters.time_domain.num_channels = {lfp_time_domain.nChannels};
    obj.survey_parameters.time_domain.channel_map = {lfp_time_domain.channel_map};
    obj.survey_parameters.time_domain.channel_names = {lfp_time_domain.channel_names};
    obj.survey_parameters.time_domain.data = {lfp_time_domain.data};
    obj.survey_parameters.time_domain.fs = {lfp_time_domain.Fs};
    obj.survey_parameters.time_domain.time = {lfp_time_domain.time};

    % Initialize filter parameters
    obj.survey_parameters.filtered_data.filter_type = {};
    obj.survey_parameters.filtered_data.up_bound = {};
    obj.survey_parameters.filtered_data.low_bound = {};
    obj.survey_parameters.filtered_data.data = {};
    obj.survey_parameters.filtered_data.typeofdata = {};

end

end