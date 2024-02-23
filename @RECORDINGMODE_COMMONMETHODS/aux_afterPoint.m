function [ out ] = aux_afterPoint( obj, str )
% Remove all text before point
%
% Syntax:
%   out = AUX_AFTERPOINT( obj, str );
%
% Input parameters:
%    * obj - object containg data
%    * str
%
% Output parameters:
%   out
%
% Example:
%   out = AUX_AFTERPOINT( str );
%
% Adapted from Yohann Thenaisie 20.12.2020 - Lausanne University Hospital
% (CHUV) https://github.com/YohannThenaisie/PerceptToolbox
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

startIndex = strfind(str,'.');
out = str(startIndex+1:end);
