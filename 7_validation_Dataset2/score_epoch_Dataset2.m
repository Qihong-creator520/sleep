clc;clear
cd /nd_disk2/qihong/Sleep_PKU/Gu_Liu_Sleep_EEG_fMRI/sourcedata
dirs=dir('sub*tsv');
N_subj_epoch=zeros(33,14);
ep_length = 300;
TR = 2.1;
ff = 0;

for ii=1:length(dirs)
    cd /nd_disk2/qihong/Sleep_PKU/Gu_Liu_Sleep_EEG_fMRI/sourcedata
    %% load scores
    clear data1 score score_m stage acc_sleep
    opts = detectImportOptions(['sub-', num2str(ii,'%02d'), '-sleep-stage.tsv'],'FileType','text','Delimiter','\t');
    if length(opts.VariableTypes)==4
        opts.VariableTypes=["double" "string" "double" "string"];
    else
        opts.VariableTypes=["string" "double" "string"];
    end

    opts.SelectedVariableNames = ["session","epoch_start_time_sec","x30_sec_epoch_sleep_stage"];
    data1=readtable(['sub-', num2str(ii,'%02d'), '-sleep-stage.tsv'],opts);

    score = data1.x30_sec_epoch_sleep_stage;
    score_m=zeros(size(score));
    for j=1:length(score)
        switch score{j}
            case 'W' ;
                score_m(j)=0;
            case 'W (uncertain)' ;
                score_m(j)=0;
            case '1' ;
                score_m(j)=1;
            case '1 (uncertain)' ;  
                score_m(j)=1;
            case '2' ;
                score_m(j)=2;
            case '2 (uncertain)' ;
                score_m(j)=2;
            case '3';
                score_m(j)=3;
            case '3 (uncertain)' ;
                score_m(j)=3;
            case 'Unscorable' ;
                score_m(j)=5;
        end
    end

    for mm=1:length(score)/10
        epoch = score_m( ((mm-1)*10+1) : mm*10);
        stage(mm,1) = median(epoch);
        acc_sleep(1,1) = 0;
        if mm>0
            acc_sleep(mm,1) = sum(score_m( 1: (mm-1)*10)>0);
        end
    end


    N_subj_epoch(ii,3) = sum(stage==0); % number of wake epochs
    N_subj_epoch(ii,4) = sum(stage>0); % number of sleep epochs
    N_subj_epoch(ii,1:2) = N_subj_epoch(ii,3:4)>0; % if subject exist at least one wake/sleep epoch?

    N_subj_epoch(ii,5) = sum(score_m>0); % number of sleep frames
    N_subj_epoch(ii,6) = sum(score_m(1:40)>0); % number of sleep frames in rest runs
    N_subj_epoch(ii,7) = sum(score_m(41:end)>0); % number of sleep frames in sleep runs

    N_subj_epoch(ii,8) = sum(stage==0 & acc_sleep<120); % number of wake epochs during early sleep
    N_subj_epoch(ii,9) = sum(stage>0 & acc_sleep<120); % number of sleep epochs during early sleep
    N_subj_epoch(ii,10) = sum(stage==0 & acc_sleep>=120); % number of wake epochs during late sleep
    N_subj_epoch(ii,11) = sum(stage>0 & acc_sleep>=120); % number of sleep epochs during late sleep



    %% load fMRI data
    path1=['/nd_disk2/qihong/Sleep_PKU/Gu_Liu_Sleep_EEG_fMRI/sub-', num2str(ii,'%02d'), '/func']
    cd(path1)
    fmri=dir("*.nii.gz");
    a_concat=[];
    for nn=1:length(fmri)
        a=niftiread(fmri(nn).name);
        a_concat=cat(4,a_concat,a);
    end
    
    N_W=0;
    N_S=0;
    a_info=niftiinfo(fmri(1).name);
    out_info = a_info;
    out_info.ImageSize(4) = round(ep_length/TR); 

    if ~exist([path1,'/', num2str(ep_length)])
%         rmdir([num2str(ep_length)],'s')
        mkdir([path1,'/', num2str(ep_length)])
    end
  
    for mm=1:length(score)/10
        if stage(mm,1) ==0
            N_W=N_W+1;
            filename=['sub-', num2str(ii,'%02d'),'_stage0','sess',num2str(N_W,'%02d')];
        else
            N_S=N_S+1;
            filename=['sub-', num2str(ii,'%02d'),'_sleep','sess',num2str(N_S,'%02d')];
        end
        out_info.Filename=[path1,'/', num2str(ep_length),'/', filename];
        niftiwrite(a_concat(:,:,:,((mm-1)*round(ep_length/TR)+1) : mm*round(ep_length/TR)),out_info.Filename,out_info);
        
        ff = ff+1;
        filenames{ff} = filename;
    end
    
    cd([path1,'/', num2str(ep_length)])
    N_subj_epoch(ii,12) = length(dir("*stage0*nii*")); % validate the wake epochs
    N_subj_epoch(ii,13) = length(dir("*sleep*nii*")); % validate the sleep epochs
    N_subj_epoch(ii,14) = sum(score_m==5); % number of Unscorable epochs
end


sum(N_subj_epoch)
%          29          32         324         375        3571         581        2990         313         293          11          82         324         375           1
cd /nd_disk2/qihong/Sleep_PKU/Gu_Liu_Sleep_EEG_fMRI/sourcedata
save N_subj_epoch.txt N_subj_epoch '-ascii'
