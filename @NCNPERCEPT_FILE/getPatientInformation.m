function [ text ] = getPatientInformation( obj )
% Display information about patient.
%
% Syntax:
%   GETPATIENTINFORMATION( obj );
%
% Input parameters:
%    * obj - object containg data
%
% Example:
%   GETPATIENTINFORMATION( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

text = [ 'Clinical Notes: ', obj.parameters.system_information.clinical_notes, newline...
    'Diagnosis: ', obj.parameters.system_information.diagnosis, newline ];

end

