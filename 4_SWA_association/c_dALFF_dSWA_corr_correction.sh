###
rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"

###
### etimate clustersize using the same mask as 3dLMEr
cd ${rtpath}/processed/ALFF_N2361/stats
rm -f 3dFWHMx.1D*
rm -f all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid_top5-CHCP_Yeo2011_2mm_mask.txt
3dFWHMx -dset all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid_top5.nii.gz \
-mask ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-detrend -unif -acf \
> all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid_top5-CHCP_Yeo2011_2mm_mask.txt


# the first row in the txt file represents FWHM
# the second row represents acf (three parameters), which is what we need
1d_tool.py -infile all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid_top5-CHCP_Yeo2011_2mm_mask.txt -select_rows '1' \
-write all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid_top5-CHCP_Yeo2011_2mm_mask_acf.txt


### acf parameters from all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid_top5-CHCP_Yeo2011_2mm_mask_acf.txt
rm -f all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid_top5-CHCP_Yeo2011_2mm_mask_3dClustSim.txt
3dClustSim -mask ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-acf 0.43354 5.3239 17.1829 -iter 10000 \
-prefix all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid_top5-CHCP_Yeo2011_2mm_mask_3dClustSim.txt



rm -f all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top5-p001.nii.gz
3dcalc -prefix all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top5-p001.nii.gz \
-a all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top5.nii.gz[0] \
-b all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top5.nii.gz[1] \
-expr 'a*step(0.001-b)'



# read the minimum cluster size for uncorrected p < 0.001 and corrected p < 0.05 from:
# all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid_top5-CHCP_Yeo2011_2mm_mask_3dClustSim.txt.NN2_2sided.1D
# to show corrected contours
rm -f all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top5-correctp05.nii.gz
3dmerge -1thresh 0.00001 -dxyz=1 -1clust 1.5  120  \
-prefix all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top5-correctp05.nii.gz \
all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top5-p001.nii.gz



### to show orginal beta map
rm -f all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top50.nii.gz
3dcalc -prefix all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top50.nii.gz \
-a all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top5.nii.gz[0] \
-expr 'a'


### for scatter plots
rm -f all_ALFF-v6_Sleep-Wake_all_SWAol_SW_all_beta_top5.nii.gz
3dresample -dxyz 6 6 6 -prefix all_ALFF-v6_Sleep-Wake_all_SWAol_SW_all_beta_top5.nii.gz \
-inset all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top5.nii.gz



###
rtpath="/nd_disk2/qihong/Sleep_PKU/brain_restoration"

###
### etimate clustersize using the same mask as 3dLMEr
cd ${rtpath}/processed/ALFF_N2361/stats
rm -f 3dFWHMx.1D*
rm -f all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid-CHCP_Yeo2011_2mm_mask.txt
3dFWHMx -dset all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid.nii.gz \
-mask ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-detrend -unif -acf \
> all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid-CHCP_Yeo2011_2mm_mask.txt


# the first row in the txt file represents FWHM
# the second row represents acf (three parameters), which is what we need
1d_tool.py -infile all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid-CHCP_Yeo2011_2mm_mask.txt -select_rows '1' \
-write all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid-CHCP_Yeo2011_2mm_mask_acf.txt


### acf parameters from all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid-CHCP_Yeo2011_2mm_mask_acf.txt
rm -f all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid-CHCP_Yeo2011_2mm_mask_3dClustSim.txt
3dClustSim -mask ${rtpath}/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz \
-acf 0.433893 5.32477 17.1844 -iter 10000 \
-prefix all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid-CHCP_Yeo2011_2mm_mask_3dClustSim.txt



rm -f all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta-p001.nii.gz
3dcalc -prefix all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta-p001.nii.gz \
-a all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta.nii.gz[0] \
-b all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta.nii.gz[1] \
-expr 'a*step(0.001-b)'



# read the minimum cluster size for uncorrected p < 0.001 and corrected p < 0.05 from:
# all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid-CHCP_Yeo2011_2mm_mask_3dClustSim.txt.NN2_2sided.1D
# to show corrected contours
rm -f all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta-correctp05.nii.gz
3dmerge -1thresh 0.00001 -dxyz=1 -1clust 1.5  125  \
-prefix all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta-correctp05.nii.gz \
all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta-p001.nii.gz



### to show orginal beta map
rm -f all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta0.nii.gz
3dcalc -prefix all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta0.nii.gz \
-a all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta.nii.gz[0] \
-expr 'a'


### for scatter plots
rm -f all_ALFF-v6_Sleep-Wake_all_SWAol_SW_all_beta.nii.gz
3dresample -dxyz 6 6 6 -prefix all_ALFF-v6_Sleep-Wake_all_SWAol_SW_all_beta.nii.gz \
-inset all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta.nii.gz

