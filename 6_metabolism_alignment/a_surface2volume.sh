# generate cmrglc and cmro2 nii files

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/raichle/cmrglc/fsLR

wb_command -metric-to-volume-mapping source-raichle_desc-cmrglc_space-fsLR_den-164k_hemi-L_feature.func.gii ../../../atlas/tpl-fsLR_den-164k_hemi-L_midthickness.surf.gii /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/MNI152_T1_2mm_brain.nii.gz cmrglc_l_wb.nii.gz -nearest-vertex 4


wb_command -metric-to-volume-mapping source-raichle_desc-cmrglc_space-fsLR_den-164k_hemi-R_feature.func.gii ../../../atlas/tpl-fsLR_den-164k_hemi-R_midthickness.surf.gii /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/MNI152_T1_2mm_brain.nii.gz cmrglc_r_wb.nii.gz -nearest-vertex 4



cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/raichle/cmro2/fsLR

wb_command -metric-to-volume-mapping source-raichle_desc-cmro2_space-fsLR_den-164k_hemi-L_feature.func.gii ../../../atlas/tpl-fsLR_den-164k_hemi-L_midthickness.surf.gii /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/MNI152_T1_2mm_brain.nii.gz cmro2_l_wb.nii.gz -nearest-vertex 4


wb_command -metric-to-volume-mapping source-raichle_desc-cmro2_space-fsLR_den-164k_hemi-R_feature.func.gii ../../../atlas/tpl-fsLR_den-164k_hemi-R_midthickness.surf.gii /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/MNI152_T1_2mm_brain.nii.gz cmro2_r_wb.nii.gz -nearest-vertex 4



