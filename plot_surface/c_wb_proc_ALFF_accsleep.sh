### for Fig. 3
### generate surface maps for sleep-promoted brain restoration
### 
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361

for data in accsleep-long-short-sleep-wake accsleep-long-short-sleep-wake-correctp05 ; do

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361/stats/for_wb
# map volume to surface
wb_command -volume-to-surface-mapping ../lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.nii.gz Conte69.L.midthickness.32k_fs_LR.surf.gii ./lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.Conte69.l.func.gii -enclosing

wb_command -volume-to-surface-mapping ../lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.nii.gz Conte69.R.midthickness.32k_fs_LR.surf.gii ./lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.Conte69.r.func.gii -enclosing  


# transform to a cifti file
wb_command -cifti-create-dense-scalar lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.Conte69.l.dscalar.nii -left-metric lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.Conte69.l.func.gii 
wb_command -cifti-create-dense-scalar lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.Conte69.r.dscalar.nii -right-metric lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.Conte69.r.func.gii 
done


# mask out subcortical
infolder='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361/stats/for_wb';
outfolder='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361/stats/for_wb';
mask_path='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks';
python_path='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361/stats/for_wb';
cd ${outfolder}

for data in accsleep-long-short-sleep-wake accsleep-long-short-sleep-wake-correctp05 ; do
   for hemi in l r ; do

    indata_name=lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.Conte69.${hemi}.dscalar.nii;
    outdata_name=lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.Conte69.${hemi}.mask.func.gii;
    mask_name=iter15.thickness.${hemi}.AVERAGE.shape.gii;
    temp_name=lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.Conte69.${hemi}.func.gii
  
    python3 /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_v202410/plot_surface/test.py ${infolder} ${indata_name} ${outfolder} ${outdata_name} ${mask_path} ${mask_name} ${temp_name}

  done
done



###
# combine left and right hemi
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361/stats/for_wb
for data in accsleep-long-short-sleep-wake accsleep-long-short-sleep-wake-correctp05 ; do
wb_command -cifti-create-dense-scalar lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.Conte69.mask.dscalar.nii -left-metric lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.Conte69.l.mask.func.gii -right-metric lme_ALFF-ctx-z_2stages_2bins-N2361_${data}.Conte69.r.mask.func.gii
done

rm -f *.l.* *.r.*

