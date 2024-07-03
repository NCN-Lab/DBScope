function [ LFP ] = extractLFP( obj, data, parameters )
% Extract and visualize LFPs from Percept PC - JSON structure
%
% Syntax:
%   [ LFP ] = EXTRACTLFP( obj, data, parameters );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%    * parameters - recording mode parameters
%
% Output parameters:
%    * LFP
%
% Example:
%   [ LFP ] = EXTRACTLFP( obj, data, parameters );
%
% Adapted from Yohann Thenaisie 02.09.2020 - Lausanne University Hospital
% (CHUV) https://github.com/YohannThenaisie/PerceptToolbox
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Extract parameters for this recording mode
recordingMode   = parameters.mode;

LFP_out = [];

%Identify the different recordings
nLines = size(data.(recordingMode), 1);
FirstPacketDateTime = cell(nLines, 1);
for lineId = 1:nLines
    FirstPacketDateTime{lineId, 1} = data.(recordingMode)(lineId).FirstPacketDateTime;
end
FirstPacketDateTime = categorical(FirstPacketDateTime);
recNames = unique(FirstPacketDateTime);
nRecs = numel(recNames);

%Extract LFPs in a new structure for each recording
for recId = 1:nRecs

    datafield = data.(recordingMode)(FirstPacketDateTime == recNames(recId));

    LFP = struct;
    LFP.nChannels = size(datafield, 1);
    LFP.channel_names = cell(1, LFP.nChannels);
    LFP.data = [];
    for chId = 1:LFP.nChannels
        LFP.channel_names{chId} = strrep(datafield(chId).Channel, '_', ' ');
        LFP.data(:, chId) = datafield(chId).TimeDomainData;
    end
    LFP.Fs = datafield(1).SampleRateInHz;
    LFP.first_packet_datetimes = datetime( datafield(1).FirstPacketDateTime, "InputFormat", 'yyyy-MM-dd''T''HH:mm:ss.SSS''Z''' );

    %Extract size of received packets
    GlobalPacketSizes = str2num(datafield(1).GlobalPacketSizes);
    % if sum(GlobalPacketSizes) ~= size(LFP.data, 1) && ~strcmpi(recordingMode, 'SenseChannelTests') && ~strcmpi(recordingMode, 'CalibrationTests')
    %     warning([recordingMode ': data length (' num2str(size(LFP.data, 1)) ' samples) differs from the sum of packet sizes (' num2str(sum(GlobalPacketSizes)) ' samples)'])
    % end

    % Calculate first sample tick
    TicksInMses = str2num(datafield(1).TicksInMses);
    if ~isempty(TicksInMses)
        LFP.firstTickInSec = TicksInMses(1)/1000; %first tick time (s)
    end
    
    LFP.global_packets_ID = str2num(datafield(1).GlobalSequences);
    LFP.global_packets_size = GlobalPacketSizes;
    LFP.global_packets_ticks = TicksInMses;
    
    switch recordingMode
        case 'BrainSenseTimeDomain'
            
            % Generate time vector from total number of samples
            LFP.time = (1:length(LFP.data))/LFP.Fs; % [s]
            
            % Get indices of missing packets
            diff_ticks = [0, diff(TicksInMses) - 250]; % 250 ms is the default
            indx_gaps = find(diff_ticks > 0);
            
            % Correct time vector
            cum_packets_size = [0, cumsum(LFP.global_packets_size)];
            for i = indx_gaps
                LFP.time(cum_packets_size(i):end) = LFP.time(cum_packets_size(i):end) + diff_ticks(i)/1000;
            end

        otherwise

            % Generate time vector from total number of samples
            LFP.time = (1:length(LFP.data))/LFP.Fs; % [s]
    end

    if LFP.nChannels <= 2
        LFP.channel_map = 1:LFP.nChannels;
    else
        LFP.channel_map = parameters.channel_map;
    end
    LFP.xlabel = 'Time [s]';
    LFP.ylabel = 'LFP [\muV]';
    LFP.recordingMode = recordingMode;

    LFP_out = [LFP_out LFP] ;
end

LFP = LFP_out;

end
