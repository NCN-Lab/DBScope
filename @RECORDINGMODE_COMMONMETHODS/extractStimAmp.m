function [ stimAmp ] = extractStimAmp( obj, data, obj_file )
% Extract and visualize stimulation amplitude from Percept PC JSON files
%
% Syntax:
%   [ stimAmp ] = EXTRACTSTIMAMP( obj, data, obj_file );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%    * obj_file - object to contain data
%
% Output parameters:
%   stimAmp
%
% Example:
%   [ stimAmp ] = EXTRACTSTIMAMP( data, obj_file );
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

stimAmp_out = [];

%Extract parameters for this recording mode
recordingMode = obj_file.recording_mode.mode;

%Identify the different recordings
nLines = size(data.(recordingMode), 1);
FirstPacketDateTime = cell(nLines, 1);
for lineId = 1:nLines
    FirstPacketDateTime{lineId, 1} = data.(recordingMode)(lineId).FirstPacketDateTime;
end
FirstPacketDateTime = categorical(FirstPacketDateTime);
recNames = unique(FirstPacketDateTime);
nRecs = numel(recNames);

for recId = 1:nRecs

    commaIdx = regexp(data.(recordingMode)(recId).Channel, ',');
    nChannels = numel(commaIdx)+1;

    %Convert structure to arrays
    nSamples = size(data.(recordingMode)(recId).LfpData, 1);
    TicksInMs = NaN(nSamples, 1);
    mA = NaN(nSamples, nChannels);
    for sampleId = 1:nSamples
        TicksInMs(sampleId) = data.(recordingMode)(recId).LfpData(sampleId).TicksInMs;
        mA(sampleId, 1) = data.(recordingMode)(recId).LfpData(sampleId).Left.mA;
        mA(sampleId, 2) = data.(recordingMode)(recId).LfpData(sampleId).Right.mA;
    end

    stimAmp.global_packets_ID = [data.(recordingMode)(recId).LfpData.Seq];
    stimAmp.global_packets_ticks = [data.(recordingMode)(recId).LfpData.TicksInMs];

    %Make time start at 0 and convert to seconds
    TicksInS = (TicksInMs - TicksInMs(1))/1000;

    Fs = data.(recordingMode)(recId).SampleRateInHz;

    %Store LFP band power and stimulation amplitude in one structure
    stimAmp.data = mA;
    stimAmp.time = TicksInS;
    stimAmp.Fs = Fs;
    stimAmp.channel_names = cellstr(strrep(strsplit(data.(recordingMode)(recId).Channel, ','), '_', ' '));
    stimAmp.firstTickInSec = TicksInMs(1)/1000; %first tick time (s)
    stimAmp.group = strrep(data.(recordingMode)(recId).TherapySnapshot.ActiveGroup, 'GroupIdDef.GROUP_', '');
    
    
    stimAmp.therapy_snapshot = data.(recordingMode)(recId).TherapySnapshot;
    % Get stimulating electrodes
    hemispheres = ["Left", "Right"];
    stim_channel_names = {};
    for h = hemispheres
        if ~isfield(stimAmp.therapy_snapshot, h) || ~isfield( stimAmp.therapy_snapshot.(h), "ElectrodeState")
            continue
        end
        electrode_names = cellfun(@(x) x.Electrode, stimAmp.therapy_snapshot.(h).ElectrodeState, 'UniformOutput', false);
        electrode_names = electrode_names(contains(electrode_names, 'Sensight'));
        electrode_names = strrep(electrode_names, 'ElectrodeDef.Sensight_', '');
        stim_channel_names{end+1} = strjoin(electrode_names, ' & ');
    end
    stimAmp.stim_channel_names = stim_channel_names;

   
    stimAmp_out = [stimAmp_out stimAmp] ;

    %save name
    savename = regexprep(char(recNames(recId)), {':', '-'}, {''});
    savename = [savename(1:end-5) '_' recordingMode '_stimAmp'];

end

stimAmp = stimAmp_out;

end
