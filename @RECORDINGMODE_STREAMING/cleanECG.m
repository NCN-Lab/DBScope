function text = cleanECG( obj, fs )
% filter ECG artifacts from LFP online streaming recordings
%
% Syntax:
%   CLEANECG( obj, fs, ax );
%
% Input parameters:
%    * obj - object containg data
%    * fs - sampling frequency
%    * ax (optional) - axis where you want to plot
%
% Example:
%   CLEANECG( fs, ax );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136..
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Get LFP data
LFP_ordered = obj.streaming_parameters.time_domain.data;

text = "";

%Apply ECG artifact filter
if iscell(LFP_ordered)
    obj.streaming_parameters.time_domain.artefact_status = cell(1, length(LFP_ordered));
    for i = 1:length(LFP_ordered)
        LFP_raw = LFP_ordered{i}';
        text = text + newline + "Recording " + string(i) + ":";
        for e = 1:size(LFP_raw,1)
            [LFP_ECGdata{i}{e}, txt]    = obj.filterEcg( LFP_raw(e,:), fs );
            switch txt
                case 'Unreliable or no ECG detected.'
                    obj.streaming_parameters.time_domain.artefact_status{i}{e} = 'NO ARTEFACT DETECTED';
                case 'Consistent ECG detected.'
                    obj.streaming_parameters.time_domain.artefact_status{i}{e} = 'ECG ARTEFACT DETECTED';
            end

            text = text + newline + string([obj.streaming_parameters.time_domain.channel_names{i}{e} ': ' txt]);
        end
    end
end

%Save ECG cleaned data
clean_ECG = [];

if isequal(class(obj),'RECORDINGMODE_STREAMING')
    obj.streaming_parameters.time_domain.ecg_clean = {};
    for i = 1:length(LFP_ECGdata)
        data = zeros(length(LFP_ECGdata{1, i}{1, 1}.cleandata'),length(LFP_ECGdata{i}));
        for c = 1:length(LFP_ECGdata{i})
            data(:,c)  = LFP_ECGdata{1, i}{1,c}.cleandata';
        end
        clean_ECG{i} = data;
        obj.streaming_parameters.time_domain.ecg_clean{i} = clean_ECG{i};
    end
end

end
