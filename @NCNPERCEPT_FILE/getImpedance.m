function status = getImpedance( obj, data )
% Extract impedance information.
%
% Syntax:
%  status = GETIMPEDANCE( obj, data );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%
% Example:
%  status = obj.GETIMPEDANCE( data )
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

if isempty(data.Impedance)
    status = 0;
    warning('There is no impedance data available.');
else
    status = 1;
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
end

end