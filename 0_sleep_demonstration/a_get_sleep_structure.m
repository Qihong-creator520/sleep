%% for Fig. 1
%% get sleep structure during sleep EEG-fMRI scan

clc;clear
cd('/nd_disk2/qihong/Sleep_PKU/brain_restoration')
dirs=dir('sub*');
Nstgs=5;%0-W,1-N1,2-N2,3-N3,4-R
prob_stgs=zeros(Nstgs,10000);
All_inds = zeros(length(dirs),Nstgs,10000);
All_acq =zeros(length(dirs),10000);

for dirn=1:length(dirs)
    dirn
    cd(['/nd_disk2/qihong/Sleep_PKU/brain_restoration/' dirs(dirn).name '/stages']);
    f=dir('sub*sleep*txt');% modified staging files
    %read txt files: scoring results
    lf =length(f);% number of sleep runs

    pred=[];

    for file_n = 1:lf

        inds=zeros(Nstgs,10000);
        a=load(f(file_n).name);
        pred = [pred;a];
        
    end
    

    for j=1:Nstgs
        inds(j,1:size(pred))=(pred==j-1);                
    end

    All_inds(dirn,:,:)=inds;
    All_acq(dirn,:)=sum(inds,1);
    
end

N_subj = sum(All_acq,1);
N_subj(:,min(find(sum(All_acq,1)==0)):end) = [];

prob_stgs1 = squeeze(sum(All_inds,1))./sum(All_acq,1);
prob_stgs = squeeze(prob_stgs1);
prob_stgs(:,min(find(sum(All_acq,1)==0)):end) = [];

%%%
duration = sum(All_inds,3); % 30-second per frame 

duration_sleep_stages=cell(1,5);
for j=1:Nstgs
    duration_sleep_stages{1,j}=duration(:,j)/120; % in hour
end


cd('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/0_sleep_demonstration');
save N_subj.txt N_subj -ascii
save prob_stgs.txt prob_stgs -ascii
save duration_sleep_stages.mat duration_sleep_stages

