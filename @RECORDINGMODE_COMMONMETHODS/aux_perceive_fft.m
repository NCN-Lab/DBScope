function [ pow,f,rpow,lpow ]=aux_perceive_fft( obj, data, fs, tw )
% Auxiliar method for ECG artifact filtering
%
% Syntax:
%       [ pow,f,rpow,lpow ]= AUX_PERCEIVE_FFT( obj, data, fs, tw );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%    * fs - sampling frequency
%    * tw
%
% Example:
%   [ pow,f,rpow,lpow ]= AUX_PERCEIVE_FFT( data, fs, tw );
%
% Adapted from Wolf-Julian Neumann 22.11.2021 - ICN Charité Berlin, Germany
% https://github.com/neuromodulation/perceive
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

if ~exist('tw','var')
    tw = fs;
end

for a = 1:size(data,1)
    [pow(a,:),f] = pwelch(data(a,:),hanning(round(tw)),round(tw*0.5),round(tw),fs);
    rpow(a,: ) = 100.*pow(a,:)./sum(pow(a,obj.aux_perceive_sc(f,[5:45 55:95])));
    try
        lpow(a,:)= perceive_fftlogfitter(f,pow(a,:));
    end

end
