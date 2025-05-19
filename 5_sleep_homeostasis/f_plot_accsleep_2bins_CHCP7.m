%% for Fig. 3
%% plot 2 stage by 2 bin interaction effect on average ALFF in 7 networks

%%
clc;clear
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/5_sleep_homeostasis
% load mean and se resutls from R
data1=csvread('out_sleep_wake_2stages_accsleep_2bins_CHCP7.csv',1,0);
data=data1(7:10,:);
cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
colormap1 = SPECTRAL(256); % Colormap 
Colors2=colormap1([210 40],:);



%% CHCP7
[tmp order_yeo7] = sort(data(2,:)-data(1,:));

label={'Vis','SM','DAN','VAN','Aud','FP','DMN'};

Gname={'WFS','AFS'};
Numgroup=2;
Numregion=7;
Numlname  = 1;
Numgname  = size(Gname, 2);


figure
set(gcf,'Units','Centimeters','position',[1 1 5 5])
yMean = reshape(data(1:2,order_yeo7), Numgroup, Numregion)';
yse  = reshape(data(3:4,order_yeo7), Numgroup, Numregion)';

groupwidth = min(0.8, Numgroup/(Numgroup+1.5));

        H = bar(yMean, 'LineStyle', '-');
        hold on;
        set(gca, 'Xlim', [0.38 Numregion + 0.62], 'xtick', 1:Numregion, 'YGrid', 'off', 'box', 'off', 'TickDir', 'in');
        
        for i = 1:Numgroup
            
            set(H(i), 'FaceColor', Colors2(i,:), 'BarWidth', 0.66);
            
            % Aligning error bar with individual bar (Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange)
            x = (1:Numregion) - groupwidth/2 + (2*i-1) * groupwidth / (2*Numgroup);

            yErr = yse;

            yErrBar=zeros(Numregion, 2);
            for nr=1:Numregion
                yOneMean=yMean(nr, i);
                if yOneMean >=0
                    yErrBar(nr, 1)=yOneMean;
                    yErrBar(nr, 2)=yOneMean + yErr(nr, i);
                else
                    yErrBar(nr, 1)=yOneMean - yErr(nr, i);
                    yErrBar(nr, 2)=yOneMean;            
                end
            end
            plot([x; x], yErrBar',  'color', Colors2(i,:), 'LineWidth', 2);            
        end
        

set(gca, 'Xlim', [0.38 Numregion + 0.62], 'YGrid', 'off', 'box', 'off', 'TickDir', 'out','fontname','Arial','fontsize',7);
set(gca, 'xtick', 1:7, 'XTickLabel', label(order_yeo7));
xtickangle(45)

ylabel('{\Delta} ALFF','fontname','Arial','fontsize',7);

set(gca, 'Ylim', [-0.45 0.65]);
set(gca, 'ytick', [-0.4:0.2:0.8])
set(gca,'looseInset',[0.05 0.02 0 0.02])

leg=legend([H(1) H(2)],Gname,'EdgeColor',[1,1,1],'fontname','Arial','fontsize',7)
legend('Position',[0.78 0.85 0.1 0.1],'box','off','NumColumns',1)
leg.ItemTokenSize(1) = 4;


cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/5_sleep_homeostasis/


print(gcf,'-dpdf','-r400')
oldname=['figure1.pdf'];
newname=['sleep_wake_accsleep_2bins_CHCP7.pdf'];
movefile(oldname,newname);    

close all;

