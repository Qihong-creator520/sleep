rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration/"
rtpath1="/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/tSNR/"


Subjects=`cat ${rtpath}/Sleep_EEG_fMRI-main_R1/Subjects_N130.txt`

for subject in ${Subjects}
do
echo "Subject ${subject}"

cd ${rtpath1}
mkdir ${subject}

cd ${rtpath}/${subject}/fMRI/
for session in `ls *leep*.nii*`
do
echo $session
cd ${rtpath}/${subject}/fMRI/

Duration=`3dinfo $session | grep "time steps" | sed 's/^.* steps = //g' |sed 's/  Time step = 2.00000s  Origin = 0.00000s//g'`
echo $Duration

# the first 10 volumes need to be removed 
Nsession_5min=$(echo "scale=0; (${Duration}-10)/150"|bc)
echo $Nsession_5min

for run in {1..27}
do

if [ ${run} -le $Nsession_5min ]
then

echo $run
onset=$(echo "scale=0; (${run}-1)*150+10"|bc); echo "onset ${onset}"
#the last volume of this session, session length = 150
end=$(echo "scale=0; ${onset}+149"|bc); echo "end ${end}"
name=`printf "%02d" $run`
pre=`echo ${session%????}`

cd ${rtpath1}/${subject}
rm -f $pre-${name}.nii.gz
3dcalc -prefix $pre-${name}.nii.gz -a ${rtpath}/${subject}/fMRI/$session"[${onset}-${end}]" -expr 'a'
rm -f $pre-${name}-dt.nii.gz
3dDeconvolve -input \
$pre-${name}.nii.gz \
-polort 1 -float -errts $pre-${name}-dt.nii.gz -bucket bucket
rm -f bucket* 3dDeconvolve.err 

rm -f $pre-${name}-mask.nii.gz
3dAutomask -prefix $pre-${name}-mask.nii.gz \
$pre-${name}.nii.gz

rm -f $pre-${name}-mean.nii.gz
3dTstat -mean -prefix $pre-${name}-mean.nii.gz $pre-${name}.nii.gz

rm -f $pre-${name}-dt-std.nii.gz
3dTstat -stdev -prefix $pre-${name}-dt-std.nii.gz $pre-${name}-dt.nii.gz

rm -f $pre-${name}-tSNR.nii.gz
3dcalc -prefix $pre-${name}-tSNR.nii.gz \
-a $pre-${name}-mean.nii.gz \
-b $pre-${name}-dt-std.nii.gz -expr 'a/b'

3dmaskave -mask $pre-${name}-mask.nii.gz -q $pre-${name}-tSNR.nii.gz >> $pre-tSNR.txt
fi

rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration/"
done
done
done






rtpath1="/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/tSNR/"

Subjects="sub3055"
N_delete="17"
# the first 10, plus additional 7 volumes to be excluded to match EEG for the 2nd sleep session

Subjects="sub3100"
N_delete="15"
# the first 10, plus additional 5 volumes to be excluded to match EEG for the 2nd sleep session

for subject in ${Subjects}
do
echo "Subject ${subject}"

cd ${rtpath1}
mkdir ${subject}

cd ${rtpath}/${subject}/fMRI/
for session in `ls *leep2.nii*`
do
echo $session
cd ${rtpath}/${subject}/fMRI/

Duration=`3dinfo $session | grep "time steps" | sed 's/^.* steps = //g' |sed 's/  Time step = 2.00000s  Origin = 0.00000s//g'`
echo $Duration

Nsession_5min=$(echo "scale=0; (${Duration}-${N_delete})/150"|bc)
echo $Nsession_5min

for run in {1..27}
do

if [ ${run} -le $Nsession_5min ]
then

echo $run
onset=$(echo "scale=0; (${run}-1)*150+${N_delete}"|bc); echo "onset ${onset}"
#the last volume of this session, session length = 150
end=$(echo "scale=0; ${onset}+149"|bc); echo "end ${end}"
name=`printf "%02d" $run`
pre=`echo ${session%????}`

cd ${rtpath1}/${subject}
rm -f $pre-${name}.nii.gz
3dcalc -prefix $pre-${name}.nii.gz -a ${rtpath}/${subject}/fMRI/$session"[${onset}-${end}]" -expr 'a'
rm -f $pre-${name}-dt.nii.gz
3dDeconvolve -input \
$pre-${name}.nii.gz \
-polort 1 -float -errts $pre-${name}-dt.nii.gz -bucket bucket
rm -f bucket* 3dDeconvolve.err 

rm -f $pre-${name}-mask.nii.gz
3dAutomask -prefix $pre-${name}-mask.nii.gz \
$pre-${name}.nii.gz

rm -f $pre-${name}-mean.nii.gz
3dTstat -mean -prefix $pre-${name}-mean.nii.gz $pre-${name}.nii.gz

rm -f $pre-${name}-dt-std.nii.gz
3dTstat -stdev -prefix $pre-${name}-dt-std.nii.gz $pre-${name}-dt.nii.gz

rm -f $pre-${name}-tSNR.nii.gz
3dcalc -prefix $pre-${name}-tSNR.nii.gz \
-a $pre-${name}-mean.nii.gz \
-b $pre-${name}-dt-std.nii.gz -expr 'a/b'

3dmaskave -mask $pre-${name}-mask.nii.gz -q $pre-${name}-tSNR.nii.gz >> $pre-tSNR.txt
fi

done
done
done





