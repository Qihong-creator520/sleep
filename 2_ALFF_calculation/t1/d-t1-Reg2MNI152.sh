rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration/"

Subjects=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/Subjects_N130.txt`


FSLDIR=/usr/local/fsl
Reference=/usr/local/fsl/data/standard/MNI152_T1_1mm.nii.gz
ReferenceBrain=/usr/local/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz
Reference2mm=/usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz
Reference2mmMask=/usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask_dil.nii.gz
WD=./MNINonLinear
FNIRTConfig=/usr/local/fsl/etc/flirtsch/T1_2_MNI152_2mm.cnf

for subject in ${Subjects}
do
echo ${subject}
date

cd ${rtpath}/processed/${subject}

mkdir -p ${rtpath}/processed/${subject}/MNINonLinear
mkdir -p ${rtpath}/processed/${subject}/MNINonLinear/xfms

T1wBrain=${subject}-T1_RPI_acpc_brain.nii.gz
T1wBrainBasename=`${FSLDIR}/bin/remove_ext $T1wBrain`;
T1wBrainBasename=`basename $T1wBrainBasename`;
T1w=${subject}-T1_RPI_acpc.nii.gz

# Linear then non-linear registration to MNI
${FSLDIR}/bin/flirt -interp spline -dof 12 -in ${T1wBrain} -ref ${ReferenceBrain} -omat ${WD}/xfms/acpc2MNILinear.mat -out ${WD}/xfms/${T1wBrainBasename}_to_MNILinear

${FSLDIR}/bin/fnirt --in=${T1w} --ref=${Reference2mm} --aff=${WD}/xfms/acpc2MNILinear.mat --refmask=${Reference2mmMask} --fout=${WD}/xfms/acpc2standard.nii.gz --jout=${WD}/xfms/NonlinearRegJacobians.nii.gz --refout=${WD}/xfms/IntensityModulatedT1.nii.gz --iout=${WD}/xfms/2mmReg.nii.gz --logout=${WD}/xfms/NonlinearReg.txt --intout=${WD}/xfms/NonlinearIntensities.nii.gz --cout=${WD}/xfms/NonlinearReg.nii.gz --config=${FNIRTConfig}

# Input and reference spaces are the same, using 2mm reference to save time
${FSLDIR}/bin/invwarp -w ${WD}/xfms/acpc2standard.nii.gz -o ${WD}/xfms/standard2acpc.nii.gz -r ${Reference2mm}

# T1w set of warped outputs (brain/whole-head)
${FSLDIR}/bin/applywarp --rel --interp=spline -i ${T1w} -r ${Reference} -w ${WD}/xfms/acpc2standard.nii.gz -o ${subject}-T1_RPI_MNI.nii.gz
${FSLDIR}/bin/applywarp --rel --interp=nn -i ${T1wBrain} -r ${Reference} -w ${WD}/xfms/acpc2standard.nii.gz -o ${subject}-T1_RPI_MNI_brain.nii.gz
${FSLDIR}/bin/fslmaths ${subject}-T1_RPI_MNI.nii.gz -mas ${subject}-T1_RPI_MNI_brain.nii.gz ${subject}-T1_RPI_MNI_brain.nii.gz

done

