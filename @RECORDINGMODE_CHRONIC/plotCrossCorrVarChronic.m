function  plotCrossCorrVarChronic( obj, varargin )
% Cross-correlation and cross-variance of chronic LFP recordings
%
% Syntax:
%   PLOTCROSSCORRVARCHRONIC( obj, ax );
%
% Input parameters:
%    * obj - object containg data
%    * ax (optional) - axis where you want to plot
%
% Example:
%   PLOTCROSSCORRVARCHRONIC( obj );
%   PLOTCROSSCORRVARCHRONIC( obj, ax );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

hemispheres_names  = obj.chronic_parameters.time_domain.hemispheres;
LFP_ordered = obj.chronic_parameters.time_domain.data;

% Parse input variables
switch nargin
    case 2
        % Plot crosscorr and crossvar in specified axis
        ax = varargin{1};

        if size(LFP_ordered,2) == 2
            [c1,lags1] = xcov( LFP_ordered(:,1), LFP_ordered(:,2), 'unbiased' );
            [c2,lags2]= xcorr( LFP_ordered(:,1), LFP_ordered(:,2), 'unbiased' );

            cla(ax(1), 'reset');
            plot(ax(1), lags1/(6*24), c1');
            title(ax(1), 'Hemispherical Cross-covariance' );
            xlabel(ax(1), 'Time [days]');
            ylabel(ax(1), 'Unbiased Cross-covariance');

            cla(ax(2), 'reset');
            plot(ax(2), lags2/(6*24), c2');
            title(ax(2), 'Hemispherical Cross-correlation' );
            xlabel(ax(2), 'Time [days]');
            ylabel(ax(2), 'Unbiased Cross-correlation');
        end

    case 1
        % Plot crosscorr and crossvar in new figure
        if length(LFP_ordered(1,:)) == 2
            [c5,lags5] = xcov( LFP_ordered(:,1), LFP_ordered(:,2),'unbiased' );
            [c6,lags6]= xcorr ( LFP_ordered(:,1), LFP_ordered(:,2),'unbiased' );

            fig = figure;
            new_position = [16, 48, 1425, 727];
            set(fig, 'position', new_position)
            sgtitle([char(obj.chronic_parameters.time_domain.time(:,1)) ' to ' ...
                char(obj.chronic_parameters.time_domain.time(:,end))])
            subplot (1,2,1)
            plot( lags5/(6*24),c5 )
            title('Cross-covariance LFP channels: ' )
            subtitle([ char(hemispheres_names(1,:)) ' & ' char(hemispheres_names(2,:)) ], 'Interpreter', 'none' );
            ylabel( 'Normalized Cross-covariance' )
            xlabel( 'Time [days]' )
            subplot(1,2,2)
            plot( lags6/(6*24),c6 )
            title('Cross-correlation LFP channels: ' )
            subtitle([ char(hemispheres_names(1,:)) ' & ' char(hemispheres_names(2,:)) ], 'Interpreter', 'none' );
            ylabel( 'Normalized Cross-correlation' )
            xlabel( 'Time [days]' )

        elseif length(LFP_ordered(1,:)) == 1
            disp('Only one hemisphere available')
        end

end


end

