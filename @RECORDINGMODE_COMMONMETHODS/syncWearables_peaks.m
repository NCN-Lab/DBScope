function wearable_sync = syncWearables_peaks( obj, wearable_obj, streaming_obj )
% Automatic synchronization wearables signal w/ LFPs recordings - via peak
% detection
%
%   Syntax:
%       syncWearables( obj )
%
%   Input parameters:
%       obj
%
%   Example:
%       syncWearables( );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia Oliveira, Eduardo Carvalho & Paulo Aguiar - NCN INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

%PROBLEM: IN THIS METHOD, ALL SEQUENCES WILL HAVE DIFFERENT SIZES?


sampling_freq_Hz = wearable_obj.wearable_parameters.fs;
Nyquist = 0.5 * sampling_freq_Hz;
factor_interpolate = floor(streaming_obj.streaming_parameters.time_domain.fs  / ...
    wearable_obj.wearable_parameters.fs );
artifact_threshold = 90/100; % in percentage
artifact_threshold_wearable = 50/100; % in percentage

for d = 1:length(streaming_obj.streaming_parameters.time_domain.data)

    data_lfp = streaming_obj.streaming_parameters.time_domain.data{d};
    time_lfp = streaming_obj.streaming_parameters.time_domain.time(d);

    if length(data_lfp(1,:)) == 2

        data_lfp_left = streaming_obj.streaming_parameters.time_domain.data{d}(:,1);
        data_lfp_right = streaming_obj.streaming_parameters.time_domain.data{d}(:,2);

        [pks_wear_l,locs_wear_l] = findpeaks(data_lfp_left,'Threshold', artifact_threshold); % confirm threshold
        [pks_wear_r,locs_wear_r] = findpeaks(data_lfp_right,'Threshold', artifact_threshold); % confirm threshold

        sync_data_lfp_l = data_lfp_left(locs_wear_l(1):end);
        sync_data_lfp_r = data_lfp_right(locs_wear_r(1):end);

        wearables_sync = { sync_data_lfp_l, sync_data_lfp_r };

    elseif length(data_lfp(1,:)) == 1

        data_lfp_left = streaming_obj.streaming_parameters.time_domain.data{d}(:,1);
        [pks_wear_l,locs_wear_l] = findpeaks(data_lfp_left,'Threshold', artifact_threshold); % confirm threshold
        sync_data_lfp_l = data_lfp_left(locs_wear_l(1):end);
        wearables_sync = { sync_data_lfp_l, sync_data_lfp_r };

    end

%     obj_file.streaming_obj.streaming_parameters.time_domain.wearables_sync(d) = wearables_sync;

end

for d = 1:length(wearable_obj.wearable_parameters.data)

%     for s = 1:numel(wearable_obj.wearable_parameters.data(d).sensor)
    for s = 1:2

        data_wearable = sqrt(wearable_obj.wearable_parameters.data(d).sensor(s).ax.^2 + ...
            wearable_obj.wearable_parameters.data(d).sensor(s).ay.^2 + ...
            wearable_obj.wearable_parameters.data(d).sensor(s).az.^2);
        % Search max peak in first 20 seconds
        [pks_wear,locs_wear] = findpeaks(data_wearable,'Threshold', artifact_threshold_wearable); % 1g different is enough?
        
        figure;
        sgtitle("Rec" + d + " / Sensor " + s);
        subplot(2,1,1);
        plot((1:length(data_wearable))./wearable_obj.wearable_parameters.fs, data_wearable);
        title("Raw Recording");
        if ~isempty(locs_wear)
            sync_data_wearable = data_wearable(locs_wear(1):length(data_wearable));
            %         obj.wearable_parameters.data(d).sensor(s).at_sync = sync_data_wearable;

            interpolate_data_wearable  = interp(sync_data_wearable, factor_interpolate);
            wearable_sync.data(d).sensor(s).at_sync = interpolate_data_wearable;

            subplot(2,1,2)
            plot((1:length(interpolate_data_wearable))./(wearable_obj.wearable_parameters.fs*factor_interpolate), interpolate_data_wearable);
            title("Sync Recording");
        else
            wearable_sync.data(d).sensor(s).at_sync = {};
        end

    end
end


