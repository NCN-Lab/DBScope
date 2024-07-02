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

    if isfield(group_data.ProgramSettings, "SensingChannel")
        for hemisphere = 1:length(group_data.ProgramSettings.SensingChannel)
            if iscell(group_data.ProgramSettings.SensingChannel)
                group_obj(group).stimulation.hemispheres(hemisphere).location = ...
                    strrep(group_data.ProgramSettings.SensingChannel{hemisphere}.ProgramId, 'ProgramIdDef.', '');
                group_obj(group).stimulation.hemispheres(hemisphere).pulse_width = ...
                    group_data.ProgramSettings.SensingChannel{hemisphere}.PulseWidthInMicroSecond;
            else
                group_obj(group).stimulation.hemispheres(hemisphere).location = ...
                    strrep(group_data.ProgramSettings.SensingChannel(hemisphere).ProgramId, 'ProgramIdDef.', '');
                group_obj(group).stimulation.hemispheres(hemisphere).pulse_width = ...
                    group_data.ProgramSettings.SensingChannel(hemisphere).PulseWidthInMicroSecond;
            end

            if isfield(group_data.ProgramSettings, "RateInHertz")
                group_obj(group).stimulation.hemispheres(hemisphere).frequency = ...
                    group_data.ProgramSettings.RateInHertz;
            else
                if iscell(group_data.ProgramSettings.SensingChannel)
                    group_obj(group).stimulation.hemispheres(hemisphere).frequency = ...
                        group_data.ProgramSettings.SensingChannel{hemisphere}.RateInHertz;
                else
                    group_obj(group).stimulation.hemispheres(hemisphere).frequency = ...
                        group_data.ProgramSettings.SensingChannel(hemisphere).RateInHertz;
                end
            end

        end
    else
        for hemisphere = 1:length(hemisphere_labels)
            if isfield(group_data.ProgramSettings, hemisphere_labels(hemisphere))
                group_obj(group).stimulation.hemispheres(hemisphere).location = ...
                    strrep(group_data.ProgramSettings.(hemisphere_labels(hemisphere)).Programs.ProgramId, 'ProgramIdDef.', '');
                group_obj(group).stimulation.hemispheres(hemisphere).amplitude = ...
                    group_data.ProgramSettings.(hemisphere_labels(hemisphere)).Programs.AmplitudeInMilliAmps;
                group_obj(group).stimulation.hemispheres(hemisphere).pulse_width = ...
                    group_data.ProgramSettings.(hemisphere_labels(hemisphere)).Programs.PulseWidthInMicroSecond;


                if isfield(group_data.ProgramSettings, "RateInHertz")
                    group_obj(group).stimulation.hemispheres(hemisphere).frequency = ...
                        group_data.ProgramSettings.RateInHertz;
                else
                    group_obj(group).stimulation.hemispheres(hemisphere).frequency = ...
                        group_data.ProgramSettings.(hemisphere_labels(hemisphere)).Programs.RateInHertz;
                end

            else
                group_obj(group).stimulation = [];
            end
        end
    end

    group_obj(group).sensing = struct;
    if isfield(group_data.ProgramSettings, "SensingChannel")
        for hemisphere = 1:length(group_data.ProgramSettings.SensingChannel)
            if iscell(group_data.ProgramSettings.SensingChannel)
                group_obj(group).sensing.hemispheres(hemisphere).location = ...
                    strrep(group_data.ProgramSettings.SensingChannel{hemisphere}.HemisphereLocation, 'HemisphereLocationDef.', '');
                group_obj(group).sensing.hemispheres(hemisphere).channel = ...
                    strrep(group_data.ProgramSettings.SensingChannel{hemisphere}.Channel, 'SensingElectrodeConfigDef.', '');
                group_obj(group).sensing.hemispheres(hemisphere).status = ...
                    strrep(group_data.ProgramSettings.SensingChannel{hemisphere}.BrainSensingStatus, 'SensingStatusDef.', '');
                group_obj(group).sensing.hemispheres(hemisphere).center_frequency = ...
                    group_data.ProgramSettings.SensingChannel{hemisphere}.SensingSetup.FrequencyInHertz;
                group_obj(group).sensing.hemispheres(hemisphere).artifact = ...
                    strrep(group_data.ProgramSettings.SensingChannel{hemisphere}.SensingSetup.ChannelSignalResult.ArtifactStatus, 'ArtifactStatusDef.', '');
            else
                group_obj(group).sensing.hemispheres(hemisphere).location = ...
                    strrep(group_data.ProgramSettings.SensingChannel(hemisphere).HemisphereLocation, 'HemisphereLocationDef.', '');
                group_obj(group).sensing.hemispheres(hemisphere).channel = ...
                    strrep(group_data.ProgramSettings.SensingChannel(hemisphere).Channel, 'SensingElectrodeConfigDef.', '');
                group_obj(group).sensing.hemispheres(hemisphere).status = ...
                    strrep(group_data.ProgramSettings.SensingChannel(hemisphere).BrainSensingStatus, 'SensingStatusDef.', '');
                group_obj(group).sensing.hemispheres(hemisphere).center_frequency = ...
                    group_data.ProgramSettings.SensingChannel(hemisphere).SensingSetup.FrequencyInHertz;
                group_obj(group).sensing.hemispheres(hemisphere).artifact = ...
                    strrep(group_data.ProgramSettings.SensingChannel(hemisphere).SensingSetup.ChannelSignalResult.ArtifactStatus, 'ArtifactStatusDef.', '');
            end
        end
    else
        group_obj(group).sensing = [];
    end
end

end