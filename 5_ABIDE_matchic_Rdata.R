#----------------------------------------------------------------------------------------------------------
# Purpose: Transfer the matched components to nifti data with original dimension 
#          For better viewed in wb_view software
# Author: Zixi Yang
# Date: 04/18/2019 
#----------------------------------------------------------------------------------------------------------
lapply(c("steadyICA","oro.nifti","neuRosim","JADE","parallel","AnalyzeFMRI","multitaper","snow","corrplot","neurobase")
       , library, character.only=T)
setwd("/cbis4/projects/R_hcp/results_mb6")
sub29298_ori=readNIfTI('/cbis4/projects/R_hcp/results_mb6/sub_nii_data/sub-29298_ses-ch1_task-rest_run-01_bold.nii.gz',reorient = FALSE)
mdata = sub29298_ori@.Data
dimdata = dim(mdata)
load("/cbis4/projects/R_hcp/results_mb6/sub29298_matchedic100.RData")
n.comp = 80

#----------------------------------------------------------------------------------------------------------
# create function rev_icamatrix: transfer maksed & matched ICs (components) to original dimension before mask
rev_icamatrix <- function(match_ic,n.comp,ic_seed){
  melmask = ic_seed@.Data[,,,1]!=0
  supmask = ic_seed@.Data[,,,1]==0
  melmask = as.vector(melmask)
  supmask = as.vector(supmask)
  Mat = matrix(0,prod(dimdata[1:3]),n.comp)
  Mat[melmask,]=match_ic
  Mat[supmask,]=0
  dim(Mat) = c(dimdata[1],dimdata[2],dimdata[3],n.comp)
  return(Mat)
}

#----------------------------------------------------------------------------------------------------------
# match ICs with seed=77 to ICs with seed=27 for vislualization 
# (27 and 77 are just examples choosed based on the cluster structure from 2_ABIDE_cmd_plot.R Figure)
ic_seed=list()
ic=list()
matched_ic<-function(k){
  ic_seed[[k]]=readNIfTI(paste0('/cbis4/projects/R_hcp/results_mb6/sub-29298ica_result_100seeds/sub-29298_ses-ch1_task-rest_run-01_bold',k,'.ica/melodic_IC.nii.gz'),reorient = FALSE)
  ic[[k]]=rev_icamatrix(match_ic[[k]],n.comp,ic_seed[[k]])
  writeNIfTI(ic[[k]],paste0('/cbis4/projects/R_hcp/results_mb6/sub-29298ica_result_100seeds/sub-29298_ses-ch1_task-rest_run-01_bold',k,'.ica/sub29298_matched_melodic_IC_seed',k,'.nii.gz'))
}

matched_ic(27)
matched_ic(77)









