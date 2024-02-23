function reorderRecordings( obj, order_indx )
% Change the streaming recordings order.
%
% Syntax:
%   REORDERRECORDINGS( obj, order_indx );
%
% Input parameters:
%    * obj - object containg data
%    * order_indx - array with new order
%
% Example:
%   REORDERRECORDINGS( obj, indx_alpha, indx_beta );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Check if reordering array has the same number of recordings
if numel(obj.streaming_parameters.time_domain.data) ~= numel(order_indx)
    warning("The given indices do not match the number of existing recordings. Make sure to provide a reordering array with %d indices.", numel(obj.streaming_parameters.time_domain.data));
    return;
end

% Check if reordering array has all the recordings
if numel(obj.streaming_parameters.time_domain.data) ~= numel(unique(order_indx))
    warning("The given indices do not contain all the existing recordings. Make sure to provide a reordering array that contains all %d indices.", numel(obj.streaming_parameters.time_domain.data));
    return;
end

% Check if reordering array contains values outside the range of recordings
if any(order_indx < 1) || any(order_indx > numel(obj.streaming_parameters.time_domain.data))
    warning("The reordering array contains invalid indices. Make sure to provide a reordering array within [1, %d].", numel(obj.streaming_parameters.time_domain.data));
    return;
end

% LFP
obj.streaming_parameters.time_domain.nchannels = obj.streaming_parameters.time_domain.nchannels(order_indx);
obj.streaming_parameters.time_domain.channel_map = obj.streaming_parameters.time_domain.channel_map(order_indx);
obj.streaming_parameters.time_domain.channel_names = obj.streaming_parameters.time_domain.channel_names(order_indx);
obj.streaming_parameters.time_domain.first_packet_datetimes = obj.streaming_parameters.time_domain.first_packet_datetimes(order_indx);
obj.streaming_parameters.time_domain.global_packets_ID = obj.streaming_parameters.time_domain.global_packets_ID(order_indx);
obj.streaming_parameters.time_domain.global_packets_size = obj.streaming_parameters.time_domain.global_packets_size(order_indx);
obj.streaming_parameters.time_domain.global_packets_ticks = obj.streaming_parameters.time_domain.global_packets_ticks(order_indx);
obj.streaming_parameters.time_domain.data = obj.streaming_parameters.time_domain.data(order_indx);
obj.streaming_parameters.time_domain.time = obj.streaming_parameters.time_domain.time(order_indx);
if ~isempty(obj.streaming_parameters.time_domain.ecg_clean)
    obj.streaming_parameters.time_domain.ecg_clean = obj.streaming_parameters.time_domain.ecg_clean(order_indx);
end

% Stimulation
obj.streaming_parameters.stim_amp.channel_names = obj.streaming_parameters.stim_amp.channel_names(order_indx);
obj.streaming_parameters.stim_amp.global_packets_ID = obj.streaming_parameters.stim_amp.global_packets_ID(order_indx);
obj.streaming_parameters.stim_amp.global_packets_ticks = obj.streaming_parameters.stim_amp.global_packets_ticks(order_indx);
obj.streaming_parameters.stim_amp.data = obj.streaming_parameters.stim_amp.data(order_indx);
obj.streaming_parameters.stim_amp.time = obj.streaming_parameters.stim_amp.time(order_indx);

end

