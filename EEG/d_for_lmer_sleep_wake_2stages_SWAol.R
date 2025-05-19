library(lme4)
library(lmerTest)
library(readxl)
library(emmeans)
library(tidyverse)
library(broom.mixed)
library(data.table)

setwd('D:/R_test/new202504')
dir()
data=fread("Model_sleep_wake_accsleep_2bins_SWAol.txt",header=TRUE,sep=',')
str(data)


nn=names(data)[9:60]
nn

write.table(t(nn),'out_sleep_wake_2stages_SWAol.csv',sep=',',append=TRUE,row.names=FALSE,col.names=FALSE)


re1=NULL
re2=NULL
tmp1=NULL
tmp2=NULL
out1=NULL
out2=NULL
out3=NULL
out4=NULL
out5=NULL
out6=NULL
out7=NULL
out8=NULL


for(i in seq_along(nn)){
  i
### stage effect  
  model<-lmer(formula(paste0(nn[i],"~stage_n1+(1|Var1)+(1|Var6)+Var2+Var3+Var4+Var5")),data=data)
  re1[[i]]=anova(model)
  out1[[i]]=re1[[i]]$`F value`[[1]]
  out2[[i]]=re1[[i]]$`Pr(>F)`[[1]]
  
  re2[[i]] = emmeans(model,list(pairwise~stage_n1),adjust="none")
  tmp1=re2[[i]]$`emmeans of stage_n1`
  
  out3[[i]]<-tidy(tmp1)$estimate
  out4[[i]]<-tidy(tmp1)$std.error
  
  tmp2=re2[[i]]$`pairwise differences of stage_n1`
  
  out5[[i]]<-tidy(tmp2)$statistic
  out6[[i]]<-tidy(tmp2)$p.value 
  out7[[i]]<-tidy(tmp2)$estimate 
  out8[[i]]<-tidy(tmp2)$std.error
  
}

write.table(t(out1),'out_sleep_wake_2stages_SWAol.csv',sep=',',append=TRUE,row.names=FALSE,col.names=FALSE)
write.table(t(out2),'out_sleep_wake_2stages_SWAol.csv',sep=',',append=TRUE,row.names=FALSE,col.names=FALSE)
write.table(out3,'out_sleep_wake_2stages_SWAol.csv',sep=',',append=TRUE,row.names=FALSE,col.names=FALSE)
write.table(out4,'out_sleep_wake_2stages_SWAol.csv',sep=',',append=TRUE,row.names=FALSE,col.names=FALSE)
write.table(out5,'out_sleep_wake_2stages_SWAol.csv',sep=',',append=TRUE,row.names=FALSE,col.names=FALSE)
write.table(out6,'out_sleep_wake_2stages_SWAol.csv',sep=',',append=TRUE,row.names=FALSE,col.names=FALSE)
write.table(out7,'out_sleep_wake_2stages_SWAol.csv',sep=',',append=TRUE,row.names=FALSE,col.names=FALSE)
write.table(out8,'out_sleep_wake_2stages_SWAol.csv',sep=',',append=TRUE,row.names=FALSE,col.names=FALSE)
