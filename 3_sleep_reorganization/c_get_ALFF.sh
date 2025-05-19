## extract all the ALFF maps
## get prepared for LME analysis

rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"

###
# 130 wake pre sleep sessions (300 s) from 130 subjects
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-wake-pre.txt`
# 2231 wake/sleep sessions (300 s) from 130 subjects
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-all2231.txt`


cd ${rtpath}/processed/ALFF_N2361

for session in ${Sessions}
do

cd ${rtpath}/processed/ALFF_N2361

rm -f ${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ALFF-ctx-z.nii.gz
cp ${rtpath}/processed/Five-min-sessions/${session}/${session}-volreg_MNI_bbr-dt-noGSR-residual-blur6_ALFF-ctx-z.nii.gz ./
done



# prepare for dALFF calculation
rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"
cd ${rtpath}/processed/ALFF_N2361/
mkdir stats
cd ${rtpath}/processed/ALFF_N2361/stats
rm -f all2361-volreg_MNI_bbr-dt-noGSR-residual-blur6_ALFF-ctx-z.nii.gz
3dTcat -prefix all2361-volreg_MNI_bbr-dt-noGSR-residual-blur6_ALFF-ctx-z.nii.gz \
../sub*wake*ALFF-ctx-z.nii.gz \
../sub*stage*ALFF-ctx-z.nii.gz



