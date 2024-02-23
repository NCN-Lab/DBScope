function [ status, text ] = open_batch_folder( obj )
% Select files to open.
%
% Syntax:
%   OPEN_BATCH_FOLDER( obj, multiple_files )
%
% Input parameters:
%    * obj - object containg data
%
% Output parameters:
%   status
%   text
%
% Example:
%   OPEN_BATCH_FOLDER( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
text = [];
obj.ncnpercept_patient = {}; % Reset
obj.patient_list = {};
[text_file] = [];

datapath=uigetdir([],'Select Data Directory');
d=dir(fullfile(datapath,'*.json'));

for file_num=1:numel(d)
    [text_file_int] = [];

    temp = NCNPERCEPT_FILE;
    datapath = ([datapath,'/']);
    [~, text_file_int] = temp.loadFile(datapath,d(file_num).name);
    patient_id = temp.parameters.patient_information.patient_id;

    patient = find(ismember(obj.patient_list, patient_id), 1);
    if isempty(patient)
        obj.patient_list{end+1} = patient_id;
        patient = ismember(obj.patient_list, patient_id);
        obj.ncnpercept_patient{patient}{1}  = temp;
        L = 1;
    else
        obj.ncnpercept_patient{patient}{L+1}  = temp;
        L = length(obj.ncnpercept_patient{patient});
    end

    text_file = [ text_file, text_file_int ];
end

    status = 1;
    text = text_file;

end