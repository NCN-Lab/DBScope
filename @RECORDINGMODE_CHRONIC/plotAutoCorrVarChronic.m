function  plotAutoCorrVarChronic( obj, varargin )
% Plot autocorrelation and autocovariance for chronic LFP recordings.
%
% Syntax:
%   PLOTAUTOCORRVAR( obj, ax );
%
% Input parameters:
%    * obj - object containg data
%    * ax (optional) - axis where you want to plot
%
% Example:
%   obj.PlotAutoCorrVar();
%   PLOTCIRCADIAN( obj );
%   PLOTCIRCADIAN( obj, ax );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
hemispheres_names  = obj.chronic_parameters.time_domain.hemispheres;
LFP_ordered = obj.chronic_parameters.time_domain.data;
color = lines(2);

% Parse input variables
switch nargin
    case 2
        % Plot autocorr and autovar in specified axis
        ax = varargin{1};
        
        for i = 1:size(LFP_ordered, 2)
            [c1,lags1] = xcov( LFP_ordered(:,i), 'normalized' );
            [c2,lags2]= xcorr( LFP_ordered(:,i), 'normalized' );

            cla(ax(2*(i-1)+1), 'reset');
            plot(ax(2*(i-1)+1), lags1/(6*24), c1', 'Color', color(i,:));
            xlabel(ax(2*(i-1)+1), 'Time [days]');
            ylabel(ax(2*(i-1)+1), 'Normalized Autocovariance');

            cla(ax(2*(i-1)+2), 'reset');
            plot(ax(2*(i-1)+2), lags2/(6*24), c2', 'Color', color(i,:));
            xlabel(ax(2*(i-1)+2), 'Time [days]');
            ylabel(ax(2*(i-1)+2), 'Normalized Autocorrelation');

            if contains(hemispheres_names(i,:), 'Left')
                title(ax(2*(i-1)+1), 'Left Hemisphere' );
                title(ax(2*(i-1)+2), 'Left Hemisphere' );
            else
                title(ax(2*(i-1)+1), 'Right Hemisphere' );
                title(ax(2*(i-1)+2), 'Right Hemisphere' );
            end

        end

    case 1
        % Plot autocorr and autovar in new figure
        if length(LFP_ordered(1,:)) == 2
            [c1,lags1] = xcov( LFP_ordered(:,1),'normalized'  );
            [c2,lags2]= xcorr ( LFP_ordered(:,1),'normalized'  );
            [c3,lags3] = xcov(  LFP_ordered(:,2),'normalized' );
            [c4,lags4]= xcorr (  LFP_ordered(:,2),'normalized' );

            figure
            sgtitle([char(obj.chronic_parameters.time_domain.time(:,1)) ' to ' ...
                char(obj.chronic_parameters.time_domain.time(:,end))])
            subplot (2,2,1)
            plot( lags1/(6*24),c1, 'r' )
            title('Autocovariance LFP channel:')
            subtitle( char(hemispheres_names(1,:)), 'Interpreter', 'none' );
            ylabel( 'Normalized Autocovariance' )
            xlabel( 'Time [days]' )
            subplot(2,2,2)
            plot( lags2/(6*24),c2, 'r' )
            title('Autocorrelation LFP channel:' )
            subtitle( char(hemispheres_names(1,:)), 'Interpreter','none' );
            ylabel( 'Normalized Autocorrelation' )
            xlabel( 'Time [days]' )
            subplot (2,2,3)
            plot( lags3/(6*24),c3 )
            title('Autocovariance LFP channel:' )
            subtitle( char(hemispheres_names(2,:)), 'Interpreter', 'none' );
            ylabel( 'Normalized Autocovariance' )
            xlabel( 'Time [days]' )
            subplot(2,2,4)
            plot( lags4/(6*24),c4 )
            title('Autocorrelation LFP channel:' )
            subtitle( char(hemispheres_names(2,:)), 'Interpreter', 'none' );
            ylabel( 'Normalized Autocorrelation' )
            xlabel( 'Time [days]' )

        elseif length(LFP_ordered(1,:)) == 1
            [c1,lags1] = xcov( LFP_ordered(:,1),'normalized'  );
            [c2,lags2]= xcorr ( LFP_ordered(:,1),'normalized'  );

            figure
            sgtitle([char(obj.chronic_parameters.time_domain.time(:,1)) ' to ' ...
                char(obj.chronic_parameters.time_domain.time(:,end))])
            subplot (2,1,1)
            plot( lags1/(6*24),c1, 'r' )
            title('Autocovariance LFP channel:' )
            subtitle( char(hemispheres_names(1,:)), 'Interpreter', 'none' );
            ylabel( 'Normalized Autocovariance' )
            xlabel( 'Time [days]' )
            subplot(2,1,2)
            plot( lags2/(6*24),c2, 'r' )
            title('Autocorrelation LFP channel:' )
            subtitle( char(hemispheres_names(1,:)), 'Interpreter', 'none' );
            ylabel( 'Normalized Autocorrelation' )
            xlabel( 'Time [days]' )

            disp('Only one hemisphere available')
        end

end

end
