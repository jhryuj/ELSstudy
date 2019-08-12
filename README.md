# ELSstudy
fMRI analysis for the ELS KIDMID task <br />

##Codes for analysis: <br />

### Preprocessing <br />
  - SPM: prep_coregSPM.sh; behaviorAnalysis.m <br />
  - Freesurfer: prep_segmentation.sh <br />
  - Convert freesurfer brain mask to nii: convertMgz2Nii.sh <br />
  
### Behavioral analysis: <br />
  - behaviorAnalysis: build_designMat.m <br />
  
### ROIs: <br />
  - Generate a list of ROIS from freesurfer: roiListGen.m <br />
  - Extract ROI: ROI_analysis.m; <br />
  
### GLM: <br />
  - Build design matrix: build_designMat.m <br />
  - Run GLM on ROIs: GLM_analysis.m <br />
  - Plot ROI timectourses and GLM model: roi_plottimecourses.m <br />
  - Statistical maps for each subject: is_ContrastMaps.m <br />
    - SPM map, filtering based on R-squared or t-value <br />
    - Beta histograms: distribution of betas for each ROI. <br />
    - percent variance explained histogram <br />
  - Plotting function (using SPM): vis_ContrastMaps_plot.m <br />
    - Needs the plotting folder and SPM12 <br />
    
### Functional connectivity: <br />
  - Analysis: fConn_analysis.m <br />
  - Plotting: fConn_analysis_plot.m <br />
  
### Group analysis: <br />
  - Second-level analysis for contrasts: group_analysis.m <br />
  - Second-level analysis for connectivity: group_analysis_fConn.m <br />
  - Bar plots: group_plotResults.m <br />
