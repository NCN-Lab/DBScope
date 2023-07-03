function [ lfp_montage ] = extractLFPMontage( obj, data )
% Extracts LFPs Montage data.
%
% Syntax:
%    [ lfp_montage ] = EXTRACTLFPMONTAGE( obj, data );
%
% Input parameters:
%    * obj - object containg survey data
%    * data - structure containing montage
%
% Output parameters:
%    * lfp_montage - new structure containing montage data
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

% Two data formats co-exist (structure or cell of structures)
n_recordings = size(data.LFPMontage, 1);

if ~iscell(data.LFPMontage)
    s = cell(n_recordings, 1);

    for rec_id = 1:n_recordings
        s{rec_id} = data.LFPMontage(rec_id);
    end

    data.LFPMontage = s;

end

% Extract LFP Montage data
lfp_montage.frequency = data.LFPMontage{1}.LFPFrequency;
lfp_montage.magnitude = NaN(size(lfp_montage.frequency, 1), n_recordings);

for rec_id = 1:n_recordings
    lfp_montage.hemisphere{rec_id} = obj.aux_afterPoint(data.LFPMontage{rec_id}.Hemisphere);
    lfp_montage.channel_names{rec_id} = strrep(obj.aux_afterPoint(data.LFPMontage{rec_id}.SensingElectrodes), '_', ' ');
    lfp_montage.magnitude(:, rec_id) = data.LFPMontage{rec_id}.LFPMagnitude;
    lfp_montage.artifact_status{rec_id} = obj.aux_afterPoint(data.LFPMontage{rec_id}.ArtifactStatus);
end

end