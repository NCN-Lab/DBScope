function plotSignalAndStimulation( obj, varargin )
% PLOTSIGNALANDSTIMULATION Computes and plot standard spectrogram
% Use with LFP online streaming recordings
%
% Syntax:
%   PLOTSIGNALANDSTIMULATION( obj, varargin );
%
% Input parameters:
%    * obj - object containg data
%    * ax (optional) - axis where you want to plot
%    * data_type (optional) - type of input data (raw, ecg cleaned or filtered)
%    * rec (optional) - recording index
%    * channel (optional) - hemisphere
%
% Example:
%   PLOTSIGNALANDSTIMULATION( obj );
%   PLOTSIGNALANDSTIMULATION( obj, ax, data_type, rec, channel );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Parse input variables
switch nargin
    case 5
        ax          = varargin{1};
        data_type   = varargin{2};
        rec         = varargin{3};
        channel     = varargin{4};

        switch data_type
            case 'Raw'
                LFP_selected = obj.streaming_parameters.time_domain.data;
            case 'ECG Cleaned'
                LFP_selected = obj.streaming_parameters.time_domain.ecg_clean;
            case 'Latest Filtered'
                LFP_selected = obj.streaming_parameters.filtered_data.data{end};
        end

        aux_plotSignalAndStimulation( obj, ax, LFP_selected, rec, channel );

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
            for channel = 1:numel( LFP_selected{rec}(1,:) )
                ax = subplot( numel( LFP_selected{rec}(1,:) ), 1, channel );
                aux_plotSignalAndStimulation( obj, ax, LFP_selected, rec, channel );
            end
        end
end


end

function aux_plotSignalAndStimulation(obj, ax, LFP_selected, rec, channel)
% Get sampling frequency parameters
stimAmp                 = obj.streaming_parameters.stim_amp;
sampling_freq_Hz        = obj.streaming_parameters.time_domain.fs;
sampling_freq_stimAmp   = obj.streaming_parameters.stim_amp.fs;

% Get data
LFP         = LFP_selected{rec}(:, channel);
tms         = ( 0:numel( LFP ) - 1 ) / sampling_freq_Hz;
stim        = stimAmp.data{rec}(:, channel);
tms_stim    = ( 0:numel( stim ) - 1 ) / sampling_freq_stimAmp;

% Plot data
cla( ax, 'reset' );
yyaxis( ax, "left" );
plot( ax, tms, LFP);
ylabel( ax, 'LFP [\muVp]' );
yyaxis( ax, "right" );
plot( ax, tms_stim, stim, 'LineWidth', 2 );
ylabel( ax, stimAmp.ylabel );
title( ax, 'Signal & Stimulation' );
xlabel( ax, 'Time [sec]' );
xlim( ax, [min(tms) max(tms)] );
ylim( ax, [0 ceil( max(stim) + 1)] );

end



