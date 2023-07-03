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
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

switch data_type
    case 'Raw'
        LFP_ordered = obj.streaming_parameters.time_domain.data;
        obj.streaming_parameters.filtered_data.original{end+1} = 'Raw';
    case 'Latest Filtered'
        LFP_ordered = obj.streaming_parameters.filtered_data.data{end};
        obj.streaming_parameters.filtered_data.original{end+1} = 'Latest Filtered';
    case 'ECG Clean'
        LFP_ordered = obj.streaming_parameters.time_domain.ecg_clean;
        obj.streaming_parameters.filtered_data.original{end+1} = 'ECG Clean';
end

%Apply filter
LFP_filtdata = obj.applyFilt_ordered( LFP_ordered, fs, filterType, order, varargin );

% Save filtered data
if isequal(class(obj),'RECORDINGMODE_STREAMING')
    obj.streaming_parameters.filtered_data.data{end+1} = LFP_filtdata;
    obj.streaming_parameters.filtered_data.filter_type{end+1} = {filterType};
    switch filterType
        case 'Low pass'
            obj.streaming_parameters.filtered_data.up_bound{end+1} = varargin{1};
            obj.streaming_parameters.filtered_data.low_bound{end+1} = 0;
            disp(['Filter type: ' cell2mat(obj.streaming_parameters.filtered_data.filter_type{end}), newline...
                'Upper bound: ', num2str(obj.streaming_parameters.filtered_data.up_bound{end})]);
        case 'High pass'
            obj.streaming_parameters.filtered_data.low_bound{end+1} = varargin{1};
            obj.streaming_parameters.filtered_data.up_bound{end+1} = 0;
            disp(['Filter type: ' cell2mat(obj.streaming_parameters.filtered_data.filter_type{end}), newline...
                'Lower bound: ', num2str(obj.streaming_parameters.filtered_data.low_bound{end})]);
        case 'Bandpass'
            obj.streaming_parameters.filtered_data.low_bound{end+1} = varargin{1, 1};
            obj.streaming_parameters.filtered_data.up_bound{end+1} = varargin{1, 2};
            disp(['Filter type: ' cell2mat(obj.streaming_parameters.filtered_data.filter_type{end}), newline...
                'Lower bound: ', num2str(obj.streaming_parameters.filtered_data.low_bound{end}), newline,...
                'Upper bound: ', num2str(obj.streaming_parameters.filtered_data.up_bound{end})]);
        case 'Stop band'
            obj.streaming_parameters.filtered_data.low_bound{end+1} = varargin{1, 1};
            obj.streaming_parameters.filtered_data.up_bound{end+1} = varargin{1, 2};
            disp(['Filter type: ' cell2mat(obj.streaming_parameters.filtered_data.filter_type{end}), newline...
                'Lower bound: ', num2str(obj.streaming_parameters.filtered_data.low_bound{end}), newline,...
                'Upper bound: ', num2str(obj.streaming_parameters.filtered_data.up_bound{end})]);
        otherwise
    end

end

end