function concatenateRecordings( obj, indx_alpha, indx_beta )
% Concatenate two recordings.
%
% Syntax:
%   CONCATENATERECORDINGS( obj, indx_alpha, indx_beta );
%
% Input parameters:
%    * obj - object containg data
%    * indx_alpha - first indx of recording to be concatenated
%    * indx_beta - second indx of recording to be concatenated
%
% Example:
%   CONCATENATERECORDINGS( obj, indx_alpha, indx_beta );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

if ~isequal(obj.streaming_parameters.time_domain.nchannels(indx_alpha), ...
    obj.streaming_parameters.time_domain.nchannels(indx_beta))
    warning("Number of channels in recordings %d and %d is different. Only the first will be kept.", indx_alpha, indx_beta);
end

% -----------------------------------------------------------------------
% NOTE: When the communicator's connection is disrupted (e.g., battery 
% died), the recording is interrupted, and upon resume a new one is 
% created.
% -----------------------------------------------------------------------
% Check if second recording was due to loss of connection 
% (1st packet ID does not start at 0)
if obj.streaming_parameters.time_domain.global_packets_ID{indx_beta}(1) > 0 || ...
        round(1/1000*(obj.streaming_parameters.stim_amp.global_packets_ticks{indx_beta}(1) - ...
        obj.streaming_parameters.stim_amp.global_packets_ticks{indx_alpha}(end))) ~= ...
        seconds( obj.streaming_parameters.time_domain.first_packet_datetimes{indx_beta} - ...
        obj.streaming_parameters.time_domain.first_packet_datetimes{indx_alpha})
    obj.streaming_parameters.time_domain.time{indx_alpha}  = [ obj.streaming_parameters.time_domain.time{indx_alpha} ...
        obj.streaming_parameters.time_domain.time{indx_beta} + seconds( ...
        obj.streaming_parameters.time_domain.first_packet_datetimes{indx_beta} - ...
        obj.streaming_parameters.time_domain.first_packet_datetimes{indx_alpha} )];
    obj.streaming_parameters.stim_amp.time{indx_alpha}  = [ obj.streaming_parameters.stim_amp.time{indx_alpha}; ...
        obj.streaming_parameters.stim_amp.time{indx_beta} + seconds( ...
        obj.streaming_parameters.time_domain.first_packet_datetimes{indx_beta} - ...
        obj.streaming_parameters.time_domain.first_packet_datetimes{indx_alpha} )];
    warning("The concatenated recording originated from a loss of connection between the communicator and the device. Beware of packet information usage.");
else
    obj.streaming_parameters.time_domain.time{indx_alpha}  = [ obj.streaming_parameters.time_domain.time{indx_alpha} ...
        obj.streaming_parameters.time_domain.time{indx_beta} + 1/1000*( ...
        obj.streaming_parameters.time_domain.global_packets_ticks{indx_beta}(1) - ...
        obj.streaming_parameters.time_domain.global_packets_ticks{indx_alpha}(end) )];
    obj.streaming_parameters.stim_amp.time{indx_alpha}  = [ obj.streaming_parameters.stim_amp.time{indx_alpha}; ...
        obj.streaming_parameters.stim_amp.time{indx_beta} + 1/1000*( ...
        obj.streaming_parameters.stim_amp.global_packets_ticks{indx_beta}(1) - ...
        obj.streaming_parameters.stim_amp.global_packets_ticks{indx_alpha}(end) )];
end
obj.streaming_parameters.time_domain.data{indx_alpha} = [ obj.streaming_parameters.time_domain.data{indx_alpha}; obj.streaming_parameters.time_domain.data{indx_beta} ];
obj.streaming_parameters.time_domain.global_packets_ID{indx_alpha} = [ obj.streaming_parameters.time_domain.global_packets_ID{indx_alpha} obj.streaming_parameters.time_domain.global_packets_ID{indx_beta} ];
obj.streaming_parameters.time_domain.global_packets_size{indx_alpha} = [ obj.streaming_parameters.time_domain.global_packets_size{indx_alpha} obj.streaming_parameters.time_domain.global_packets_size{indx_beta} ];
obj.streaming_parameters.time_domain.global_packets_ticks{indx_alpha} = [ obj.streaming_parameters.time_domain.global_packets_ticks{indx_alpha} obj.streaming_parameters.time_domain.global_packets_ticks{indx_beta} ];

if ~isempty(obj.streaming_parameters.time_domain.ecg_clean)
    obj.streaming_parameters.time_domain.ecg_clean{indx_alpha} = [ obj.streaming_parameters.time_domain.ecg_clean{indx_alpha}; obj.streaming_parameters.time_domain.ecg_clean{indx_beta} ];
end

obj.streaming_parameters.stim_amp.data{indx_alpha} = [ obj.streaming_parameters.stim_amp.data{indx_alpha}; obj.streaming_parameters.stim_amp.data{indx_beta} ];
obj.streaming_parameters.stim_amp.global_packets_ID{indx_alpha} = [ obj.streaming_parameters.stim_amp.global_packets_ID{indx_alpha} obj.streaming_parameters.stim_amp.global_packets_ID{indx_beta} ];
obj.streaming_parameters.stim_amp.global_packets_ticks{indx_alpha} = [ obj.streaming_parameters.stim_amp.global_packets_ticks{indx_alpha} obj.streaming_parameters.stim_amp.global_packets_ticks{indx_beta} ];

% Delete extra recording
obj.deleteRecordings(indx_beta);

end