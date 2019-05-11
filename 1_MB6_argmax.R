#----------------------------------------------------------------------------------------------------------
# Purpose: calculate the arg max based on objective function
# Author: Zixi Yang
# Date: 04/18/2019 
#----------------------------------------------------------------------------------------------------------

lapply(c("steadyICA","oro.nifti","neuRosim","JADE","parallel","AnalyzeFMRI","multitaper","snow","moments","corrplot")
       , library, character.only=T)
setwd("/cbis4/projects/R_hcp/results_mb6")

# input original nifti data from MB6 data set
melodic_ori_ic=readNIfTI('/cbis4/projects/R_hcp/results_mb6/filtered_func_data.nii.gz',reorient = FALSE)
# sub29298ori=readNIfTI('/cbis4/projects/R_hcp/results_mb6/sub_nii_data/sub-29298_ses-ch1_task-rest_run-01_bold.nii.gz',reorient = FALSE)

# create matrix for original data
o = melodic_ori_ic@.Data
dimdata = dim(o)
dim(o) = c(prod(dimdata[1:3]),dimdata[4])

# create masked matrix for components of seed 1~100
n.comp = 159 # the number of components as 159 is from the estimation of melodic software
icmatrix <- function(ic_seed,n.comp){
  # create mask as melmask
  melmask = ic_seed@.Data[,,,1]!=0
  melmask = as.vector(melmask)
  icmelodic_matrix = ic_seed@.Data
  dim(icmelodic_matrix) = c(prod(dimdata[1:3]),n.comp)
  icmelodic_matrix = icmelodic_matrix[melmask,]
  return(icmelodic_matrix)
}

ic_seed=list()
s=list()
for (subject in 1:100) {
  ic_seed[[subject]]=readNIfTI(paste0('/cbis4/projects/R_hcp/results_mb6/no_smooth_result_seed',subject,'.ica/melodic_IC.nii.gz'),reorient = FALSE)
  s[[subject]]=icmatrix(ic_seed[[subject]],n.comp)
}
#----------------------------------------------------------------------------------------------------------
# calculate sum of kurtosis of each components
objfv_ori<-function(data_ori){
  k_ori=rep(0,n.comp)
  for (i in 1:n.comp) {
    k_ori[i]=kurtosis(data_ori[,,,i]) 
  }
  sum(k_ori)
}

# find the number of seeds from estimation with the largest sum of kurtosis of components
objfvo=rep(0,100)
for (i in 1:100) {
  objfvo[i]=objfv_ori(ic_seed[[i]])
}

which.max(objfvo)







