classdef NCNPERCEPT_BATCH < handle
    % Object with properties and methods to analyse PerceptPC json file at
    % NCN lab - BATCH
    %
    % Available at: https://github.com/NCN-Lab/DBScope
    % For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
    % a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: https://doi.org/10.1101/2023.07.23.23292136.
    %
    % Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
    % INEB/i3S 2022
    % pauloaguiar@i3s.up.pt
    % -----------------------------------------------------------------------

    % Add folders to path!

    properties ( SetAccess = private )
        ncnpercept_patient
        patient_list = {};
    end

    properties ( SetAccess = public )

    end

    methods
        function obj = NCNPERCEPT_BATCH() % constructor
            disp('Initialization of NCNPERCEPT_BATCH files');
            
        end

        % Run loadFile
        [ loading_mode ] = aux_open_batch( obj )
        [ status, text ] = open_batch_files( obj );
        [ status, text ] = open_batch_folder( obj );
        [ status, text, obj ] = open_mat_files( obj );

        saveWorkspace_single( obj )

        % Anonymized data 
        anonymizedata( obj )

    end

end