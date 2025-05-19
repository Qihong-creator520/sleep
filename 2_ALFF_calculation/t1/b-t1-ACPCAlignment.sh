rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration/"

Subjects=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/Subjects_N130.txt`


FSLDIR=/usr/local/fsl
BrainSizeOpt=150
Reference=/usr/local/fsl/data/standard/MNI152_T1_1mm.nii.gz

for subject in ${Subjects}
do
echo ${subject}
date

cd ${rtpath}/processed/${subject}

mkdir ACPCAlignment
mkdir xfms

# Crop the FOV
${FSLDIR}/bin/robustfov -i ${subject}-T1_RPI.nii.gz -m ./ACPCAlignment/roi2full.mat -r ./ACPCAlignment/robustroi.nii.gz -b $BrainSizeOpt

# Invert the matrix (to get full FOV to ROI)
${FSLDIR}/bin/convert_xfm -omat ./ACPCAlignment/full2roi.mat -inverse ./ACPCAlignment/roi2full.mat

# Register cropped image to MNI152 (12 DOF)
${FSLDIR}/bin/flirt -interp spline -in ./ACPCAlignment/robustroi.nii.gz -ref "$Reference" -omat ./ACPCAlignment/roi2std.mat -out ./ACPCAlignment/acpc_final.nii.gz -searchrx -30 30 -searchry -30 30 -searchrz -30 30

# Concatenate matrices to get full FOV to MNI
${FSLDIR}/bin/convert_xfm -omat ./ACPCAlignment/full2std.mat -concat ./ACPCAlignment/roi2std.mat ./ACPCAlignment/full2roi.mat

# Get a 6 DOF approximation which does the ACPC alignment (AC, ACPC line, and hemispheric plane)
${FSLDIR}/bin/aff2rigid ./ACPCAlignment/full2std.mat ./xfms/acpc.mat

# Create a resampled image (ACPC aligned) using spline interpolation
${FSLDIR}/bin/applywarp --rel --interp=spline -i ${subject}-T1_RPI.nii.gz -r "$Reference" --premat=./xfms/acpc.mat -o ${subject}-T1_RPI_acpc.nii.gz 

done

