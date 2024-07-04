function filtStreaming ( obj, fs, data_type, filterType, order, varargin )
% Filter LFP signal from  streaming recordings
%
% Syntax:
%   FILTSTREAMING( obj, fs, filterType, varargin );
%
% Input parameters:
%    * obj - object containg data
%    * fs - sampling frequency
%    * filterType - type of filter selected
%    * order - order of filter ( default = 4 )
%    * ax (optional) - axis where you want to plot
%
% Example:
%   FILTSTREAMING( fs, filterType, varargin )
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

if ~isempty(obj.streaming_parameters.filtered_data.data_ID)
    latest_ID = obj.streaming_parameters.filtered_data.data_ID{end};
    indx = str2num(strrep(latest_ID, 'Filtered_', ''));
else
    indx = 0;
end

obj.streaming_parameters.filtered_data.data_ID{end+1} = ['Filtered_' num2str(indx + 1, '%03d')];

switch data_type
    case 'Raw'
        LFP_ordered = obj.streaming_parameters.time_domain.data;
        obj.streaming_parameters.filtered_data.original_data_ID{end+1} = 'Raw';
    case 'Latest Filtered'
        LFP_ordered = obj.streaming_parameters.filtered_data.data{end};
        obj.streaming_parameters.filtered_data.original_data_ID{end+1} = latest_ID;
    case 'ECG Clean'
        LFP_ordered = obj.streaming_parameters.time_domain.ecg_clean;
        obj.streaming_parameters.filtered_data.original_data_ID{end+1} = 'ECG';
end

%Apply filter
LFP_filtdata = obj.applyFilt_ordered( LFP_ordered, fs, filterType, order, varargin{1} );

% Save filtered data
if isequal(class(obj),'RECORDINGMODE_STREAMING')
    obj.streaming_parameters.filtered_data.data{end+1} = LFP_filtdata;
    obj.streaming_parameters.filtered_data.filter_type{end+1} = {filterType};
    switch filterType
        case 'Low pass'
            obj.streaming_parameters.filtered_data.bounds{end+1} = [0 varargin{1}(1)];
            disp(['Filter type: ' cell2mat(obj.streaming_parameters.filtered_data.filter_type{end}), newline...
                'Upper bound: ', num2str(obj.streaming_parameters.filtered_data.bounds{end}(2))]);
        case 'High pass'
            obj.streaming_parameters.filtered_data.bounds{end+1} = [varargin{1}(1) obj.streaming_parameters.time_domain.fs];
            disp(['Filter type: ' cell2mat(obj.streaming_parameters.filtered_data.filter_type{end}), newline...
                'Lower bound: ', num2str(obj.streaming_parameters.filtered_data.bounds{end}(1))]);
        case 'Bandpass'
            obj.streaming_parameters.filtered_data.bounds{end+1} = [varargin{1}(1) varargin{1}(2)];
            disp(['Filter type: ' cell2mat(obj.streaming_parameters.filtered_data.filter_type{end}), newline...
                'Lower bound: ', num2str(obj.streaming_parameters.filtered_data.bounds{end}(1)), newline,...
                'Upper bound: ', num2str(obj.streaming_parameters.filtered_data.bounds{end}(2))]);
        case 'Stop band'
            obj.streaming_parameters.filtered_data.bounds{end+1} = [varargin{1}(1) varargin{1}(2)];
            disp(['Filter type: ' cell2mat(obj.streaming_parameters.filtered_data.filter_type{end}), newline...
                'Lower bound: ', num2str(obj.streaming_parameters.filtered_data.bounds{end}(1)), newline,...
                'Upper bound: ', num2str(obj.streaming_parameters.filtered_data.bounds{end}(2))]);
        otherwise
    end

end

end