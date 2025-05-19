## get ReHo maps

rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"

# 2461 sessions (300 s) + 130 sessions
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-all2591.txt`


for session in ${Sessions}
do

echo ${session}
date

cd ${rtpath}/processed/Five-min-sessions/${session}


# lp & dt
rm -f ${session}-volreg_MNI_bbr-dt-noGSR-residual-lp1.nii.gz
3dFourier -prefix ${session}-volreg_MNI_bbr-dt-noGSR-residual-lp1.nii.gz \
-lowpass 0.08 -highpass 0.009 -ignore 0 -retrend ${session}-volreg_MNI_bbr-dt-noGSR-residual.nii.gz

rm -f ${session}-volreg_MNI_bbr-dt-noGSR-residual-lp.nii.gz 3dDeconvolve*
3dDeconvolve -input \
${session}-volreg_MNI_bbr-dt-noGSR-residual-lp1.nii.gz \
-polort 1 -float -errts ${session}-volreg_MNI_bbr-dt-noGSR-residual-lp.nii.gz -bucket bucket
rm -f bucket* 3dDeconvolve.err 
rm -f ${session}-volreg_MNI_bbr-dt-noGSR-residual-lp1.nii.gz



# ReHo
rm -f ${session}-volreg-ReHo.nii.gz
3dReHo -inset ${session}-volreg_MNI_bbr-dt-noGSR-residual-lp.nii.gz \
-mask ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-nneigh 27 \
-prefix ${session}-volreg-ReHo.nii.gz


# blur6
rm -f ${session}-volreg-ReHo-blur6.nii.gz
3dmerge -doall -1blur_fwhm 6 -prefix \
${session}-volreg-ReHo-blur6.nii.gz \
${session}-volreg-ReHo.nii.gz


# within cortex mask
scale=(`3dmaskave -sigma -mask ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz -q ${session}-volreg-ReHo-blur6.nii.gz`)
rm -f ${session}-volreg-ReHo-blur6-ctx-z.nii.gz
3dcalc -prefix ${session}-volreg-ReHo-blur6-ctx-z.nii.gz \
-a ${session}-volreg-ReHo-blur6.nii.gz \
-b ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-expr "step(b)*(a-${scale[0]})/${scale[1]}"

done

