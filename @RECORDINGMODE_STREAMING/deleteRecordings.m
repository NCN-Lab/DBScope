function deleteRecordings( obj, indx )
% Delete a recording.
%
% Syntax:
%   DELETERECORDING( obj, indx );
%
% Input parameters:
%    * obj - object containing data
%    * indx - indices of recordings to be deleted
%
% Example:
%   DELETERECORDING( indx );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% LFP
fields = fieldnames(obj.streaming_parameters.time_domain);

for i = 1:numel(fields)
    if iscell(obj.streaming_parameters.time_domain.(fields{i})) 
        obj.streaming_parameters.time_domain.(fields{i})(indx) = [];
    end
end

% Stimulation
fields = fieldnames(obj.streaming_parameters.stim_amp);

for i = 1:numel(fields)
    if iscell(obj.streaming_parameters.stim_amp.(fields{i})) 
        obj.streaming_parameters.stim_amp.(fields{i})(indx) = [];
    end
end

% Filtered
for i = 1:numel(obj.streaming_parameters.filtered_data.data)
    obj.streaming_parameters.filtered_data.data{i}(indx) = [];
end

end