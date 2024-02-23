function [ text ] = getLeadConfig( obj )
% Display information about lead settings.
%
% Syntax:
%   GETLEADCONFIG( obj );
%
% Input parameters:
%    * obj - object containg survey data
%
% Example:
%   GETLEADCONFIG( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

text = [ 'Lead Location Left Hemisphere: ', obj.parameters.system_information.lead_location_left_hemisphere, newline...
    '  ', newline...
    'Lead Location Right Hemisphere: ', obj.parameters.system_information.lead_location_right_hemisphere, newline...
    '  ', newline...
    'Lead Electrode Number Left Hemisphere: ', obj.parameters.system_information.lead_electrode_number_left_hemisphere, newline...
    '  ', newline...
    'Lead Electrode Number Right Hemisphere: ', obj.parameters.system_information.lead_electrode_number_right_hemisphere, newline...
    '  ', newline...
    'Lead Orientation in Degrees Left Hemisphere: ', num2str(obj.parameters.system_information.lead_orientation_in_degrees_left_hemisphere), newline...
    '  ', newline...
    'Lead Orientation in Degrees Right Hemisphere: ', num2str(obj.parameters.system_information.lead_orientation_in_degrees_right_hemisphere) ];

disp(text);

end