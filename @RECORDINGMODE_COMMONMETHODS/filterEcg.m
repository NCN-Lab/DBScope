function [ LFP_ECGdata, text ]   = filterEcg( obj, data, fs )
% FILTERECG Filter ECG artifacts from LFP recordings - streaming
%
% Syntax:
%   [ LFP_ECGdata ]   = FILTERECG( obj, data, fs );
%
% Input parameters:
%    * obj - object containg data
%    * data - data from json file(s)
%    * fs - sampling frequency
%
% Example:
%   [ LFP_ECGdata ] = FILTERECG( data, fs );
%
% Adapted from Wolf-Julian Neumann 22.11.2021 - ICN Charité Berlin, Germany
% https://github.com/neuromodulation/perceive
%
% Available at: https://github.com/NCN-Lab/DBScope
% For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: 
% a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, doi: https://doi.org/10.1101/2023.07.23.23292136.
%
% Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros & Paulo Aguiar - NCN
% INEB/i3S 2022
% pauloaguiar@i3s.up.pt
%% -----------------------------------------------------------------------

%% Defaults
if ~exist('fs','var') %fs = 250;end
    fs = obj.fs;
end
ns = length(data);

%% First pass using cross-correlation
dwindow=round(fs); % segment window size (500 ms)
dmove = fs; % moving window size (100 ms)
i=[1+dwindow:dmove:ns-dwindow-1]';
if ~isempty(i)
    for a = 1:length(i)
        x(a,:) = data([i(a)-dwindow:i(a)+dwindow]); % epoch data
    end
    disp(['...running cross-correlation on ' num2str(a) ' segments...'])

    ndata = zeros(1,4*dwindow); % template for adjust to xcorr lags (4*segment window size)
    nt=linspace(-2*dwindow/fs,size(ndata,2)/fs-2*dwindow/fs,size(ndata,2)); % time axis
    ndata(1,obj.aux_perceive_sc(nt,0):obj.aux_perceive_sc(nt,0)+size(x,2)-1)=x(1,:); % initialize with first segment 
    n=0; % run through remaining segments and find xcorr lags, align data
    for a = 2:size(x,1)
        [r,l]=xcorr(nanmean(ndata,1),x(a,:),fs);
        [~,mi] = max(r);
        tlag = l(mi);
        if tlag >0
            n=n+1;
            ndata(n,tlag:tlag+size(x,2)-1)=x(a,:);
        end
    end
    mdata = nanmean(ndata,1); % average aligned data

    %% find ECG peak characteristics in xcorr aligned data
    [absm,imax]=findpeaks(abs(mdata),'SortStr','descend','NPeaks',15);
    np=0.05;
    iim=[];
    iin=[];
    while isempty(iim) || isempty(iin)
        np=np+.025;
        pkrange=imax(1)-round(fs*np):imax(1)+round(fs*np);
        [~,iim,wm]=findpeaks(mdata(pkrange),'SortStr','descend','NPeaks',1);
        [~,iin,wn]=findpeaks(-mdata(pkrange),'SortStr','descend','NPeaks',1);
    end
    iim=iim+pkrange(1)-1;
    iin=iin+pkrange(1)-1;
    pdif=absm(1)./nansum(absm(2:end))*100;
    if iin(1)<iim(1)
        ii1 = iin(1);ii2 = iim(1);w1=wn(1);w2 = wm(1);
    else
        ii1=iim(1);ii2=iin(1);w1=wm(1);w2=wn(1);
    end
    ecg_cut=ii1-round(w1(1)):ii2+round(w2(1));
    ecg.proc.template1 = mdata(ecg_cut); % first template
    disp('...ecg template 1 generated...')

    %% Run temporal correlation across samples
    corrdata=[];
    for a = 1:ns-size(ecg_cut,2)-1
        corrdata(:,a) = data(1,a:a+size(ecg_cut,2)-1)';
    end
    r = corr(corrdata,ecg.proc.template1').^2;
    ecg.proc.r = r;
    disp('...first temporal correlation done...')

    %% adjust r threshold to maximize HR associated peak identification
    h=[max(findpeaks(r))*.95,...
        max(findpeaks(r))*.90,...
        max(findpeaks(r))*.85,...
        max(findpeaks(r))*.80,...
        max(findpeaks(r))*.75,...
        max(findpeaks(r))*.70,...
        max(findpeaks(r))*.65,...
        max(findpeaks(r))*.60,...
        max(findpeaks(r))*.55,...
        max(findpeaks(r))*.50];
    thr=[];
    for a=1:length(h)
        [~,ix]=findpeaks(r,'MinPeakHeight',h(a),'MaxPeakWidth',round(0.1*fs));
        if ~isempty(ix);dd=60./(diff(ix)/fs);thr(a)=nansum(dd>55&dd<120)./std(dd);end
    end
    [~,ithr]=max(thr);ecg.proc.thresh=h(ithr);
    disp('...first threshold adjusted...')

    %% find peaks from temporal correlations
    [~,i]=findpeaks(r,'MinPeakHeight',ecg.proc.thresh,'MinPeakDistance',round(fs/2));

    %% start over using the found peaks by aligning to the found peaks
    for a = 1:length(i)
        try ndata2(a,:)= data(i(a)-round(.05*fs):i(a)+round(.1*fs));end
    end
    ecg.proc.template2 = nanmean(ndata2,1);
    disp('...realigned and generated template 2...')

    %% run temporal correlation on second template
    corrdata=[];
    for a = 1:ns-size(ecg.proc.template2,2)-1
        corrdata(:,a) = data(1,a:a+size(ecg.proc.template2,2)-1)';
    end
    r2 = corr(corrdata,ecg.proc.template2').^2;
    ecg.proc.r2 = r2;
    disp('...temporal correlation on second template done...')

    %% readjust threshold
    h=[max(findpeaks(r2))*.95,...
        max(findpeaks(r2))*.90,...
        max(findpeaks(r2))*.85,...
        max(findpeaks(r2))*.80,...
        max(findpeaks(r2))*.75,...
        max(findpeaks(r2))*.70,...
        max(findpeaks(r2))*.65,...
        max(findpeaks(r2))*.60,...
        max(findpeaks(r2))*.55,...
        max(findpeaks(r2))*.50];
    for a=1:length(h)
        [~,ix]=findpeaks(r2,'MinPeakHeight',h(a),'MaxPeakWidth',round(0.1*fs));
        if ~isempty(ix),dd=60./(diff(ix)/fs);thr2(a)=nansum(dd>55&dd<120)./std(dd);end
    end
    [~,ithr2]=max(thr2);ecg.proc.thresh2=h(ithr2);

    %% find peaks based on second threshold
    [pks,i]=findpeaks(r2,'MinPeakHeight',ecg.proc.thresh2,'MaxPeakWidth',round(0.1*fs));
    disp('...final ECG artefact detection done...')

    %% save info
    ecg.stats.intervals = 60./(diff(i)./fs);
    ecg.hr=60/(nanmedian(diff(i))/fs);
    ecg.nandata = data;
    ecg.cleandata= data;
    cbins = zeros(size(data));
    if numel(pks)
        for a = 1:length(pks)
            tss=size(ecg.proc.template2,2);
            ic=i(a):i(a)+tss-1;
            mirrorrange=[i(a):-1:(i(a)-round(tss/2)+2) (i(a)+tss+round(tss/2))-1:-1:(i(a)+tss)];
            try
                ecg.cleandata(ic)= data(mirrorrange);
            catch
                ecg.cleandata(ic)=0;
            end
            ecg.stats.n = numel(pks);
            cbins(ic)=1;
        end
    else
        ecg.stats.n = 0;
    end
    ecg.nandata(find(cbins))=nan;
    ecg.ecgbins = cbins;
    ecg.stats.pctartefact = nansum(cbins)/ns*100;
    ecg.stats.msartefact = nansum(cbins)/fs;
    ecg.stats.ecglength = length(ecg.proc.template1)/fs;

    %% decide on detection
    detstring = {'Unreliable or no ECG','Consistent ECG'};
    if (ecg.hr<55 || ecg.hr>120) || ecg.stats.n <= 0.5*ns/fs || (ii2-ii1)/fs > 0.075 || pdif < 20
        disp('No reliable ECG detection possible.')
        ecg.detected = 0;
    else
        ecg.detected = 1;
    end
    text = [detstring{ecg.detected+1} ' detected.'];
    disp(text);

    %     %% plot
    %
    %     t = linspace(0,ns/fs,ns);
    %     [~,f,rpow]=obj.aux_perceive_fft(data(find(~isnan(data))),fs,fs*2);
    %     [~,f,rnpow]=obj.aux_perceive_fft(ecg.cleandata(find(~isnan(ecg.cleandata))),fs,fs*2);
    %     nt2 = linspace(-.05,.1,size(ecg.proc.template2,2));
    %
    %     figure
    %     subplot(2,2,1);
    %     plot(nt2,ndata2','linewidth',0.1,'color',[.9 .9 .9]);
    %     hold on
    %     plot(nt2,ecg.proc.template2,'color','k');
    %     xlabel('Time [s]');ylabel('Amplitude');xlim([-.02 .1]);
    %     title([detstring{ecg.detected+1} ' detected.'])
    %
    %     subplot(2,2,2)
    %     plot(f,rpow,f,rnpow,'linewidth',2);
    %     xlim([4 30]);legend('original','cleaned'); xlabel('Frequency [Hz]')
    %     ylabel('Relative spectral power [%]');title([' HR: ' num2str(ecg.hr,3) '/min  N = ' num2str(ecg.stats.n,3)]);
    %
    %     subplot(2,2,3:4);
    %     plot(t,data,'color','r');    hold on
    %     plot(t,ecg.cleandata,'color','k');
    %     legend('original','cleaned');ylabel('Amplitude');xlabel('Time [s]')

else
    warning('Insufficient data length for ECG correction.')
    ecg=[];
    ecg.cleandata =nan(size(data));
end

LFP_ECGdata = ecg;

end
