%% get LME model

clc;clear 
fid=fopen('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/filelist-wake-pre.txt');
session=textscan(fid,'%s');
fclose(fid);

rtpath='/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1';
cd(rtpath);
%meanFD=load('meanFD_N2461.txt');
%numFD=load('numFD_N2461.txt');
%maxHM=load('maxHM_N2461.txt');
meanFD=load('meanFD_wake_pre.txt');
numFD=load('numFD_wake_pre.txt');
maxHM=load('maxHM_wake_pre.txt');

%coverage = load('/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/Five-min-sessions/check_coverage/overlap_CHCP_Yeo2011_mask_all2461.1D');
coverage = load('/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/Five-min-sessions/check_coverage_wake_pre/overlap_CHCP_Yeo2011_mask_wake_pre.1D');

Demo=readtable('Demo_N130.txt');
Inc=zeros(length(session{1}),1);
y=1;z=1;

for x = 1:length(session{1})
%% 20250315
%% to keep all the wake data prior to sleep sessions
%% modify the coverage threshold to 94.5%

    if ( (numFD(x) <= 150*0.3) && (meanFD(x) <= 0.4) && (maxHM(x) <= 3) && (coverage(x) >= 0.945) )
        Inc(x,1) = 1;
      
       session_in{y} = session{1}{x};
       
       ID(y)=x;
       subj_in{y}=session_in{y}(1:7);
       
       for d=1:size(Demo,1)
           if  strcmp(subj_in{y},Demo(d,1).Var1)
               Demo(d,1).Var1
               age_in{y}=Demo(d,2).Var2;
               if Demo(d,3).Var3==0 % gender as categorical variable
                   gender_in{y}='female';
               else
                   gender_in{y}='male';
               end
               edu_in{y}=Demo(d,4).Var4; 
           end
       end
       
       stage_in{y}=session_in{y}(9:16);
       sess_in{y}='sess01_1';

       session_in_fn{y} = [session{1}{x} '.nii.gz'];
       y = y +1;
       
       
    else

        session_out{z} = session{1}{x};

        z = z +1;   

    end % a included session
       
end

session_in = session_in';
session_out = session_out';

subj_u = unique(subj_in);
subj_u = subj_u';

%% num70FD40max30, additionally constrained by coverage >= 94.5%
% 130 sess
% 130 subj

%%
Model_wake_pre=table(subj_in',age_in',gender_in',edu_in',meanFD',stage_in',sess_in',session_in_fn');
cd(rtpath);
writetable(Model_wake_pre,'Model_wake_pre.txt','Delimiter',' ')
%% then generate 3dLMEr model and run in afni

