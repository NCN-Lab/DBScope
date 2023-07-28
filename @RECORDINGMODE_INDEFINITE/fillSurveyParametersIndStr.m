function lfp_indefinite = fillSurveyParametersIndStr( obj, data, fname, obj_file  )
% FILLSURVEYPARAMETERS Extract and visualize LFPs from survey Indefinite Streaming mode
%
% Syntax:
%   FILLSURVEYPARAMETERS( obj, data, fname, obj_file );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%    * fname
%    * obj_file - object containg data
%
%   Example:
%      FILLSURVEYPARAMETERS(  data, fname, obj_file );
%
% Adapted from Yohann Thenaisie 02.09.2020 - Lausanne University Hospital
% (CHUV) https://github.com/YohannThenaisie/PerceptToolbox
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: https://doi.org/10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

if isfield( data, 'IndefiniteStreaming' )

    % Extract and save Ind Streaming Time Domain
    obj_file.recording_mode.mode = 'IndefiniteStreaming';
    obj_file.recording_mode.n_channels = 6;
    obj_file.recording_mode.channel_map = [1 2 3 ; 4 5 6];
    lfp_indefinite = obj.extractLFP( data, obj_file );

    obj.indefinite_parameters.fname = fname;

    % Store data extracted
    obj.indefinite_parameters.time_domain.recording_mode = {lfp_indefinite.recordingMode};
    obj.indefinite_parameters.time_domain.n_channels = {lfp_indefinite.nChannels};
    obj.indefinite_parameters.time_domain.channel_map = {lfp_indefinite.channel_map};
    obj.indefinite_parameters.time_domain.channel_names = {lfp_indefinite.channel_names};
    obj.indefinite_parameters.time_domain.data = {lfp_indefinite.data};
    obj.indefinite_parameters.time_domain.fs = {lfp_indefinite.Fs};
    obj.indefinite_parameters.time_domain.time = {lfp_indefinite.time};
    obj.indefinite_parameters.time_domain.xlabel = {lfp_indefinite.xlabel};
    obj.indefinite_parameters.time_domain.ylabel = {lfp_indefinite.ylabel};

end

end


