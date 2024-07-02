function loadWearables( obj, path, filenames )
% LOADWEARABLES Load wearables signal from external sensor
%
%   Syntax:
%       LOADWEARABLES( obj )
%
%   Input parameters:
%       obj
%
%   Example:
%       LOADWEARABLES( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Eduardo Carvalho, Andreia M. Oliveira & Paulo Aguiar - NCN 
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
obj.data = [];

for file = 1:numel( filenames )

    metadata                        = strsplit( filenames{file}, '_' );

    obj.data(file).wearable_id       = string(metadata(1));
    obj.data(file).task_id           = string(metadata(2));
    obj.data(file).sampling_freq_Hz = str2double(metadata{3});
    obj.data(file).recording_start  = datetime( metadata(4), "InputFormat", 'yyyyMMdd''T''HHmmss''.csv''' );

    data                    = readtable( [path filenames{file}] );
    obj.data(file).time     = datetime( uint64(data{:,1}), 'ConvertFrom', '.net', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS' );
    obj.data(file).data     = data(:, 2:numel(data.Properties.VariableNames));
    
end


warndlg('External file(s) loaded.');

end