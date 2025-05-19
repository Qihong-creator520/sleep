## get fALFF maps

rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"

# 2461 sessions (300 s) + 130 sessions
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-all2591.txt`


ALFFs="fALFF"
LP=0.009; HP=0.08
TR=2
n_vols=150


for session in ${Sessions}
do

echo ${session}
date

cd ${rtpath}/processed/Five-min-sessions/${session}


## CALCULATING ALFF
## 1. primary calculations
echo "there are ${n_vols} vols"
## decide whether n_vols is odd or even
MOD=`expr ${n_vols} % 2` ; echo "Odd (1) or Even (0): ${MOD}"
## if odd, remove the first volume
N=$(echo "scale=0; ${n_vols}/2"|bc) ; N=$(echo "2*${N}"|bc)  ; echo ${N}


## 4. Calculate fALFF
echo "Computing amplitude of total frequency"
fslmaths ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ps_sqrt.nii.gz -Tmean -mul ${N} -div 2 \
${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ps_sum.nii.gz
## calculate fALFF as ALFF/amplitude of total frequency
echo "Computing fALFF"
fslmaths ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ALFF.nii.gz -div ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ps_sum.nii.gz \
${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_fALFF.nii.gz
rm -f ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ps_sum.nii.gz



for alff in ${ALFFs}
do
# within cortex mask
scale=(`3dmaskave -sigma -mask ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz -q ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_${alff}.nii.gz`)
rm -f ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_${alff}-ctx-z.nii.gz
3dcalc -prefix ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_${alff}-ctx-z.nii.gz \
-a ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_${alff}.nii.gz \
-b ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-expr "step(b)*(a-${scale[0]})/${scale[1]}"


done


done

