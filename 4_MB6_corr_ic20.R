#----------------------------------------------------------------------------------------------------------
# Purpose: Plotted median correlation of argmax and 99 seeds for each components with 
#          0.975, 0.025 quantile correlations as bands. To find the corr of each comps
# Author: Zixi Yang
# Date: 04/18/2019 
#----------------------------------------------------------------------------------------------------------
lapply(c("steadyICA","oro.nifti","neuRosim","JADE","parallel","AnalyzeFMRI","multitaper","snow","corrplot","neurobase","ggplot2","moments")
       , library, character.only=T)
setwd("/cbis4/projects/R_hcp/results_mb6")
load("/cbis4/projects/R_hcp/results_mb6/matchedic100.RData")
#----------------------------------------------------------------------------------------------------------

n.comp=159
coric20=matrix(rep(0,100*n.comp),ncol=n.comp)
c_m=rep(0,n.comp)
c_975=rep(0,n.comp)
c_025=rep(0,n.comp)

for (k in 1:n.comp) {
  for (j in 1:100) {
    # calculate (100 X number of components) correlation matrix for argmax seeds versus the rest 99 seeds
    coric20[j,k]=cor(match_ic[[20]][,k],match_ic[[j]][,k])
  }
  # calculate quantile 0.025, 0.5, 0.975 correlations of argmax vs 99 seeds for each components
  c_m[k]=quantile(coric27[,k],probs = 0.5)
  c_975[k]=quantile(coric27[,k],probs = 0.975)
  c_025[k]=quantile(coric27[,k],probs = 0.025)
}

# create ordered data frame of quantile 0.025, 0.5, 0.975 correlations by median correlations
a=data.frame(c_m,c_975,c_025)
new=a[order(c_m),]
c_n=c(1:n.comp)

ggplot(data = new, aes(x = c_n, y = new$c_m)) + 
  geom_point() +
  geom_ribbon(aes(ymin = new$c_025, ymax = new$c_975),alpha = 0.5, fill = "grey70") +
  xlab("Components") +
  ylab("Median Correlation") +
  geom_vline(xintercept = 31,linetype="dashed", color = "red") +
  geom_text(aes(x=31, label="\ncomponents with high correlations > 0.9", y=0.5,fontface=3), colour="blue",angle=90,size=5) +
  geom_text(aes(x=31, label="components with low correlations < 0.9\n", y=0.5,fontface=3), colour="red",angle=90,size=5)

ggsave("/cbis4/projects/R_hcp/results_mb6/linear_corr_ABIDE_vline.png")
#----------------------------------------------------------------------------------------------------------
#to find all the components with median correlation smaller than 0.9 and enlarged plot
dim(new[new$c_m<=0.9,])

c_n_2=c(1:31)
labl= as.character(new$c[1:31])
pdf(file="/cbis4/projects/R_hcp/results_mb6/linear_low_corr_sub29298.pdf")
ggplot(data = new[1:31,], aes(x = c_n_2, y = c_m)) +
  geom_point() +
  geom_ribbon(aes(ymin = c_025, ymax = c_975),alpha = 0.5, fill = "grey70") +
  xlim(labl)+
  xlab("Components")+
  ylab("Median Correlation")
dev.off()

new[new$c_m<=0.9,]$c

#----------------------------------------------------------------------------------------------------------
# created x-axis as kurtosis of components with argmax,
# y-axis as median correlation of 100 seeds throughout all components

k_ic=rep(0,n.comp)
for (i in 1:n.comp) {
  k_ic[i]=kurtosis(match_ic[[20]][,i]) 
}

# ordered kurtosis of components by median correlations of components
a_k=data.frame(c_m,c_975,c_025,k_ic)
new_k=a_k[order(c_m),]

pdf(file="/cbis4/projects/R_hcp/results_mb6/linear_corrcomp_kur_sub29298.pdf")
ggplot(data = new_k, aes(x = new_k$k_ic, y = new_k$c_m)) + 
  geom_point() +
  geom_ribbon(aes(ymin = new_k$c_025, ymax = new_k$c_975),alpha = 0.5, fill = "grey70") + 
  xlab("Kurtosis of Components") +
  ylab("Median Correlation")
dev.off()
