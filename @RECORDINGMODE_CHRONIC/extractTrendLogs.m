function [ LFPTrendLogs ] = extractTrendLogs( obj, data, parameters )
%Extract LFP and Event logs from Percept PC JSON files
%
% Trends: LFP power / power domain
%         Sampling frequency = 2Hz
% Events: Frequency Domain
%         Sampling frequency = 250Hz
%
% Syntax:
%       [ LFPTrendLogs ] = EXTRACTTRENDLOGS( obj, data, parameters );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%    * parameters - recording mode parameters
%
% Output parameters:
%   LFPTrendLogs
%
% Example:
%   [ LFPTrendLogs ] = obj.ExtractTrendLogs( data, parameters );
%
% Adapted from Yohann Thenaisie 02.09.2020 - Lausanne University Hospital
% (CHUV) https://github.com/YohannThenaisie/PerceptToolbox
% Bart Keulen 4-10-2020
% Modified by Yohann Thenaisie 05.10.2020
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
recordingMode = parameters.mode;
LFP.data = [];
stimAmp.data = [];

% Extract recordings left and right
hemisphereLocationNames = fieldnames(data.DiagnosticData.LFPTrendLogs);
nHemisphereLocations = numel(hemisphereLocationNames);

for hemisphereId = 1:nHemisphereLocations

    data_hemisphere = data.DiagnosticData.LFPTrendLogs.(hemisphereLocationNames{hemisphereId});

    recFields = fieldnames(data_hemisphere);
    nRecs = numel(recFields);
    allDays = table;

    %Concatenate data accross days
    for recId = 1:nRecs

        datafield = struct2table(data_hemisphere.(recFields{recId}));
        allDays = [allDays; datafield]; %#ok<*AGROW>

    end

    allDays = sortrows(allDays, 1);

    LFP.data = [LFP.data allDays.LFP]; 
    stimAmp.data = [stimAmp.data allDays.AmplitudeInMilliAmps];

end

%Extract LFP, stimulation amplitude and date-time information
nTimepoints = size(allDays, 1);
for recId = 1:nTimepoints
    DateTime(recId) = datetime(regexprep(allDays.DateTime{recId}(1:end-1),'T',' '));
end

% Store LFP in a structure
LFP.time = DateTime;
LFP.nChannels = nHemisphereLocations;
LFP.hemispheres = hemisphereLocationNames;
LFP.xlabel = 'Date Time';
LFP.ylabel = 'LFP band power';

%Store StimAmp in a structure
stimAmp.time = DateTime;
stimAmp.nChannels = nHemisphereLocations;
stimAmp.channel_names = hemisphereLocationNames;
stimAmp.xlabel = 'Date Time';
stimAmp.ylabel = 'Stimulation amplitude [mA]';

%Store all information in one structure
LFPTrendLogs.LFP = LFP;
LFPTrendLogs.stimAmp = stimAmp;
LFPTrendLogs.recordingMode = recordingMode;

%If patient has marked events, extract them
if isfield(data.DiagnosticData, 'LfpFrequencySnapshotEvents')
    data_events = data.DiagnosticData.LfpFrequencySnapshotEvents;
    nEvents = size(data_events, 1);
    events = table('Size',[nEvents 6],'VariableTypes',...
        {'cell', 'double', 'cell', 'logical', 'logical', 'cell'},...
        'VariableNames',{'DateTime','EventID','EventName','LFP','Cycling', 'LfpFrequencySnapshotEvents'});
    for eventId = 1:nEvents
        if iscell(data_events) %depending on software version
            thisEvent = struct2table(data_events{eventId}, 'AsArray', true);
        else
            thisEvent = struct2table(data_events(eventId), 'AsArray', true);
        end
        events(eventId, 1:5) = thisEvent(:, 1:5); %remove potential 'LfpFrequencySnapshotEvents'
        if ismember('LfpFrequencySnapshotEvents', thisEvent.Properties.VariableNames)
            for hemisphereId = 1:nHemisphereLocations
                PSD.FFTBinData(:, hemisphereId) = thisEvent.LfpFrequencySnapshotEvents.(hemisphereLocationNames{hemisphereId}).FFTBinData;
                PSD.channel_names{hemisphereId} = [hemisphereLocationNames{hemisphereId}(23:end), ' ' thisEvent.LfpFrequencySnapshotEvents.(hemisphereLocationNames{hemisphereId}).SenseID(27:end)];
            end
            PSD.Frequency = thisEvent.LfpFrequencySnapshotEvents.(hemisphereLocationNames{hemisphereId}).Frequency;
            PSD.nChannels = nHemisphereLocations;
            events.LfpFrequencySnapshotEvents{eventId} = PSD;
        end
    end
    events.DateTime = cellfun(@(x) datetime(regexprep(x(1:end-1),'T',' ')), events.DateTime);
    LFPTrendLogs.events = events;
end

end