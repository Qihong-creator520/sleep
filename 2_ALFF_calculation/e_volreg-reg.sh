### head motion correction and registration
### check spatial coverage with the whole cortex

rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"

###
# 2461 sessions (300 s)
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-all2461.txt`
###
# 130 sessions (300 s)
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-wake-pre.txt`

for session in ${Sessions}
do

echo ${session}
date

cd ${rtpath}/processed/Five-min-sessions/${session}


rm -f ${session}-volreg.nii.gz ${session}-motion.1D
3dvolreg -verbose -tshift 0 -base ./${session}_reg.feat/example_func.nii.gz -1Dfile ${session}-motion.1D \
-prefix ${session}-volreg.nii.gz ${session}_RPI.nii.gz

rm -f ${session}_RPI-mask.nii.gz
3dAutomask -prefix ${session}_RPI-mask.nii.gz \
-dilate 1 ${session}-volreg.nii.gz


ref_brain=/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz

sub=`echo ${session} |cut -b 1-7`
echo ${sub}

rm -f ${session}-volreg_MNI_bbr.nii.gz
applywarp --in=./${session}-volreg --ref=${ref_brain} --warp=./MNINonLinear/xfms/NonlinearReg.nii.gz  --premat=./${session}_reg.feat/reg/example_func2highres.mat  --out=./${session}-volreg_MNI_bbr.nii.gz

rm -f ${session}-volreg_MNI_bbr-dt.nii.gz 3dDeconvolve*
3dDeconvolve -input \
${session}-volreg_MNI_bbr.nii.gz \
-polort 1 -float -errts ${session}-volreg_MNI_bbr-dt.nii.gz -bucket bucket
rm -f bucket* 3dDeconvolve.err 

3drefit -space MNI ${session}-volreg_MNI_bbr-dt.nii.gz


### extract covs and regress out covariances

rm -f ${session}-volreg_MNI_bbr-dt-csf.1D
3dmaskave -mask ${rtpath}/processed/masks/avg152T1_csf_2mm_thr75.nii.gz \
-quiet ${session}-volreg_MNI_bbr-dt.nii.gz \
>>${session}-volreg_MNI_bbr-dt-csf.1D

rm -f ${session}-volreg_MNI_bbr-dt-white.1D
3dmaskave -mask ${rtpath}/processed/masks/avg152T1_wm_2mm_thr95.nii.gz \
-quiet ${session}-volreg_MNI_bbr-dt.nii.gz \
>>${session}-volreg_MNI_bbr-dt-white.1D

rm -f ${session}-volreg_MNI_bbr-dt-brain.1D
3dmaskave -mask ${rtpath}/processed/masks/MNI152_T1_2mm_brain_mask_dil1_n.nii.gz \
-quiet ${session}-volreg_MNI_bbr-dt.nii.gz \
>>${session}-volreg_MNI_bbr-dt-brain.1D

rm -f ${session}-ts-motion.1D
1dcat \
${session}-volreg_MNI_bbr-dt-brain.1D \
${session}-volreg_MNI_bbr-dt-white.1D \
${session}-volreg_MNI_bbr-dt-csf.1D \
${session}-motion.1D \
> ${session}-ts-motion.1D
done


### get nuisance regressors in MATLAB
### perform nuisance regression and get residual time series in MATLAB



#############
rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-all2461.txt`

for session in ${Sessions}
do

echo ${session}
date

cp ${rtpath}/processed/Five-min-sessions/${session}/${session}-motion.1D \
${rtpath}/processed/motion

done





### check brain coverage
### get mask for each epoch

rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"

###
# 2461 sessions (300 s)
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-all2461.txt`

for session in ${Sessions}
do

echo ${session}
date

cd ${rtpath}/processed/Five-min-sessions/${session}


ref_brain=/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz

sub=`echo ${session} |cut -b 1-7`
echo ${sub}

rm -f ${session}-mask_MNI_bbr.nii.gz
applywarp --in=./${session}_RPI-mask --ref=${ref_brain} --warp=./MNINonLinear/xfms/NonlinearReg.nii.gz  --premat=./${session}_reg.feat/reg/example_func2highres.mat  --out=./${session}-mask_MNI_bbr.nii.gz --interp=nn

3drefit -space MNI ${session}-mask_MNI_bbr.nii.gz

cd ${rtpath}/processed/Five-min-sessions/check_coverage
cp ${rtpath}/processed/Five-min-sessions/${session}/${session}-mask_MNI_bbr.nii.gz ./

done





### get overlap between epoch-specific mask and cortex mask adopted in the analysis
rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"

###
# 2461 sessions (300 s)
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-all2461.txt`

for session in ${Sessions}
do

echo ${session}
date

cd ${rtpath}/processed/Five-min-sessions/check_coverage
3dmaskave -mask ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz -quiet \
${session}-mask_MNI_bbr.nii.gz \
>> overlap_CHCP_Yeo2011_mask_all2461.1D

done


