function [ text ] = getDeviceInformation( obj )
% Display information about device.
%
% Syntax:
%   GETDEVICEINFORMATION( obj );
%
% Input parameters:
%   * data - data from json file(s)
%
% Example:
%   GETDEVICEINFORMATION( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

text= [ 'Neurostimulator: ', obj.parameters.system_information.neurostimulator, newline...
    'Model:', obj.parameters.system_information.model, newline...
    'Location: ', obj.parameters.system_information.location, newline...
    'Implantation Date: ', obj.parameters.system_information.implantation_date, newline...
    'Device Date: ', obj.parameters.system_information.device_date, newline...
    'Accumulated Therapy On Time Since Implant: ', num2str(obj.parameters.system_information.accumulated_therapy_on_time_since_implant), newline...
    'Accumulated Therapy On Time Since Follow-up: ', num2str(obj.parameters.system_information.accumulated_therapy_on_time_since_followup), newline];

end


