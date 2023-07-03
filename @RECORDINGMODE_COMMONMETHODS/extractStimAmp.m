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
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
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

    %Make time start at 0 and convert to seconds
    TicksInS = (TicksInMs - TicksInMs(1))/1000;

    Fs = data.(recordingMode)(recId).SampleRateInHz;

    %Store LFP band power and stimulation amplitude in one structure
    stimAmp.data = mA;
    stimAmp.time = TicksInS;
    stimAmp.Fs = Fs;
    stimAmp.ylabel = 'Stimulation amplitude (mA)';
    stimAmp.channel_names = {'Left', 'Right'};
    stimAmp.firstTickInSec = TicksInMs(1)/1000; %first tick time (s)
    stimAmp.json = obj_file.fname;

    stimAmp_out = [stimAmp_out stimAmp] ;

    %save name
    savename = regexprep(char(recNames(recId)), {':', '-'}, {''});
    savename = [savename(1:end-5) '_' recordingMode '_stimAmp'];

end

stimAmp = [];
stimAmp = stimAmp_out;

end
