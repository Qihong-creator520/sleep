rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"
rtpath1="/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/tSNR"


Subjects=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/Subjects_N130.txt`

for subject in ${Subjects}
do
echo "Subject ${subject}"

cd ${rtpath}/${subject}/fMRI/
for session in `ls *leep*.nii*`
do
echo $session
pre=`echo ${session%????}`

cd ${rtpath1}/${subject}

rm -f $pre-volreg.nii.gz $pre-motion.1D
3dvolreg -verbose -tshift 0 -base ${rtpath}/${subject}/fMRI/$session"[10]" -1Dfile $pre-motion.1D \
-prefix $pre-volreg.nii.gz ${rtpath}/${subject}/fMRI/$session"[10..$]"

1dplot -jpeg $pre-motion.jpg $pre-motion.1D
done
done







rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"
rtpath1="/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/tSNR"

Subjects="sub3055"
N_delete="17"

Subjects="sub3100"
N_delete="15"

for subject in ${Subjects}
do
echo "Subject ${subject}"

cd ${rtpath}/${subject}/fMRI/
for session in `ls *leep2*.nii* `
do
echo $session
pre=`echo ${session%????}`

cd ${rtpath1}/${subject}

rm -f $pre-volreg.nii.gz $pre-motion.1D
3dvolreg -verbose -tshift 0 -base ${rtpath}/${subject}/fMRI/$session"[${N_delete}]" -1Dfile $pre-motion.1D \
-prefix $pre-volreg.nii.gz ${rtpath}/${subject}/fMRI/$session"[${N_delete}..$]"

1dplot -jpeg $pre-motion.jpg $pre-motion.1D
done
done

