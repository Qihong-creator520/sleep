clc;clear

for_EEG_N2231=readtable('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/for_EEG_N2231.txt');
rtpath='/nd_disk2/qihong/Sleep_PKU/brain_restoration/EEG/sorted/';
L_frame = 30; % 30-second for each frame, unit for the onset
ep_length = 300; % epoch length = 300 seconds
chan_select = 1:52; % all 52 overlapped EEG channels

previous='';


rtpath1='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/Five-min-sessions/';
NTpath='/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Sleep_bad_epochs/';

% get seq and k for sorting channels of sub3***
load('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/locs_n.mat');



for ii = 1:length(for_EEG_N2231.filenames_a)

    name = cell2mat(for_EEG_N2231.filenames_a(ii));

    subj = name(1:7);

    N_ss = for_EEG_N2231.N_ss(ii);
    onset_ss = for_EEG_N2231.onset_ss(ii);

    subpath = [rtpath subj];
    cd(subpath);
    
    %% EEG data have been preprocessed in BP analyzer
    EEGname = [subj '_sleep' num2str(N_ss) '.vhdr'];
    %% the earliest 20-second data of each session has been removed before sleep staging to match fMRI
    %% additional 14-second data of the 2nd session of sub3055 have been removed before sleep staging, 7 more fMRI volumes need to be removed
    %% additional 10-second data of the 2nd session of sub3100 have been removed before sleep staging, 5 more fMRI volumes need to be removed
    disp(EEGname)

    if ~strcmp(EEGname,previous)

        clear EEG0* EEG1 EEG2 EEGc* data start0 finish0
        EEG0 = pop_loadbv(subpath,EEGname, [], []);
    
        EEG01 = pop_eegfiltnew(EEG0,15.5,17.5,[],1,[],0); % notch 16.5 Hz
        EEG0_n = pop_eegfiltnew(EEG01,32,34,[],1,[],0); % notch 33 Hz
    
        EEG1 = EEG0_n;

        if ~strcmp(EEG0.chanlocs(32).labels,'ECG') % switch amplifier for sub3106
            disp(['sa for ', EEGname])
            clear dat1 chan1
            dat1(1:32,:)=EEG1.data(33:64,:);
            dat1(33:64,:)=EEG1.data(1:32,:);
            EEG1.data=dat1;
            chan1(1:32)=EEG1.chanlocs(33:64);
            chan1(33:64)=EEG1.chanlocs(1:32);
            EEG1.chanlocs=chan1;
        end
    
        if strcmp(EEG1.chanlocs(17).labels,'Fpz') % sort channels for sub3***         
            clear dat1
            for ll=1:36
                mm=seq(ll);
                dat1(ll,:)=EEG1.data(mm,:);
            end
            EEG1.data(17:52,:)=dat1;
            EEG1.chanlocs(1:52)=k;
            % get the 52 overlapped EEG channels, extract the beginning 5-minute data
            EEG2 = pop_select(EEG1,'channel',1:52); 
           
        
        else % get the 52 overlapped channels for sub1***, extract the beginning 5-minute data   
            % EOG, ECG, EMG, references (A1/2) should be removed
            % 'AF7','AF8','PO7','PO8','CPz' should be removed from sub1***
            EEG2 = pop_select(EEG1,'rmchannel',{'A1','A2','EOG1','EOG2','EMG1','EMG2','ECG',...,
                                                                           'AF7','AF8','PO7','PO8','CPz','FCz'}); 
            EEG2.chanlocs(1:52)=k;
        end
    
    % identify bad channels
        EEGc1 = pop_clean_rawdata(EEG2, 'FlatlineCriterion',5,'ChannelCriterion',0.70,'LineNoiseCriterion',4,...,
                                                                    'Highpass','off','BurstCriterion','off','WindowCriterion','off',...,
                                                                    'BurstRejection','off','Distance','Euclidian',...,
                                                                    'WindowCriterionTolerances',-1,'fusechanrej',-1);

        cd([NTpath subj])
        NTname = [subj '_sleep' num2str(N_ss) '_template.txt'];
        NT=load(NTname); % manually labeled noise segments
    
    
        if EEGc1.nbchan==52 && sum(sum(NT,2)==size(NT,2))==0
            rmc = zeros(1,52);
            
        elseif EEGc1.nbchan==52 && sum(sum(NT,2)==size(NT,2))>0

            rmc = zeros(1,52);
            rmc(find(sum(NT,2)==size(NT,2))) = 1;
            EEGc1 = pop_select(EEGc1,'rmchannel',{k(find(sum(NT,2)==size(NT,2))).labels}); 


        elseif EEGc1.nbchan<52 && sum(sum(NT,2)==size(NT,2))==0
    
            rmc = 1 - EEGc1.etc.clean_channel_mask';

        else
    
            rmc = 1 - EEGc1.etc.clean_channel_mask';
            rmc(find(sum(NT,2)==size(NT,2))) = 1;
            EEGc1 = pop_select(EEGc1,'rmchannel',{k(find(sum(NT,2)==size(NT,2))).labels}); 
 
        end

        if sum(rmc)>0
            %     vis_artifacts(EEGc1,EEG2)
            % % interpolate bad channels
            EEGc2 = pop_interp(EEGc1,EEG2.chanlocs,'spherical'); 
            NT(find(rmc>0),:) = 0; % assume interpolated channels are noise-free
        else
            EEGc2 = EEGc1;
        end


