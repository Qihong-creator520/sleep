function [meanFD, numFD, maxHM] = FDinfo(fileMC)

%% read the parameters estimated
mc_f1 = load(fileMC);
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
meanFD = mean(FD);
% Number of TRs with FD larger than 0.5
numFD = nnz(FD > 0.5);
% 
maxHM = max(max(abs(mc_f1(:,1:6))));





