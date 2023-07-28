function [ LFP_filtdata ] = applyFilt_ordered( obj, LFP_ordered, fs, filterType, order, varargin )
% APPLYFILT_ORDERED This function returns the filtered data given the parameters that define
% the desired filter.
%
% Use with streaming recordings of LFPs;
% Sampling Frequency for Streaming = 250Hz.
%
% Depending on the type of the filter, one or two cut-off frequency values
% must be specified, when calling this function.
% For low pass and high pass filters, a single cut-off frequency value is
% needed. For bandpass and stop band filters, two cut-off frequency values
% - lower and upper cut-off frequency -  must be specified.
% The cut-off frequencies are expressed in Hz.
%
% Syntax:
%   [ LFP_filtdata ] = APPLYFILT_ORDERED( obj, LFP_ordered, fs, filterType,
%   order, varargin );
%
% Inputs:
%       * obj - object containg  data
%       * fs - sampling frequency, in Hz
%       * filterType - type of the filter; the user can choose between low pass,
%       * high pass, bandpass or stop band filters
%       * varargin - variable-length input
%
% Outputs:
%        LFP_filtdata - filtered signal
%
% Examples:
% obj.survey_obj.applyFilt_ordered(fs,'Low pass', upb)
% obj.survey_obj.applyFilt_ordered(fs,' High pass', louwb)
% obj.survey_obj.applyFilt_ordered(fs,'Bandpass', louwb, upb)
% obj.survey_obj.applyFilt_ordered(fs,'Stop band', louwb, upb)
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: https://doi.org/10.1101/2023.07.23.23292136.
%
% Beatriz Barros, Andreia M. Oliveira, Eduardo Carvalho & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
% -----------------------------------------------------------------------
LFP_filtdata = NaN;

if iscell(LFP_ordered)
    LFP_filtdata = cell(1, numel(LFP_ordered));

    for c = 1:numel(LFP_ordered)
        %order = 4;
        nyquist_frequency = fs/2;
        % Apply filter; BUTTER
         switch filterType
            case 'Low pass'
                fc_normalized = varargin{1}/nyquist_frequency;
                [b, a] = butter(order, fc_normalized, 'low');
            case 'High pass'
                fc_normalized = varargin{1}/nyquist_frequency;
                [b, a] = butter(order, fc_normalized, 'high');
            case 'Bandpass'
                low_bound = varargin{1}{1};
                low_normalized =  low_bound/nyquist_frequency;
                up_bound = varargin{1}{2};
                up_normalized =  up_bound/nyquist_frequency;
                [b, a] = butter(order, [low_normalized up_normalized], 'bandpass');
            case 'Stop band'
                low_bound = varargin{1}{1};
                low_normalized =  low_bound/nyquist_frequency;
                up_bound = varargin{1}{2};
                up_normalized =  up_bound/nyquist_frequency;
                [b, a] = butter(order, [low_normalized up_normalized], 'stop');
            otherwise
        end

        % Save data
        LFP_filtdata{c} = filtfilt(b, a, LFP_ordered{c}); % zero-phase digital filtering

    end
end

end