function plotWearable( obj, varargin )
% PLOTPOWER 
% Plots power of total acceleration in 3-7 Hz range.
%
% Syntax:
%   PLOTWEARABLE( obj, varargin )
%
% Input parameters:
%    * obj                  DBScope object containg wearable data.
%    * (optional) ax        Axis where to plot.
%    * rec                  Index of recording.
%    * variable             Index of variable (in case there is more than
%                           one).
%    * (optional) limits    Plot x limits.
%
% PLOTWEARABLE(..., 'PARAM1', val1, 'PARAM2', val2, ...)
%   specifies optional name/value pairs:
%     'Limits'              Datetime limits of axis. 
%                           Defaults to []
%
% Example:
%   obj.PLOTWEARABLE();
%   PLOTWEARABLE( obj, rec, variable, limits );
%   PLOTWEARABLE( obj, ax, rec, variable, limits );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Eduardo Carvalho, Andreia M. Oliveira & Paulo Aguiar - NCN 
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Create an input parser object
parser = inputParser;

validScalarNum  = @(x) isnumeric(x) && isscalar(x) && (x > 0);

% Define input parameters and their default values
addRequired(parser, 'Recording', validScalarNum);
addRequired(parser, 'VariableIndx', validScalarNum);
addParameter(parser, 'Limits', []); % Default value is []

% Parse the input arguments
if isa(varargin{1}, 'matlab.ui.control.UIAxes') || isa(varargin{1}, 'matlab.graphics.axis.Axes')
    ax = varargin{1};
    parse(parser, varargin{2:end});
else
    ax = [];
    parse(parser, varargin{:});
end

% Access the values of inputs
rec             = parser.Results.Recording;
variable        = parser.Results.VariableIndx;
limits          = parser.Results.Limits;

if isempty(ax)
    figure("Position", [100 300 1200 300]);
    ax = axes();
end

title_str       = obj.data(rec).wearableID;

aux_tbl         = obj.data(rec).data;
variable_names  = fieldnames(aux_tbl);

% at              = sqrt(aux_tbl.ax.^2 + aux_tbl.ay.^2 + aux_tbl.az.^2);
% [signal, indx]  = rmmissing( at );
signal          = aux_tbl{:,variable};
[signal, indx]  = rmmissing( signal );

aux_time        = obj.data(rec).time;
tms             = aux_time(~indx);

diff_start      = seconds( limits(1) - tms(1) );
tms             = seconds(tms - tms(1)) - diff_start;

plot( ax, tms, signal );
xlabel( ax, "Time (s)" );
ylabel( ax, variable_names(variable), 'Interpreter', 'none' );
xlim( ax, [0 seconds( limits(2) - limits(1) )] );
title( ax, title_str );
box( ax, 'on');
    
end
