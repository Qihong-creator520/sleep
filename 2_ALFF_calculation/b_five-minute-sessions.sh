## extract all the 5-minute epochs for further analysis

rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"
Subjects=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/Subjects_N130.txt`

for subject in ${Subjects}
do

cd ${rtpath}/${subject}/fMRI/300
echo ${subject}

for session in `ls stage*sess*nii`
do
session1=`echo ${session}`
session2=`echo $session1 | sed 's/.nii//g'`
echo ${session2}

cd ${rtpath}/processed/Five-min-sessions
mkdir ${subject}_${session2}
cd ${rtpath}/processed/Five-min-sessions/${subject}_${session2}

cp ${rtpath}/${subject}/fMRI/300/${session2}.nii ./${subject}_${session2}.nii
done

done





# copy subject-specific T1 related files for registration

rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"

for subject in ${Subjects}
do

cd ${rtpath}/${subject}/fMRI/300
echo ${subject}

for session in `ls stage*sess*nii`
do
session1=`echo ${session}`
session2=`echo $session1 | sed 's/.nii//g'`
echo ${session2}

cd ${rtpath}/processed/Five-min-sessions/${subject}_${session2}

cp ${rtpath}/processed/${subject}/${subject}-T1_RPI.nii.gz  ./T1_RPI.nii.gz
cp ${rtpath}/processed/${subject}/${subject}-T1_RPI_acpc.nii.gz  ./T1_RPI_acpc.nii.gz
cp ${rtpath}/processed/${subject}/${subject}-T1_RPI_acpc_brain.nii.gz  ./T1_RPI_acpc_brain.nii.gz
cp ${rtpath}/processed/${subject}/${subject}-T1_RPI_acpc_brain_mask.nii.gz  ./T1_RPI_acpc_brain_mask.nii.gz
cp ${rtpath}/processed/${subject}/${subject}-T1_RPI_MNI.nii.gz  ./T1_RPI_MNI.nii.gz
cp ${rtpath}/processed/${subject}/${subject}-T1_RPI_MNI_brain.nii.gz  ./T1_RPI_MNI_brain.nii.gz
cp -r ${rtpath}/processed/${subject}/MNINonLinear  ./

done
done







