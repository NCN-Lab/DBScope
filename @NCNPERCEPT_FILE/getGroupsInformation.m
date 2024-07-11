function [ text ] = getGroupsInformation( obj )
% Display information about Groups.
%
% Syntax:
%   GETGROUPSINFORMATION( obj );
%
% Input parameters:
%   * data - data from json file(s)
%
% Example:
%   GETGROUPSINFORMATION( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

text = "";

if numel(obj.parameters.groups.final) > numel(obj.parameters.groups.initial)
    group_ids = {obj.parameters.groups.final(:).group_id};
else
    group_ids = {obj.parameters.groups.initial(:).group_id};
end

channels    = repmat("", 2, 2, numel(group_ids));
amps        = NaN * zeros(2, 2, numel(group_ids));
frqs        = NaN * zeros(2, 2, numel(group_ids));
cfs         = NaN * zeros(2, 2, numel(group_ids));
pws         = NaN * zeros(2, 2, numel(group_ids));
moments = ["initial", "final"];
for i = 1:numel(moments)
    for g = 1:numel(obj.parameters.groups.(moments(i)))
        for h = 1:numel(obj.parameters.groups.(moments(i))(g).stimulation.hemispheres)
            
            if contains(lower(obj.parameters.groups.(moments(i))(g).stimulation.hemispheres(h).location), "left")
                if isfield(obj.parameters.groups.(moments(i))(g).stimulation.hemispheres(h), 'amplitude')
                    amps(1,i,g) = obj.parameters.groups.(moments(i))(g).stimulation.hemispheres(h).amplitude;
                end
                frqs(1,i,g) = obj.parameters.groups.(moments(i))(g).stimulation.hemispheres(h).frequency;
                pws(1,i,g)  = obj.parameters.groups.(moments(i))(g).stimulation.hemispheres(h).pulse_width;
            else
                if isfield(obj.parameters.groups.(moments(i))(g).stimulation.hemispheres(h), 'amplitude')
                    amps(2,i,g) = obj.parameters.groups.(moments(i))(g).stimulation.hemispheres(h).amplitude;
                end
                frqs(2,i,g) = obj.parameters.groups.(moments(i))(g).stimulation.hemispheres(h).frequency;
                pws(2,i,g)  = obj.parameters.groups.(moments(i))(g).stimulation.hemispheres(h).pulse_width;
            end

            if ~isempty(obj.parameters.groups.(moments(i))(g).sensing)
                if contains(lower(obj.parameters.groups.(moments(i))(g).stimulation.hemispheres(h).location), "left")
                    channels(1,i,g) = obj.parameters.groups.(moments(i))(g).sensing.hemispheres(h).channel;
                    cfs(1,i,g) = obj.parameters.groups.(moments(i))(g).sensing.hemispheres(h).center_frequency;
                else
                    channels(2,i,g) = obj.parameters.groups.(moments(i))(g).sensing.hemispheres(h).channel;
                    cfs(2,i,g) = obj.parameters.groups.(moments(i))(g).sensing.hemispheres(h).center_frequency;
                end
            end

        end
    end
end

hemispheres = ["Left", "Right"];
for g = 1:max(numel(obj.parameters.groups.initial), numel(obj.parameters.groups.final))
    text = text + sprintf('\nGroup %s\n=============================\n', group_ids{g});

    for h = 1:2
        text = text + sprintf(['\n%s Hemisphere:\n\tFrequency (Hz): %d => %d ...' ...
            '\n\tAmplitude (mA): %.1f => %.1f\n\tPulse Width (μs): %d => %d ...' ...
            '\n\tBrainSense Contacts: %s => %s\n\tBrainSense Peak (Hz): %.1f => %.1f\n'], ...
            hemispheres(h), ...
            frqs(h,:,g), ...
            amps(h,:,g), ...
            pws(h,:,g), ...
            channels(h,:,g), ...
            cfs(h,:,g));
    end
end


end

