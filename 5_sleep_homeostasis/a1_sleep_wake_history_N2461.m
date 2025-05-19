%% calculate accumulated sleep before each 5-minute epoch
%%
clc;clear
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
Model_N2461=readtable('Model_N2461_forEEG.txt');


for jj = 1:length(Model_N2461.age)

    subj = cell2mat(Model_N2461.subjects(jj));
    
    N_ss = Model_N2461.N_ss(jj);
    onset_ss = Model_N2461.onset_ss(jj);
    
    cd(['/nd_disk2/qihong/Sleep_PKU/brain_restoration/' subj '/stages']);

    stage_a=[];
    
    
    if N_ss>1
    
        for kk = 1: N_ss-1
            clear stage
            
            stagename = [subj '_sleep' num2str(kk) '.txt'];
            stage = load(stagename);
            stage_a = [stage_a; stage];
        end
    end

    clear stage
    stagename = [subj '_sleep' num2str(N_ss) '.txt'];
    stage = load(stagename);
    
    if onset_ss ==1
        stage_a = stage_a;
    else
        stage_a = [stage_a; stage(1:onset_ss-1)];
    end

    for ss = 1:5
        SW_history_N2461(jj,ss)=length(find(stage_a==ss-1)); % W N1 N2 N3 REM
    end

    SW_history_N2461(jj,6)=sum(SW_history_N2461(jj,2:4)); % NREM
    SW_history_N2461(jj,7)=sum(SW_history_N2461(jj,2:5)); % sleep


end


cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
save -ascii SW_history_N2461.txt SW_history_N2461

