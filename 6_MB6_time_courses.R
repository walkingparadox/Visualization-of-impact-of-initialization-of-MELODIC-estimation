#----------------------------------------------------------------------------------------------------------
# Purpose: Create time courses and spectral density for chose components
# Author: Zixi Yang
# Date: 04/18/2019 
#----------------------------------------------------------------------------------------------------------

lapply(c("steadyICA","oro.nifti","neuRosim","JADE","parallel","AnalyzeFMRI","multitaper","snow","corrplot","neurobase")
       , library, character.only=T)
setwd("/cbis4/projects/R_hcp/results_mb6")
# sub29298_ori=readNIfTI('/cbis4/projects/R_hcp/results_mb6/sub_nii_data/sub-29298_ses-ch1_task-rest_run-01_bold.nii.gz',reorient = FALSE)
melodic_ori_ic=readNIfTI('/cbis4/projects/R_hcp/results_mb6/filtered_func_data.nii.gz',reorient = FALSE)
load("/cbis4/projects/R_hcp/results_mb6/sub29298_matchedic100.RData")
ic_se20=readNIfTI(paste0('/cbis4/projects/R_hcp/results_mb6/no_smooth_result_seed',20,'.ica/melodic_IC.nii.gz'),reorient = FALSE)

melmask = ic_se20@.Data[,,,1]!=0
melmask = as.vector(melmask)
mdata = melodic_ori_ic@.Data
dimdata = dim(mdata)
dim(mdata) = c(prod(dimdata[1:3]),dimdata[4])
mdata = mdata[melmask,]
xxs=apply(mdata,1,scale)

#create time courses data M=X*S (matched_ic)
timecourse=list()
chosen_seed=c(17,20) # 20 and 17 are the number of choosed seeds based on 5_ABIDE_matchic_Rdata.R
chosen_comp=c(67,54,16,140,144)#  67,144 are number of choosed components as signals, 
                        # 54, 16 are number of choosed components as artifacts
                        # 67, 54 with high correlations
                        # 144, 16 with low correlations
                        # 140 with the lowest correlation
for (seed in chosen_seed) {
  timecourse[[seed]]=xxs%*%match_ic[[seed]]
}

#create function of plotting time series and spectral density
time_series<-function(seed,comp,timecourse){
  pdf(file=paste0('/cbis4/projects/R_hcp/results_mb6/seed_',seed,'comp',comp,'_matchic_TimeSeries.pdf'))
  # create time series objects from time courses data for visualization
  temp_l = ts(timecourse[[seed]],freq=1/0.96) # 0.96 is the time between volume acquisitions for MB6
  plot(temp_l[,comp],type='l',main=paste("Component",comp,"seed",seed,"Time Series"))
  spec.mtm(temp_l[,comp],main=paste("Component",comp,"seed",seed,"Spectral Density"))
  dev.off()
}

for (seed in chosen_seed) {
  for (comp in chosen_comp) {
    time_series(seed,comp,timecourse)
  }
}

