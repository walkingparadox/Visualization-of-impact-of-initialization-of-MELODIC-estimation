#----------------------------------------------------------------------------------------------------------
# Purpose: Created cmdscale plot to visualize the Frobenius distance of estimations of 100 seeds
#          To find out possible cluster related to arg max 
# Author: Zixi Yang
# Date: 04/18/2019 
#----------------------------------------------------------------------------------------------------------

lapply(c("steadyICA","oro.nifti","neuRosim","JADE","parallel","AnalyzeFMRI","multitaper","snow","corrplot","neurobase")
       , library, character.only=T)
setwd("/cbis4/projects/R_hcp/results_mb6")
# sub29298ori=readNIfTI('/cbis4/projects/R_hcp/results_mb6/sub_nii_data/sub-29298_ses-ch1_task-rest_run-01_bold.nii.gz',reorient = FALSE)
melodic_ori_ic=readNIfTI('/cbis4/projects/R_hcp/results_mb6/filtered_func_data.nii.gz',reorient = FALSE)

#----------------------------------------------------------------------------------------------------------
# create matrix for original dataset
o = melodic_ori_ic@.Data
dimdata = dim(o)
dim(o) = c(prod(dimdata[1:3]),dimdata[4])
mask = o[,1]!=0
o = o[mask,]

#----------------------------------------------------------------------------------------------------------
# create masked matrix for components of seed 1~100
icmatrix <- function(ic_seed,n.comp){
 melmask = ic_seed@.Data[,,,1]!=0
 melmask = as.vector(melmask)
 icmelodic_matrix = ic_seed@.Data
 dim(icmelodic_matrix) = c(prod(dimdata[1:3]),n.comp)
 icmelodic_matrix = icmelodic_matrix[melmask,]
 return(icmelodic_matrix)
}

#----------------------------------------------------------------------------------------------------------
# calculate masked matrix for seed 20 (argmax) as template for match
n.comp = 159
ic_seed20=readNIfTI(paste0('/cbis4/projects/R_hcp/results_mb6/no_smooth_result_seed',20,'.ica/melodic_IC.nii.gz'),reorient = FALSE)
s20=icmatrix(ic_seed20,n.comp)

#----------------------------------------------------------------------------------------------------------
# calculate matched components as match_ic
ic_seed=list()
s=list()
match_ic=list()
for (k in 1:100) {# k is the number of seeds
 ic_seed[[k]]=readNIfTI(paste0('/cbis4/projects/R_hcp/results_mb6/no_smooth_result_seed',k,'.ica/melodic_IC.nii.gz'),reorient = FALSE)
 s[[k]]=icmatrix(ic_seed[[k]],n.comp)
 match_ic[[k]]=matchICA(S=s[[k]],template=s27)
 print(k)
}
save(match_ic, file="/cbis4/projects/R_hcp/results_mb6/matchedic100.RData")

#----------------------------------------------------------------------------------------------------------
# calculate Frobenius distance of ic by using frobICA
distance=matrix(rep(0,100*100),ncol=100)
for (i in 1:99) {
  for (j in (i+1):100) {
    distance[i,j]=sum((match_ic[[i]][,1]-match_ic[[j]][,1])^2)
    distance[j,i]=distance[i,j]
  }
}

loc <- cmdscale(distance)
x <- loc[, 1]
y <- -loc[, 2]
#----------------------------------------------------------------------------------------------------------
# plot for cmdscale
# 20 is the number of argmax, emphasize it with red dot
pdf("/cbis4/projects/R_hcp/results_mb6/mb6_cmd100seeds_.pdf")
plot(x, y, xlab = "", ylab = "", asp = 1, axes = T,
     main = "cmdscale(100 different seeds)",col=ifelse(x==x[20], "red", "black"),pch=ifelse(x==x[20], 19, 1))
text(x, y, cex = ifelse(x==x[20], 0.8, 0.5),pos = 3)
dev.off()













