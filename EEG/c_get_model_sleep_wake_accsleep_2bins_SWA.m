%% get 2 stage by 2 bin model for SWA
clc;clear
%% get model
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/
Model_wake_pre=readtable('Model_sleep_wake_wake_pre.txt');
Model_N2231=readtable('Model_sleep_wake_N2231.txt');
Model_N2231.Properties.VariableNames=Model_wake_pre.Properties.VariableNames;
Model_all=[Model_wake_pre; Model_N2231];


clear stage_n1
for jj = 1:length(Model_wake_pre.Var6)
    stage_n1{jj,1}='wake';
end

for jj = length(Model_wake_pre.Var6)+1:length(Model_wake_pre.Var6)+length(Model_N2231.Var6)

    if ~strcmp(table2cell(Model_N2231(jj-length(Model_wake_pre.Var6),6)), 'stage0')
        stage_n1{jj,1}='sleep';
    else
        stage_n1{jj,1}='wake';
    end
end


clear Model_sleep_wake_accsleep*
Model_sleep_wake_accsleep1=table(table2cell(Model_all(:,1)), ...,
                                                   table2array(Model_all(:,2)), ...,
                                                   table2cell(Model_all(:,3)), ...,
                                                   table2array(Model_all(:,4)), ...,
                                                   table2array(Model_all(:,5)), ...,
                                                   table2cell(Model_all(:,8)), ...,
                                                   stage_n1, table2cell(Model_all(:,7)));



SWAo_N2231=load('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/SWAo_N2231_nnn.txt');
SWAo_wake_pre=load('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/SWAo_N130_nnn.txt');
SWAo_all=(15-1).*[SWAo_wake_pre; SWAo_N2231]; % sum over SWA range
SWAol_all = 10*log10(SWAo_all); % log-transformed


%%
clear e
e=array2table([SWAol_all]);
for ii=1:size(e,2)
    e.Properties.VariableNames{ii} = ['SWAol_all_' num2str(ii,'%02d')];
end

clear Model_sleep_wake_accsleep
Model_sleep_wake_accsleep = [Model_sleep_wake_accsleep1 e];



cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
writetable(Model_sleep_wake_accsleep,['Model_sleep_wake_accsleep_2bins_SWAol.txt'],'Delimiter',',')



%%
% run R



clc;clear
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
color=ROY_BIG_BL(256);
color_pos = color(129:256,:);
color_neg = color(1:128,:);

load('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/locs_n.mat');




%% topoplot for Fig. 2a
SWAol_all_2stages = readtable('out_sleep_wake_2stages_SWAol.csv');
length(table2array(SWAol_all_2stages(2,:)) < 0.001*52) % 52
%% F map
[min(table2array(SWAol_all_2stages(1,:))) max(table2array(SWAol_all_2stages(1,:)))]
figure
set(gcf,'Units','Centimeters','position',[1 1 5 4.5])
topoplot(table2array(SWAol_all_2stages(1,:)),k,'maplimits',[0 500]);
% title('Main effect of stage on SWA','FontSize',7,'FontName','Arial');
colormap(color_pos)
cb = colorbar;
set(gca,'position',[0.03 0.05 0.72 0.90])
cb.Position = [0.80 0.15 0.045 0.6];
outpath = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/4_SWA_association'];
cd(outpath)

print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['Fmap_SWAol.pdf'];
movefile(oldname,newname);    

close all;


%% topoplot for Fig. 2b
%% contrast maps 9
[min(table2array(SWAol_all_2stages(9,:))) max(table2array(SWAol_all_2stages(9,:)))]
figure
set(gcf,'Units','Centimeters','position',[1 1 5 4.5])
topoplot(table2array(SWAol_all_2stages(9,:)),k,'maplimits',[0 5]);
colormap(color_pos)
cb = colorbar;
set(gca,'position',[0.03 0.05 0.72 0.90])
cb.Position = [0.80 0.15 0.045 0.6];

outpath = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/4_SWA_association'];
cd(outpath)

print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['contrast_map_SWAol.pdf'];
movefile(oldname,newname);    

