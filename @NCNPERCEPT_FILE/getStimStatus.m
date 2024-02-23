function [ text ] = getStimStatus( obj )
% Display information about stimulation status.
%
% Syntax:
%   GETSTIMSTATUS( obj );
%
% Input parameters:
%    * obj - object containg data
%
% Example:
%   GETSTIMSTATUS( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
text = [ 'Initial Stimulation Status: ', obj.parameters.system_information.initial_stimulation_status, newline...
    '  ', newline...
    'Final Stimulation Status: ', obj.parameters.system_information.final_stimulation_status]; 

disp(text);

end