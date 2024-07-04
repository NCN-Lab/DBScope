function [ text ] = getGroupsInformation( obj )
% Display information about Groups.
%
% Syntax:
%   GETGROUPSINFORMATION( obj );
%
% Input parameters:
%   * data - data from json file(s)
%
% Example:
%   GETGROUPSINFORMATION( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

indx_sensing_initial    = cellfun(@(c) isstruct(c) && numel(c.hemispheres) == 2, {obj.parameters.groups.initial(:).sensing});
indx_sensing_final      = cellfun(@(c) isstruct(c) && numel(c.hemispheres) == 2, {obj.parameters.groups.final(:).sensing});

text = [newline + "Left Channel: " + string(obj.parameters.groups.initial(indx_sensing_initial).sensing.hemispheres(1).channel) + " (" +  ...
    string(obj.parameters.groups.final(indx_sensing_final).sensing.hemispheres(1).channel) + ")" + newline + ...
    "Left Stimulation Frequency [Hz]: " + num2str(obj.parameters.groups.initial(indx_sensing_initial).sensing.hemispheres(1).center_frequency) +  " (" + ...
    num2str(obj.parameters.groups.final(indx_sensing_final).sensing.hemispheres(1).center_frequency) + ")" + newline + ...
    "Left Pulse Width [" + char(956) + "s]: " + num2str(obj.parameters.groups.initial(indx_sensing_initial).stimulation.hemispheres(1).pulse_width) +  " (" + ...
    num2str(obj.parameters.groups.final(indx_sensing_final).stimulation.hemispheres(1).pulse_width) + ")" + newline + ...
    "Right Channel: " + obj.parameters.groups.initial(indx_sensing_initial).sensing.hemispheres(2).channel +  " (" + ...
    string(obj.parameters.groups.final(indx_sensing_final).sensing.hemispheres(2).channel) + ")" + newline + ...
    "Right Stimulation Frequency [Hz]: "  + num2str(obj.parameters.groups.initial(indx_sensing_initial).sensing.hemispheres(2).center_frequency) +  " (" + ...
    num2str(obj.parameters.groups.final(indx_sensing_final).sensing.hemispheres(2).center_frequency) + ")" + newline + ...
    "Right Pulse Width [" + char(956) + "s]: " + num2str(obj.parameters.groups.initial(indx_sensing_initial).stimulation.hemispheres(2).pulse_width) +  " (" + ...
    num2str(obj.parameters.groups.final(indx_sensing_final).stimulation.hemispheres(2).pulse_width) + ")" + newline];

end

