function exportFieldtrip( obj, filename )
% EXPORTFIELDTRIP Exports streaming data to .mat file that is readable by
% the fieldtrip toolbox.
%
% NOTE: To export everything in the same file, we opted to consider all
% used channels. This means that if a channel is only used in one of the
% recordings, it will still be present in the other recordings but with NaN
% in the 'trial' field.
%
% Syntax:
%   EXPORTFIELDTRIP( obj, filename );
%
% Input parameters:
%    * obj          DBScope object containg streaming data.
%    * filename     Name of the file to be generated.
%
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Get streaming variables
streaming_data                  = obj.streaming_parameters.time_domain.data;
streaming_time                  = obj.streaming_parameters.time_domain.time;
streaming_channel_names         = obj.streaming_parameters.time_domain.channel_names;
streaming_stim_data             = obj.streaming_parameters.stim_amp.data;
streaming_stim_time             = obj.streaming_parameters.stim_amp.time;
streaming_stim_channel_names    = obj.streaming_parameters.stim_amp.channel_names;

% Create headers
hdr_lfp = obj.streaming_parameters.time_domain;
hdr_lfp = rmfield(hdr_lfp, {'channel_map', 'data', 'time', 'ecg_clean'});
hdr_stim = obj.streaming_parameters.stim_data;
hdr_stim = rmfield(hdr_stim, {'data', 'time'});

% Get all the channels that were used to record
unique_channels = [];
for r = 1:numel(streaming_data)
    unique_channels = unique([unique_channels; categorical(streaming_channel_names{r}')]);
end
unique_channels = cellstr(unique_channels);

% Get trials/recordings
trial_lfp   = {};
trial_stim  = {};
for r = 1:numel(streaming_data)

    % LFP
    temp_lfp    = NaN*ones(numel(unique_channels), numel(streaming_time{r}));
    for channel = 1:numel(streaming_channel_names{r})
        indx_channel = cellfun(@(x) strcmp(x, streaming_channel_names{r}{channel}), unique_channels);
        temp_lfp(indx_channel, :) = streaming_data{r}(:, channel);
    end
    trial_lfp{end+1}    = temp_lfp;
    
    % Stimulation Amplitude
    temp_stim   = NaN*ones(numel(unique_channels), numel(streaming_stim_time{r}));
    for channel = 1:numel(streaming_stim_channel_names{r})
        indx_channel = cellfun(@(x) strcmp(x, streaming_stim_channel_names{r}{channel}), unique_channels);
        temp_stim(indx_channel, :) = streaming_stim_data{r}(:, channel);
    end
    trial_stim{end+1}   = temp_stim;

end

lfp_raw     = struct("hdr", hdr_lfp, "trial", {trial_lfp}, "time", {streaming_time}, "label", {unique_channels});
stim_amp    = struct("hdr", hdr_stim, "trial", {trial_stim}, "time", {streaming_stim_time}, "label", {unique_channels});

% Save the data to a .mat file
fprintf('Writing %s as FieldTrip file.\n', filename);
save(filename, 'lfp_raw', 'stim_amp');

end

