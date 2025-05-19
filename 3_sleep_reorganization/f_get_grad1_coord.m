clc;clear

% whole brain including 5378 voxels
maskfile1 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/CHCP_Yeo2011_6mm_mask.nii.gz'];
mask10 = load_nifti(maskfile1);
dim=size(mask10.vol);
mask1 = reshape(mask10.vol,[dim(1)*dim(2)*dim(3) 1]);



% mask of gradient1 from Daniel S. Margulies PNAS 2016
maskfile2 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Gradients_Margulies2016/volumes/masks/grad_1/sum_All20-6mm.nii.gz'];
mask20 = load_nifti(maskfile2);
mask2 = reshape(mask20.vol,[dim(1)*dim(2)*dim(3) 1]);

% combined mask of 4637 voxels
mask12 = mask1.*mask2;


%%% load gradient1 from Daniel S. Margulies PNAS 2016
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Gradients_Margulies2016/volumes
gradientfile1 = ['volume.grad_1.MNI6mm.nii.gz'];

gradient10 = load_nifti(gradientfile1);
gradient1 = reshape(gradient10.vol,[dim(1)*dim(2)*dim(3) 1]);

gradient1_mask = gradient1(find(mask12>0))-5.425259;

%%
save grad1_CHCP_Yeo2011_6mm.txt gradient1_mask -ascii



Mask1 = reshape(mask10.vol,[dim(1) dim(2) dim(3)]);
Mask2 = reshape(mask20.vol,[dim(1) dim(2) dim(3)]);
Mask = Mask1.* Mask2;
ind=find(Mask>0);
[xx yy zz] = ind2sub(size(Mask),ind);
X = [xx yy zz];

%%
save voxel_coordinates_CHCP_Yeo2011_6mm.txt X -ascii


