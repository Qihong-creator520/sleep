%% for Fig. 4
%% scatter plot between sleep-related changes and two subcomponents of glucose metabolism

%% downsample for plot
clc;clear

% 5378 voxels
maskfile1 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/masks/CHCP_Yeo2011_6mm_mask.nii.gz'];
mask10 = load_nifti(maskfile1);
dim=size(mask10.vol);
mask1 = reshape(mask10.vol,[dim(1)*dim(2)*dim(3) 1]);

% mask of glycolysis from raichle
maskfile2 = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/raichle/mask_glycolysis_6mm.nii.gz'];
mask20 = load_nifti(maskfile2);
mask2 = reshape(mask20.vol,[dim(1)*dim(2)*dim(3) 1]);

mask12 = mask1.*mask2;


%% load sleep vs. wake contrast
outpath='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/ALFF_N2361/stats';
cd(outpath)
%%% lme
lmefile1 = ['lme_ALFF-ctx-z_2stages_age_gender_edu_N2361-s-v6.nii.gz'];
lme10 = load_nifti(lmefile1);
lme1 = reshape(lme10.vol,[dim(1)*dim(2)*dim(3) 11]);

beta1_mask = lme1(find(mask12>0),10); % Sleep vs. W




[beta_sorted, beta_order] = sort(beta1_mask);

beta_deciles = prctile(beta_sorted,1:1:99);
range= [min(beta_sorted) beta_deciles max(beta_sorted)+0.0001];




%% load glycolysis map from raichle's group
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/raichle
real(:,1)=load('cmro2_CHCP_Yeo2011_6mm.txt');
real(:,2)=load('glycolysis_CHCP_Yeo2011_6mm.txt');
real(:,3)=load('cmrglc_CHCP_Yeo2011_6mm.txt');


[r_real p]=corr(beta1_mask,real,'type','spearman');
% [r_real; p]
%     0.3893   -0.4371    0.0566
%     0.0000    0.0000    0.0001

%% load surrogate maps 
load surrogate_maps_glycolysis_CHCP_Yeo2011_6mm_resample.mat;

[r_surr p_surr]=corr(beta1_mask,surrogate_maps','type','spearman');

p1=mean((r_real(:,2))>(r_surr));
p2=p1;
p2(find(p2>0.5))=1-p2(find(p2>0.5))
% 0.0015


%% scatter plot
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
color=ROY_BIG_BL(256);
color=flipud(color);
color_deciles = prctile(1:1:256,100/99:100/99:9800/99);
color_range=floor([1 color_deciles 256]);


figure
set(gcf,'Units','Centimeters','position',[1 1 6 4])


for i = 1:100
    
    index = find(beta1_mask<range(102-i) & beta1_mask>=range(101-i));
    X_data = real(index,2);
    Y_data = beta1_mask(index);

    plot(X_data,Y_data,'o','MarkerSize',3,'MarkerEdgeColor',color(color_range(i),:),'MarkerFaceColor',color(color_range(i),:));hold on;

end

p = polyfit(real(:,2),beta1_mask,1);
yfit = polyval(p,real(:,2));
hold on;plot(real(:,2),yfit,'-w','LineWidth',1.5);


set(gca,'fontname','Arial','fontsize',7,'box','off','TickDir','out')
xlabel('Glycolysis ({\it{Z}})','fontname','Arial','fontsize',7);
ylabel('{\Delta} ALFF','fontname','Arial','fontsize',7);
set(gca,'XLim',[-3.5 2.8])
set(gca,'xtick',-2:2:2)
set(gca,'YLim',[-1.1 1.9])
set(gca, 'ytick',-1:1:1);

txt={'{\it{r}} = -0.44','{\it{P}} = 0.0015'};
t=text(-3.3,1.55,txt,'left');
t.FontSize=7;t.FontName='Arial';t.Color='k'


outpath = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/6_metabolism_alignment'];
cd(outpath)


print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['Sleep_W_ALFF_glycolysis_100deciles.pdf'];
movefile(oldname,newname);    

close all;



%% load surrogate maps 
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/raichle
load surrogate_maps_cmro2_CHCP_Yeo2011_6mm_resample.mat;

[r_surr p_surr]=corr(beta1_mask,surrogate_maps','type','spearman');

p1=mean((r_real(:,1))>(r_surr));
p2=p1;
p2(find(p2>0.5))=1-p2(find(p2>0.5))
% 0.0037




figure
set(gcf,'Units','Centimeters','position',[1 1 6 4])


for i = 1:100
    
    index = find(beta1_mask<range(102-i) & beta1_mask>=range(101-i));
    X_data = real(index,1);
    Y_data = beta1_mask(index);

    plot(X_data,Y_data,'o','MarkerSize',3,'MarkerEdgeColor',color(color_range(i),:),'MarkerFaceColor',color(color_range(i),:));hold on;

end

p = polyfit(real(:,1),beta1_mask,1);
yfit = polyval(p,real(:,1));
hold on;plot(real(:,1),yfit,'-w','LineWidth',1.5);


set(gca,'fontname','Arial','fontsize',7,'box','off','TickDir','out')
xlabel('Oxidative metabolism ({\it{Z}})','fontname','Arial','fontsize',7);
ylabel('{\Delta} ALFF','fontname','Arial','fontsize',7);
set(gca,'XLim',[-4.4 4.2])
set(gca,'xtick',-4:4:4)
set(gca,'YLim',[-1.1 1.9])
set(gca, 'ytick',-1:1:1);

txt={'{\it{r}} = 0.39','{\it{P}} = 0.0037'};
t=text(-4.1,1.55,txt,'left');
t.FontSize=7;t.FontName='Arial';t.Color='k'


outpath = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/6_metabolism_alignment'];
cd(outpath)


print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['Sleep_W_ALFF_oxidative_100deciles.pdf'];
movefile(oldname,newname);    

close all;




