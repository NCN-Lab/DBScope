classdef WEARABLE_EXTERNAL < RECORDINGMODE_COMMONMETHODS
    % Object with properties and methods to analyse external wearable data
    %
    % Available at: https://github.com/NCN-Lab/DBScope
    % For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
    % a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.
    %
    % Eduardo Carvalho, Andreia M. Oliveira & Paulo Aguiar - NCN
    % INEB/i3S 2023
    % pauloaguiar@i3s.up.pt
    % -----------------------------------------------------------------------

    properties ( SetAccess = private )
        data
    end

    methods

        function obj = WEARABLE_EXTERNAL() % constructor
            disp('Initialization of WERABLE_EXTERNAL class');

        end
        loadWearables( obj, path, filenames );
        plotWearable( obj, varargin );

    end

    methods ( Hidden )
    end

end