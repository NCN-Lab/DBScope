function [ LFP_ON ] = fillSetupParametersON( obj, data, fname, obj_file )
% Fill setup LFP recordings ON stimulation class
%
% Syntax:
%   [ LFP_ON ] = FILLSETUPPARAMETERSON( obj, data, fname, obj_file );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%    * fname
%    * obj_file - object structure to contain data
%
% Output parameters:
%   LFP_ON
%
% Example:
%   [ LFP_ON ] = FILLSETUPPARAMETERSON( data, fname, obj_file );
%
% Adapted from Yohann Thenaisie 02.09.2020 - Lausanne University Hospital
% (CHUV) https://github.com/YohannThenaisie/PerceptToolbox
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

%Extract LFPs
if isfield( data, 'CalibrationTests' ) %Setup ON stimulation

    obj_file.recording_mode.mode = 'CalibrationTests';
    obj_file.recording_mode.n_channels = 4;
    LFP_ON =  obj.extractLFP( data, obj_file  );

end

%Fill setup parameters
obj.setup_parameters.stim_on.recording_mode = LFP_ON.recordingMode;
obj.setup_parameters.stim_on.num_channels = LFP_ON.nChannels;
obj.setup_parameters.stim_on.channel_names = {LFP_ON.channel_names};
obj.setup_parameters.stim_on.data = {LFP_ON.data};
obj.setup_parameters.stim_on.fs = LFP_ON.Fs;
obj.setup_parameters.stim_on.time = {LFP_ON.time};

end