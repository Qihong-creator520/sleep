%% get 2 stage by 2 bin model for average ALFF in 7 canonical networks

clc;clear
%% get model
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/
Model_wake_pre=readtable('Model_sleep_wake_wake_pre.txt');
Model_N2231=readtable('Model_sleep_wake_N2231.txt');
Model_N2231.Properties.VariableNames=Model_wake_pre.Properties.VariableNames;
Model_all=[Model_wake_pre; Model_N2231];


% get ALFF in CHCP7
maskfile1 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz'];
mask10 = load_nifti(maskfile1);
dim=size(mask10.vol);
mask1 = reshape(mask10.vol,[dim(1)*dim(2)*dim(3) 1]);


% mask from CHCP
maskfile2 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/CHCP_Yeo7_2mm.nii.gz'];
mask20 = load_nifti(maskfile2);
dim=size(mask20.vol);
mask2 = reshape(mask20.vol,[dim(1)*dim(2)*dim(3) 1]);

mask12 = (mask1>0).*mask2;


%%
outpath='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361/stats';
cd(outpath)
clear ALFF ALFF1
ALFFfile1 = ['all2361-volreg_MNI_bbr-dt-noGSR-residual-blur6_ALFF-ctx-z.nii.gz'];
ALFF10 = load_nifti(ALFFfile1);
dim4=size(ALFF10.vol);
ALFF1 = reshape(ALFF10.vol,[dim4(1)*dim4(2)*dim4(3) dim4(4)]);

label={'Vis','SM','DAN','VAN','Aud','FP','DMN'};


cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Gradients_Margulies2016/volumes
pg1file = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Gradients_Margulies2016/volumes/volume.grad_1.MNI2mm.nii.gz'];
pg10 = load_nifti(pg1file);
pg1 = reshape(pg10.vol,[dim(1)*dim(2)*dim(3) 1]);


for roi = 1 : 7
    
    CHCP7_ALFF(roi,:) = mean(ALFF1(mask12==roi,:),1);
    CHCP7_pg1(roi,1) =mean(pg1(mask12==roi));
end

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
sum(strcmp(stage_n1,'wake')) % 568
sum(strcmp(stage_n1,'sleep')) % 1793


clear Model_sleep_wake_accsleep*
Model_sleep_wake_accsleep1=table(table2cell(Model_all(:,1)), ...,
                                                   table2array(Model_all(:,2)), ...,
                                                   table2cell(Model_all(:,3)), ...,
                                                   table2array(Model_all(:,4)), ...,
                                                   table2array(Model_all(:,5)), ...,
                                                   table2cell(Model_all(:,8)), ...,
                                                   stage_n1, table2cell(Model_all(:,7)));




%%
clear e
e=array2table([CHCP7_ALFF']);
for ii=1:size(e,2)
    e.Properties.VariableNames{ii} = label{ii};
end


clear Model_sleep_wake_accsleep
Model_sleep_wake_accsleep = [Model_sleep_wake_accsleep1 e];



cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
writetable(Model_sleep_wake_accsleep,['Model_sleep_wake_accsleep_2bins_CHCP7.txt'],'Delimiter',',')



%%
% run R


%% F map interaction
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
CHCP7 = readtable('out_sleep_wake_2stages_accsleep_2bins_CHCP7.csv');
%    0.0095    0.5250    0.0001    0.5623    0.0004    0.0000    0.8895
