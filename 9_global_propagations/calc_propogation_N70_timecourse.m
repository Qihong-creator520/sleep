clc;clear

% 902629 voxels
maskfile1 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz'];
mask10 = load_nifti(maskfile1);
dim=size(mask10.vol);
mask1 = reshape(mask10.vol,[dim(1)*dim(2)*dim(3) 1]);

% mask of gradient1 from Daniel S. Margulies PNAS 2016
maskfile2 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Gradients_Margulies2016/volumes/masks/grad_1/sum_All20.nii.gz'];
mask20 = load_nifti(maskfile2);
mask2 = reshape(mask20.vol,[dim(1)*dim(2)*dim(3) 1]);

mask12 = mask1.*mask2;


%% load gradient1 from Daniel S. Margulies PNAS 2016
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Gradients_Margulies2016/volumes
pg1file = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Gradients_Margulies2016/volumes/volume.grad_1.MNI2mm.nii.gz'];
pg10 = load_nifti(pg1file);
pg1 = reshape(pg10.vol,[dim(1)*dim(2)*dim(3) 1]);
pg1_mask = pg1(find(mask12>0),:); % pg1

num_bins = 70;
pgd1 = discretize(pg1_mask,prctile(pg1_mask,0:100/num_bins:100));
pgd1 = pgd1-min(pgd1)+1;

       


%%
fid=fopen('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/filelist-all2361.txt');
subj=textscan(fid,'%s');
fclose(fid);
rtpath='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/Five-min-sessions';
cd(rtpath);
gs_index=NaN(length(subj{1}),2+2*num_bins);
gs_times_width=NaN(length(subj{1}),6);
gs_amplitude=NaN(length(subj{1}),2+2*num_bins);
gs_latency=NaN(length(subj{1}),2*num_bins);

