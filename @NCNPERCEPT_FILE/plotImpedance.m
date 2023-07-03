function [ text ] = plotImpedance( obj, varargin )
% Plot impedance.
%
% Syntax:
%   PLOTIMPEDANCE( obj );
%
% Input parameters:
%    * obj - object containg data
%
%   Output parameters:
%   text
%
% Example:
%   PLOTIMPEDANCE( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
n_hemispheres = numel(obj.parameters.impedance.hemispheres);
color = lines (2);

lbl_subplot = ["Left Hemipshere", "Right Hemisphere"];

switch nargin
    case 3
        ax = varargin{1};
        mode = varargin{2};

        if any(contains({obj.parameters.impedance.hemispheres.label},'Left'))
            if contains(obj.parameters.impedance.hemispheres(1).label,'Left')
                hemisphere_indx = [1, 2];
            else
                hemisphere_indx = [2, 1];
            end
        end
    case 2
        figure;
        for i = 1:n_hemispheres
            ax(i) = subplot(n_hemispheres,1,i);
        end
        mode = varargin{1};
        hemisphere_indx = [1, 2];
        lbl_subplot = [obj.parameters.impedance.hemispheres.label];
end

mode = lower(mode);

for h = 1:n_hemispheres
    switch mode
        case "monopolar"
            e2 = string(obj.parameters.impedance.hemispheres(h).monopolar.electrode2);
            lbl = string(numel(e2));
            for i = 1:numel(e2)
                temp_split = split(e2(i), '_');
                lbl(i) = temp_split(2);
            end

        case "bipolar"
            e1 = string(obj.parameters.impedance.hemispheres(h).bipolar.electrode1);
            e2 = string(obj.parameters.impedance.hemispheres(h).bipolar.electrode2);
            lbl = string(numel(e1));
            for i = 1:numel(e1)
                temp_split_e1 = split(e1(i), '_');
                temp_split_e2 = split(e2(i), '_');
                lbl(i) = temp_split_e1(2) + " & " + temp_split_e2(2);
            end
    end

    bar( ax(hemisphere_indx(h)), obj.parameters.impedance.hemispheres(h).(mode).results, 'FaceColor', color(hemisphere_indx(h),:));
    xlabel(ax(hemisphere_indx(h)), 'Electrodes');
    ylabel(ax(hemisphere_indx(h)), 'Impedance [\Omega]');
    xticks(ax(hemisphere_indx(h)), 1:numel(e2));
    xticklabels(ax(hemisphere_indx(h)), lbl);
    xtickangle(ax(hemisphere_indx(h)), 45);
    title(ax(hemisphere_indx(h)), lbl_subplot(hemisphere_indx(h)));

end

end

