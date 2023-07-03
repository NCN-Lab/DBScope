function deleteFilter( obj, filt_list )
% Delete previously applied filters
%
%Syntax:
%   DELETEFILTER( obj, filt_list );
%
% Input parameters:
%    * obj - object containg data
%    * filt_list - list of filters applied
%
% Example:
%   DELETEFILTER( filt_list );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Delete signal
obj.streaming_parameters.filtered_data.data(filt_list) = [];
obj.streaming_parameters.filtered_data.filter_type(filt_list) = [];
obj.streaming_parameters.filtered_data.up_bound(filt_list) = [];
obj.streaming_parameters.filtered_data.low_bound(filt_list) = [];
obj.streaming_parameters.filtered_data.original(filt_list) = [];

end