function syncWearables_manual( obj, obj_file )
% Synchronization wearables signal w/ LFPs recordings
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

sampling_freq_Hz = obj.wearable_parameters.fs;
Nyquist = 0.5 * sampling_freq_Hz;
factor_interpolate = floor(obj_file.streaming_obj.streaming_parameters.time_domain.fs  /obj.wearable_parameters.fs );
artifact_threshold_lfp = 90/100; % in percentage
artifact_threshold_wearable = 90/100; % in percentage

% A discutir: faz primeiro o ajuste automático, e depois o fine tuning
% manual, ou ignora o automático, e faz logo o manual?
if ~isnan(obj.streaming_parameters.time_domain.wearables_sync{1}) % if there is a run, is indiferent which recording we see, all were processed?

    % proceed with the visual adjustement
    % plot each signal, and get index directly from axis?
        % PROBLEM: we have diferent acelerometer data (1 at per sensor), we
        % plot all five in the same subplot, ajust all plots, and get the
        % index from there?
        % Diferent indexes !!

    % test code - to discuss  / validate
    for d = 1:length(obj.wearable_parameters.data)
        r_1 = length(obj.wearable_parameters.data(d).sensor);

        figure
        for d = 1:length(obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.data)
            data_lfp = obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.data{d};
            time_lfp = obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.time(d);
            if length(data_lfp(1,:) == 2
                r_2 = 2
                r_3 = r_1 + r_2;
                subplot(1,1,r_3)
                plot(data_lfp(:,1),time_lfp)
                title('LFP Left hemisphere')
                subplot(2,1,r_3)
                plot(data_lfp(:,2),time_lfp)
                title('LFP Right hemisphere')
            elseif length(data_lfp(1,:) == 1
                r_2 = r_1 + r_2;
                subplot(1,1,r_3)
                plot(data_lfp(:,1),time_lfp)
                title('LFP Available hemisphere')
            end
        end

        for s = 1:numel(obj.wearable_parameters.data(d).sensor)
            suplot(s+r_2,1,r_3)
            plot(obj.wearable_parameters.data(d).sensor(s).at)
        end

        %Now, align figure and get axis, assuming new axis:
        output_axis = (); % use this as output variable from the UI figure

        if length(output_axis)-r_2 == 2
            for d = 1:length(obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.data)
                data_lfp = obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.data{d};
                time_lfp = obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.time(d);
                sync_data_lfp_l = data_lfp_left(output(axis(1):end);
                sync_data_lfp_r = data_lfp_right(output(axis(2):end);
                obj.streaming_parameters.time_domain.wearables_sync{d} = { sync_data_lfp_l, sync_data_lfp_r };
            end
            for s = 1:numel(obj.wearable_parameters.data(d).sensor)
                data_wearable = obj.wearable_parameters.data(d).sensor(s).at;
                sync_data_wearable = data_wearable(output_axis(s+2):end);
                obj.wearable_parameters.data(d).sensor(s).at_sync = sync_data_wearable;
                interpolate_data_wearable  = interp(sync_data_wearable, factor_interpolate);
                obj.wearable_parameters.data(d).sensor(s).at_sync = interpolate_data_wearable;
            end
        elseif length(output_axis)-r_2 == 1
            data_lfp = obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.data{d};
            time_lfp = obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.time(d);
            sync_data_lfp_l = data_lfp_left(output(axis(1):end);
            obj.streaming_parameters.time_domain.wearables_sync{d} = { sync_data_lfp_l };
            for s = 1:numel(obj.wearable_parameters.data(d).sensor)
                data_wearable = obj.wearable_parameters.data(d).sensor(s).at;
                sync_data_wearable = data_wearable(output_axis(s+1):end);
                obj.wearable_parameters.data(d).sensor(s).at_sync = sync_data_wearable;
                interpolate_data_wearable  = interp(sync_data_wearable, factor_interpolate);
                obj.wearable_parameters.data(d).sensor(s).at_sync = interpolate_data_wearable;
            end
        end

    end

else
    answer = questdlg('Do you want to run an automatic pre-synchronization?', ...
        '', ...
        'Yes','No','No');
    switch answer
        case 'Yes'
            data_type = 'Raw';

            for d = 1:length(obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.data)

                data_lfp = obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.data{d};
                time_lfp = obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.time(d);

                if length(data_lfp(1,:) == 2

                    data_lfp_left = obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.data{d}(:,1);
                    data_lef_right = obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.data{d}(:,2);

                    [pks_wear_l,locs_wear_l] = findpeaks(data_lfp_left,'Threshold', artifact_threshold_lfp); % confirm threshold
                    [pks_wear_r,locs_wear_r] = findpeaks(data_lfp_right,'Threshold', artifact_threshold_lfp); % confirm threshold

                    sync_data_lfp_l = data_lfp_left(locs_wear_l(1):end);
                    sync_data_lfp_r = data_lfp_right(locs_wear_r(1):end);

                    wearables_sync = { sync_data_lfp_l, sync_data_lfp_r };

                elseif length(data_lfp(1,:) == 1

                    data_lfp_left = obj.ncnpercept_patient{1}.streaming_obj.streaming_parameters.time_domain.data{d}(:,1);
                    [pks_wear_l,locs_wear_l] = findpeaks(data_lfp_left,'Threshold', artifact_threshold_lfp); % confirm threshold
                    sync_data_lfp_l = data_lfp_left(locs_wear_l(1):end);
                    wearables_sync = { sync_data_lfp_l, sync_data_lfp_r };

                end

                obj.streaming_parameters.time_domain.wearables_sync{d} = wearables_sync;

            end

            for d = 1:length(obj.wearable_parameters.data)

                for s = 1:numel(obj.wearable_parameters.data(d).sensor)

                    data_wearable = obj.wearable_parameters.data(d).sensor(s).at;
                    [pks_wear,locs_wear] = findpeaks(data_wearable,'Threshold', artifact_threshold_wearable); % 1g different is enough?

                    sync_data_wearable = data_wearable(locs_wear(1):end);
                    obj.wearable_parameters.data(d).sensor(s).at_sync = sync_data_wearable;

                    interpolate_data_wearable  = interp(sync_data_wearable, factor_interpolate);
                    obj.wearable_parameters.data(d).sensor(s).at_sync = interpolate_data_wearable;

                end
            end

            % complete with the visual adjustement

        case 'No'

            % complete with the visual adjustement
    end

end
