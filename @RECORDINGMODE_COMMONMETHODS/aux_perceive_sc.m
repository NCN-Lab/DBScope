function [ i,o ] = aux_perceive_sc( obj, vec, pts )
% Auxiliar method for ECG artifact filtering
%
% Syntax:
%   [i,o]= AUX_PERCEIVE_SC( obj, vec,pts );
%
% Inputs parameters:
%    * obj - object containg data
%    * vec
%    * pts
%   Example:
%        [i,o]= AUX_PERCEIVE_SC( vec,pts );
%
% Adapted from Wolf-Julian Neumann 22.11.2021 - ICN Charité Berlin, Germany
% https://github.com/neuromodulation/perceive
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

if size(vec,1)~=1
    vec = vec';
end

for a = 1:length(pts)
    [~,i(a)]=min(abs(diff([vec;ones(size(vec)).*pts(a)])));
    o(a)=vec(i(a));
end

end