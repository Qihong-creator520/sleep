## get epoch list

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/Five-min-sessions
ls -d sub* > /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/filelist-all2461.txt


### registration

rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"

###
# 2461 sessions (300 s) from 130 participants
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-all2461.txt`
###
# 130 sessions (300 s)
Sessions=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/filelist-wake-pre.txt`

for session in ${Sessions}
do

echo ${session}
date

cd ${rtpath}/processed/Five-min-sessions/${session}

sub=`echo ${session} |cut -b 1-7`
echo ${sub}
stage_sess=`echo ${session} |cut -c 9-`
echo ${stage_sess}

rm -f ${session}_RPI.nii.gz
3dresample -orient RPI -inset ${session}.nii -prefix ${session}_RPI.nii.gz

3drefit -Tslices `cat ${rtpath}/Sleep_EEG_fMRI-main_R1/2_ALFF_calculation/SliceTimes.1D` ${session}_RPI.nii.gz



rm -f preproc_reg.fsf
cp ${rtpath}/Sleep_EEG_fMRI-main_R1/preproc_reg.fsf .

rm -f ${session}_reg.fsf
cat preproc_reg.fsf | sed "s/sub1001/${sub}/g" > ${session}_reg-tmp1.fsf
cat ${session}_reg-tmp1.fsf | sed "s/stage0sess01_1/${stage_sess}/g" > ${session}_reg.fsf
rm -f ${session}_reg-tmp*.fsf

rm -rf ${session}_reg.feat
feat ${session}_reg.fsf

done

