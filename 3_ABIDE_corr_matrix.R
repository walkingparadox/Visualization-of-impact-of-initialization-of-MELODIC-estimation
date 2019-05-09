#----------------------------------------------------------------------------------------------------------
# Purpose: visualized the correlation matrices for all/artifacts/signals/unknowns/chosed components
# Author: Zixi Yang
# Date: 04/18/2019 
#----------------------------------------------------------------------------------------------------------
# import matched components as match_ic
lapply(c("steadyICA","oro.nifti","neuRosim","JADE","parallel","AnalyzeFMRI","multitaper","snow","corrplot")
       , library, character.only=T)
setwd("/cbis4/projects/R_hcp/results_mb6")
load("/cbis4/projects/R_hcp/results_mb6/sub29298_matchedic100.RData")
#----------------------------------------------------------------------------------------------------------
# calculate 0.025,0.5,0.975 correlation matrix for all components

corr_of_seed=matrix(rep(0,100*100*80),ncol=80)
dim(corr_of_seed)=c(100,100,80)
corr_q=matrix(rep(0,100*100),ncol = 100)

full_matrix<-function(match_ic,corr_of_seed,p){
  for (i in 1:99) {
    for (j in (i+1):100) {
      for (k in 1:80) {
        # calculate correlations of seeds for all components 
        corr_of_seed[i,j,k]=cor(match_ic[[i]][,k],match_ic[[j]][,k])
        # calculate 100 X 100 matrix for quantile 0.025, 0.5, 0.975 correlations for components
        corr_q[i,j]=quantile(corr_of_seed[i,j,],probs = p) # p=0.025, 0.5, 0.975
        corr_q[j,i]=corr_q[i,j]
      }
    }
  }
  diag(corr_q)=1
  return(corr_q)
}

# visualize quantile 0.025, 0.5, 0.975 correlation matrices for seeds (initializations) in corrplot
plot_full<-function(p){
  pdf(file = paste0("/cbis4/projects/R_hcp/results_mb6/new_ABIDE_",p,"_corr_new.pdf"))
  corrplot(full_matrix(match_ic,corr_of_seed,p), method="color",
           tl.pos="n",
           cl.lim = c(min(full_matrix(match_ic,corr_of_seed,p)),1), is.corr=FALSE,
           main =paste0( "quantile ",p," correlation of distance matrix for 100 different seeds"),
           mar=c(0,0,2,0),
           cex.main=1)
  dev.off()
}

lapply(c(0.025,0.5,0.975), plot_full)

#----------------------------------------------------------------------------------------------------------
# calculate 0.025,0.5,0.975 correlation matrix for signals,artifacts,unknowns

#specify the number of choosed components through imaging software wb_view
artifacts=c(1,4,5,8,9,12,16,24,25,47,26,32,33,37,38,49,50,55,56)
unknown=c(13,14,15,17,19,20,27,30,34,43,44,45,46,53,57,58,59,60,61,62,63,64,65,66,67,68,70:80)
signal=c(2,3,6,7,10,11,18,21,22,23,28,29,31,35,36,39,40,41,42,48,51,52,54,69)
dat=list(artifacts,signal,unknown)
dat_name=list("artifacts","signal","unknown")
corr_of_seed_class=list()
corr_q_class=matrix(rep(0,100*100),ncol = 100)

separate_matrix<-function(class,corr_of_seed_class,corr_q_class,p){ # class is signal/artifacts/unknown
  # calculate correlations of seeds for choosed components as signals/artifacts/unknowns
  len=length(class)
  class_new=data.frame(class)
  for (k in 1:len) {
    corr_of_seed_class[[k]]=matrix(rep(0,100*100),ncol=100)
    for (i in 1:99) {
      for (j in (i+1):100) {
          corr_of_seed_class[[k]][i,j]=cor(match_ic[[i]][,class_new[k,]],match_ic[[j]][,class_new[k,]])
      }
    }
  }
  # create 100 X 100 X number of components as len matrix contain correlations of seeds above
  corr_of_seed_class_new=as.matrix(as.data.frame(corr_of_seed_class))
  dim(corr_of_seed_class_new)=c(100,100,len)
  # calculate 100 X 100 matrix for quantile 0.025, 0.5, 0.975 correlations for components
  for (i in 1:99) {
    for (j in (i+1):100) {
      corr_q_class[i,j]=quantile(corr_of_seed_class_new[i,j,],probs = p)
      corr_q_class[j,i]=corr_q_class[i,j]
    }
  }
  diag(corr_q_class)=1
  return(corr_q_class)
}

