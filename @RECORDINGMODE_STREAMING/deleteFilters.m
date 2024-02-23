function deleteFilters( obj, indx )
% Delete previously applied filters
%
%Syntax:
%   DELETEFILTER( obj, filt_list );
%
% Input parameters:
%    * obj - object containg data
%    * indx - indices of filters to be deleted
%
% Example:
%   DELETEFILTER( indx );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

fields = fieldnames(obj.streaming_parameters.filtered_data);

for i = 1:numel(fields)
    if iscell(obj.streaming_parameters.filtered_data.(fields{i})) 
        obj.streaming_parameters.filtered_data.(fields{i})(indx) = [];
    end
end


end