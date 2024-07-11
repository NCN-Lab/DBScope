function setExternalStatus( obj, value )
% Change status of external data. 
%
% Syntax:
%   SETEXTERNALSTATUS( obj, value );
%
% Input parameters:
%    * obj - object containg data
%    * value - true or false
%
% Example:
%   SETEXTERNALSTATUS( obj, value );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

obj.status.external = double(value);

end

