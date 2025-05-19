%% for fig. S2
%% plot the histogram of data adoted in the stage by accumulated sleep LME analysis

clc;clear
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
Model_wake_pre=readtable('Model_sleep_wake_wake_pre.txt');
Model_N2231=readtable('Model_sleep_wake_N2231.txt');
Model_N2231.Properties.VariableNames=Model_wake_pre.Properties.VariableNames;
Model_all=[Model_wake_pre; Model_N2231];

%%
clear stage_n
for jj = 1:length(Model_wake_pre.Var6)
    stage_n{jj,1}='stage0';
end

for jj = length(Model_wake_pre.Var6)+1:length(Model_wake_pre.Var6)+length(Model_N2231.Var6)
    stage_n{jj,1}=table2cell(Model_N2231(jj-length(Model_wake_pre.Var6),6));
end

%% 2 bins
figure
set(gcf,'Units','Centimeters','position',[1 1 5 5])

sum(cellfun(@(x) contains(x,'stage0'), stage_n).*contains(Model_all.sw_history_2bins,'oneless'))
% 391
sum(cellfun(@(x) contains(x,'stage0'), stage_n).*contains(Model_all.sw_history_2bins,'onemore'))
% 177
Counts5=[391 177; 124 69; 362 606; 382 179; 3 68];

HH=bar([1 2],Counts5);
Gname={'WFS','AFS'};

Color=[156,197,217; 230,169,140; 162,42,49; 89,18,29; 52,100,165]./255;

for ii=1:5
    set(HH(ii),'FaceColor',Color(ii,:))
end


ylabel('Count','FontName','Arial','fontsize',7);
set(gca,  'xtick', 1:2, 'xticklabel',Gname, 'YGrid', 'off', 'box', 'off', 'TickDir', 'out','FontName','Arial','fontsize',7);

set(gca, 'Xlim', [0.3 2.8]);
hl=legend('W','N1','N2','N3','REM','FontName','Arial','fontsize',7);
set(hl,'Box','off');
hl.ItemTokenSize(1) = 6;
legend('Position',[0.80 0.66 0.1 0.1],'box','off','Orientation','Vertical', 'NumColumns',1)



cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/5_sleep_homeostasis

print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['histogram_sw_history_2bins_5stages.pdf'];
movefile(oldname,newname);    

close all;




