function group_obj = extractGroupsInformation( obj, data )
% Extract groups information from one session
%
% Syntax:
%   group_obj = EXTRACTGROUPSINFORMATION( obj, data );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%
%
% Example:
%   group_obj = EXTRACTGROUPSINFORMATION( obj, data );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

hemisphere_labels = ["LeftHemisphere", "RightHemisphere"];
group_obj = struct;

for group = 1:length(data)
    if isstruct(data)   % Groups
        group_data = data(group);
    else                % GroupHistory
        group_data = data{group};
    end
    
    % Check if group exists
    if ~isfield(group_data, 'ActiveGroup')
        continue;
    end
    
    group_obj(group).group_id     = strrep(group_data.GroupId, 'GroupIdDef.GROUP_', '');
    
    if isfield(group_data, 'GroupName')
        group_obj(group).group_label  = group_data.GroupName;
    end
    group_obj(group).active       = group_data.ActiveGroup;
    group_obj(group).stimulation  = struct;
    
    % =========================================================================
    % 1. STIMULATION PARAMETERS PARSING
    % =========================================================================
    if isfield(group_data.ProgramSettings, "SensingChannel")
        for hemisphere = 1:length(group_data.ProgramSettings.SensingChannel)
            if iscell(group_data.ProgramSettings.SensingChannel)
                sens_chan = group_data.ProgramSettings.SensingChannel{hemisphere};
            else
                sens_chan = group_data.ProgramSettings.SensingChannel(hemisphere);
            end
            
            group_obj(group).stimulation.hemispheres(hemisphere).location = ...
                strrep(sens_chan.ProgramId, 'ProgramIdDef.', '');
                
            if isfield(sens_chan, 'PulseWidthInMicroSecond')
                group_obj(group).stimulation.hemispheres(hemisphere).pulse_width = ...
                    sens_chan.PulseWidthInMicroSecond;
            end
            
            % CLINICAL UPDATE: Safely map actual AmplitudeInMilliAmps or Adaptive SuspendAmplitude
            if isfield(sens_chan, 'AmplitudeInMilliAmps')
                group_obj(group).stimulation.hemispheres(hemisphere).amplitude = ...
                    sens_chan.AmplitudeInMilliAmps;
            elseif isfield(sens_chan, 'SuspendAmplitudeInMilliAmps')
                group_obj(group).stimulation.hemispheres(hemisphere).amplitude = ...
                    sens_chan.SuspendAmplitudeInMilliAmps;
            end
            
            if isfield(group_data.ProgramSettings, "RateInHertz")
                group_obj(group).stimulation.hemispheres(hemisphere).frequency = ...
                    group_data.ProgramSettings.RateInHertz;
            elseif isfield(sens_chan, 'RateInHertz')
                group_obj(group).stimulation.hemispheres(hemisphere).frequency = ...
                    sens_chan.RateInHertz;
            end
        end
    else
        hemi_idx = 1;
        for hemisphere = 1:length(hemisphere_labels)
            hemi_lbl = hemisphere_labels(hemisphere);
            if isfield(group_data.ProgramSettings, hemi_lbl)
                
                hemi_data = group_data.ProgramSettings.(hemi_lbl);
                
                % SAFELY PARSE 'Programs' ARRAY (Prevents array indexing crashes)
                if isfield(hemi_data, 'Programs') && ~isempty(hemi_data.Programs)
                    if iscell(hemi_data.Programs)
                        active_prog = hemi_data.Programs{1};
                    else
                        active_prog = hemi_data.Programs(1);
                    end
                    
                    group_obj(group).stimulation.hemispheres(hemi_idx).location = ...
                        strrep(active_prog.ProgramId, 'ProgramIdDef.', '');
                        
                    % CLINICAL UPDATE: Properly map Amplitude from the resolved struct or Adaptive fallback
                    if isfield(active_prog, 'AmplitudeInMilliAmps')
                        group_obj(group).stimulation.hemispheres(hemi_idx).amplitude = ...
                            active_prog.AmplitudeInMilliAmps;
                    elseif isfield(active_prog, 'SuspendAmplitudeInMilliAmps')
                        group_obj(group).stimulation.hemispheres(hemi_idx).amplitude = ...
                            active_prog.SuspendAmplitudeInMilliAmps;
                    end
                    
                    if isfield(active_prog, 'PulseWidthInMicroSecond')
                        group_obj(group).stimulation.hemispheres(hemi_idx).pulse_width = ...
                            active_prog.PulseWidthInMicroSecond;
                    end
                    
                    if isfield(group_data.ProgramSettings, "RateInHertz")
                        group_obj(group).stimulation.hemispheres(hemi_idx).frequency = ...
                            group_data.ProgramSettings.RateInHertz;
                    elseif isfield(active_prog, 'RateInHertz')
                        group_obj(group).stimulation.hemispheres(hemi_idx).frequency = ...
                            active_prog.RateInHertz;
                    end
                    
                    hemi_idx = hemi_idx + 1;
                end
            end
        end
        % Ensure the struct is initialized even if empty to prevent crashes later
        if ~isfield(group_obj(group).stimulation, 'hemispheres')
            group_obj(group).stimulation = [];
        end
    end
    
    % =========================================================================
    % 2. SENSING PARAMETERS PARSING
    % =========================================================================
    group_obj(group).sensing = struct;
    if isfield(group_data.ProgramSettings, "SensingChannel")
        for hemisphere = 1:length(group_data.ProgramSettings.SensingChannel)
            if iscell(group_data.ProgramSettings.SensingChannel)
                sc = group_data.ProgramSettings.SensingChannel{hemisphere};
            else
                sc = group_data.ProgramSettings.SensingChannel(hemisphere);
            end
            
            group_obj(group).sensing.hemispheres(hemisphere).location = ...
                strrep(sc.HemisphereLocation, 'HemisphereLocationDef.', '');
            group_obj(group).sensing.hemispheres(hemisphere).channel = ...
                strrep(sc.Channel, 'SensingElectrodeConfigDef.', '');
            group_obj(group).sensing.hemispheres(hemisphere).status = ...
                strrep(sc.BrainSensingStatus, 'SensingStatusDef.', '');
            
            if isfield(sc, 'SensingSetup') && isfield(sc.SensingSetup, 'FrequencyInHertz')
                group_obj(group).sensing.hemispheres(hemisphere).center_frequency = ...
                    sc.SensingSetup.FrequencyInHertz;
            end
            
            if isfield(sc, 'SensingSetup') && isfield(sc.SensingSetup, 'ChannelSignalResult') && ...
               isfield(sc.SensingSetup.ChannelSignalResult, 'ArtifactStatus')
                group_obj(group).sensing.hemispheres(hemisphere).artifact = ...
                    strrep(sc.SensingSetup.ChannelSignalResult.ArtifactStatus, 'ArtifactStatusDef.', '');
            end
        end
    else
        group_obj(group).sensing = [];
    end
end
end