function [ anon ] = anonymizedata( obj )
% Import and Anonymize Medtronic Percept PC json files
% This funtion anonymizes selected parameters from json files, Percept PC.
% The variables are the following: 
% from Patient Information Initial / Final:
% PatientFirstName
% PatientLastName
% PatientGender
% PatientDateOfBirth
% PatientId
% from Devide Information Initial/Final:
% NeurostimulatorSerialNumber
% ImplantDate
%
% Syntax:
%   [ anon ] = ANONYMIZEDATA( );
%
% Input parameters:
%    * obj - object containg data
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira &  Paulo de Castro Aguiar  - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
pathname = uigetdir();
cd( pathname );
filelist = dir( '*.json' );

for f = 1 : numel( filelist )

    % Load Data
    filename = filelist(f).name;
    [fileid, ~] = fopen( filename, 'r', 'n', 'UTF-8' );
    json = fscanf( fileid, '%c' );
    fclose( fileid );

    % Find expression and anonymize

    %Patient Information Initial / Final:
    anon = regexprep( json, '\"PatientFirstName\": \"[\w- ]*\"', '"PatientFirstName": "XXXXXX"' );
    anon = regexprep( anon, '\"PatientLastName\": \"[\w- ]*\"', '"PatientLastName": "XXXXXX"' );
    anon = regexprep( anon, '\"PatientGender\": \"[\w- ]*\"', '"PatientGender": "XXXXXX"' );
    anon = regexprep( anon, '\"PatientDateOfBirth\": \"[\d\S- ]*\"', '"PatientDateOfBirth": "XXXXXX"' );
    %anon = regexprep( anon, '\"PatientId\": \"[\w- ]*\"', '"PatientId": "XXXXXX"' );

    % Divide Information Initial/Final:
    anon = regexprep( anon, '\"ImplantDate\": \"[\d\S- ]*\"', '"ImplantDate": "XXXXXX"' );
    anon = regexprep( anon, '\"NeurostimulatorSerialNumber\": \"[\d\S- ]*\"', '"NeurostimulatorSerialNumber": "XXXXXX"' );

    % Save to new json file
    fid = fopen([pathname,'\_ANONYMIZED_',filename], 'w');
    if fid == -1
        error('Cannot create JSON file');
    end
    fwrite(fid, anon, 'char');
    fclose(fid);

end