function [ status, text ] = open_batch_files( obj )
% Select files to open.
%
% Syntax:
%    OPEN_BATCH( obj );
%
% Input parameters:
%    * obj - object containg data
%
% Output parameters:
%   status
%   text
%
% Example:
%    OPEN_BATCH( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

%% Open classes
text = [];

[filename, data_pathname] = uigetfile( '*.json','Select .json file','MultiSelect','on' );

if isnumeric( filename ) % Cancel/None Selected
    status = 0;
    return
elseif ischar( filename ) % Only 1 File selected
    filename = cellstr( filename );
end

obj.ncnpercept_patient = {}; % Reset
obj.patient_list = {};
[text_file] = [];

for file_num = 1:length( filename )

    temp = NCNPERCEPT_FILE;
    [~, text_file_int] = temp.loadFile(data_pathname,filename{file_num});
    patient_id = temp.parameters.patient_information.patient_id;
%     patient_id = 'Example2';

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