for x = 1:length(subj{1})
    disp( strtrim(subj{1}{x}) )
    path = [rtpath '/' strtrim(subj{1}{x}) '/'];


    %% load epoch data
    cd(path);
    datafile = [strtrim(subj{1}{x}) '-volreg_MNI_bbr-dt.nii.gz'];
    data = load_nifti(datafile);
    dim=size(data.vol);
    nt=dim(4);
    data1=reshape(data.vol,[dim(1)*dim(2)*dim(3) dim(4)]);
    
    data_mask1=data1(find(mask12>0),:);
    data_mask1=data_mask1';
    data_mask=data_mask1;

    epi1msk0 = FT_Filter_mulch2(data_mask,[0.01 0.1]/.25)'; % temporally smoothing data

    t = 1:nt;  
    t_upsampled = 1:0.25:nt; 

    epi1msk1 = interp1(t, epi1msk0', t_upsampled, 'spline');

    epi1msk = zscore(epi1msk1)';

    gs_LR1 = mean(epi1msk); % calculate the global mean of input data

    [gls_neg_pk,locs1] = findpeaks(-double(gs_LR1)); %% location of global troughs
    locs = locs1';

    latency = NaN(size(locs,1)-1,1);
    amplitude = NaN(size(locs,1)-1,1);
    TPs = NaN(size(locs,1)-1,51);

    for li = 1:size(locs,1)-1

        %% peak info of gs
        [pks_prin, a_prin] = findpeaks(gs_LR1(locs(li):locs(li+1))); % location of global peaks
        thre1 = 0;
        if isempty(a_prin)
            latency(li) = nan;
            amplitude(li) = nan;
        elseif size(a_prin,2)>1
            [valmax1,id_prin] = max(pks_prin);
            if valmax1<=thre1
                latency(li) = nan;
                amplitude(li) = nan;
            else
                latency(li) = a_prin(id_prin) + locs(li);
                TPs (li,:) = latency(li) -25:1:latency(li)+25;
                amplitude(li) = pks_prin(id_prin) - 0.5*gs_LR1(locs(li)) - 0.5*gs_LR1(locs(li+1)); 
            end
        elseif pks_prin>thre1
            latency(li) = a_prin + locs(li); 
            TPs (li,:) = latency(li) -25:1:latency(li)+25;
            amplitude(li) = pks_prin - 0.5*gs_LR1(locs(li)) - 0.5*gs_LR1(locs(li+1));
        else
            latency(li) = nan;
            amplitude(li) = nan;
        end
    end

    TPs(find(TPs<1))=nan;
    TPs(find(TPs>597))=nan;


    tw1 = grpstats(epi1msk,pgd1); % tw1: time-position graph along the pg1 brain map
   
    %% find delay of local peaks relative to global peaks at gd1
    latency_gd1 = NaN(num_bins,size(locs,1)-1);
    amplitude_gd1 = NaN(num_bins,size(locs,1)-1);

    for li = 1:size(locs,1)-1

        %% peak info of gd1 networks
        clear tmp_prin 
        tmp_prin = tw1(:,locs(li):locs(li+1));     
        for lj = 1:num_bins
            
            tmp2_prin = tmp_prin(lj,:);
            [pks_prin, a_prin] = findpeaks(double(tmp2_prin));
        
            thre1 = 0;
            if isempty(a_prin)
                latency_gd1(lj,li) = nan;
                amplitude_gd1(lj,li) = nan;
            elseif size(a_prin,2)>1
                [valmax1,id_prin] = max(pks_prin);
                if valmax1<=thre1
                    latency_gd1(lj,li) = nan;
                    amplitude_gd1(lj,li) = nan;
                else
                    latency_gd1(lj,li) = a_prin(id_prin) + locs(li);
                    amplitude_gd1(lj,li) = pks_prin(id_prin) - 0.5*tmp2_prin(1) - 0.5*tmp2_prin(end);
                end
            elseif pks_prin>thre1
                latency_gd1(lj,li) = a_prin + locs(li);
                amplitude_gd1(lj,li) = pks_prin - 0.5*tmp2_prin(1) - 0.5*tmp2_prin(end);
            else
                latency_gd1(lj,li) = nan;
                amplitude_gd1(lj,li) = nan;
            end
        end

    end


    latency_gd1 = latency_gd1 - repmat(latency',num_bins,1);

    %% calculate time-position correlation at each segment: rval_prin_2
    sz = diff(locs);
    rval_prin_2 = zeros(size(locs,1)-1,2);
    
    for ln = 1:size(locs,1)-1
        clear x_ax
        x_ax = (0:(sz(ln)-1)/size(latency_gd1,1):(sz(ln)-1));
        x_ax = x_ax(1:end-1);
        
        if sum(isnan(latency_gd1(:,ln)))>14 
            rval_prin_2(ln,:) = nan;

        else    
            [rval_prin_2(ln,1),rval_prin_2(ln,2)] = corr((x_ax)',latency_gd1(:,ln),'rows','pairwise');
        end
        
    end

    outname1=[strtrim(subj{1}{x}) '-locs_raw_56_rs_n.txt'];
    save(outname1,'locs','-ascii');
    
    outname3=[strtrim(subj{1}{x}) '-rval_prin_2_raw_56_rs_n.txt']; % resampled to 0.5s temporal resolution
    save(outname3,'rval_prin_2','-ascii');
    
    gs_sig = rval_prin_2;


    %% bottom-up gs: significantly pos corr witg pg1
    bu_index = find((gs_sig(:,1)>0) & (gs_sig(:,2)<1e-5));
    gs_mean = nan(51,1);

    if sum(~isnan(nanmean(TPs(bu_index,:),1)))==51 %% at least 1 available gs peak
        gs_index(x,1)=1;
        gs_amplitude(x,1) = nanmean(amplitude(bu_index));
        gs_times_width(x,1) = length(bu_index);
        gs_times_width(x,2) = mean(sz(bu_index))/2; % in second
        gs_times_width(x,3) = sum(sz(bu_index))./600; % occurence
        
        for tp = 1:1:51
            gs_mean(tp)=mean(gs_LR1(TPs(bu_index(~isnan(TPs(bu_index,tp))),tp)));
        end
    end
     outname1=[strtrim(subj{1}{x}), '-gs-bu-mean.txt'];
     save(outname1,'gs_mean','-ascii');

    %% top-down gs
    td_index = find((gs_sig(:,1)<0) & (gs_sig(:,2)<1e-5));
    gs_mean = nan(51,1);

    if sum(~isnan(nanmean(TPs(td_index,:),1)))==51 %% at least 1 available gs peak
        gs_index(x,1+num_bins+1)=1;
        gs_amplitude(x,1+num_bins+1) = nanmean(amplitude(td_index));
        gs_times_width(x,4) = length(td_index);
        gs_times_width(x,5) = mean(sz(td_index))/2;
        gs_times_width(x,6) = sum(sz(td_index))./600;

        for tp = 1:1:51
            gs_mean(tp)=mean(gs_LR1(TPs(td_index(~isnan(TPs(td_index,tp))),tp)));
        end

    end
    outname1=[strtrim(subj{1}{x}), '-gs-td-mean.txt'];
    save(outname1,'gs_mean','-ascii');

    for net = 1:num_bins

        gs_mean_net = nan(51,1);
        %% bottom-up gs       
        if sum(~isnan(nanmean(TPs(bu_index,:),1)))==51 & sum(~isnan(latency_gd1(net,bu_index)))>0 %% at least 1 available gs peak
            gs_index(x,net+1)=1;
            gs_latency(x,net) = nanmean(latency_gd1(net,bu_index));
            gs_amplitude(x,net+1) = nanmean(amplitude_gd1(net,bu_index(~isnan(latency_gd1(net,bu_index)'))));
            % get gs mean curve across gs peaks
            for tp = 1:1:51
                gs_mean_net(tp)=mean(tw1(net,TPs(bu_index(~isnan(TPs(bu_index,tp).*latency_gd1(net,bu_index)')),tp)));
            end
        end
        outname1=[strtrim(subj{1}{x}), '-gs-bu-mean-',num2str(net,'%02d'), '.txt'];
        save(outname1,'gs_mean_net','-ascii');

        %% top-down gs    
        gs_mean_net = nan(51,1);
        if sum(~isnan(nanmean(TPs(td_index,:),1)))==51 & sum(~isnan(latency_gd1(net,td_index)))>0 %% at least 1 available gs peak
            gs_index(x,net+1+num_bins+1)=1;
            gs_latency(x,net+num_bins) = nanmean(latency_gd1(net,td_index));
            gs_amplitude(x,net+1+num_bins+1) = nanmean(amplitude_gd1(net,td_index(~isnan(latency_gd1(net,td_index)'))));
            % get gs mean curve across gs peaks
            for tp = 1:1:51
                gs_mean_net(tp)=mean(tw1(net,TPs(td_index(~isnan(TPs(td_index,tp).*latency_gd1(net,td_index)')),tp)));
            end
        end            
        outname1=[strtrim(subj{1}{x}), '-gs-td-mean-',num2str(net,'%02d'), '.txt'];
        save(outname1,'gs_mean_net','-ascii');

    end

    % save gs info for each session
    outname1=[strtrim(subj{1}{x}), '-gs-amplitude-n.txt'];
    cc=gs_amplitude(x,:);
    save(outname1,'cc','-ascii');

    outname1=[strtrim(subj{1}{x}), '-gs-times-width-n.txt'];
    dd=gs_times_width(x,:);
    save(outname1,'dd','-ascii');
end

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
save('gs_amplitude_N2361_raw_56_n.txt','gs_amplitude','-ascii') 
save('gs_times_width_N2361_raw_56_n.txt','gs_times_width','-ascii') 



%% 2 stages and accsleep
clc;clear
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
Model_wake_pre=readtable('Model_sleep_wake_wake_pre.txt');
Model_all=readtable('Model_sleep_wake_N2361.txt');
Model_N2231.Properties.VariableNames=Model_wake_pre.Properties.VariableNames;
Model_all=[Model_wake_pre; Model_N2231];


clear stage_n1
for jj = 1:length(Model_wake_pre.Var6)
    stage_n1{jj,1}='wake';
end

for jj = length(Model_wake_pre.Var6)+1:length(Model_wake_pre.Var6)+length(Model_N2231.Var6)

    if ~strcmp(table2cell(Model_N2231(jj-length(Model_wake_pre.Var6),6)), 'stage0')
        stage_n1{jj,1}='sleep';
    else
        stage_n1{jj,1}='wake';
    end
end


clear Model_sleep_wake_accsleep*
Model_sleep_wake_accsleep1=table(table2cell(Model_all(:,1)), ...,
                                                   table2array(Model_all(:,2)), ...,
                                                   table2cell(Model_all(:,3)), ...,
                                                   table2array(Model_all(:,4)), ...,
                                                   table2array(Model_all(:,5)), ...,
                                                   table2cell(Model_all(:,8)), ...,
                                                   stage_n1, table2cell(Model_all(:,7)));


%% features
fid=fopen('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/filelist-all2361.txt');
subj=textscan(fid,'%s');
fclose(fid);
for x = 1:length(subj{1})
    disp( strtrim(subj{1}{x}) )
    path = [rtpath '/' strtrim(subj{1}{x}) '/'];

    %% load epoch data
    cd(path);
    datafile1 = [strtrim(subj{1}{x}), '-gs-times-width-n.txt'];
    data1 = load(datafile1);
    datafile2 = [strtrim(subj{1}{x}), '-gs-amplitude-n.txt'];
    data2 = load(datafile2);
    data = [data1(:,3) data2(:,1) data1(:,2) data1(:,6) data2(:,72) data1(:,5)];
    data_all =[data_all; data];
end

%%
e=array2table([data_all]);
e.Properties.VariableNames{1} =  'bu_occurence';
e.Properties.VariableNames{2} =  'bu_amplitude';
e.Properties.VariableNames{3} =  'bu_width';
e.Properties.VariableNames{4} =  'td_occurence';
e.Properties.VariableNames{5} =  'td_amplitude';
e.Properties.VariableNames{6} =  'td_width';


Model_sleep_wake_accsleep = [Model_sleep_wake_accsleep1 e];

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/gs_timecourse
writetable(Model_sleep_wake_accsleep,['Model_sleep_wake_accsleep_2bins_gs_occurence_amplitude_width_N2361.txt'],'Delimiter',',')


