function status = fillGroupsInformation( obj, data )
% Fill groups information
%
% Syntax:
%   status = FILLGROUPSINFORMATION( obj, data );
%
% Input parameters:
%    * data - data from json file(s)
%
%
% Example:
%   status = FILLGROUPSINFORMATION( obj, data );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

% Group History
obj.parameters.group_history = [];
if isfield(data, 'GroupHistory')
    GroupHistory = table;
    for session = 1:numel(data.GroupHistory)
        datafield           = struct2table(data.GroupHistory(session), 'AsArray', true);
        GroupHistory        = [GroupHistory; datafield]; %#ok<*AGROW>
    end
    GroupHistory = sortrows(GroupHistory, 1);
    GroupHistory.SessionDate = cellfun(@(x) datetime(regexprep(x(1:end-1),'T',' ')), GroupHistory.SessionDate);
    
    % Define the default values for missing fields
    defaultGroupValues = {
        {[]}, ...               % Default for GroupId
        false, ...              % Default for ActiveGroup
        struct(), ...           % Default for ProgramSettings
        struct()                % Default for GroupSettings
    };
    for session = 1:numel(data.GroupHistory)
        GroupsInfo      = table;
        expectedFields  = {'GroupId','ActiveGroup','ProgramSettings','GroupSettings'};
    
        for group = 1:numel(data.GroupHistory(session).Groups)
            if iscell(data.GroupHistory(session).Groups) % depending on software version
                thisGroup = struct2table(data.GroupHistory(session).Groups{group}, 'AsArray', true);
            else
                thisGroup = struct2table(data.GroupHistory(session).Groups(group), 'AsArray', true);
            end
    
            % For each expected field, check if it's missing in group, and add the default if necessary
            for fieldIdx = 1:numel(expectedFields)
                fieldName = expectedFields{fieldIdx};
                if ~ismember(fieldName, thisGroup.Properties.VariableNames)
                    thisGroup.(fieldName) = defaultGroupValues{fieldIdx};
                end
            end
    
            thisGroup.GroupId           = strrep(thisGroup.GroupId, 'GroupIdDef.', '');
            thisGroup.ProgramSettings   = {thisGroup.ProgramSettings};
            thisGroup.GroupSettings     = {thisGroup.GroupSettings};
    
            GroupsInfo = [GroupsInfo; thisGroup]; %#ok<*AGROW>
    
        end    
        GroupHistory.Groups{session} = GroupsInfo;
    end
    
    obj.parameters.group_history = GroupHistory;
end

% Session Groups
moments = ["Initial", "Final"];
for m = moments
    obj.parameters.groups.(lower(m)) = obj.extractGroupsInformation(data.Groups.(m));
end

status = 1;

end
