function plotCoherence ( obj, varargin )
% Plot coherence for LFP online streaming mode
%
% Syntax:
%   PLOTCOHERENCE( obj, varargin );
%
% Input parameters:
%    * obj - object containg data
%    * ax (optional) - axis where you want to plot
%    * data_type (optional) - type of input data (raw, ecg cleaned or filtered)
%    * rec (optional) - recording index
%
% Example:
%   PLOTCOHERENCE( obj );
%   PLOTCOHERENCE( obj, ax, data_type, rec );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

switch nargin
    case 4
        ax          = varargin{1};
        data_type   = varargin{2};
        rec         = varargin{3};

        switch data_type
            case 'Raw'
                LFP_selected = obj.streaming_parameters.time_domain.data;
            case 'ECG Cleaned'
                LFP_selected = obj.streaming_parameters.time_domain.ecg_clean;
            case 'Latest Filtered'
                LFP_selected = obj.streaming_parameters.filtered_data.data{end};
        end

        aux_plotCoherence(obj, ax, LFP_selected, rec);

    case 1 % No interface; returns at the end
        if isempty( obj.streaming_parameters.filtered_data.data )
            disp( 'Data is not filtered' );
            data_type = questdlg( 'Which data do you want to visualize?', ...
                '', 'Raw', 'ECG Cleaned', 'ECG Cleaned' );
        else
            disp( 'Data is filtered' );
            data_type = questdlg( 'Which data do you want to visualize?', ...
                '', 'Raw', 'ECG Cleaned', 'Latest Filtered', 'Latest Filtered' );
        end

        switch data_type
            case 'Raw'
                LFP_selected = obj.streaming_parameters.time_domain.data;
            case 'ECG Cleaned'
                LFP_selected = obj.streaming_parameters.time_domain.ecg_clean;
            case 'Latest Filtered'
                LFP_selected = obj.streaming_parameters.filtered_data.data{end};
        end

        for rec = 1:numel( LFP_selected )
            figure;
            ax = axes;
            aux_Coherence( obj, ax, LFP_selected, rec );
        end

end
end

function aux_plotCoherence(obj, ax, LFP_selected, rec)
% Get sampling frequency parameters
sampling_freq_Hz        = obj.streaming_parameters.time_domain.fs;

% Get data
LFP         = LFP_selected{rec};
tms         = ( 0:size( LFP, 1 ) - 1 ) / sampling_freq_Hz;

% Check if both hemisphere are available
if size(LFP, 2) ~= 2
    disp ('Only one hemisphere available');
    return;
end

% Calculate coherence
[wcoh,~,f,coi] = wcoherence(LFP(:,1), LFP(:,2), sampling_freq_Hz);
wcoh(wcoh<0) = 0;
% Plot data
cla( ax, 'reset');

imagesc(ax, tms, log10(f), wcoh.*0.9999 );
yticks(ax, log10([1, 4, 8, 13, 35, 60]));
set( ax, 'YDir','normal' );
ax.XLabel.String    = 'Time';
yticklabels( ax, [] );
ax.Title.String     = 'Cross-hemispherical Coherence';
ylim(ax, [0 max(log10(f))]);
xlim(ax, [min(tms) max(tms)]);
hcol = colorbar(ax);
hcol.Limits = [0 1];
hcol.Label.String   = 'Magnitude-Squared Coherence';

% disp( [ 'channel 1: ' char(obj.streaming_parameters.time_domain.channel_names{rec}(:,1)),...
%     ', channel 2: ' char(obj.streaming_parameters.time_domain.channel_names{rec}(:,2))]);

end