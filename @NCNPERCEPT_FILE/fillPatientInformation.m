function status = fillPatientInformation( obj, data )
% Fill patient information
%
% Syntax:
%   status = FILLPATIENTINFORMATION( obj, data );
%
% Input parameters:
%    * data - data from json file(s)
%
%
% Example:
%   status = FILLPATIENTINFORMATION( obj, data );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

obj.parameters.patient_information.patient_id       = data.PatientInformation.Final.PatientId;
obj.parameters.patient_information.patient_gender   = strrep(data.PatientInformation.Final.PatientGender, 'PatientGenderDef.', '');

status = 1;

end