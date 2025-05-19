%% get motion paramters for all the 5-minute epochs

clc;clear
rtpath='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/tSNR/';
cd(rtpath);
dirs=dir('sub*');

for dirn=1:length(inc)
    dirn
    cd(rtpath);
    cd(dirs(inc(dirn)).name);
    
    f=dir('*sleep*-motion.1D');
    
    lf =length(f);
    
        for file_n = 1:lf

            a=load(f(file_n).name);
            if length(a)<150
                break
            end
            
            Nsession_5min=floor(length(a)/150);
            meanFD=zeros(Nsession_5min,1);
            numFD=zeros(Nsession_5min,1);
            maxHM=zeros(Nsession_5min,1);

            for ns = 1:Nsession_5min
                mc_f1 = a(((ns-1)*150+1):ns*150,:);
                
                %% Absolute head motion
                mc_dS = mc_f1(:,1); mc_dL = mc_f1(:,2); mc_dP = mc_f1(:,3); 
                mc_roll = mc_f1(:,4); mc_pitch = mc_f1(:,5); mc_yaw = mc_f1(:,6);
                rmc_dS = diff(mc_dS); 
                rmc_dL = diff(mc_dL); 
                rmc_dP = diff(mc_dP);
                rmc_roll = diff(mc_roll); 
                rmc_pitch = diff(mc_pitch); 
                rmc_yaw = diff(mc_yaw);

                %% Framewise displacement: FD
                FD = abs(rmc_dS) + abs(rmc_dL) + abs(rmc_dP) + ...
                    50*pi/180*abs(rmc_roll) + 50*pi/180*abs(rmc_pitch) + 50*pi/180*abs(rmc_yaw);

                % Mean
                meanFD(ns,1) = mean(FD);

                % Number of TRs with FD larger than 0.5
                numFD(ns,1) = nnz(FD > 0.5);

                % max HM rative to the middle time point
                maxHM(ns,1) = max(max(abs(mc_f1(:,1:6)-repmat(mc_f1(76,1:6),150,1))));
            end

            meanFDname1 = f(file_n).name;
            meanFDname = [meanFDname1(1:(length(meanFDname1)-3)), '-meanFD.txt'];
            save(meanFDname,'meanFD','-ascii');

            numFDname1 = f(file_n).name;
            numFDname = [numFDname1(1:(length(numFDname1)-3)), '-numFD.txt'];
            save(numFDname,'numFD','-ascii');

            maxHMname1 = f(file_n).name;
            maxHMname = [maxHMname1(1:(length(maxHMname1)-3)), '-maxHM.txt'];
            save(maxHMname,'maxHM','-ascii');

        end

end
