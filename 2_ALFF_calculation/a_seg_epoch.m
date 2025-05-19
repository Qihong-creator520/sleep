%% generate 5-minute epochs
%% modify ep_length to generate epochs with different length

clc;clear
TR = 2;
for ep_length=[300] %% epoch length = 300 seconds
    cd /nd_disk2/qihong/Sleep_PKU/brain_restoration
    dirs=dir('sub*');
%     dirs=dir('sub3055*');
%     dirs=dir('sub3100*');
    for dirn=1:length(dirs)
        cd /nd_disk2/qihong/Sleep_PKU/brain_restoration
        cd([dirs(dirn).name '/stages']);
        f=dir('sub*.txt'); % 1 label for 30 seconds for EEG
        
        lf = length(f); % number of sleep sessions
        del_vol = ones(lf,1)*10; % remove 10 volumes for fMRI of each sleep session to match EEG and stage txt files
%         del_vol = [10;17]; % for sub3055, 7 additonal fMRI volumes need to be excluded to match EEG for the 2nd sleep session 
%         del_vol = [10;15]; % for sub3100, 5 additonal fMRI volumes need to be excluded to match EEG for the 2nd sleep session

        epoch_num=0; % the number of epochs
        filenames={}; % filename of each epoch
        num_dir=0;
        for file_n = 1:lf
            cd /nd_disk2/qihong/Sleep_PKU/brain_restoration
            cd([dirs(dirn).name '/stages']);
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
                                ed=k
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
                    cd /nd_disk2/qihong/Sleep_PKU/brain_restoration
                    cd([dirs(dirn).name '/fMRI']);
                    sleepfile=dir(['*sleep*.nii*']);
                    a_info=niftiinfo(sleepfile(file_n).name);

                    out_info = a_info;
                    out_info.ImageSize(4) = round(ep_length/TR);
                    a=niftiread(sleepfile(file_n).name);
                    
                    for i=1:size(stgs,1)
                        % first volume
                        fir0=(stgs(i,2)-1)*round(30/TR)+del_vol(file_n)+1;
                        
                        num_dir=0;
                        for j=1:stgs(i,6)

                            epoch_num=epoch_num+1;
                            temp=strfind(filenames,['stage',num2str(stgs(i,1)-1)]);
                            num_dir=length(find(~cellfun(@isempty,temp)==1))+1;

                            mkdir(num2str(ep_length))

                            
                            filename=['stage',num2str(stgs(i,1)-1),'sess',num2str(num_dir,'%02d'),'_',num2str(file_n)];
                            
                            filenames{epoch_num}=filename;
                            
                            fir=fir0+round(ep_length/TR)*(j-1);
                            
                            out_info.Filename=[cd,'/',num2str(ep_length),'/',filename];
                            niftiwrite(a(:,:,:,fir:fir+round(ep_length/TR)-1),out_info.Filename,out_info);
                        end % epochs
  
                    end
                    
                end
                
            end

        end % sleep sessions

    end % participants

end % ep_length


% Segment fMRI data to episodes with equal length




