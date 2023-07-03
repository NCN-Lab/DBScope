function [LFP, stimAmp] = fillStreamingParameters( obj, data, fname, obj_file )
% Extract and visualize LFPs from online streaming mode
%
% Syntax:
%   [LFP, stimAmp] = FILTSTREAMINGPARAMETERS( obj, data, fname, obj_file );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%    * fname
%    * obj_file - object structure to contain data
%
% Output parameters:
%   LFP
%   stimAMP
%
% Example:
%   [LFP, stimAmp] = FILTSTREAMINGPARAMETERS( data, fname, obj_file ):
%
% Adapted from Yohann Thenaisie 02.09.2020 - Lausanne University Hospital
% (CHUV) https://github.com/YohannThenaisie/PerceptToolbox
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------


% Extract LFPs
if isfield( data, 'BrainSenseTimeDomain' ) % 'BrainSenseTimeDomain'  = Streaming mode
    obj_file.recording_mode.n_channels  = 2;
    obj_file.recording_mode.channel_map = 1:obj_file.recording_mode.n_channels;
    obj_file.recording_mode.mode = 'BrainSenseTimeDomain';
    LFP = obj.extractLFP( data, obj_file );

    obj.streaming_parameters.time_domain.recording_mode = LFP(1).recordingMode;
    obj.streaming_parameters.time_domain.nchannels = {LFP(:).nChannels};
    obj.streaming_parameters.time_domain.channel_map = {LFP(:).channel_map};
    obj.streaming_parameters.time_domain.fs = LFP(1).Fs;
    obj.streaming_parameters.time_domain.first_packet_datetimes = {LFP(:).first_packet_datetimes};
    obj.streaming_parameters.time_domain.channel_names = {LFP(:).channel_names};
    obj.streaming_parameters.time_domain.data = {LFP(:).data};
    obj.streaming_parameters.time_domain.time = {LFP(:).time};
    obj.streaming_parameters.time_domain.first_tick_in_sec = {LFP(:).firstTickInSec};
    obj.streaming_parameters.time_domain.xlabel = LFP(1).xlabel;
    obj.streaming_parameters.time_domain.ylabel = LFP(1).ylabel;
    obj.streaming_parameters.time_domain.ratiobands = [];

    % Extract stimulation data
    obj_file.recording_mode.mode = 'BrainSenseLfp';
    stimAmp = obj.extractStimAmp( data, obj_file );

    obj.streaming_parameters.stim_amp.data = {stimAmp(:).data};
    obj.streaming_parameters.stim_amp.time = {stimAmp(:).time};
    obj.streaming_parameters.stim_amp.fs = stimAmp(1).Fs;
    obj.streaming_parameters.stim_amp.ylabel = stimAmp(1).ylabel;
    obj.streaming_parameters.stim_amp.channel_names = {stimAmp(:).channel_names};
    obj.streaming_parameters.stim_amp.first_tick_in_sec = {stimAmp(:).firstTickInSec};

    obj.streaming_parameters.filtered_data.filter_type = {};
    obj.streaming_parameters.filtered_data.up_bound = [];
    obj.streaming_parameters.filtered_data.low_bound = [];
    obj.streaming_parameters.filtered_data.data = {};
    obj.streaming_parameters.filtered_data.typeofdata = [];
    obj.streaming_parameters.time_domain.ecg_clean = [];

    LFP_ordered = obj.streaming_parameters.time_domain.data;

    for c = 1:numel(LFP_ordered)
        if length(LFP_ordered{c}(1,:)) == 2
            disp('Two hemispheres available')
        elseif length(LFP_ordered{c}(1,:)) == 1
            disp('Only one hemispheres available')
        end
    end
end

% indx_keep = [8];
% 
% % LFP recording
% obj.streaming_parameters.time_domain.nchannels = ...
%     obj.streaming_parameters.time_domain.nchannels(indx_keep);
% obj.streaming_parameters.time_domain.channel_map = ...
%     obj.streaming_parameters.time_domain.channel_map(indx_keep);
% obj.streaming_parameters.time_domain.channel_names = ...
%     obj.streaming_parameters.time_domain.channel_names(indx_keep);
% obj.streaming_parameters.time_domain.data = ...
%     obj.streaming_parameters.time_domain.data(indx_keep);
% obj.streaming_parameters.time_domain.time = ...
%     obj.streaming_parameters.time_domain.time(indx_keep);
% obj.streaming_parameters.time_domain.first_tick_in_sec = ...
%     obj.streaming_parameters.time_domain.first_tick_in_sec(indx_keep);
% obj.streaming_parameters.time_domain.first_packet_datetimes = ...
%     obj.streaming_parameters.time_domain.first_packet_datetimes(indx_keep);
% 
% % Stimulation Amplitude
% obj.streaming_parameters.stim_amp.data = ...
%     obj.streaming_parameters.stim_amp.data(indx_keep);
% obj.streaming_parameters.stim_amp.time = ...
%     obj.streaming_parameters.stim_amp.time(indx_keep);
% obj.streaming_parameters.stim_amp.channel_names = ...
%     obj.streaming_parameters.stim_amp.channel_names(indx_keep);
% obj.streaming_parameters.stim_amp.first_tick_in_sec = ...
%     obj.streaming_parameters.stim_amp.first_tick_in_sec(indx_keep);

end


