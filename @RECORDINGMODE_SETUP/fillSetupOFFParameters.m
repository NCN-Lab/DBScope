function status = fillSetupOFFParameters( obj, data )
% Fill setup LFP recordings OFF stimulation class
%
% Syntax:
%   [ status ] = FILLSETUPOFFPARAMETERS( obj, data );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%
% Output parameters:
%    * status
%
% Example:
%   status = FILLSETUPOFFPARAMETERS( obj, data );
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

status = 0;

%Extract LFPs
if isfield( data, 'SenseChannelTests' ) %Setup OFF stimulation

    parameters.mode         = 'SenseChannelTests';
    parameters.num_channels = 6;
    parameters.channel_map  = [1 2 3 ; 4 5 6];
    LFP_OFF                 =  obj.extractLFP( data, parameters );

    % Fill setup parameters
    obj.setup_parameters.stim_off.recording_mode = LFP_OFF.recordingMode;
    obj.setup_parameters.stim_off.num_channels = LFP_OFF.nChannels;
    obj.setup_parameters.stim_off.channel_names = {LFP_OFF.channel_names};
    temp_data = {};
    for i = 1:numel(LFP_OFF)
        temp_data{end+1} = mat2cell(LFP_OFF(i).data', ones(size(LFP_OFF(i).data, 2), 1), size(LFP_OFF(i).data, 1));
    end
    obj.setup_parameters.stim_off.data = temp_data;
    obj.setup_parameters.stim_off.fs = LFP_OFF.Fs;
    obj.setup_parameters.stim_off.time = {LFP_OFF.time};

    status = 1;

end

end
