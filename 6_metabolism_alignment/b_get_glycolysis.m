%% get glucose metabolism as well as its two subcomponents and mask maps

clc;clear
%%
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/raichle/cmro2/fsLR
cmro2_rfile1 = ['cmro2_r_wb.nii.gz'];
cmro2_r10 = load_nifti(cmro2_rfile1);
dim4=size(cmro2_r10.vol);
cmro2_r1 = reshape(cmro2_r10.vol,[dim4(1)*dim4(2)*dim4(3) 1]);

cmro2_lfile1 = ['cmro2_l_wb.nii.gz'];
cmro2_l10 = load_nifti(cmro2_lfile1);
dim4=size(cmro2_l10.vol);
cmro2_l1 = reshape(cmro2_l10.vol,[dim4(1)*dim4(2)*dim4(3) 1]);

%%
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/raichle/cmrglc/fsLR
cmrglc_rfile1 = ['cmrglc_r_wb.nii.gz'];
cmrglc_r10 = load_nifti(cmrglc_rfile1);
cmrglc_r1 = reshape(cmrglc_r10.vol,[dim4(1)*dim4(2)*dim4(3) 1]);

cmrglc_lfile1 = ['cmrglc_l_wb.nii.gz'];
cmrglc_l10 = load_nifti(cmrglc_lfile1);
cmrglc_l1 = reshape(cmrglc_l10.vol,[dim4(1)*dim4(2)*dim4(3) 1]);

%%
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks
maskfile1 = ['CHCP_Yeo2011_2mm_mask.nii.gz'];
mask10 = load_nifti(maskfile1);
mask1 = reshape(mask10.vol,[dim4(1)*dim4(2)*dim4(3) 1]);

index_cmro2 = (cmro2_l1>0) + (cmro2_r1>0);
index_cmrglc = (cmrglc_l1>0) + (cmrglc_r1>0);

cmrglc_n1 = (cmrglc_l1 + cmrglc_r1)./index_cmrglc;
cmro2_n1 = (cmro2_l1 + cmro2_r1)./index_cmro2;


index_glycolysis = index_cmro2.*index_cmrglc;
index_mask =mask1>0;
index_final = index_glycolysis .* index_mask;



cmrglc_n = cmrglc_n1(index_final>0) ./ mean(cmrglc_n1(index_final>0)); % global mean of 1 as in PNAS 2010 paper
cmro2_n = cmro2_n1(index_final>0) ./ mean(cmro2_n1(index_final>0)); % global mean of 1 as in PNAS 2010 paper


s = regstats(cmrglc_n,cmro2_n,'linear',{'beta','tstat','r'}); 
glycolysis = s.r.*1000;  % global scaling of 1000 as in PNAS 2010 paper


%% save CMR data
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/raichle/
resultsmap = cmro2_r10;

results1 = zeros(dim4(1)*dim4(2)*dim4(3), 1);
%% glycolysis
results1(index_final>0,:) = glycolysis;

resultsmap.vol = reshape(results1,[dim4(1) dim4(2) dim4(3) 1]);
resultsfile= ['glycolysis.nii.gz'];
err = save_nifti(resultsmap,resultsfile);

%% glycolysis zscore
results1(index_final>0,:) = zscore(glycolysis);

resultsmap.vol = reshape(results1,[dim4(1) dim4(2) dim4(3) 1]);
resultsfile= ['glycolysis_z.nii.gz'];
err = save_nifti(resultsmap,resultsfile);




%% cmro2
results1(index_final>0,:) = cmro2_n;

resultsmap.vol = reshape(results1,[dim4(1) dim4(2) dim4(3) 1]);
resultsfile= ['cmro2.nii.gz'];
err = save_nifti(resultsmap,resultsfile);

%% cmro2 zscore
results1(index_final>0,:) = zscore(cmro2_n);

resultsmap.vol = reshape(results1,[dim4(1) dim4(2) dim4(3) 1]);
resultsfile= ['cmro2_z.nii.gz'];
err = save_nifti(resultsmap,resultsfile);





%% cmrglc
results1(index_final>0,:) = cmrglc_n;

resultsmap.vol = reshape(results1,[dim4(1) dim4(2) dim4(3) 1]);
resultsfile= ['cmrglc.nii.gz'];
err = save_nifti(resultsmap,resultsfile);

%% cmrglc zscore
results1(index_final>0,:) = zscore(cmrglc_n);

resultsmap.vol = reshape(results1,[dim4(1) dim4(2) dim4(3) 1]);
resultsfile= ['cmrglc_z.nii.gz'];
err = save_nifti(resultsmap,resultsfile);


%% save mask
results1(index_final>0,:) = 1;

resultsmap.vol = reshape(results1,[dim4(1) dim4(2) dim4(3) 1]);
resultsfile= ['mask_glycolysis.nii.gz'];
err = save_nifti(resultsmap,resultsfile);


%% downsample the glucose metabolism and mask maps into 6-mm resolution using 3dresample in afni

