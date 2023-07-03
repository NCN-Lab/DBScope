function [ text ] = getBatteryInformation( obj )
% Display information about battery.
%
% Syntax:
%   GETBATTERYINFORMATION( obj );
%
% Input parameters:
%    * obj - object containg data
%
% Example:
%   GETBATTERYINFORMATION( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
% obj.parameters.patient_information.patient_id = 'Example2';


text = [ 'Battery Percentage: ', num2str(obj.parameters.system_information.battery_percentage), newline...
    '  ', newline...
    'Battery Status: ', obj.parameters.system_information.battery_status];

disp(text);

end
