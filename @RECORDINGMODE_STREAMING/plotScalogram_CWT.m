function plotScalogram_CWT( obj, varargin )
% Continuous 1-D wavelet transform using Morlet wavelet
% Use LFP online streaming recordings
%
% Syntax:
%   PLOT_SCALOGRAM_CWT( obj data_type, varargin );
%
% Input parameters:
%    * obj - object containg data
%    * data_type - type of input data (raw, ecg cleaned or filtered)
%    * ax (optional) - axis where you want to plot
%
% Example:
%   PLOT_SCALOGRAM_CWT(  data_type, varargin );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3S.up.pt
% -----------------------------------------------------------------------
% colormap_boost_factor = 10;

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
            case 'Latest Filtered'
                LFP_selected = obj.streaming_parameters.filtered_data.data{end};
            case 'ECG Cleaned'
                LFP_selected = obj.streaming_parameters.time_domain.ecg_clean;
        end

        aux_plotScalogram( obj, ax, LFP_selected, rec, channel );

    case 1
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
                ax(1) = subplot( numel( LFP_selected{rec}(1,:) ), 2, channel );
                ax(2) = subplot( numel( LFP_selected{rec}(1,:) ), 2, channel + 2 );

                plotSignalAndStimulation( obj, ax(1), data_type, rec, channel );
                aux_plotScalogram( obj, ax(2), LFP_selected, rec, channel );
                    
                set(ax(2), 'PositionConstraint', 'innerposition');
                set(ax(1), 'PositionConstraint', 'innerposition');
                pos2 = get(ax(2), 'InnerPosition');
                pos1 = get(ax(1), 'InnerPosition');

                if pos1(3) ~= pos2(3)
                    pos1(1) = pos2(1);
                    pos1(3) = pos2(3);
                    set(ax(1),'InnerPosition', pos1);
                end
            end
        end
        return;
end

end

function aux_plotScalogram( obj, ax, LFP_selected, rec, channel )
% Get sampling frequency parameters
sampling_freq_Hz        = obj.streaming_parameters.time_domain.fs;

% Get data
LFP                     = LFP_selected{rec}(:, channel);
[ cfs, frq ]            = cwt( LFP, 'amor', sampling_freq_Hz );
tms                     = ( 0:numel( LFP_selected{rec}(:, channel) ) - 1 ) / sampling_freq_Hz;

% Plot data
cla( ax, 'reset' );
imagesc( ax, tms, frq, abs(cfs));
% s = pcolor( ax, tms, frq, abs(cfs));
% s.EdgeColor = 'none';
% s.FaceColor = 'flat';
xlabel( ax, 'Time [sec]');
yticks( ax, [0, 10, floor(max(frq))] );
ylabel( ax, 'Frequency [Hz]');
c = colorbar( ax );
colormap( ax, 'hot');
c.Label.String = 'Power/Frequency (dB/Hz)';
dmax = max( prctile(abs(cfs), 99, "all") );
dmin = 0;
clim( ax, [dmin dmax] );
set( ax, 'YDir', 'normal', 'YScale', 'log');
%set( ax, 'YDir', 'reverse', 'YScale', 'log');
title( ax, 'Scalogram' );
axtoolbar( ax, {'export'} );

end
