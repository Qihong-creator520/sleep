rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration/"

Subjects=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/Subjects_N130.txt`


FSLDIR=/usr/local/fsl
Reference=/usr/local/fsl/data/standard/MNI152_T1_1mm.nii.gz
Reference2mm=/usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz
ReferenceMask=/usr/local/fsl/data/standard/MNI152_T1_1mm_brain_mask.nii.gz
Reference2mmMask=/usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask_dil.nii.gz
WD=./BrainExtraction_FNIRTbased
FNIRTConfig=/usr/local/fsl/etc/flirtsch/T1_2_MNI152_2mm.cnf

for subject in ${Subjects}
do
echo ${subject}
date

cd ${rtpath}/processed/${subject}

mkdir BrainExtraction_FNIRTbased
Input=${subject}-T1_RPI_acpc.nii.gz
BaseName=`${FSLDIR}/bin/remove_ext $Input`;
BaseName=`basename $BaseName`;

# Register to 2mm reference image (linear then non-linear)
${FSLDIR}/bin/flirt -interp spline -dof 12 -in "$Input" -ref "$Reference2mm" -omat "$WD"/roughlin.mat -out "$WD"/"$BaseName"_to_MNI_roughlin.nii.gz -nosearch
${FSLDIR}/bin/fnirt --in="$Input" --ref="$Reference2mm" --aff="$WD"/roughlin.mat --refmask="$Reference2mmMask" --fout="$WD"/str2standard.nii.gz --jout="$WD"/NonlinearRegJacobians.nii.gz --refout="$WD"/IntensityModulatedT1.nii.gz --iout="$WD"/"$BaseName"_to_MNI_nonlin.nii.gz --logout="$WD"/NonlinearReg.txt --intout="$WD"/NonlinearIntensities.nii.gz --cout="$WD"/NonlinearReg.nii.gz --config="$FNIRTConfig"

# Overwrite the image output from FNIRT with a spline interpolated highres version
${FSLDIR}/bin/applywarp --rel --interp=spline --in="$Input" --ref="$Reference" -w "$WD"/str2standard.nii.gz --out="$WD"/"$BaseName"_to_MNI_nonlin.nii.gz

# Invert warp and transform dilated brain mask back into native space, and use it to mask input image
# Input and reference spaces are the same, using 2mm reference to save time
${FSLDIR}/bin/invwarp --ref="$Reference2mm" -w "$WD"/str2standard.nii.gz -o "$WD"/standard2str.nii.gz
${FSLDIR}/bin/applywarp --rel --interp=nn --in="$ReferenceMask" --ref="$Input" -w "$WD"/standard2str.nii.gz -o ${subject}-T1_RPI_acpc_brain_mask.nii.gz
${FSLDIR}/bin/fslmaths "$Input" -mas ${subject}-T1_RPI_acpc_brain_mask.nii.gz ${subject}-T1_RPI_acpc_brain.nii.gz

done

