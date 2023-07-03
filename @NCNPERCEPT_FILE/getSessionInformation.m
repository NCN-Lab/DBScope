function [ text ] = getSessionInformation( obj )
% Display information about session date.
%
% Syntax:
%   GETSESSIONINFORMATION( obj );
%
% Input parameters:
%    * obj - object containg data
%
% Example:
%   GETSESSIONINFORMATION( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

text = [ 'Start of Session: ',  obj.parameters.system_information.start_of_session, newline...
    '  ', newline...
    'End of Session: ', obj.parameters.system_information.end_of_session ];

disp(text);

end

