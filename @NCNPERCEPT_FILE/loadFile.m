function [ parsing_status, text ] = loadFile( obj, file_pathname, filename )
% Parse data from json file.
%
% Syntax:
%     [ parsing_status, text ] = LOADFILE(obj, file_pathname, filename);
%
% Input parameters:
%    * obj - object containg data
%    * file_pathname
%    * filename
%
% Output parameters:
%   status
%   text
%
% Example:
%    [ parsing_status, text ] = obj.LOADFILE(file_pathname, filename);
%
% Adapted from Yohann Thenaisie 02.09.2020 - Lausanne University Hospital
% (CHUV) https://github.com/YohannThenaisie/PerceptToolbox
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

parsing_status = 0;
text = [];

% Programmer versions that can be parsed by toolbox
all_programmer_versions = ["2.0.4584", ...
    "3.0.1057", "3.0.1062", "3.0.1081", "3.0.1098", ...
    "4.0.1052"];

error_msg = 'Could not successfully import the provided file.';

%% Load File
try
    fname       = [file_pathname, filename];
    data        = jsondecode(fileread(fname));
catch
    warndlg('File could not be read. Make sure you are importing a .json file.', 'Warning');
end

% Get Main Parameters
obj.parameters.fname                = fname;
obj.parameters.session_date         = datetime( data.SessionDate, "InputFormat", 'yyyy-MM-dd''T''HH:mm:ss''Z''' );
obj.parameters.save_pathname        = [ file_pathname filesep regexprep(data.SessionDate, {':', '-', 'Z'}, {''}) ];
obj.parameters.programmer_version   = data.ProgrammerVersion;
obj.parameters.programmer_utc       = data.ProgrammerUtcOffset;

% Check if file is from any known version
if any(strcmp(all_programmer_versions, data.ProgrammerVersion))
    programmer_version = data.ProgrammerVersion;
else
    indx = max(1, find(str2double(strrep(all_programmer_versions, '.', '')) < str2double(strrep(data.ProgrammerVersion, '.', '')), 1, 'last'));
    programmer_version = all_programmer_versions(indx);
    warndlg(sprintf("The toolbox's parser does not recognize programmer version %s.\nTrying to parse the data according to version %s." + ...
        "\nIf there is a parsing error, please contact us at pauloaguiar@i3s.up.pt", data.ProgrammerVersion, programmer_version) , 'Warning');
end

% Get Patient Information
try
    % Get Patient Information
    obj.fillPatientInformation( data );

    % Get System Information
    obj.fillSystemInformation( data );
    
    % Get Groups Information
    obj.fillGroupsInformation( data );

    % Check Recording Modes & Fill Classes

    obj.status.survey       = obj.survey_obj.fillSurveyParameters( data );
    obj.status.indefinite   = obj.indefinite_obj.fillIndefiniteParameters( data );
    obj.status.setup_off    = obj.setup_obj.fillSetupOFFParameters( data );
    obj.status.setup_on     = obj.setup_obj.fillSetupONParameters( data );
    obj.status.streaming    = obj.streaming_obj.fillStreamingParameters( data );
    [obj.status.chronic, ...
        obj.status.events, ...
        obj.status.events_FFT] = obj.chronic_obj.fillChronicParameters( data );
    obj.status.impedance    = obj.getImpedance( data );

catch exception
    warndlg([error_msg newline 'Error occurred: ' exception.message], 'Warning');
end

availability_string = ["Not available", "Available"];

modes_strings = ["Impedance", "Survey", "Indefinite Streaming", "Setup OFF", ...
    "Setup ON", "Timeline", "Events", "Streaming"];

text = sprintf("%s\n\n", fname) + ...
    sprintf('%20s : %s\n', modes_strings(1), availability_string(obj.status.impedance + 1)) + ...
    sprintf('%20s : %s\n', modes_strings(2), availability_string(obj.status.survey + 1)) + ...
    sprintf('%20s : %s\n', modes_strings(3), availability_string(obj.status.indefinite + 1)) + ...
    sprintf('%20s : %s\n', modes_strings(4), availability_string(obj.status.setup_off + 1)) + ...
    sprintf('%20s : %s\n', modes_strings(5), availability_string(obj.status.setup_on + 1)) + ...
    sprintf('%20s : %s\n', modes_strings(6), availability_string(obj.status.chronic + 1)) + ...
    sprintf('%20s : %s\n', modes_strings(7), availability_string(obj.status.events + 1)) + ...
    sprintf('%20s : %s\n\n', modes_strings(8), availability_string(obj.status.streaming + 1));

disp(text);

parsing_status = 1; % Successful parsing

end