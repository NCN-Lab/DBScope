function saveWorkspace_single( obj )
% SAVEWORKSPACE_SINGLE Saves workspace
%
% Syntax:
%   SAVEWORKSPACE_SINGLE( obj );
%
% Input parameters:
%    * obj - object containg data
%
% Example:
%   SAVEWORKSPACE_SINGLE( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of
% sensing data from Deep Brain Stimulation, doi: https://doi.org/10.1101/2023.07.23.23292136
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

date = datestr( datetime('now'), 'dd-mmm-yyyy HH-MM-SS' );
save_pathname_workspace = [date, '_Workspace'];

mkdir( save_pathname_workspace );
save( [save_pathname_workspace, '/Perceive_Analysis_Workspace.mat'], "obj" );


