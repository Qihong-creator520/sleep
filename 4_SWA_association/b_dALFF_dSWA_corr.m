
%% low-res for each of 52 channels
clc;clear
load('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/locs_n.mat');

%% dSWA
outpath='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361/stats';
cd(outpath)
dSWA = load('all_SWAol_SW_all.1D');

%% mask used for the main analysis
maskfile1 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/CHCP_Yeo2011_6mm_mask.nii.gz'];
mask10 = load_nifti(maskfile1);
dim=size(mask10.vol);
mask1 = reshape(mask10.vol,[dim(1)*dim(2)*dim(3) 1]);
mask1(mask1>0)=1;

%% mask of gradient1 from Daniel S. Margulies PNAS 2016
maskfile2 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Gradients_Margulies2016/volumes/masks/grad_1/sum_All20-6mm.nii.gz'];
mask20 = load_nifti(maskfile2);
mask2 = reshape(mask20.vol,[dim(1)*dim(2)*dim(3) 1]);

mask12 = mask1.*mask2;


%% load gradient1 from Daniel S. Margulies PNAS 2016
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Gradients_Margulies2016/volumes
real=load('grad1_CHCP_Yeo2011_6mm.txt');
load surrogate_maps_grad1_CHCP_Yeo2011_6mm_resample.mat;



%% dALFF
cd(outpath)
ALFFfile1 = ['all_ALFF-ctx-z-v6_Sleep-Wake_all.nii.gz'];
ALFF10 = load_nifti(ALFFfile1);
ALFF1 = reshape(ALFF10.vol,[dim(1)*dim(2)*dim(3) 125]);
ALFF1_mask = ALFF1(find(mask12>0),:);

for ss = 1:size(dSWA,1)
    disp(k(ss).labels)
    

    clear s beta_all resid
    for kkk = 1:sum(mask12)
        kkk
        s = regstats(ALFF1_mask(kkk,:),dSWA(ss,:),'linear',{'beta','tstat','r'});
        beta_all(kkk,1) = s.beta(2);
        beta_all(kkk,2) = s.tstat.pval(2);
        resid(kkk,:) = s.r;
    end
    
    
    Nsig_dALFF_dSWA_beta (ss,1) = sum(beta_all(:,2)<0.001);

    save Nsig_dALFF_dSWAol_beta.1D Nsig_dALFF_dSWA_beta '-ascii'


end




%% topoplot
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
color=COOL_WARM(256);
color=flipud(color);
color_pos = color(129:256,:);
color_neg = color(1:128,:);

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361/stats
load Nsig_dALFF_dSWAol_beta.1D

%% 
[min(Nsig_dALFF_dSWAol_beta) max(Nsig_dALFF_dSWAol_beta)]
% 6x6x6 mm3
%   139   458
figure
% 2x2x2 mm3
set(gcf,'Units','Centimeters','position',[1 1 5 4.5])
topoplot(Nsig_dALFF_dSWAol_beta(:,1)*27,k,'maplimits',[0 10000]);
% title('No. of voxels with significant association');
colormap(color_pos)
cb = colorbar;
set(gca,'position',[0.03 0.05 0.72 0.90])
cb.Position = [0.77 0.15 0.045 0.6];

outpath = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/4_SWA_association'];
cd(outpath)

print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['Nsig_corr_SWAol.pdf'];
movefile(oldname,newname);    

close all;




%% get voxel-wise regression beta values between dALFF and dSWA
%% also save residuals for cluster size estimation in afni
clc;clear
load('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/locs_n.mat');

%% dSWA
outpath='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361/stats';
cd(outpath)
dSWA1 = load('all_SWAol_SW_all.1D');
Nsig = load('Nsig_dALFF_dSWAol_beta.1D');
[Nv, index] = sort(Nsig,'descend');
dSWA = nanmean(dSWA1(index(1:5),:),1);

%% mask used for the main analysis
maskfile1 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz'];
mask10 = load_nifti(maskfile1);
dim=size(mask10.vol);
mask1 = reshape(mask10.vol,[dim(1)*dim(2)*dim(3) 1]);
mask1(mask1>0)=1;

% mask of gradient1 from Daniel S. Margulies PNAS 2016
maskfile2 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Gradients_Margulies2016/volumes/masks/grad_1/sum_All20.nii.gz'];
mask20 = load_nifti(maskfile2);
mask2 = reshape(mask20.vol,[dim(1)*dim(2)*dim(3) 1]);

mask12 = mask1.*mask2;


%% load gradient1 from Daniel S. Margulies PNAS 2016
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Gradients_Margulies2016/volumes
pg1file = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Gradients_Margulies2016/volumes/volume.grad_1.MNI2mm.nii.gz'];
pg10 = load_nifti(pg1file);
pg1 = reshape(pg10.vol,[dim(1)*dim(2)*dim(3) 1]);
pg1_mask = pg1(find(mask12>0),:); % pg1



%% dALFF
cd(outpath)
ALFFfile1 = ['all_ALFF-ctx-z-v2_Sleep-Wake_all.nii.gz'];
ALFF10 = load_nifti(ALFFfile1);
ALFF1 = reshape(ALFF10.vol,[dim(1)*dim(2)*dim(3) 125]);
ALFF1_mask = ALFF1(find(mask12>0),:);


for ss = 1:1


    clear s beta_all resid
    for kkk = 1:length(find(mask12>0))
        kkk
        s = regstats(ALFF1_mask(kkk,:),dSWA(ss,:),'linear',{'beta','tstat','r'});
        beta_all(kkk,1) = s.beta(2);
        beta_all(kkk,2) = s.tstat.pval(2);
        resid(kkk,:) = s.r;
    end
    
    
    Nsig_dALFF_dSWA_beta (ss,1) = sum(beta_all(:,2)<0.001);

    %% save beta map
    %% 
    cd(outpath)
    resultsmap = ALFF10;
    
    results1 = zeros(dim(1)*dim(2)*dim(3), 2);
    results1(mask12>0,:) = beta_all;
    
    resultsmap.vol = reshape(results1,[dim(1) dim(2) dim(3) 2]);
    resultsfile= ['all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top5.nii.gz'];
    err = save_nifti(resultsmap,resultsfile);
    
    
    %% save residual map for cluster size estimation
    %%
    residmap = ALFF10;
    
    resid1 = zeros(dim(1)*dim(2)*dim(3), 125);
    resid1(mask12>0,:) = resid;
    
    residmap.vol = reshape(resid1,[dim(1) dim(2) dim(3) 125]);
    residfile= ['all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_resid_top5.nii.gz'];
    err = save_nifti(residmap,residfile);


    save Nsig_dALFF_dSWAol_beta_top5.1D Nsig_dALFF_dSWA_beta '-ascii'

end






