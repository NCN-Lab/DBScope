function plotFiltDataStream_multi( obj, filter_indx, varargin )
% Plot filtered LFP online streaming recordings: plot two filters
%
% Syntax:
%   PLOTFILTDATASTREAM_MULTI( obj, filter_indx, varargin );
%
% Input parameters:
%    * obj - object containg data
%    * filter_indx
%    * ax (optional) - axis where you want to plot
%
% Example:
%   PLOTFILTDATASTREAM_MULTI( filter_indx, varargin );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Get sampling frequency
sampling_freq_Hz =  obj.streaming_parameters.time_domain.fs;
Nyquist = 0.5 * sampling_freq_Hz;

% Check if data is filtered
if isempty (obj.streaming_parameters.filtered_data.data)
    disp('Data is not filtered')
    return
else
    disp('Data is filtered')
    indx_filter = filter_indx;

end

if size(indx_filter) ~= 2
    disp( 'Please, select two filtered signals to compare.')
    return
end

% Get LFP data
LFP_raw = obj.streaming_parameters.time_domain.data;
LFP_filtered = [];
LFP_filtered{1} = obj.streaming_parameters.filtered_data.data{indx_filter(1)};
LFP_filtered{2} = obj.streaming_parameters.filtered_data.data{indx_filter(2)};
channel_name =  obj.streaming_parameters.time_domain.channel_names;
LFP_ylabel = obj.streaming_parameters.time_domain.ylabel;

switch nargin
    case 5
        ax = varargin{1};
        record = varargin{2};
        indx = varargin{3};

    LFP_aux_one = {};
    for c = 1:numel(LFP_filtered{1})
        for d = 1:numel(LFP_filtered{1}{record}(1,:))
            LFP_aux_one{end+1} = LFP_filtered{1}{record}(:,d);
        end
    end
    LFP_aux_two = {};
    for c = 1:numel(LFP_filtered{2})
        for d = 1:numel(LFP_filtered{2}{record}(1,:))
            LFP_aux_two{end+1} = LFP_filtered{2}{record}(:,d);
        end
    end
    LFP_raw_vw = {};
    for d = 1:numel(LFP_raw{record}(1,:))
        LFP_raw_vw{end+1} = LFP_raw{record}(:,d);
    end

    if indx == 1

        tms_left = (0:numel(LFP_raw_vw{1})-1)/sampling_freq_Hz;

        cla( ax(1), 'reset');
        plot( ax (1), tms_left, LFP_raw_vw{1} );
        ylabel( ax(1), LFP_ylabel)
        title( ax(1), 'Raw Signal' )
        xlabel( ax(1), 'Time [sec]')

        cla( ax(2), 'reset');
        plot( ax(2), tms_left,LFP_aux_one{1})
        ylabel( ax(2), LFP_ylabel)
        title( ax(2), 'Filtered signal 1' )
        xlabel( ax(2), 'Time [sec]')

        cla(ax(3), 'reset');
        plot( ax(3), tms_left,LFP_aux_two{1})
        ylabel( ax(3), LFP_ylabel)
        title( ax(3), 'Filtered signal 2' )
        xlabel( ax(3), 'Time [sec]')

    elseif indx == 2
        tms_right = (0:numel(LFP_raw_vw{2})-1)/sampling_freq_Hz;

        cla( ax(1), 'reset');
        plot( ax (1), tms_right, LFP_raw_vw{2} );
        ylabel( ax(1), LFP_ylabel)
        title( ax(1), 'Raw Signal' )
        xlabel( ax(1), 'Time [sec]')

        cla( ax(2), 'reset');
        plot( ax(2), tms_right,LFP_aux_one{2})
        ylabel( ax(2), LFP_ylabel)
        title( ax(2), 'Filtered signal 1' )
        xlabel( ax(2), 'Time [sec]')

        cla(ax(3), 'reset');
        plot( ax(3), tms_right,LFP_aux_two{2})
        ylabel( ax(3), LFP_ylabel)
        title( ax(3), 'Filtered signal 2' )
        xlabel( ax(3), 'Time [sec]')

    end

