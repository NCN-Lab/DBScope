function [ status, text, obj ] = open_mat_files( obj )
% OPEN_MAT_FILES Select workspace to open.
%
% Syntax:
%   OPEN_MAT_FILES( obj  );
%
% Input parameters:
%    * obj - object containg data
%
% Output parameters:
%   status
%   text
%
% Example:
%   OPEN_MAT_FILES( multiple_files );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: https://doi.org/10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

[filename, data_pathname] = uigetfile('*.mat','Select .mat file');
fname_workspace = [data_pathname, filename];
temp_obj = load( fname_workspace );
obj = temp_obj.obj;

status = 1;
text = ['Workspace uploaded:', filename];

obj.patient_list{1} = 'Example2';

end