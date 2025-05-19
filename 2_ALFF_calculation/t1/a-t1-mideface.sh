rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration/"

Subjects=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/Subjects_N130.txt`



for subject in ${Subjects}
do

cd ${rtpath}/processed/${subject}

3dresample -orient RPI -inset *t1_mprage*.nii -prefix ${subject}-T1_RPI.nii.gz

mideface --i ${subject}-T1_RPI.nii.gz --o ${subject}-T1_mideface.nii.gz --odir qa --pics --code ${subject}-T1 --no-samseg-fast --nii

done

