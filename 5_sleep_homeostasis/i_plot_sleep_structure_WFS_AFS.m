%% for fig. S2
%% plot sleep structure of a representative participant as well as the sleep-wake history

clc;clear
Color_5stages=[156,197,217; 230,169,140; 162,42,49; 89,18,29; 52,100,165]./255;
% colors for early and late
colormap1 = SPECTRAL(256); % Colormap 
Colors2=colormap1([150,210],:);

stagename = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/sub3117/stages/sub3117_sleep1.txt'];
    
stage_a  = load(stagename);
xlabels={'0', '0.5', '1', '1.5', '2', '2.5', '3', '3.5', '4', '4.5', '5', '5.5', '6'};

figure
set(gcf,'Units','Centimeters','position',[1 1 11 5])

%%
sleep_stage=repmat(floor(stage_a),1,5);
subplot('position',[0.06    0.26    0.92    0.04])
imagesc(sleep_stage')
set(gca,'CLim',[0 4],'Colormap',Color_5stages)
box off;
axis off

%% set onset of each five-minute epoch according to the 'for_EEG_N2231.txt'
ax1=subplot('position',[0.06    0.14    0.92    0.10])
% W
plot(82:92,3*ones(11,1),'-','color',Color_5stages(1,:),'LineWidth',1);
hold on;
plot(127:147,3*ones(21,1),'-','color',Color_5stages(1,:),'LineWidth',1);
hold on;
plot(251:261,3*ones(11,1),'-','color',Color_5stages(1,:),'LineWidth',1);
hold on;

% N1
plot(162:172,2*ones(11,1),'-','color',Color_5stages(2,:),'LineWidth',1);
hold on;

% N2
plot(13:23,ones(11,1),'-','color',Color_5stages(3,:),'LineWidth',1);
hold on;
plot(68:78,ones(11,1),'-','color',Color_5stages(3,:),'LineWidth',1);
hold on;
plot(173:203,ones(31,1),'-','color',Color_5stages(3,:),'LineWidth',1);
hold on;
plot(213:233,ones(21,1),'-','color',Color_5stages(3,:),'LineWidth',1);
hold on;

% N3
plot(31:51,zeros(21,1),'-','color',Color_5stages(4,:),'LineWidth',1);
hold on;
plot(239:249,zeros(11,1),'-','color',Color_5stages(4,:),'LineWidth',1);
hold on;

set(ax1,'Xlim',[0 length(stage_a)])
set(ax1,'ylim',[-0.5 3.5])

box off;
axis off



%%
ax=subplot('position',[0.06    0.47    0.92    0.50])
accsleep=cumsum(stage_a>0);
[ii jj] = find(accsleep./120 ==1);

plot(1:length(stage_a),accsleep./120,'-','color','k','LineWidth',1);
hold on;
plot(1:length(stage_a),ones(length(stage_a),1),'-','color',[0.7 0.7 0.7],'LineWidth',0.5);
hold on;
plot(ii*ones(14,1),0:20./120:260./120,'-','color',[0.7 0.7 0.7],'LineWidth',0.5);

set(ax,'Xlim',[0 length(stage_a)+0.5],'xtick',[0:60:floor(length(stage_a)/60)*60],'xticklabel',xlabels(1:ceil(length(stage_a)/60)),'TickDir','out','fontname','Arial','fontsize',7)
set(ax,'ylim',[0 2.5],'ytick',[0 1 2])
xlabel('Time (hour)','fontname','Arial','fontsize',7,'color','k'); 
ylabel('Accumulated sleep (hour)','fontname','Arial','fontsize',7,'color','k'); 
box off;


%%
sleep_early_late=repmat([ones(ii,1);2*ones(length(stage_a)-ii,1)],1,3);
subplot('position',[0.06    0.02    0.92    0.02])
imagesc(sleep_early_late')
set(gca,'CLim',[1 2],'Colormap',Colors2)
box off;
axis off



    cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1

    print(gcf,'-dpdf','-r400')
    oldname=['figure1.pdf'];
    newname=['sub3117_accsleep_WFS_AFS.pdf'];
    movefile(oldname,newname);    
