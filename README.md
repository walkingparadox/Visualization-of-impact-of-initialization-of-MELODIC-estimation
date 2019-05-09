# Visualization-of-impact-of-initialization-of-MELODIC-estimation
Purpose: 
Visualization for the impact of multiple initializations in optimization of independent components in fMRI when using MELODIC software

1. Used bash script to obtain estimations from MELODIC software
Bash script:
for i in {1..100}; do melodic -i filtered_func_data.nii.gz -o no_smooth_result_seed${i}.ica --tr=0.72 --seed=${i} --nobet --report --Oall -d 80 & done

Notation：
filtered_func_data.nii.gz is the original nifti data, 80 is the number of components, 100 is the number of initializations (seeds)
Here, we used ABIDE sub29298 data as an example 

2. Calculated argmax initilization values in 1_ABIDE_argmax.R script

3. Visualized dissimilarities through Multidimensional Scaling for estimations of multiple initializations to find possible clustered structure in 2_ABIDE_cmd_plot.R script

4. Visualized correlation matrices for multiple initializations in 3_ABIDE_corr_matrix.R
  1: the quantile 0.025, 0.5, 0.975 correlation matrices for all components 
  2: the quantile 0.025, 0.5, 0.975 correlation matrices for signals, artifacts, unknowns to better clarify the difference
  3: the quantile 0.025, 0.5, 0.975 correlation matrices for choosed components related to Orthographic views and Time courses

5. Visualized median correlations of initializations among all components as well as kurtosis of components with quantile 0.025 and 0.975 correlation bands to find certain components with high correlations versus low correlations in 4_ABIDE_corr_ic27.R 

6. Created mathced components with original data dimension for better view in wb_view software for choosed components to compare any differences of a component with various initial values in 5_ABIDE_matchic_Rdata.R

7. Vislualized Time courses and Spectral density for choosed components to compare any differences of a component with various initial values as a complement in 6_ABIDE_time_courses.R

