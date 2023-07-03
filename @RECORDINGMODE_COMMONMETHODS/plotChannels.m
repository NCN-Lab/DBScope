function channelsFig = plotChannels( obj, data, channelParams, obj_file )
% Plots data from each channel of LFP data in a subplot
% S is a structure with fields:
% .data, .time, .nChannels, .channel_names, .channel_map, .ylabel
%
% Syntax:
%   channelsFig = PLOTCHANNELS( obj );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%    * channelParams
%
% Output parameters:
%   channelsFig
%
% Example:
%   channelsFig = PLOTCHANNELS( data, channelParams, obj_file );
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
%% -----------------------------------------------------------------------
channelsFig = figure();

ax = gobjects(channelParams.nChannels, 1);
[nColumns, nRows] = size(channelParams.channel_map);
for chId = 1:channelParams.nChannels
    channel_pos = find(channelParams.channel_map == chId);
    ax(chId) = subplot(nRows, nColumns, channel_pos);
    hold on
    plot(channelParams.time, data(:, chId))
    title(channelParams.channel_names{chId})
    xlim([channelParams.time(1) channelParams.time(end)])
    grid on
    minY = min(data(:, chId));
    maxY = max(data(:, chId));
    if minY ~= maxY
        ylim([minY maxY])
    end
end

subplot(nRows, nColumns, channelParams.nChannels-nColumns+1)
xlabel('Time (s)')
ylabel(channelParams.ylabel)
linkaxes(ax, 'x')

