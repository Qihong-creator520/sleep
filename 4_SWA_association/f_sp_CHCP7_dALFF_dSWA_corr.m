%% for Fig. 2
% scatter plots between network-level dALFF and dSWA

%% get data
clc;clear  

%% dSWA
outpath='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361/stats';
cd(outpath)
dSWA1 = load('all_SWAol_SW_all.1D');
Nsig = load('Nsig_dALFF_dSWAol_beta.1D');
[Nv, index] = sort(Nsig,'descend');
dSWA = nanmean(dSWA1(index(1:5),:),1);




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


%%% ALFF
ALFFfile1 = ['all_ALFF-ctx-z-v2_Sleep-Wake_all.nii.gz'];
ALFF10 = load_nifti(ALFFfile1);
ALFF1 = reshape(ALFF10.vol,[dim(1)*dim(2)*dim(3) 125]);



%% CHCP7
for roi = 1 : 7

    Y_data_mean(roi,:) = mean(ALFF1(mask12==roi,:),1);
    s = regstats(Y_data_mean(roi,:),dSWA,'linear',{'beta','tstat'});
    beta(1,roi) = s.beta(2);
    beta(2,roi) = s.beta(1);
    beta(3,roi) = s.tstat.pval(2);  
    [r_real p]=corr(Y_data_mean(roi,:)',dSWA','type','spearman');
    beta(4,roi) = r_real;  
    beta(5,roi) = p;  

end

CHCP7 = Y_data_mean';

Colors7=[120,18,134;70,130,180;0,118,14;196,58,250;220,248,164;230,148,34;205,62,78]./255;
%% colors for Vis, SM, DAN, VAN, Aud, FP, DMN

shown_yeo7=[6     7     3     4     1     5     2];

label={'Vis','SM','DAN','VAN','Aud','FP','DMN'};



figure
set(gcf,'Units','Centimeters','position',[1 1 17.5 5])

%% dSWA_dALFF

for ii = 1:7
    hold on;
    plot(dSWA+20*(ii-1),CHCP7(:,shown_yeo7(ii)),...,
            'o','MarkerSize',3,'MarkerEdgeColor',Colors7(shown_yeo7(ii),:),'MarkerFaceColor',Colors7(shown_yeo7(ii),:));hold on;
    
    yfit = polyval([beta(1,shown_yeo7(ii)) beta(2,shown_yeo7(ii))-20*(ii-1)*beta(1,shown_yeo7(ii))],dSWA+20*(ii-1));
    hold on;plot(dSWA+20*(ii-1),yfit,'--','color','k','LineWidth',1);
    
    txt=sprintf('$\\beta = %.4f$', beta(1,shown_yeo7(ii)));
    t=text(11+20*(ii-1),0.9,txt, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Interpreter', 'latex');
    t.FontSize=7;t.FontName='Arial';t.Color='k'

    txt1=label(shown_yeo7(ii));
    t1=text(8+20*(ii-1),1.05,txt1, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Interpreter', 'latex');
    t1.FontSize=7;t1.FontName='Arial';t1.Color='k'
end


set(gca,'fontname','Arial','fontsize',7,'box','off','TickDir','out')
ylabel('Network-level {\Delta}ALFF','fontname','Arial','fontsize',7);
xlabel(' {\Delta}SWA','fontname','Arial','fontsize',7);
set(gca,'XLim',[-5 135])
set(gca,'xtick',[-2 12 18 32 38 52 58 72 78 92 98 112 118 132],'xticklabel',{'-2','12','-2','12','-2','12','-2','12','-2','12','-2','12','-2','12'},'FontName','Arial','fontsize',7,'Tickdir','out')
set(gca,'YLim',[-0.55 1.2],'ytick',[-0.5:0.5:1])
set(gca,'looseInset',[0.05 0.02 0.05 0.02])


hold on
plot([-5 -2.5],[-0.55 -0.55],'-','color','w','LineWidth',1);
hold on
plot([13 17.5],[-0.55 -0.55],'-','color','w','LineWidth',1);
hold on
plot([33 37.5],[-0.55 -0.55],'-','color','w','LineWidth',1);
hold on
plot([53 57.5],[-0.55 -0.55],'-','color','w','LineWidth',1);
hold on
plot([73 77.5],[-0.55 -0.55],'-','color','w','LineWidth',1);
hold on
plot([93 97.5],[-0.55 -0.55],'-','color','w','LineWidth',1);
hold on
plot([113 117.5],[-0.55 -0.55],'-','color','w','LineWidth',1);
hold on
plot([133 135],[-0.55 -0.55],'-','color','w','LineWidth',1);



outpath = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/4_SWA_association'];
cd(outpath)

print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['dALFF_dSWAol_CHCP7_N125.pdf'];
movefile(oldname,newname);    

close all;






