### for Fig. 4
### generate surface maps for two subcomponents of glucose metabolism
### 
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF/stats/
cp /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_v202410/raichle/glycolysis_z.nii.gz .
cp /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_v202410/raichle/cmro2_z.nii.gz .
cp /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_v202410/raichle/cmrglc_z.nii.gz .



cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF/stats/for_wb

for data in glycolysis_z cmro2_z cmrglc_z ; do
# map volume to surface
wb_command -volume-to-surface-mapping ../${data}.nii.gz Conte69.L.midthickness.32k_fs_LR.surf.gii ./${data}.Conte69.l.func.gii -enclosing

wb_command -volume-to-surface-mapping ../${data}.nii.gz Conte69.R.midthickness.32k_fs_LR.surf.gii ./${data}.Conte69.r.func.gii -enclosing 


# transform to a cifti file
wb_command -cifti-create-dense-scalar ${data}.Conte69.l.dscalar.nii -left-metric ${data}.Conte69.l.func.gii 
wb_command -cifti-create-dense-scalar ${data}.Conte69.r.dscalar.nii -right-metric ${data}.Conte69.r.func.gii 

done

# sudo usermod -s /bin/bash qihong

# mask out subcortical
infolder='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF/stats/for_wb';
outfolder='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF/stats/for_wb';
mask_path='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks';
python_path='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF/stats/for_wb';
cd ${outfolder}

for data in glycolysis_z cmro2_z cmrglc_z ; do
   for hemi in l r ; do

    indata_name=${data}.Conte69.${hemi}.dscalar.nii;
    outdata_name=${data}.Conte69.${hemi}.mask.func.gii;
    mask_name=iter15.thickness.${hemi}.AVERAGE.shape.gii;
    temp_name=${data}.Conte69.${hemi}.func.gii

  
    python3 /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_v202410/plot_surface/test.py ${infolder} ${indata_name} ${outfolder} ${outdata_name} ${mask_path} ${mask_name} ${temp_name}

  done
done



###
# combine left and right hemi
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF/stats/for_wb
for data in glycolysis_z cmro2_z cmrglc_z ; do
wb_command -cifti-create-dense-scalar ${data}.Conte69.mask.dscalar.nii -left-metric ${data}.Conte69.l.mask.func.gii -right-metric ${data}.Conte69.r.mask.func.gii
done

rm -f *.l.* *.r.*





