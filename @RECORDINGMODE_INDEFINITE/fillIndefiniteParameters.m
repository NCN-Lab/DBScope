function status = fillIndefiniteParameters( obj, data  )
% Extract LFPs from Indefinite Streaming mode
%
% Syntax:
%   FILLSURVEYPARAMETERS( obj, data );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%
% Output parameters:
%    * status
%
%   Example:
%      status = FILLINDEFINITEPARAMETERS( obj, data );
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

status = 0;

if isfield( data, 'IndefiniteStreaming' )
    
    % Extract and save Ind Streaming Time Domain
    parameters.mode         = 'IndefiniteStreaming';
    parameters.num_channels = 6;
    parameters.channel_map  = [1 2 3 ; 4 5 6];
    lfp_indefinite          = obj.extractLFP( data, parameters );

    % Store data extracted
    obj.indefinite_parameters.time_domain.recording_mode = {lfp_indefinite.recordingMode};
    obj.indefinite_parameters.time_domain.n_channels = {lfp_indefinite.nChannels};
    obj.indefinite_parameters.time_domain.channel_names = {lfp_indefinite.channel_names};
    obj.indefinite_parameters.time_domain.data = {lfp_indefinite.data};
    obj.indefinite_parameters.time_domain.fs = {lfp_indefinite.Fs};
    obj.indefinite_parameters.time_domain.time = {lfp_indefinite.time};

    status = 1;

end

end


