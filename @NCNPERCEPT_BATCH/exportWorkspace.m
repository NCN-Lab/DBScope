function exportWorkspace( obj )
% EXPORTWORKSPACE Saves workspace
%
% Syntax:
%   EXPORTWORKSPACE( obj );
%
% Input parameters:
%    * obj - object containg data
%
% Example:
%   EXPORTWORKSPACE( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

workspace_datetime = datetime('now');
workspace_datetime.Format = 'yyyyMMdd''T''HHmmss';
workspace_filename = [workspace_datetime '_Workspace.mat'];

mkdir( workspace_datetime );
save( [workspace_datetime '/' workspace_filename], "obj" );