close all;






%% F map interaction
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
SWAol_all_2stages_2bins = readtable('out_sleep_wake_2stages_accsleep_2bins_SWAol.csv');

length(find(table2array(SWAol_all_2stages_2bins(2,:))*52<0.05))
%% 2stages x 2bins: 52 channels out of 52 were significant: p*52 < 0.05, same as the fMRI analyses, adopted
[min(table2array(SWAol_all_2stages_2bins(1,:))) max(table2array(SWAol_all_2stages_2bins(1,:)))]


%% topoplot for Fig. 3a
%% contrast diff maps
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
color=SPECTRAL(256);
color_pos = color(129:256,:);
color_neg = color(1:128,:);

min((table2array(SWAol_all_2stages_2bins(8,:))-table2array(SWAol_all_2stages_2bins(7,:))))
max((table2array(SWAol_all_2stages_2bins(8,:))-table2array(SWAol_all_2stages_2bins(7,:))))
figure
set(gcf,'Units','Centimeters','position',[1 1 5 4.5])
topoplot((table2array(SWAol_all_2stages_2bins(8,:))-table2array(SWAol_all_2stages_2bins(7,:))),k,'maplimits',[-3 0]);
% title('\DeltaSWA_AFS vs. \DeltaSWA_WFS');
colormap(color_neg)
cb = colorbar;
set(gca,'position',[0.03 0.05 0.72 0.90])
cb.Position = [0.80 0.15 0.045 0.6];

outpath = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/5_sleep_homeostasis'];
cd(outpath)

print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['accsleep_dSWA_AFS_WFS_topo.pdf'];
movefile(oldname,newname);    

close all;





%% contrast comparison
s_real = regstats(table2array(SWAol_all_2stages_2bins(8,:)),table2array(SWAol_all_2stages_2bins(7,:)),'linear',{'beta','tstat'}); % real beta
s_real.beta
%    -1.6588
%     0.9281
s_real.tstat.pval

s_1 = regstats(table2array(SWAol_all_2stages_2bins(8,:))-table2array(SWAol_all_2stages_2bins(7,:)),table2array(SWAol_all_2stages_2bins(7,:)),'linear',{'beta','tstat'}); % compared to beta = 1 
s_1.tstat.pval(2)
%    0.0080


% Fig. 3b
figure
set(gcf,'Units','Centimeters','position',[1 1 5.5 5.5])

plot(table2array(SWAol_all_2stages_2bins(7,:)),table2array(SWAol_all_2stages_2bins(7,:)),'-','LineWidth',1.5,'Color',[0.7 0.7 0.7]);
hold on;plot(table2array(SWAol_all_2stages_2bins(7,:)),table2array(SWAol_all_2stages_2bins(8,:)),'ko','MarkerSize',3)
p = polyfit(table2array(SWAol_all_2stages_2bins(7,:)),table2array(SWAol_all_2stages_2bins(8,:)),1);
yfit = polyval(p,table2array(SWAol_all_2stages_2bins(7,:)));
hold on;plot(table2array(SWAol_all_2stages_2bins(7,:)),yfit,'-k','LineWidth',1.5);
set(gca,'fontname','Arial','fontsize',7,'box', 'off', 'TickDir', 'out')
xlabel('\DeltaSWA_WFS','fontname','Arial','fontsize',7);
ylabel('\DeltaSWA_AFS','fontname','Arial','fontsize',7);
xlim([3 7.9]);


txt={'{\it{y}} = -1.66 + 0.93{\it{x}}'}; %
t=text(5.2,2.5,txt,'left');
t.FontSize=7;t.FontName='Arial';t.Color='k'

txt={'{\it{y}} = {\it{x}}'}; %
t=text(4.8,6.0,txt,'left');
t.FontSize=7;t.FontName='Arial';t.Color=[0.7 0.7 0.7]


outpath = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/5_sleep_homeostasis'];
cd(outpath)

print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['accsleep_dSWA_AFS_WFS_sp.pdf'];
movefile(oldname,newname);    

close all;


