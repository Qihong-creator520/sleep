%%
clc;clear
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
Model_wake_pre=readtable('Model_wake_pre.txt');


for jj = 1:length(Model_wake_pre.Var1)
    
    if strcmp(Model_wake_pre.Var6(jj),'wake_pre')
        SW_history_wake_pre(jj,1:7)=0;

    else
        subj = cell2mat(Model_wake_pre.Var1(jj));
  
        cd(['/nd_disk2/qihong/Sleep_PKU/brain_restoration/' subj '/stages']);
    
        stage_a=[];
    
        dirns=dir('*sleep*txt');
        
        for N_ss=1:length(dirns)
        
            clear stage        
            stagename = [subj '_sleep' num2str(N_ss) '.txt'];
            stage = load(stagename);
            stage_a = [stage_a; stage];
        end
    
    
        for ss = 1:5
            SW_history_wake_pre(jj,ss)=length(find(stage_a==ss-1)); % W N1 N2 N3 REM
        end
    
        SW_history_wake_pre(jj,6)=sum(SW_history_wake_pre(jj,2:4)); % NREM
        SW_history_wake_pre(jj,7)=sum(SW_history_wake_pre(jj,2:5)); % sleep
        
    end
    
end


cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
save -ascii SW_history_wake_pre.txt SW_history_wake_pre



clc;clear
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
Model_wake_pre=readtable('Model_wake_pre.txt');
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
SW_history_wake_pre=load('SW_history_wake_pre.txt');

%%% 2bins
sw_history = SW_history_wake_pre(:,7)./120;
for xx = 1:length(sw_history)
    if sw_history(xx) <= 1
        sw_history_2bins{xx,1} = 'oneless'; % 128
    else
        sw_history_2bins{xx,1} = 'onemore'; % 2
    end
end


clear Model_sleep_wake_wake_pre
Model_sleep_wake_wake_pre=table(table2cell(Model_wake_pre(:,1)), ...,
                                                   table2array(Model_wake_pre(:,2)), ...,
                                                   table2cell(Model_wake_pre(:,3)), ...,
                                                   table2array(Model_wake_pre(:,4)), ...,
                                                   table2array(Model_wake_pre(:,5)), ...,
                                                   table2cell(Model_wake_pre(:,6)), ...,
                                                   sw_history_2bins, ...,
                                                   table2cell(Model_wake_pre(:,7)), ...,
                                                   table2cell(Model_wake_pre(:,8)));

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
writetable(Model_sleep_wake_wake_pre,['Model_sleep_wake_wake_pre.txt'],'Delimiter',',')

