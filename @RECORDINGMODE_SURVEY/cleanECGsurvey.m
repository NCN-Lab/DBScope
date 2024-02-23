function text = cleanECGsurvey( obj, fs )
% Filters ECG artifacts from LFP Survey recordings.
%
% Syntax:
%    CLEANECGSURVEY( obj, fs );
%
% Input parameters:
%    * obj - object containg survey data
%    * fs - sampling frequency
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Get LFP data
LFP_ordered = obj.survey_parameters.time_domain.data;

text = "";

% Apply ECG artifact filter
if iscell(LFP_ordered)
    for i = 1:length( LFP_ordered )
        LFP_raw = LFP_ordered{i}';

        for e = 1:size( LFP_raw,1 )
            [~, txt]    = obj.filterEcg( LFP_raw(e,:), fs );
            text        = text + newline + string([obj.survey_parameters.time_domain.channel_names{i}{e} ': ' txt]);
        end

    end

    % This function does not save the ECG clean data in the object structure.

end
end