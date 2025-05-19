%% Fig. 1
%% relationship between tSNR and motion

clc;clear
cd('/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/tSNR')

fid=fopen('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Subjects_N130.txt');
subj=textscan(fid,'%s');
fclose(fid);
dirs=subj{1};
All_tSNR = zeros(length(dirs),110);
All_acq =zeros(length(dirs),110);

for dirn=1:length(dirs)
    dirn
    cd('/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/tSNR')
    cd(dirs{dirn});
    f=dir('*tSNR*txt');% tSNR of 5-min sessions
    lf =length(f);% number of runs

    tSNR=[];

    for file_n = 1:lf
        
        a=load(f(file_n).name);
        tSNR = [tSNR;a];
        
    end
    
    All_tSNR(dirn,1:length(tSNR))=tSNR;
    All_acq(dirn,1:length(tSNR))=ones(1,length(tSNR));
    cd ..
end

tSNR_mean = sum(All_tSNR,1)./sum(All_acq,1);
tSNR_mean(min(find(sum(All_acq,1)<3)):end) = [];
% min(find(sum(All_acq,1)<3))
% 76
cd('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/1_tSNR_demonstration');
save tSNR_mean.txt tSNR_mean -ascii


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
All_meanFD = zeros(length(dirs),110);
All_acq =zeros(length(dirs),110);

cd('/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/tSNR')
for dirn=1:length(dirs)
    dirn
    cd(dirs{dirn});
    f=dir('*meanFD*txt');% meanFD of 5-min sessions
    lf =length(f);% number of runs

    meanFD=[];

    for file_n = 1:lf
        
        a=load(f(file_n).name);
        meanFD = [meanFD;a];
        
    end
    
    All_meanFD(dirn,1:length(meanFD))=meanFD;
    All_acq(dirn,1:length(meanFD))=ones(1,length(meanFD));
    cd ..
end

meanFD_mean = sum(All_meanFD,1)./sum(All_acq,1);
meanFD_mean(min(find(sum(All_acq,1)<3)):end) = [];

cd('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/1_tSNR_demonstration');
save meanFD_mean.txt meanFD_mean -ascii



%%
figure
set(gcf,'Units','Centimeters','position',[0 0 10 4.5])

%%% tSNR
subplot('position',[0.09    0.17   0.40    0.78])

for ii = 1:length(dirs)
    hold on; plot(1:length(find(All_acq(ii,:)>0)),All_tSNR(ii,1:length(find(All_acq(ii,:)>0))),'.','MarkerSize',4);
end


hold on;plot(tSNR_mean(1:75)','-','color','k','linewidth',1.5); 
% hold on;plot(30,All_tSNR(99,30),'o','MarkerSize',6,'MarkerEdgeColor','k')
set(gca,'Tickdir','out','FontName','Arial','FontSize',7,'box','off');

xlabel('Time (hour)','FontSize',7,'FontName','Arial');ylabel('tSNR','FontSize',7,'FontName','Arial');
set(gca,'Ylim',[0 135],'ytick',[0:30:135])
% 75 valid data points (with at least 3 sessions)
set(gca,'Xlim',[0.5 75.5],'xtick',[12:12:72],'xticklabel',{'1','2','3','4','5','6'},'FontName','Arial','FontSize',7)
ax=gca;
ax.XColor = 'k';
ax.YColor = 'k';



% meanFD
subplot('position',[0.59    0.17    0.40    0.78])
for ii = 1:length(dirs)
    hold on; plot(1:length(find(All_acq(ii,:)>0)),All_meanFD(ii,1:length(find(All_acq(ii,:)>0))),'.','MarkerSize',4);
end
hold on;plot(meanFD_mean(1:75)','-','color','k','linewidth',1.5);
% hold on;plot(30,All_meanFD(99,30),'o','MarkerSize',6,'MarkerEdgeColor','k')
set(gca,'Tickdir','out','FontName','Arial','FontSize',7,'box','off');


xlabel('Time (hour)','FontSize',7,'FontName','Arial');ylabel('meanFD (mm)','FontSize',7,'FontName','Arial');
set(gca,'Ylim',[0 2.1],'ytick',[0:0.5:2.1])
set(gca,'Xlim',[0.5 75.5],'xtick',[12:12:72],'xticklabel',{'1','2','3','4','5','6'},'FontName','Arial','FontSize',7)
ax=gca;
ax.XColor = 'k';
ax.YColor = 'k';




outpath = ['/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/1_tSNR_demonstration'];
cd(outpath)

print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['tSNR_meanFD_n.pdf'];
movefile(oldname,newname);    

close all;




[r p]=corr(meanFD_mean(1:75)',tSNR_mean(1:75)','type','Spearman')
% ans =
% 
%    -0.7535    0.0000
   


