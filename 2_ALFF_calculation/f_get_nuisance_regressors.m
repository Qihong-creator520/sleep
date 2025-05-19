%% get nuisance parameters
 
clc;clear
fid=fopen('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/filelist-all2461.txt');
session=textscan(fid,'%s');
fclose(fid);
fid=fopen('/nd_disk2/qihong/Sleep_PKU/brain_restoration/Sleep_EEG_fMRI-main_R1/filelist-wake-pre.txt');
session=textscan(fid,'%s');
fclose(fid);
rtpath='/nd_disk2/qihong/Sleep_PKU/brain_restoration/processed/Five-min-sessions';
cd(rtpath);


for x = 1:length(session{1})
    disp( strtrim(session{1}{x}) )
    path = [rtpath '/' strtrim(session{1}{x}) '/']
    cd(path);
    infile = [strtrim(session{1}{x}) '-ts-motion.1D'];
    nuisance_regressors(infile,'Power2014');
end

