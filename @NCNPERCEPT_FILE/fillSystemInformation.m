function status = fillSystemInformation( obj, data )
% Fill system information
%
% Syntax:
%   status = FILLSYSTEMINFORMATION( obj, data );
%
% Input parameters:
%    * data - data from json file(s)
%
%
% Example:
%   status = FILLSYSTEMINFORMATION( obj, data );
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope:
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: 10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------

obj.parameters.system_information.battery_percentage                            = data.BatteryInformation.BatteryPercentage;
obj.parameters.system_information.battery_status                                = data.BatteryInformation.BatteryStatus;
obj.parameters.system_information.neurostimulator                               = data.DeviceInformation.Initial.Neurostimulator;
obj.parameters.system_information.model                                         = data.DeviceInformation.Initial.NeurostimulatorModel;
obj.parameters.system_information.location                                      = data.DeviceInformation.Initial.NeurostimulatorLocation;
obj.parameters.system_information.device_date                                   = data.DeviceInformation.Initial.DeviceDateTime;
obj.parameters.system_information.implantation_date                             = data.DeviceInformation.Initial.ImplantDate;
obj.parameters.system_information.accumulated_therapy_on_time_since_implant     = data.DeviceInformation.Initial.AccumulatedTherapyOnTimeSinceImplant;
obj.parameters.system_information.accumulated_therapy_on_time_since_followup    = data.DeviceInformation.Initial.AccumulatedTherapyOnTimeSinceFollowup;
obj.parameters.system_information.lead_location_left_hemisphere                 = data.LeadConfiguration.Initial(1).LeadLocation;
obj.parameters.system_information.lead_location_right_hemisphere                = data.LeadConfiguration.Initial(2).LeadLocation;
obj.parameters.system_information.lead_electrode_number_left_hemisphere         = data.LeadConfiguration.Initial(1).ElectrodeNumber;
obj.parameters.system_information.lead_electrode_number_right_hemisphere        = data.LeadConfiguration.Initial(2).ElectrodeNumber;
obj.parameters.system_information.clinical_notes                                = data.PatientInformation.Initial.ClinicianNotes;
obj.parameters.system_information.diagnosis                                     = data.PatientInformation.Initial.Diagnosis;
obj.parameters.system_information.start_of_session                              = strrep(data.SessionDate(1:end-1),'T',' ');
obj.parameters.system_information.end_of_session                                = strrep(data.SessionEndDate(1:end-1),'T',' ');
obj.parameters.system_information.initial_stimulation_status                    = data.Stimulation.InitialStimStatus;
obj.parameters.system_information.final_stimulation_status                      = data.Stimulation.FinalStimStatus;
obj.parameters.system_information.medication_state                              = nan; % Clinician can add here information

status = 1;

end