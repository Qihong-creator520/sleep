%% get coordinates and metabolism data
%% get prepared for generating surrogate maps

clc;clear

% whole brain including 5378 voxels
maskfile1 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/CHCP_Yeo2011_6mm_mask.nii.gz'];
mask10 = load_nifti(maskfile1);
dim=size(mask10.vol);
mask1 = reshape(mask10.vol,[dim(1)*dim(2)*dim(3) 1]);



% mask of glycolysis from raichle's group
maskfile2 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/raichle/mask_glycolysis_6mm.nii.gz'];
mask20 = load_nifti(maskfile2);
mask2 = reshape(mask20.vol,[dim(1)*dim(2)*dim(3) 1]);

% combined mask of 4493 voxels
mask12 = mask1.*mask2;


%%% load glycolysis map from raichle's group
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/raichle
glycolysisfile1 = ['cmr_cmro2_glycolysis_cmrglc_z_6mm.nii.gz'];

glycolysis10 = load_nifti(glycolysisfile1);
glycolysis1 = reshape(glycolysis10.vol,[dim(1)*dim(2)*dim(3) 3]);

glycolysis1_mask = glycolysis1(find(mask12>0),:);

cmro2 = glycolysis1_mask(:,1);
glycolysis = glycolysis1_mask(:,2);
cmrglc = glycolysis1_mask(:,3);

%%
save cmro2_CHCP_Yeo2011_6mm.txt cmro2 -ascii
save glycolysis_CHCP_Yeo2011_6mm.txt glycolysis -ascii
save cmrglc_CHCP_Yeo2011_6mm.txt cmrglc -ascii



Mask1 = reshape(mask10.vol,[dim(1) dim(2) dim(3)]);
Mask2 = reshape(mask20.vol,[dim(1) dim(2) dim(3)]);
Mask = Mask1.* Mask2;
ind=find(Mask>0);
[xx yy zz] = ind2sub(size(Mask),ind);
X = [xx yy zz];

%%
save voxel_coordinates_CHCP_Yeo2011_6mm.txt X -ascii


