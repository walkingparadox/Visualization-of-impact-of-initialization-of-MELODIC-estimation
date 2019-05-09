#----------------------------------------------------------------------------------------------------------
# Purpose: Created cmdscale plot to visualize the Frobenius distance of estimations of 100 seeds
#          To find out possible cluster related to arg max 
# Author: Zixi Yang
# Date: 04/18/2019 
#----------------------------------------------------------------------------------------------------------

lapply(c("steadyICA","oro.nifti","neuRosim","JADE","parallel","AnalyzeFMRI","multitaper","snow","corrplot","neurobase")
       , library, character.only=T)
setwd("/cbis4/projects/R_hcp/results_mb6")
sub29298ori=readNIfTI('/cbis4/projects/R_hcp/results_mb6/sub_nii_data/sub-29298_ses-ch1_task-rest_run-01_bold.nii.gz',reorient = FALSE)

#----------------------------------------------------------------------------------------------------------
# create matrix for original dataset
o = sub29298ori@.Data
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
# calculate masked matrix for seed 27 (argmax) as template for match
n.comp = 80
ic_seed27=readNIfTI(paste0('/cbis4/projects/R_hcp/results_mb6/sub-29298ica_result_100seeds/sub-29298_ses-ch1_task-rest_run-01_bold',27,'.ica/melodic_IC.nii.gz'),reorient = FALSE)
s27=icmatrix(ic_seed27,80)

#----------------------------------------------------------------------------------------------------------
# calculate matched components as match_ic
ic_seed=list()
s=list()
match_ic=list()
for (k in 1:100) {
 ic_seed[[k]]=readNIfTI(paste0('/cbis4/projects/R_hcp/results_mb6/sub-29298ica_result_100seeds/sub-29298_ses-ch1_task-rest_run-01_bold',k,'.ica/melodic_IC.nii.gz'),reorient = FALSE)
 s[[k]]=icmatrix(ic_seed[[k]],n.comp)
 match_ic[[k]]=matchICA(S=s[[k]],template=s27)
 print(k)
}
save(match_ic, file="/cbis4/projects/R_hcp/results_mb6/sub29298_matchedic100.RData")

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
pdf("/cbis4/projects/R_hcp/results_mb6/sub29298_cmd100seeds_.pdf")
plot(x, y, xlab = "", ylab = "", asp = 1, axes = T,
     main = "cmdscale(100 different seeds)",col=ifelse(x==x[27], "red", "black"),pch=ifelse(x==x[27], 19, 1))
text(x, y, cex = ifelse(x==x[27], 0.8, 0.5),pos = 3)
dev.off()