% % re-reference based on the 52 channels
        EEGc31 = pop_reref(EEGc2,[]);

        previous = EEGname;
    
    end

    rmc_N2231(ii,:) = rmc;

    NT_epoch=NT(chan_select,((onset_ss-1)*L_frame/2+1):((onset_ss+9)*L_frame/2));
    
    %% get 5-minute EEG data
    start0 = (onset_ss-1)*L_frame*EEG0.srate+1;
    finish0 = start0 + ep_length*EEG0.srate - 1;
    EEGc32 = EEGc31;
    EEGc32.data = EEGc31.data(:, start0:finish0);
    EEGc32.pnts = ep_length*EEG0.srate;
    EEGc32.xmin = EEGc31.xmin + start0/EEGc31.srate; 
    EEGc32.xmax = EEGc31.xmin + finish0/EEGc31.srate;


    %% remove muscle, eye and heart artifacts using ica
    ALLEEG = pop_runica(EEGc32, 'icatype','picard','concatcond','on','options',{'pca',-1});
    ALLEEG = pop_iclabel(ALLEEG, 'default');
    ALLEEG = pop_icflag( ALLEEG,[NaN NaN;0.9 1;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN]);
    %% pop_viewprops(ALLEEG, 0)
    
    %% number of flagged mucle components
    N_ic_flagged(ii,1) = length(find(ALLEEG.etc.ic_classification.ICLabel.classifications(:,2)>0.9));
    N_ic_flagged(ii,2) = max(ALLEEG.etc.ic_classification.ICLabel.classifications(:,2));
    %% number of flagged eye components
    N_ic_flagged(ii,3) = length(find(ALLEEG.etc.ic_classification.ICLabel.classifications(:,3)>0.9));
    N_ic_flagged(ii,4) = max(ALLEEG.etc.ic_classification.ICLabel.classifications(:,3));
    %% number of flagged heart components
    N_ic_flagged(ii,6) = length(find(ALLEEG.etc.ic_classification.ICLabel.classifications(:,4)>0.9));
    N_ic_flagged(ii,7) = max(ALLEEG.etc.ic_classification.ICLabel.classifications(:,4));

    if N_ic_flagged(ii,3) == 0
        [low_thresh, low_index] = max(ALLEEG.etc.ic_classification.ICLabel.classifications(:,3));
        N_ic_flagged(ii,5) = low_thresh-0.000001;
        if low_thresh > 0.7 && ALLEEG.etc.ic_classification.ICLabel.classifications(low_index,1) < 0.1
            %% remove eye artifact using lower threshold, but make sure it is not a brain component
            ALLEEG = pop_runica(EEGc32, 'icatype','picard','concatcond','on','options',{'pca',-1});
            ALLEEG = pop_iclabel(ALLEEG, 'default');
            ALLEEG = pop_icflag( ALLEEG,[NaN NaN;0.9 1;low_thresh-0.000001 1;0.9 1;NaN NaN;NaN NaN;NaN NaN]);
            %% update number of flagged eye components
            N_ic_flagged(ii,3) = length(find(ALLEEG.etc.ic_classification.ICLabel.classifications(:,3)>low_thresh-0.00001));
        end

    else
        N_ic_flagged(ii,5) = 0.9;

    end

    
    %% removed flagged muscle and eye components
    ALLEEG = pop_subcomp(ALLEEG, []);
    ALLEEG = pop_reref( ALLEEG, []);

    
    EEGc3=ALLEEG;

    data_epoch=double(EEGc3.data);

    for n = 1:size(chan_select,2)
        clear data_frame pxx f index* powero_frame*

        for m=1:10 %i=frame_index
            data_frame{m}=data_epoch(n, (L_frame*EEG0.srate*(m-1)+1) : (L_frame*EEG0.srate*m));
            warning('off');
            [pxx,f]=pwelch(data_frame{m},hanning(2000),1000,2000,500);%4s,overlap2s
            warning('on');

            index_s2=find(f==0.5); % 0.3 Hz - 35 Hz
            index_e2=find(f==35); % temporal filter range

            powero_frame_all(m,:)=(pxx(index_s2:index_e2));% 0.3 Hz to 35 Hz, raw

            if sum(NT_epoch(n,((m-1)*L_frame/2+1):m*L_frame/2))>0 % noise at this frame for this channel
                powero_frame_all(m,:)=nan;
            end
        end

  

        %%
        for jj = 1:size(powero_frame_all,2)
            tf=isoutlier(powero_frame_all(:,jj)); % for each frequency point, outlier across frames
            powero_frame_all(tf>0,jj)=nan;
        end

        powero_epoch_all(n,:)=nanmean(powero_frame_all,1); % average across the 10 possible frames

    end

    SWAo_N2231(ii,:) = nanmean(powero_epoch_all(:,2:15),2)'; % 0.75-4Hz over SWA across 52 channels

end

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
save('rmc_N2231_nnn.txt','-ascii','rmc_N2231');
save('N_ic_flagged_N2231_nnn.txt','-ascii','N_ic_flagged');
save('SWAo_N2231_nnn.txt','-ascii','SWAo_N2231');

% repeat the above analysis on 130 wakefulness data prior to (or after) sleep sessions
% and get SWAo_N130_nnn.txt


