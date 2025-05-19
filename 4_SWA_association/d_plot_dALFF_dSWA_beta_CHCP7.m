%% for Fig. 2
%% violin plot of inter-individual dALFF-dSWA correlation in 7 canonical networks

clc;clear

% mask used for the main analysis
maskfile1 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/CHCP_Yeo2011_2mm_mask.nii.gz'];
mask10 = load_nifti(maskfile1);
dim=size(mask10.vol);
mask1 = reshape(mask10.vol,[dim(1)*dim(2)*dim(3) 1]);


% mask from CHCP
maskfile2 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/CHCP_Yeo7_2mm.nii.gz'];
mask20 = load_nifti(maskfile2);
dim=size(mask20.vol);
mask2 = reshape(mask20.vol,[dim(1)*dim(2)*dim(3) 1]);


mask12 = (mask1>0).*mask2;


%% for plot
outpath='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361/stats';
cd(outpath)
%% lme
lmefile1 = ['all_ALFF-v2_Sleep-Wake_all_SWAol_SW_all_beta_top5.nii.gz'];
lme10 = load_nifti(lmefile1);
lme1 = reshape(lme10.vol,[dim(1)*dim(2)*dim(3) 2]);


beta=lme1(:,1);

for roi = 1 : 7

    Y_data{1,roi} = beta(mask12==roi,1);
    Y_data_mean(roi) = mean(beta(mask12==roi,:),1);

end

%% sorted by average beta values in CHCP7
% [tmp order_yeo7] = sort(Y_data_mean,'ascend');
order_yeo7 = [6     7     3     4     1     5     2];

label={'Vis','SM','DAN','VAN','Aud','FP','DMN'};



figure
set(gcf,'Units','Centimeters','position',[1 1 6 5.5])
hold on;
plot(0:8,zeros(1,9),'--','color',[0.8 0.8 0.8],'linewidth',1);

%% first config gretna_plot_violin 'Color' as colors for the reordered 7 networks
%% then run
gretna_plot_violin(Y_data(order_yeo7),label(order_yeo7),{' '},'meanstdfill')

set(gca,'FontName','Arial','fontsize',7,'Tickdir','out')
set(gca,'Ylim',[-0.035 0.065],'ytick',[-0.02:0.02:0.06])
ylabel('{\beta}','FontName','Arial','fontsize',7,'Rotation',0)
legend('off')

set(gca,'xtick',1:1:7,'xticklabel',label(order_yeo7))
set(gca,'looseInset',[0.05 0.02 0 0.02])
legend('off')

outpath = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/4_SWA_association'];
cd(outpath)


print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['dALFF_dSWAol_beta_CHCP7.pdf'];
movefile(oldname,newname);    

close all;



