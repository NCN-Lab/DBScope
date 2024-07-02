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
obj.parameters.group_history = struct;
for session = 1:numel(data.GroupHistory)
    obj.parameters.group_history(session).session_date  = datetime(data.GroupHistory(session).SessionDate, "InputFormat", 'yyyy-MM-dd''T''HH:mm:ss''Z''');
    obj.parameters.group_history(session).groups        = obj.extractGroupsInformation(data.GroupHistory(session).Groups);
    obj.parameters.group_history(session).changes       = struct;
end
if isfield(data.DiagnosticData, 'EventLogs')
    for event = 1:numel(data.DiagnosticData.EventLogs)
        if isfield(data.DiagnosticData.EventLogs{event}, 'NewGroupId')
            event_datetime = datetime(data.DiagnosticData.EventLogs{event}.DateTime, "InputFormat", 'yyyy-MM-dd''T''HH:mm:ss''Z''');
            indx = find(event_datetime < [obj.parameters.group_history.session_date], 1, "last");
            obj.parameters.group_history(indx).changes(end+1).datetime = datetime(data.DiagnosticData.EventLogs{event}.DateTime, "InputFormat", 'yyyy-MM-dd''T''HH:mm:ss''Z''');
            obj.parameters.group_history(indx).changes(end).old = strrep(data.DiagnosticData.EventLogs{event}.OldGroupId, 'GroupIdDef.GROUP_', '');
            obj.parameters.group_history(indx).changes(end).new = strrep(data.DiagnosticData.EventLogs{event}.NewGroupId, 'GroupIdDef.GROUP_', '');
        end
    end
end

% Session Groups
moments = ["Initial", "Final"];
for m = moments
    obj.parameters.groups.(lower(m)) = obj.extractGroupsInformation(data.Groups.(m));
end

status = 1;

end
