function cleanECGsurvey( obj, fs )
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
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Get LFP data
LFP_ordered = obj.survey_parameters.time_domain.data;

% Apply ECG artifact filter
if iscell(LFP_ordered)
    for i = 1:length( LFP_ordered )
        LFP_raw = LFP_ordered{i}';

        for e = 1:size( LFP_raw,1 )
            LFP_ECGdata{i}{e} = obj.filterEcg( LFP_raw(e,:), fs );
        end

    end

    % This function does not save the ECG clean data in the object structure.

end
end