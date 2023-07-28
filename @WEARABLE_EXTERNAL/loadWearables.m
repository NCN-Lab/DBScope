function loadWearables( obj, path, filenames )
% LOADWEARABLES Load wearables signal from external sensor
%
%   Syntax:
%       LOADWEARABLES( obj )
%
%   Input parameters:
%       obj - object containg data 
%
%   Example:
%       LOADWEARABLES( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: https://doi.org/10.1101/2023.07.23.23292136.
%
% Eduardo Carvalho, Andreia M. Oliveira & Paulo Aguiar - NCN 
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
obj.data = [];

for file = 1:numel( filenames )

    metadata                        = strsplit( filenames{file}, '_' );
    obj.data(file).wearableID       = metadata(1);
    obj.data(file).task             = string(metadata(3));
    obj.data(file).titration        = string(metadata(4));
    obj.data(file).sampling_freq_Hz = str2double(metadata{5});
    obj.data(file).session_start    = datetime( metadata(6), "InputFormat", 'yyyy-MM-dd''T''HH-mm-ss''.csv''' );

    data                    = readtable( [path filenames{file}] );
    obj.data(file).time     = datetime( uint64(data{:,1}), 'ConvertFrom', '.net', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS' );
    for field = 2:numel(data.Properties.VariableNames)
        obj.data(file).(data.Properties.VariableNames{field}) = data{:,field};
    end
    
end


warndlg('File loaded to Wearable class.');

end