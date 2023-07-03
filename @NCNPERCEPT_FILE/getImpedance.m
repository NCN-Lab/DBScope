function status = getImpedance( obj, data )
% Extract impedance information.
%
% Syntax:
%  GETIMPEDANCE( obj, data );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%
% Example:
%  GETIMPEDANCE( data )
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

modes = ["Monopolar", "Bipolar"];
for hemisphere = 1:numel(data.Impedance.Hemisphere)
    for mode = modes
        obj.parameters.impedance.hemispheres(hemisphere).label = ...
            data.Impedance.Hemisphere(hemisphere).Hemisphere;

        imp = data.Impedance.Hemisphere(hemisphere).SessionImpedance.(mode);
        C = struct2cell(imp)';
        ResultValues = cell2mat(C(:,3));
        obj.parameters.impedance.hemispheres(hemisphere).(lower(mode)).results = ResultValues;
        obj.parameters.impedance.hemispheres(hemisphere).(lower(mode)).electrode1 = {data.Impedance.Hemisphere(hemisphere).SessionImpedance.(mode).Electrode1};
        obj.parameters.impedance.hemispheres(hemisphere).(lower(mode)).electrode2 = {data.Impedance.Hemisphere(hemisphere).SessionImpedance.(mode).Electrode2};
    end
end

if numel(data.Impedance.Hemisphere) > 0 
    status = 1;
else
    status = 0;
end

end