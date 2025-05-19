%% get onsets for all the 5-minute epochs
clc;clear
TR = 2;
Demo=readtable('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Demo_N130.txt');

for ep_length=[300] % epoch length = 300 seconds
    cd /nd_disk2/qihong/Sleep_PKU/brain_restoration
    dirs=dir('sub*');
    epoch_num_a=0;
    filenames_a={}; % filename of each epoch
    age=[];
    gender={};
    edu=[];
    session_onset=[];

    for dirn=1:length(dirs)
        cd(['/nd_disk2/qihong/Sleep_PKU/brain_restoration/' dirs(dirn).name '/stages']);
        f=dir('sub*.txt'); % 1 label for 30 seconds for EEG
        
        lf = length(f); % number of sleep sessions

        epoch_num=0; % the number of epochs
        filenames={};

        num_dir=0;
        L_a=0;
        for file_n = 1:lf
            
            inds=zeros(5,10000);
            a=load(f(file_n).name); % read txt files: scoring results

            
            
            for j=1:5 % 5 stages
                inds(j,1:length(find(a==j-1)))=find(a==j-1);
                
            end
            inds_sec=inds;
            
            clear l_ofeach % timing info for start and end of each continuous part with a same stage
            clear l_ofeachep % timing info for start and end of each continuous part with a same stage longer than ep_length
            
            for j=1:5
                
                x=unique(squeeze(inds_sec(j,:)));
                x(find(x==0))=[];
                if length(x)>1
                    n=0;
                    beg=1;
                    ed=1;
                    for k=2:length(x)
                        if x(k)-x(k-1)>1|k==length(x)
                            n=n+1;
                            
                            if x(k)-x(k-1)>1
                                ed=k-1;
                            else
                                ed=k;
                            end
                            l_ofeach(j,n,:)=[x(beg),x(ed)]; 
                            beg=k;
                        end
                    end
                end
            end
            
            
            
            % segment index to discontinuous parts
            % with duration longer than ep_length
           
            n=0;
            kn=size(l_ofeach,2);
            for j=1:size(l_ofeach,1)
                
                for k=1:kn
                    
                    if l_ofeach(j,k,2)-l_ofeach(j,k,1)+1>=ep_length/30;
                        n=n+1;
                        l_ofeachep(n,:)=[j,l_ofeach(j,k,1),l_ofeach(j,k,2)];
                    end
                end
                
            end


            if exist('l_ofeachep')
                % for parts with duration > ep_length
                l_ofeachep(:,5)=(l_ofeachep(:,3)-l_ofeachep(:,2)+1)/round(ep_length/30);
                % column 5 (number of episode length)
                
                stgs=l_ofeachep;
                
                stgs(:,6)=floor(stgs(:,5));
                if ~isempty(stgs)

                    for i=1:size(stgs,1) % all parts
                        % first frame of this part
                        fir0=stgs(i,2);
                        
                        num_dir=0;
                        for j=1:stgs(i,6) % epoches

                            epoch_num=epoch_num+1;
                            epoch_num_a = epoch_num_a + 1;
                            temp=strfind(filenames,['stage',num2str(stgs(i,1)-1)]);
                            num_dir=length(find(~cellfun(@isempty,temp)==1))+1;

                           
                            filename=[dirs(dirn).name '_stage',num2str(stgs(i,1)-1),'sess',num2str(num_dir,'%02d'),'_',num2str(file_n)];
                            
                            
                            filenames{epoch_num,1}=filename;
                            filenames_a{epoch_num_a,1}=filename;

                            % first volume of this epoch
                            fir=fir0+round(ep_length/30)*(j-1);

                            N_ss{epoch_num_a,1} = [file_n]; % sleep sessions, 1, 2, 3, 4
                            onset_ss{epoch_num_a,1} = [fir]; % unit 30 seconds



                            subjects{epoch_num_a,1} = dirs(dirn).name;
                            stages{epoch_num_a,1} = ['stage' num2str(stgs(i,1)-1)];
                            sessions{epoch_num_a,1} = ['sess',num2str(num_dir,'%02d')];


                           for d=1:size(Demo,1)
                               if  strcmp(subjects{epoch_num_a,1},Demo(d,1).Var1)
                                   age{epoch_num_a,1}=Demo(d,2).Var2;
                                   if Demo(d,3).Var3==0 % gender as categorical variable
                                       gender{epoch_num_a,1}='female';
                                   else
                                       gender{epoch_num_a,1}='male';
                                   end
                                   edu{epoch_num_a,1}=Demo(d,4).Var4; 
                               end
                           end


                            
                        end % epoches
  
                    end
                    
                end
                
            end
            

            L_a = L_a+length(a);

        end % sleep sessions


    end % participants

end % ep_length




%% get onsets for all the 5-minute epochs
%% prepare for main effect of stage LME model for all the 5-minute epochs, including stage, age, gender, edu, session (epoch) and subject
Model_N2461=table(subjects,age,gender,edu,stages,N_ss,onset_ss,sessions,filenames_a);

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
writetable(Model_N2461,'Model_N2461_forEEG.txt','Delimiter',',')




%%
%%%
%% get onsets for the 5-minute epochs included in the final analysis
%% prepare for main effect of stage LME model for all the included 5-minute epochs, including stage, age, gender, edu, session (epoch) and subject
clc;clear
Model_N2461=readtable('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Model_N2461_forEEG.txt');
Model_N2231=readtable('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/Model_N2231.txt');

for jj = 1:length(Model_N2231.Var8)
    filename1 = Model_N2231.Var8(jj);
    filename = filename1{1}(1:22);

    index = contains(Model_N2461.filenames_a,filename);
    index_N2231(jj,1) = find(index>0);

end

for_EEG_N2231  = Model_N2461(index_N2231,[6 7 9]);

cd /nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1
writetable(for_EEG_N2231,'for_EEG_N2231.txt','Delimiter',' ')

