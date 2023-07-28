function [ loading_mode ] = aux_open_batch( obj )
% AUX_OPEN_BATCH Aux to open files / folder
%
% Syntax:
%   AUX_OPEN_BATCH( obj )
%
% Input parameters:
%   * obj - object to cointain data
%
% Output parameters:
%   data_type - type of data to load
%
% Example:
%    AUX_OPEN_BATCH( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: https://doi.org/10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

loading_mode = [];

answer = questdlg('What do you want to upload?', ...
    '', ...
    'Select file(s)','Folder','Workspace','Workspace');
switch answer
    case 'Select file(s)'
        loading_mode = 'files';
    case 'Folder'
        loading_mode = 'folder';
    case 'Workspace'
        loading_mode = 'workspace';
end

end