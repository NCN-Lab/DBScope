function status = filtSurvey( obj,  fs, filterType, order, bounds )
% Filters LFP Survey recordings, using a Butterworth filter.
%
% Syntax:
%    status = FILTSURVEY( obj, fs, filterType, order, bounds );
%
% Input parameters:
%    * obj - object containg survey data
%    * fs - sampling frequency
%    * filterType - low, high, band, stop
%    * order - filter order (Butterworth
%    * bounds - cut-off frequencies
%
% Output parameters:
%    * status - 1, for successful filtration; 0, otherwise
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
status = 0;

% Select data to filter
answer = questdlg('Which data do you want to filter?', ...
    '', ...
    'Raw','Latest Filtered','Latest Filtered');

% Handle response
switch answer
    case 'Raw'
        if isequal( class(obj),'RECORDINGMODE_SURVEY' )
            LFP_ordered = obj.survey_parameters.time_domain.data;
            obj.survey_parameters.filtered_data.typeofdata{end+1} = {'Raw'};
        end
    case 'Latest Filtered'
        if isequal( class(obj),'RECORDINGMODE_SURVEY' )
            if isempty (obj.survey_parameters.filtered_data.data )
                disp(' Recording has not been filtered yet.')
                return
            else
                LFP_ordered = obj.survey_parameters.filtered_data.data{end};
                obj.survey_parameters.filtered_data.typeofdata{end+1} = {'Latest_filtered'};
            end
        end
    otherwise
        return
end

if numel(bounds) == 1
elseif numel(bounds) == 2
    if bounds(2) <= bounds(1)
        disp(['Invalid cut-off frequency values. Make sure you follow the form ...' ...
            ' [low high].']);
        return;
    end
else
    disp('Cut-off frequencies do not match filter type.');
    return;
end

% Apply filter
LFP_filtdata = obj.applyFilt_ordered( LFP_ordered, fs, filterType, order, {bounds} );

% Save filtered data
if isequal( class(obj),'RECORDINGMODE_SURVEY' )
    obj.survey_parameters.filtered_data.data{end+1} = LFP_filtdata;
    obj.survey_parameters.filtered_data.filter_type{end+1} = {filterType};

    switch filterType
        case 'Low pass'
            obj.survey_parameters.filtered_data.up_bound{end+1} = bounds(1);
            obj.survey_parameters.filtered_data.low_bound{end+1} = 0;
            disp(['Filter type: ' cell2mat(obj.survey_parameters.filtered_data.filter_type{end}), newline...
                'Upper bound: ', num2str(obj.survey_parameters.filtered_data.up_bound{end})]);
        case 'High pass'
            obj.survey_parameters.filtered_data.low_bound{end+1} = bounds(1);
            obj.survey_parameters.filtered_data.up_bound{end+1} = 0;
            disp(['Filter type: ' cell2mat(obj.survey_parameters.filtered_data.filter_type{end}), newline...
                'Lower bound: ', num2str(obj.survey_parameters.filtered_data.low_bound{end})]);
        case 'Bandpass'
            obj.survey_parameters.filtered_data.low_bound{end+1} = bounds(1);
            obj.survey_parameters.filtered_data.up_bound{end+1} = bounds(2);
            disp(['Filter type: ' cell2mat(obj.survey_parameters.filtered_data.filter_type{end}), newline...
                'Lower bound: ', num2str(obj.survey_parameters.filtered_data.low_bound{end}), newline,...
                'Upper bound: ', num2str(obj.survey_parameters.filtered_data.up_bound{end})]);
        case 'Stop band'
            obj.survey_parameters.filtered_data.low_bound{end+1} = bounds(1);
            obj.survey_parameters.filtered_data.up_bound{end+1} = bounds(2);
            disp(['Filter type: ' cell2mat(obj.survey_parameters.filtered_data.filter_type{end}), newline...
                'Lower bound: ', num2str(obj.survey_parameters.filtered_data.low_bound{end}), newline,...
                'Upper bound: ', num2str(obj.survey_parameters.filtered_data.up_bound{end})]);
        otherwise

    end
end

status = 1;

end
