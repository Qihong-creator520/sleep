
### stage by accsleep interaction
rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"
cd ${rtpath}/processed/ALFF_N2361


# with age, gender, edu as covariates
chmod +x 3dlmer_2stages_2bins_accsleep-age-gender-edu_ALFF-ctx-z-s-N2361.txt
./3dlmer_2stages_2bins_accsleep-age-gender-edu_ALFF-ctx-z-s-N2361.txt




###
### etimate clustersize using the same mask as 3dLMEr
cd ${rtpath}/processed/ALFF_N2361/stats
rm -f 3dFWHMx.1D*
rm -f resid_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s-CHCP_Yeo2011_2mm_mask.txt
3dFWHMx -dset resid_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s.nii.gz \
-mask ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-unif -acf \
> resid_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s-CHCP_Yeo2011_2mm_mask.txt


# the first row in the txt file represents FWHM
# the second row represents acf (three parameters), which is what we need
1d_tool.py -infile resid_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s-CHCP_Yeo2011_2mm_mask.txt -select_rows '1' \
-write resid_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s-CHCP_Yeo2011_2mm_mask_acf.txt


### acf parameters from resid_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s-CHCP_Yeo2011_2mm_mask_acf.txt
rm -f resid_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s-CHCP_Yeo2011_2mm_mask_3dClustSim.txt
3dClustSim -mask ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-acf 0.428718 5.06059 16.5561 -iter 10000 \
-prefix resid_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s-CHCP_Yeo2011_2mm_mask_3dClustSim.txt






###
rm -f lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake.nii.gz
3dcalc -prefix lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake.nii.gz \
-a lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s.nii.gz[11] \
-b lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s.nii.gz[13] \
-expr '(b-a)'


rm -f lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake-p001.nii.gz
3dcalc -prefix lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake-p001.nii.gz \
-a lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s.nii.gz[11] \
-b lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s.nii.gz[13] \
-c lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s.nii.gz[6] \
-expr '(b-a)*step(c-13.718)'


# read the minimum cluster size for uncorrected p < 0.001 and corrected p < 0.05 from:
# resid_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s-CHCP_Yeo2011_2mm_mask_3dClustSim.txt.NN2_1sided.1D
# cluster size is smaller than that of 2stage main effect, use the larger one for consistentency
rm -f lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake-correctp05.nii.gz
3dmerge -1thresh 0.00001 -dxyz=1 -1clust 1.5  131  \
-prefix lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake-correctp05.nii.gz \
lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake-p001.nii.gz


rm lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake-correctp05-FP.nii.gz
3dcalc -prefix lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake-correctp05-FP.nii.gz \
-a lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake-correctp05.nii.gz \
-b ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-c ${rtpath}/processed/masks/CHCP_Yeo7_2mm.nii.gz \
-expr 'equals(c,6)*b*a' 

rm lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-interact-FP.nii.gz
3dcalc -prefix lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-interact-FP.nii.gz \
-a lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s.nii.gz[6] \
-b ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-c ${rtpath}/processed/masks/CHCP_Yeo7_2mm.nii.gz \
-expr 'equals(c,6)*b*a*step(a-13.718)' 

rm lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake-correctp05-Vis.nii.gz
3dcalc -prefix lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake-correctp05-Vis.nii.gz \
-a lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-long-short-sleep-wake-correctp05.nii.gz \
-b ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-c ${rtpath}/processed/masks/CHCP_Yeo7_2mm.nii.gz \
-expr 'equals(c,1)*b*a' 

rm lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-interact-Vis.nii.gz
3dcalc -prefix lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep-interact-Vis.nii.gz \
-a lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s.nii.gz[6] \
-b ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-c ${rtpath}/processed/masks/CHCP_Yeo7_2mm.nii.gz \
-expr 'equals(c,1)*b*a*step(a-13.718)' 




### for scatter plots
rm -f lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s-v6.nii.gz
3dresample -dxyz 6 6 6 -prefix lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s-v6.nii.gz \
-inset lme_ALFF-ctx-z_2stages_2bins-N2361_accsleep_age_gender_edu-s.nii.gz

