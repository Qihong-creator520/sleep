## get ALFF maps

rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"

###
# 2461 sessions (300 s)
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-all2461.txt`
###
# 130 sessions (300 s)
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-wake-pre.txt`

ALFFs="ALFF"
LP=0.009; HP=0.08
TR=2
n_vols=150


for session in ${Sessions}
do

echo ${session}
date

cd ${rtpath}/processed/Five-min-sessions/${session}


# blur6
rm -f ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6.nii.gz
3dmerge -doall -1blur_fwhm 6 -prefix \
${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6.nii.gz \
${session}-volreg_MNI_bbr-dt-noGSR-residual.nii.gz


## CALCULATING ALFF
## 1. primary calculations
echo "there are ${n_vols} vols"
## decide whether n_vols is odd or even
MOD=`expr ${n_vols} % 2` ; echo "Odd (1) or Even (0): ${MOD}"
## if odd, remove the first volume
N=$(echo "scale=0; ${n_vols}/2"|bc) ; N=$(echo "2*${N}"|bc)  ; echo ${N}
if [ ${MOD} -eq 1 ]
then
    echo "Deleting the first volume from ${type} data due to a bug in fslpspec"
    fslroi ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6.nii.gz ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_4ps.nii.gz 1 ${N}
fi
if [ ${MOD} -eq 0 ]
then
    cp ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6.nii.gz ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_4ps.nii.gz
fi
rm -f ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6.nii.gz

## 2. Computing power spectrum
echo "Computing power spectrum"
fslpspec ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_4ps.nii.gz ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ps.nii.gz
rm -f ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_4ps.nii.gz
echo "Computing square root of power spectrum"
fslmaths ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ps.nii.gz -sqrt ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ps_sqrt.nii.gz
rm -f ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ps.nii*

## 3. Calculate ALFF
echo "Extracting power spectrum at the slow frequency band"
## calculate the low frequency point
n_lp=$(echo "scale=10; ${LP}*${N}*${TR}"|bc)
n1=$(echo "${n_lp}-1"|bc|xargs printf "%1.0f") ; 
echo "${LP} Hz is around the ${n1} frequency point."
## calculate the high frequency point
n_hp=$(echo "scale=10; ${HP}*${N}*${TR}"|bc)
n2=$(echo "${n_hp}-${n_lp}+1"|bc|xargs printf "%1.0f") ; 
echo "There are about ${n2} frequency points before ${HP} Hz."
## cut the low frequency data from the the whole frequency band
fslroi ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ps_sqrt.nii.gz ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ps_slow.nii.gz ${n1} ${n2}
## calculate ALFF as the sum of the amplitudes in the low frequency band
echo "Computing amplitude of the low frequency fluctuations (ALFF)"
fslmaths ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ps_slow.nii.gz -Tmean -mul ${n2} \
${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ALFF.nii.gz
rm -f ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ps_slow.nii.gz 


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