# calculate list of correlation matrices from separate_matrix function above
for (n in 1:3) {
  assign(paste0("list_c_",n,"_025"),separate_matrix(class=dat[[n]],corr_of_seed_class=corr_of_seed_class,corr_q_class=corr_q_class,p=0.025))
  assign(paste0("list_c_",n,"_5"),separate_matrix(class=dat[[n]],corr_of_seed_class=corr_of_seed_class,corr_q_class=corr_q_class,p=0.5))
  assign(paste0("list_c_",n,"_975"),separate_matrix(class=dat[[n]],corr_of_seed_class=corr_of_seed_class,corr_q_class=corr_q_class,p=0.975))
}

list_c_025=list(list_c_1_025,list_c_2_025,list_c_3_025)
list_c_5=list(list_c_1_5,list_c_2_5,list_c_3_5)
list_c_975=list(list_c_1_975,list_c_2_975,list_c_3_975)

range(c(list_c_1_025,list_c_2_025,list_c_3_025))
range(c(list_c_1_5,list_c_2_5,list_c_3_5))
range(c(list_c_1_975,list_c_2_5,list_c_3_975))

# calculate the lower limit of values for corrplot by choosed minimum of each correlations in the same class
min_025=round(min(c(list_c_1_025,list_c_2_025,list_c_3_025)),digits = 2)-0.01
min_5=round(min(c(list_c_1_5,list_c_2_5,list_c_3_5)),digits = 2)-0.01
min_975=round(min(c(list_c_1_975,list_c_2_975,list_c_3_975)),digits = 2)-0.01

# visualize quantile 0.025, 0.5, 0.975 correlation matrices for seeds (initializations) in corrplot
# of signals, artifacts, unknowns
plot_separate_<-function(min,data,p,n,name){
  pdf(file = paste0("/cbis4/projects/R_hcp/results_mb6/new_quantile",p,"_corr_sub29298_",name[[n]],".pdf"))
  corrplot(data[[n]], method="color",
           tl.pos="n",
           cl.lim = c(min,1),
           is.corr=FALSE,
           main = paste0("quantile ",p," correlation of distance matrix for 100 different seeds of ",name[[n]]),
           mar=c(0,0,2,0),
           cex.main=1)
  dev.off()
}

lapply(c(1,2,3), plot_separate_,min=min_025,data=list_c_025,p=0.025,name=dat_name)
lapply(c(1,2,3), plot_separate_,min=min_5,data=list_c_025,p=0.5,name=dat_name)
lapply(c(1,2,3), plot_separate_,min=min_975,data=list_c_025,p=0.975,name=dat_name)

#----------------------------------------------------------------------------------------------------------
# calculate correlation matrix for choosed components
corr_of_seed_chos=matrix(rep(0,100*100),ncol=100)

choosed_matrix=function(k){
  for (i in 1:99) {
    for (j in (i+1):100) {
      corr_of_seed_chos[i,j]=cor(match_ic[[i]][,k],match_ic[[j]][,k])
      corr_of_seed_chos[j,i]=corr_of_seed_chos[i,j]
    }
  }
  diag(corr_of_seed_chos)=1
  return(corr_of_seed_chos)
}

# calculate the range for each correlation matrix for the plot
lapply(c(list(c(choosed_matrix(3))),list(c(choosed_matrix(7))),list(c(choosed_matrix(55))),list(c(choosed_matrix(60)))), range)
# calculate the lower limit of values for corrplot by choosed minimum of each correlations in the same class
min_high_corr=round(min(c(choosed_matrix(3),choosed_matrix(7))),digits = 2)-0.01
min_low_corr=round(min(c(choosed_matrix(55),choosed_matrix(60))),digits = 2)-0.01

# visualize correlation matrices for seeds (initializations) in corrplot for choosed components
# n is the number of chosen components
plot_chosen<-function(func,min,n){
  pdf(file = paste0("/cbis4/projects/R_hcp/results_mb6/sub29298_median_corr_",n,".pdf"))
  corrplot(func(n), method="color",
           tl.pos="n",
           cl.lim = c(min,1), is.corr=FALSE,
           main = paste0("median correlation of distance matrix for 100 different seeds for components ",n),
           mar=c(0,0,2,0),
           cex.main=1)
  dev.off()
}

lapply(c(3,7), plot_chosen,min=min_high_corr,func=choosed_matrix)
lapply(c(55,60), plot_chosen,min=min_low_corr,func=choosed_matrix)









