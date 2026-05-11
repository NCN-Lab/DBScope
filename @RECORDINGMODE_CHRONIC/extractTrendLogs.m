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
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Pedro Melo & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Extract parameters for this recording mode
recordingMode = parameters.mode;

% Extract recordings left and right
hemisphereLocationNames = fieldnames(data.DiagnosticData.LFPTrendLogs);
nHemisphereLocations = numel(hemisphereLocationNames);
hemisphereLocationNames = sort(hemisphereLocationNames); 

% Store data and time in cells to allow different lengths
LFP.data = cell(1, nHemisphereLocations);
LFP.time = cell(1, nHemisphereLocations);
stimAmp.data = cell(1, nHemisphereLocations);
stimAmp.time = cell(1, nHemisphereLocations);

for hemisphereId = 1:nHemisphereLocations

    data_hemisphere = data.DiagnosticData.LFPTrendLogs.(hemisphereLocationNames{hemisphereId});

    recFields   = fieldnames(data_hemisphere);
    nRecs       = numel(recFields);
    allDays     = table;

    % Concatenate data accross days
    for recId = 1:nRecs

        datafield   = struct2table(data_hemisphere.(recFields{recId}));
        allDays     = [allDays; datafield]; %#ok<*AGROW>

    end
    allDays = sortrows(allDays, 1);

    LFP.data{hemisphereId}        = allDays.LFP; 
    stimAmp.data{hemisphereId}        = allDays.AmplitudeInMilliAmps;

    % Vectorized datetime conversion
    raw_times = regexprep(allDays.DateTime, 'T', ' ');
    raw_times = cellfun(@(x) x(1:end-1), raw_times, 'UniformOutput', false);
    LFP.time{hemisphereId} = datetime(raw_times);
    stimAmp.time{hemisphereId} = LFP.time{hemisphereId}; % Use the same time for stim

end

% Store LFP in a structure
LFP.nChannels   = nHemisphereLocations;
LFP.hemispheres = hemisphereLocationNames;
LFP.xlabel      = 'Date Time';
LFP.ylabel      = 'LFP band power';

% Store StimAmp in a structure
stimAmp.nChannels       = nHemisphereLocations;
stimAmp.channel_names   = hemisphereLocationNames;
stimAmp.xlabel          = 'Date Time';
stimAmp.ylabel          = 'Stimulation amplitude [mA]';

% Store all information in one structure
LFPTrendLogs.LFP            = LFP;
LFPTrendLogs.stimAmp        = stimAmp;
LFPTrendLogs.recordingMode  = recordingMode;

% If patient has marked events, extract them

variable_names_strings = {'DateTime','EventID','EventName','LFP','Cycling', 'LfpFrequencySnapshotEvents'};

if isfield(data.DiagnosticData, 'LfpFrequencySnapshotEvents')
    data_events = data.DiagnosticData.LfpFrequencySnapshotEvents;
    nEvents     = size(data_events, 1);
    events      = table('Size',[nEvents 6], ...
        'VariableTypes', ...
        {'cell', 'double', 'cell', 'logical', 'logical', 'cell'}, ...
        'VariableNames', ...
        variable_names_strings);
    
    for eventId = 1:nEvents
        % 1. Safely extract the raw struct (DO NOT use struct2table here)
        if iscell(data_events)
            thisEventStruct = data_events{eventId};
        else
            thisEventStruct = data_events(eventId);
        end
        
        for var_cell = variable_names_strings
            var_name = var_cell{1};
            
            % 2. Check if the field exists directly in the struct
            if isfield(thisEventStruct, var_name)
                
                if strcmp(var_name,'LfpFrequencySnapshotEvents')
                    % --- FFT SNAPSHOT EXTRACTION (Our robust padding logic) ---
                    present_hemispheres = fieldnames(thisEventStruct.LfpFrequencySnapshotEvents);
                    
                    if ~isempty(present_hemispheres)
                        sample_hemi = present_hemispheres{1};
                        PSD.Frequency = thisEventStruct.LfpFrequencySnapshotEvents.(sample_hemi).Frequency;
                        nBins = length(thisEventStruct.LfpFrequencySnapshotEvents.(sample_hemi).FFTBinData);
                    else
                        PSD.Frequency = [];
                        nBins = 0;
                    end
                    
                    for hemisphereId = 1:nHemisphereLocations
                        hName = hemisphereLocationNames{hemisphereId};
                        
                        if isfield(thisEventStruct.LfpFrequencySnapshotEvents, hName)
                            PSD.FFTBinData(:, hemisphereId) = thisEventStruct.LfpFrequencySnapshotEvents.(hName).FFTBinData;
                            PSD.channel_names{hemisphereId} = [hName(23:end), ' ' thisEventStruct.LfpFrequencySnapshotEvents.(hName).SenseID(27:end)];
                        else
                            if nBins > 0
                                PSD.FFTBinData(:, hemisphereId) = NaN(nBins, 1);
                            else
                                PSD.FFTBinData(:, hemisphereId) = NaN;
                            end
                            PSD.channel_names{hemisphereId} = [hName(23:end), ' Missing Snapshot'];
                        end
                    end
                    
                    PSD.nChannels = nHemisphereLocations;
                    events.LfpFrequencySnapshotEvents{eventId} = PSD;
                    
                else
                    % --- METADATA EXTRACTION (The Fix) ---
                    raw_val = thisEventStruct.(var_name);
                    
                    % We must wrap text in a cell {} to fit the table's 'cell' column types
                    if strcmp(var_name, 'DateTime') || strcmp(var_name, 'EventName')
                        if ischar(raw_val) || isstring(raw_val)
                            events{eventId, var_name} = {char(raw_val)};
                        elseif isempty(raw_val)
                            events{eventId, var_name} = {''};
                        else
                            events{eventId, var_name} = {raw_val}; 
                        end
                    else
                        % For EventID (double), LFP (logical), Cycling (logical)
                        if ~isempty(raw_val)
                            events{eventId, var_name} = raw_val;
                        end
                    end
                end
            end
        end
    end
    
    % Handle potential empty events table safely
    if ~isempty(events)
        % Pre-allocate a safe datetime array filled with NaT (Not-a-Time)
        safe_dt_array = NaT(height(events), 1);
        
        for eId = 1:height(events)
            val = events.DateTime{eId};
            
            % Only attempt conversion if the value is valid text and not empty
            if (ischar(val) || isstring(val)) && ~isempty(val)
                % Remove the trailing 'Z' (or similar) and replace 'T' with a space
                cleaned_string = regexprep(val(1:end-1), 'T', ' ');
                safe_dt_array(eId) = datetime(cleaned_string);
            end
        end
        
        % Replace the cell array column with the properly formatted datetime vector
        events.DateTime = safe_dt_array;
    end
    LFPTrendLogs.events = events;
    
end

end