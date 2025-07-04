function correctMissingSamples( obj, rec, new_lfp_time, new_stim_time )
% Corrects missing samples.
%
% Syntax:
%   CORRECTMISSINGSAMPLES( obj, new_lfp_time, new_stim_time );
%
% Input parameters:
%    * obj - object containg data
%    * rec - recording
%    * new_lfp_time - new time vector for lfp signal
%    * new_stim_time - new time vector for stimulation signal
%
% Example:
%   CORRECTMISSINGSAMPLES( obj, new_lfp_time, new_stim_time );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

obj.streaming_parameters.time_domain.time{rec} = new_lfp_time;

obj.streaming_parameters.stim_amp.time{rec} = new_stim_time;

end

