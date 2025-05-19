
%%
clc;clear
Model_N2231=readtable('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Model_N2231.txt');
filename=Model_N2231.Var8;
Model_N2461=readtable('Model_N2461_forEEG.txt');
SW_history_N2461=load('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/SW_history_N2461.txt');

for jj = 1:length(Model_N2231.Var8)
    filename1 = Model_N2231.Var8(jj);
    filename = filename1{1}(1:22);

    index = contains(Model_N2461.filenames_a,filename);
    index_N2231(jj,1) = find(index>0);

end

SW_history_N2231 = SW_history_N2461(index_N2231,:);

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
save -ascii SW_history_N2231.txt SW_history_N2231



%%% 2bins
sw_history = SW_history_N2231(:,7)./120;
for xx = 1:length(sw_history)
    if sw_history(xx) <= 1
        sw_history_2bins{xx,1} = 'oneless'; % 1134
    else
        sw_history_2bins{xx,1} = 'onemore'; % 1097
    end
end



clear Model_sleep_wake_N2231
Model_sleep_wake_N2231=table(table2cell(Model_N2231(:,1)), ...,
                                                   table2array(Model_N2231(:,2)), ...,
                                                   table2cell(Model_N2231(:,3)), ...,
                                                   table2array(Model_N2231(:,4)), ...,
                                                   table2array(Model_N2231(:,5)), ...,
                                                   table2cell(Model_N2231(:,6)), ...,
                                                   sw_history_2bins, ...,
                                                   table2cell(Model_N2231(:,7)), ...,
                                                   table2cell(Model_N2231(:,8)));

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
writetable(Model_sleep_wake_N2231,['Model_sleep_wake_N2231.txt'],'Delimiter',',')


cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
Model_wake_pre=readtable('Model_sleep_wake_wake_pre.txt');
Model_N2231=readtable('Model_sleep_wake_N2231.txt');
Model_N2231.Properties.VariableNames=Model_wake_pre.Properties.VariableNames;
Model_all=[Model_wake_pre; Model_N2231];

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
writetable(Model_all,['Model_sleep_wake_N2361.txt'],'Delimiter',',')

%% run 3dLMEr in afni


%%
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
SW_history_wake_pre=load('SW_history_wake_pre.txt');
SW_history_sleep=load('SW_history_N2231.txt');
SW = [SW_history_wake_pre(:,7)./120; SW_history_sleep(:,7)./120];

clear stage_n
stage_n(1:130)=0;
for jj = 131:length(Model_all.Var6)
    stage_n(jj)=~contains(table2cell(Model_all(jj,6)),'stage0');
end

median(SW(stage_n>0))
%    1.0417

