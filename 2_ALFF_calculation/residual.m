function residual(rtpath,session,nuisance_regressors)

subj=session;

cd(rtpath);

for x = 1:length(subj{1})
    disp( strtrim(subj{1}{x}) )
    path = [rtpath '/' strtrim(subj{1}{x}) '/'];
        cd(path);
        datafile = [strtrim(subj{1}{x}) '-volreg_MNI_bbr-dt.nii.gz'];
        data = load_nifti(datafile);
        dim=size(data.vol);
        nt=dim(4);
        data1=reshape(data.vol,[dim(1)*dim(2)*dim(3) dim(4)]);
            
        maskfile = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/MNI152_T1_2mm_brain_mask_dil1_n.nii.gz'];
        mask = load_nifti(maskfile);
        mask1 = reshape(mask.vol,[size(mask.vol,1)*size(mask.vol,2)*size(mask.vol,3) 1]);
            
        data_mask1=data1(find(mask1),:);
        data_mask1=data_mask1';
        data_mask=data_mask1;
             
        desnmatrix = load(nuisance_regressors);
            
        for i = 1:size(data_mask,2)
            resp = data_mask(:,i);
            s = regstats(resp,desnmatrix,'linear',{'r'});
            residual_mask(:,i) = s.r;
        end
        
        residual = zeros(size(data1'));
        
        residual(:,find(mask1))=residual_mask;
        residual(:,find(mask1==0))=0;
        residual = reshape(residual',[dim(1) dim(2) dim(3) nt]);
        
        cd(path);
        %%% 
        residualmap = data;
        residualmap.vol = residual;
        residualfile= [path subj{1}{x} '-volreg_MNI_bbr-dt-noGSR-residual.nii.gz'];
        err = save_nifti(residualmap,residualfile);
end

            