case 1

    for c = 1:numel(LFP_raw)
        if length(LFP_raw{c}(1,:)) == 2

            tms_left = (0:numel(LFP_raw{c}(:,1))-1)/sampling_freq_Hz;
            tms_right = (0:numel(LFP_raw{c}(:,2))-1)/sampling_freq_Hz;

            fig = figure;
            new_position = [16, 48, 1425, 727];
            set(fig, 'position', new_position)
            subplot(2,3,1)
            plot(tms_left, LFP_raw{c}(:,1));
            ylabel(LFP_ylabel)
            title('Raw Signal channel: ' )
            subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' );
            xlabel('Time [sec]')
            ax1 = gca;
            subplot(2,3,2)
            plot(tms_left,LFP_filtered{1}{c}(:,1))
            ylabel(LFP_ylabel)
            title('Filtered signal channel: ' )
            subtitle([ char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)) ', idx filter: 1' ], 'Interpreter', 'none' )
            xlabel('Time [sec]')
            subplot(2,3,3)
            plot(tms_right,LFP_filtered{2}{c}(:,1))
            ylabel(LFP_ylabel)
            title('Filtered signal channel: ' )
            subtitle([ char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)) ', idx filter: 2' ], 'Interpreter', 'none' )
            xlabel('Time [sec]')
            subplot(2,3,4)
            plot(tms_right, LFP_raw{c}(:,2));
            ylabel(LFP_ylabel)
            title('Raw signal channel: ' )
            subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,2)), 'Interpreter', 'none' );
            xlabel('Time [sec]')
            ax1 = gca;
            subplot(2,3,5)
            plot(tms_right,LFP_filtered{1}{c}(:,2))
            ylabel(LFP_ylabel)
            title('Filtered signal channel: ' )
            subtitle([ char(obj.streaming_parameters.time_domain.channel_names{c}(:,2)) ', idx filter: 1' ], 'Interpreter', 'none' )
            xlabel('Time [sec]')
            subplot(2,3,6)
            plot(tms_right,LFP_filtered{2}{c}(:,2))
            ylabel(LFP_ylabel)
            title('Filtered signal channel: ' )
            subtitle([ char(obj.streaming_parameters.time_domain.channel_names{c}(:,2)) ', idx filter: 2' ], 'Interpreter', 'none' )
            xlabel('Time [sec]')

        elseif length(LFP_raw{c}(1,:)) == 1
            disp('Only one hemisphere was available')
            tms_left = (0:numel(LFP_raw{c}(:,1))-1)/sampling_freq_Hz;

            fig = figure;
            new_position = [16, 48, 1425, 727];
            set(fig, 'position', new_position)
            subplot(2,3,1)
            plot(tms_left, LFP_raw{c}(:,1));
            ylabel(LFP_ylabel)
            title('Raw Signal channel: ' )
            subtitle( char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)), 'Interpreter', 'none' )
            xlabel('Time [sec]')
            ax1 = gca;
            subplot(2,3,2)
            plot(tms_left,LFP_filtered{1}{c}(:,1))
            ylabel(LFP_ylabel)
            title( 'Filtered signal channel: ' )
            subtitle([ char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)) ', idx filter: 1' ], 'Interpreter', 'none');
            xlabel('Time [sec]')
            subplot(2,3,3)
            plot(tms_left,LFP_filtered{2}{c}(:,1))
            ylabel(LFP_ylabel)
            title('Filtered signal channel: ' )
            subtitle([char(obj.streaming_parameters.time_domain.channel_names{c}(:,1)) ', idx filter: 2' ], 'Interpreter', 'none' );
            xlabel('Time [sec]')

        end

    end

end

disp(['Filter type: ' cell2mat(obj.streaming_parameters.filtered_data.filter_type{end}), newline...
    'Lower bound: ', num2str(obj.streaming_parameters.filtered_data.low_bound{end}), newline,...
    'Upper bound: ', num2str(obj.streaming_parameters.filtered_data.up_bound{end})]);
end
