# Visualization-of-impact-of-initialization-of-MELODIC-estimation
------------------------------------------------------------------------------------------------------------------------------
### Purpose: 
Visualization for the impact of multiple initializations in optimization of independent components in fMRI when using MELODIC software

### Author: 
Zixi Yang

### Thanks to:
Benjamin B. Risk

------------------------------------------------------------------------------------------------------------------------------

### Data Sources: 

  - ABIDE dataset:

    http://fcon_1000.projects.nitrc.org/indi/abide/databases.html

  - MB6 tutorial dataset:

    https://www.fmrib.ox.ac.uk/primers/rest_primer/3.1_ICA_single_subject/index.html


### Installation:

  - R packages:

```r
    > lapply(c("steadyICA","oro.nifti","neuRosim","JADE","parallel","AnalyzeFMRI","multitaper","snow","moments","corrplot")
       , install.packages)
```

  - FSL:
  
    https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation

  - wb_view:

    https://www.humanconnectome.org/software/get-connectome-workbench

### Steps:

  - 1. Used bash script to obtain estimations from MELODIC software

    Bash script:

```sh
$ for i in {1..100}; do melodic -i filtered_func_data.nii.gz -o no_smooth_result_seed${i}.ica --tr=0.72 --seed=${i} --nobet --report --Oall -d 80 & done
```

   Notation：
   filtered_func_data.nii.gz is the original nifti data, 80 is the number of components, 100 is the number of initializations    (seeds)
   Here, we used ABIDE sub29298 data as an example 

  - 2. Calculated argmax initilization values in 1_ABIDE_argmax.R script

  - 3. Visualized dissimilarities through Multidimensional Scaling for estimations of multiple initializations to find possible clustered structure in 2_ABIDE_cmd_plot.R script

  - 4. Visualized correlation matrices for multiple initializations in 3_ABIDE_corr_matrix.R
    - 1: the quantile 0.025, 0.5, 0.975 correlation matrices for all components 
    - 2: the quantile 0.025, 0.5, 0.975 correlation matrices for signals, artifacts, unknowns to better clarify the difference
    - 3: the quantile 0.025, 0.5, 0.975 correlation matrices for choosed components related to Orthographic views and Time courses

  - 5. Visualized median correlations of initializations among all components as well as kurtosis of components with quantile 0.025 and 0.975 correlation bands to find certain components with high correlations versus low correlations in 4_ABIDE_corr_ic27.R 

  - 6. Created mathced components with original data dimension for better view in wb_view software for choosed components to compare any differences of a component with various initial values in 5_ABIDE_matchic_Rdata.R

  - 7. Vislualized Time courses and Spectral density for choosed components to compare any differences of a component with various initial values as a complement in 6_ABIDE_time_courses.R
  
  - 8. Notation:
  For MB6 data, repeat all the seven steps previously, and the corresponding R scripts are 1_MB6_argmax.R, 2_MB6_cmd_plot.R, 3_MB6_corr_matrix.R, 4_MB6_corr_ic20.R, 5_MB6_matchic_Rdata.R, 6_MB6_time_courses.R.  

### Thank you!
