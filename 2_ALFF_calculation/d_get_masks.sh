cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks

# T1 underlay from FSL
cp /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz ./


# CHCP_Yeo7 mask from NN2023 CHCP study
3dresample -master MNI152_T1_2mm_brain.nii.gz -prefix CHCP_Yeo7_2mm.nii.gz -inset CHCP_Yeo7.nii.gz -rmode NN

3drefit -space MNI CHCP_Yeo7_2mm.nii.gz


# Yeo7 cortical masks from freesurfer website
# https://surfer.nmr.mgh.harvard.edu/fswiki/CorticalParcellation_Yeo2011
# Yeo_JNeurophysiol11_MNI152

3dresample -master CHCP_Yeo7_2mm.nii.gz -prefix Yeo2011_2mm.nii.gz \
-inset ./Yeo_JNeurophysiol11_MNI152/Yeo2011_7Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz

3drefit -space MNI Yeo2011_2mm.nii.gz


# combine to get final mask for analysis
3dcalc -prefix CHCP_Yeo2011_2mm_mask.nii.gz -a CHCP_Yeo7_2mm.nii.gz -b Yeo2011_2mm.nii.gz -expr 'step(a+b)'

3dresample -dxyz 6 6 6 -prefix CHCP_Yeo2011_6mm_mask.nii.gz -inset CHCP_Yeo2011_2mm_mask.nii.gz


# csf and wm from FSL
cp /usr/local/fsl/data/standard/tissuepriors/avg152T1_csf* .
cp /usr/local/fsl/data/standard/tissuepriors/avg152T1_white* .
cp /usr/local/fsl/data/standard/tissuepriors/avg152T1_brain.* ./

rm -f avg152T1_brain.nii.gz
3dcalc -prefix avg152T1_brain.nii.gz -a avg152T1_brain.hdr -expr 'a'

flirt -in avg152T1_brain.nii.gz -ref MNI152_T1_2mm_brain.nii.gz -out avg152T1_brain_MNI.nii.gz -omat hdr2nii.mat -dof 6

# csf
rm -f avg152T1_csf.nii.gz
3dcalc -prefix avg152T1_csf.nii.gz -a avg152T1_csf.hdr -expr 'a'

flirt -in avg152T1_csf.nii.gz -ref MNI152_T1_2mm_brain.nii.gz -out avg152T1_csf_2mm.nii.gz -init hdr2nii.mat  -applyxfm

3dcalc -prefix avg152T1_csf_2mm_thr75.nii.gz -a avg152T1_csf_2mm.nii.gz -expr 'step(a-0.75)'

3drefit -space MNI avg152T1_csf_2mm_thr75.nii.gz 

# wm
rm -f avg152T1_wm.nii.gz
3dcalc -prefix avg152T1_wm.nii.gz -a avg152T1_white.hdr -expr 'a'

flirt -in avg152T1_wm.nii.gz -ref MNI152_T1_2mm_brain.nii.gz -out avg152T1_wm_2mm.nii.gz -init hdr2nii.mat  -applyxfm

3dcalc -prefix avg152T1_wm_2mm_thr95.nii.gz -a avg152T1_wm_2mm.nii.gz -expr 'step(a-0.95)'

3drefit -space MNI avg152T1_wm_2mm_thr95.nii.gz 



# whole brain mask from FSL
cp /usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz .
3dresample -master CHCP_Yeo7_2mm.nii.gz -prefix MNI152_T1_2mm_brain_mask_dil1_n.nii.gz \
-inset MNI152_T1_2mm_brain_mask_dil1.nii.gz

3drefit -space MNI MNI152_T1_2mm_brain_mask_dil1_n.nii.gz


