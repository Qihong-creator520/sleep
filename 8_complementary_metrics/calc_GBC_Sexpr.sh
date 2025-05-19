## get GBC maps

rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"

# 2461 sessions (300 s) + 130 sessions
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-all2591.txt`


for session in ${Sessions}
do


cd ${rtpath}/processed/Five-min-sessions/${session}


# lp & dt
rm -f ${session}-volreg_MNI_bbr-dt-GSR-residual-lp1.nii.gz
3dFourier -prefix ${session}-volreg_MNI_bbr-dt-GSR-residual-lp1.nii.gz \
-lowpass 0.08 -highpass 0.009 -ignore 0 -retrend ${session}-volreg_MNI_bbr-dt-GSR-residual.nii.gz

rm -f ${session}-volreg_MNI_bbr-dt-GSR-residual-lp.nii.gz 3dDeconvolve*
3dDeconvolve -input \
${session}-volreg_MNI_bbr-dt-GSR-residual-lp1.nii.gz \
-polort 1 -float -errts ${session}-volreg_MNI_bbr-dt-GSR-residual-lp.nii.gz -bucket bucket
rm -f bucket* 3dDeconvolve.err 
rm -f ${session}-volreg_MNI_bbr-dt-GSR-residual-lp1.nii.gz


# blur6
rm -f ${session}-volreg_MNI_bbr-dt-GSR-residual-lp-blur6.nii.gz
3dmerge -doall -1blur_fwhm 6 -prefix \
${session}-volreg_MNI_bbr-dt-GSR-residual-lp-blur6.nii.gz \
${session}-volreg_MNI_bbr-dt-GSR-residual-lp.nii.gz


# downsample to v3 to speed up the GBC calculation
rm -f ${session}-volreg_MNI_bbr-dt-GSR-residual-lp-blur6-v3.nii.gz
3dresample -dxyz 3 3 3 -prefix ${session}-volreg_MNI_bbr-dt-GSR-residual-lp-blur6-v3.nii.gz \
-inset ${session}-volreg_MNI_bbr-dt-GSR-residual-lp-blur6.nii.gz

# sum of the absolute correlation coefficients larger than 0.3
# blur6-GBC-aTCsp3
rm -f  ${session}-volreg-GSR-GBC-aTCsp3-v3.nii.gz
3dTcorrMap -input ${session}-volreg_MNI_bbr-dt-GSR-residual-lp-blur6-v3.nii.gz \
-mask ${rtpath}/processed/masks/CHCP_Yeo2011_3mm_mask.nii.gz \
-Sexpr 'abs(z)*step(abs(r)-0.3)' ${session}-volreg-GSR-GBC-aTCsp3-v3.nii.gz

# within cortex mask
scale=(`3dmaskave -sigma -mask ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz -q ${session}-volreg-GSR-GBC-aTCsp3-v3.nii.gz`)
rm -f ${session}-volreg-GSR-GBC-aTCsp3-v3-ctx-z.nii.gz
3dcalc -prefix ${session}-volreg-GSR-GBC-aTCsp3-v3-ctx-z.nii.gz \
-a ${session}-volreg-GSR-GBC-aTCsp3-v3.nii.gz \
-b ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-expr "step(b)*(a-${scale[0]})/${scale[1]}"

done






