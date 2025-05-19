function nuisance_regressors(infile,method,FDfile)
%% Absolute tissue signals and head motion
ts_mc = load(infile);

% driviative
rts_mc = [zeros(1,9);diff(ts_mc)];

% square of absolute
sts_mc = ts_mc.*ts_mc;

% square of driviate
srts_mc = rts_mc.*rts_mc;

if strcmp(method, 'Power2014')
    nuisance_regressors=[ts_mc(:,2) rts_mc(:,2) ts_mc(:,3) rts_mc(:,3) ts_mc(:,4:9) sts_mc(:,4:9) rts_mc(:,4:9) srts_mc(:,4:9)];
elseif strcmp(method, 'Satterthwaite2013')
    FD = load(FDfile);
    spikes=[];
    for i = 1:length(FD)
        if FD(i)==0
            tmp=zeros(size(FD));
            tmp(i)=1;
            spikes=[spikes tmp];
        end
    end      
    nuisance_regressors=[ts_mc(:,2) rts_mc(:,2) ts_mc(:,3) rts_mc(:,3) ts_mc(:,4:9) sts_mc(:,4:9) rts_mc(:,4:9) srts_mc(:,4:9) spikes];
    
end

save -ascii nuisance_regressors.1D nuisance_regressors
    


