function plotWearable( obj, varargin )
% PLOTPOWER Plots power of total acceleration in 3-7 Hz range.
%
%   Syntax:
%       PLOTPOWER( obj )
%
%   Input parameters:
%       obj
%
%   Example:
%       PLOTPOWER( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Eduardo Carvalho, Andreia M. Oliveira & Paulo Aguiar - NCN 
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Parse input variables
switch nargin
    case 5
        ax                      = varargin{1};
        lbl                     = varargin{2};
        variable_name           = varargin{3};
        recording_limits        = varargin{4};

    case 1


end

lbl             = strsplit( lbl, ' ' );
rec             = find( strcmp( [obj.data.wearableID], lbl(1) ) & ...
                        strcmp( [obj.data.titration], lbl(2)));
title_str       = obj.data(rec).wearableID;
[signal, indx]  = rmmissing( obj.data(rec).(variable_name) );
tms             = obj.data(rec).time(~indx);

diff_start      = seconds( recording_limits(1) - tms(1) );
tms             = seconds(tms - tms(1)) - diff_start;

plot( ax, tms, signal );
xlabel( ax, "Time [sec]" );
ylabel( ax, variable_name, 'Interpreter', 'none' );
xlim( ax, [0 seconds( recording_limits(2) - recording_limits(1) )] );
title( ax, title_str );
box( ax, 'on');

end
