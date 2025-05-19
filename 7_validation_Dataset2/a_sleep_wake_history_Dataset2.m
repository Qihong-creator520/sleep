clc;clear
cd /nd_disk2/qihong/Sleep_PKU/Gu_Liu_Sleep_EEG_fMRI/sourcedata
dirs=dir('sub*tsv');
N_subj_epoch=zeros(33,14);
ep_length = 300;
TR = 2.1;

subj_all={};
filename_all={};
stage_all={};
sess_all={};
sw_history_2bins_all={};

for ii=1:length(dirs)
    cd /nd_disk2/qihong/Sleep_PKU/Gu_Liu_Sleep_EEG_fMRI/sourcedata
    %% load scores
    clear data1 score score_m stage acc_sleep
    clear opts stage1 sess1 filename1 subj1 sw_history_2bins1
    %% updated on 20250421
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

    N_W=0;
    N_S=0;

    for mm=1:length(score)/10
        subj1{mm,1}=['sub-', num2str(ii,'%02d')];
        if stage(mm,1) ==0
            N_W=N_W+1;
            filename1{mm,1}=['sub-', num2str(ii,'%02d'),'_stage0','sess',num2str(N_W,'%02d'),'.nii.gz'];
            stage1{mm,1}='stage0';
            sess1{mm,1}=['sess',num2str(N_W,'%02d')];
        else
            N_S=N_S+1;
            filename1{mm,1}=['sub-', num2str(ii,'%02d'),'_sleep','sess',num2str(N_S,'%02d'),'.nii.gz'];
            stage1{mm,1}='sleep';
            sess1{mm,1}=['sess',num2str(N_S,'%02d')];
        end

        if acc_sleep(mm,1)>120 % accumulated 60 minutes of sleep
            sw_history_2bins1{mm,1}='more';
        else
            sw_history_2bins1{mm,1}='less';
        end

    end
    
    subj_all=[subj_all; subj1];
    filename_all=[filename_all; filename1];
    stage_all=[stage_all; stage1];
    sess_all=[sess_all; sess1];
    sw_history_2bins_all=[sw_history_2bins_all; sw_history_2bins1];

end


clear Model_sleep_wake
Model_sleep_wake=table(subj_all, ...,
                                       stage_all, ...,
                                       sess_all, ...,
                                       sw_history_2bins_all, ...,
                                       filename_all);

cd /nd_disk2/qihong/Sleep_PKU/Gu_Liu_Sleep_EEG_fMRI/scripts
writetable(Model_sleep_wake,['Model_sleep_wake_60min_n.txt'],'Delimiter',',')



%% updated 20250422
clc;clear
cd /nd_disk2/qihong/Sleep_PKU/Gu_Liu_Sleep_EEG_fMRI/scripts
Model_N574=readtable('Model_N574_n.txt');
Model_sleep_wake=readtable('Model_sleep_wake_60min_n.txt');

for jj = 1:length(Model_N574.Var5)
    index = contains(Model_sleep_wake.filename_all,Model_N574.Var5(jj));
    index_sleep_wake(jj,1) = find(index>0);

end

clear Model_sleep_wake_N574
Model_sleep_wake_N574=table(table2cell(Model_N574(:,1)), ...,
                                                   table2array(Model_N574(:,2)), ...,
                                                   table2cell(Model_N574(:,3)), ...,
                                                   table2array(Model_N574(:,4)), ...,
                                                   table2cell(Model_sleep_wake(index_sleep_wake,4)), ...,
                                                   table2cell(Model_N574(:,5)));

cd /nd_disk2/qihong/Sleep_PKU/Gu_Liu_Sleep_EEG_fMRI/scripts
writetable(Model_sleep_wake_N574,['Model_sleep_wake_N574_60min_n.txt'],'Delimiter',',')




aa=readtable('Model_sleep_wake_N574_60min_n.txt');
acc=(aa.Var5);
sub=(aa.Var1);
subs=contains(acc,'more');
subs_u=unique(sub(subs)); % 11
sub_u=unique(sub); % 33
subb=contains(acc,'less'); 
subb_u=unique(sub(subb));% 33




aa=0;bb=0;cc=0;dd=0;
for ii=1:length(Model_sleep_wake.subj_all)
    if contains(table2cell(Model_sleep_wake(ii,4)),'less') && contains(table2cell(Model_sleep_wake(ii,2)),'stage0')
        aa=aa+1;
    elseif contains(table2cell(Model_sleep_wake(ii,4)),'less') && contains(table2cell(Model_sleep_wake(ii,2)),'sleep')
        bb=bb+1;
    elseif contains(table2cell(Model_sleep_wake(ii,4)),'more') && contains(table2cell(Model_sleep_wake(ii,2)),'stage0')
        cc=cc+1;
    else
        dd=dd+1;
    end
end

[aa bb cc dd]
% 120
%    313   295    11    80



aa=0;bb=0;cc=0;dd=0;
for ii=1:length(Model_sleep_wake_N574.Var1)
    if contains(table2cell(Model_sleep_wake_N574(ii,5)),'less') && contains(table2cell(Model_sleep_wake_N574(ii,3)),'stage0')
        aa=aa+1;
    elseif contains(table2cell(Model_sleep_wake_N574(ii,5)),'less') && contains(table2cell(Model_sleep_wake_N574(ii,3)),'sleep')
        bb=bb+1;
    elseif contains(table2cell(Model_sleep_wake_N574(ii,5)),'more') && contains(table2cell(Model_sleep_wake_N574(ii,3)),'stage0')
        cc=cc+1;
    else
        dd=dd+1;
    end
end

[aa bb cc dd]
% 120
%   272   248     9    45



