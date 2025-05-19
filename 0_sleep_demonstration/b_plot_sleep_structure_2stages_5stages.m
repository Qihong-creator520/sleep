%% for Fig. 1
%% plot sleep-wake probability during the sleep EEG-fMRI scan 

clc;clear
figure
set(gcf,'Units','Centimeters','position',[0 0 7 4.5])
Colors=[156,197,217; 230,169,140; 162,42,49; 89,18,29; 52,100,165]./255;
Colors2=[156,197,217; mean([230,169,140; 162,42,49; 89,18,29; 52,100,165])]./255;

cd('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/0_sleep_demonstration');
load prob_stgs.txt
load N_subj.txt

x = 1:1:27;

prob_W = mean(reshape(prob_stgs(1,1:810),30,27),1);
probs_stgs = sum(prob_stgs(2:5,:),1);
prob_S = mean(reshape(probs_stgs(1:810),30,27),1);
N_subj1 = floor(mean(reshape(N_subj(1,1:810),30,27),1));

prob_N1 = mean(reshape(prob_stgs(2,1:810),30,27),1);
prob_N2 = mean(reshape(prob_stgs(3,1:810),30,27),1);
prob_N3 = mean(reshape(prob_stgs(4,1:810),30,27),1);
prob_REM = mean(reshape(prob_stgs(5,1:810),30,27),1);

[ax h1 h2] = plotyy(x, prob_W*100', x, N_subj1'); %W and N_subj
hold on;
h3 = plot(ax(1),x,prob_S*100','-','color',Colors2(2,:),'linewidth',1);%Sleep
hold on;N1=plot(prob_N1*100','-','color',Colors(2,:),'linewidth',1);%N1
hold on;N2=plot(prob_N2*100','-','color',Colors(3,:),'linewidth',1);%N2
hold on;N3=plot(prob_N3*100','-','color',Colors(4,:),'linewidth',1);%N3
hold on;REM=plot(prob_REM*100','-','color',Colors(5,:),'linewidth',1);%R

set(h1,'color',Colors2(1,:),'linewidth',1);%W
set(h2,'color',[0.7 0.7 0.7],'linewidth',1);%N_subj
set(N1,'color',Colors(2,:),'linewidth',1);%N1
set(N2,'color',Colors(3,:),'linewidth',1);%N2
set(N3,'color',Colors(4,:),'linewidth',1);%N3
set(REM,'color',Colors(5,:),'linewidth',1);%REM

set(ax(1),'Ylim',[0 125],'ytick',[0:50:100],'FontName','Arial','fontsize',7);
set(ax(2),'Ylim',[0 150],'ytick',[0:40:120],'FontName','Arial','fontsize',7);
set(ax(1),'Xlim',[0.5 27.5],'xtick',[4:4:24],'xticklabel',{'1','2','3','4','5','6'})
set(ax(2),'Xlim',[0.5 27.5],'xtick',[4:4:24],'xticklabel',{'1','2','3','4','5','6'})

ax(1).YColor = 'k';
ax(2).YColor = 'k';
xlabel('Time (hour)','FontName','Arial','fontsize',7);
ylabel(ax(1),'Probability (%)','FontName','Arial','fontsize',7);
ylabel(ax(2),'No. of participants','FontName','Arial','fontsize',7);

ax = gca;
ax.XAxis.Color = 'k';
set(gca,'FontName','Arial','fontsize',7,'box','off','Tickdir','out');

hl=legend([h1 h3 h2 N1 N2 N3 REM],'W','Sleep','Sample size','N1','N2','N3','REM','FontName','Arial','fontsize',7,'NumColumns',3);
set(hl,'Box','off');
hl.ItemTokenSize(1) = 4;

set(gca,'position',[0.13 0.17 0.75 0.78])


cd('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/0_sleep_demonstration');

print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['sleep_structure_probability_2stages_5stages_N_subjects_mean.pdf'];
movefile(oldname,newname);    

close all;

