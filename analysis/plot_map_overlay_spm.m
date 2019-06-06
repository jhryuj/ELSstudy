% make a separate .m file: 

% inputs: 
% anatomical image
% mask
% functional map to overlay.
% threshold map to threshold the functionals
% thresholdvalue
% output directory
% outfile

% example: 
% anat        = '/Volumes/iang/users/lrborch/204b/Data/006-T1/Segmentation/mri/brain.nii';
% mask        = '/Volumes/iang/users/lrborch/204b/Data/006-T1/Segmentation/mri/brain.nii';
% func        = '/Volumes/iang/users/lrborch/204b/Data/006-T1/GLManalysis/Analysis_190520/rois/wholebrain/contrast1_gain-loss.nii';
% funcThresh  = '/Volumes/iang/users/lrborch/204b/Data/006-T1/GLManalysis/Analysis_190520/rois/wholebrain/r2.nii';
% threshval   = 0.05; 
% mrVista_dir = '/Volumes/iang/users/lrborch/204b/Codes/vistasoft-master'; %add mrVista to path
% addpath(genpath(mrVista_dir))
% spm_dir     = ''
% outdir      = '/Volumes/iang/users/lrborch/204b/Data/006-T1/GLManalysis/Analysis_190520/contrastMaps'; %should be the name of the out.
% outfile     = 'gain-loss_threshr2=5';



function plot_map_overlay_spm(anat, mask, func, funcThresh, threshval, outdir,outfile)
cd(outdir)
%% parameters
global model;

model.xacross = 'auto';
model.itype{1} = 'Structural';
model.itype{2} = 'Blobs - Positive';
model.itype{3} = 'Blobs - Negative';
model.imgns{1} = 'Img 1 (Structural)';
model.imgns{2} = 'Img 2 (Blobs - Positive)';
model.imgns{3} = 'Img 3 (Blobs - Negative)';
model.range(:,1) = [0 1];
model.range(:,2) = [0.1; 10];%This selects the colormap range for contrast 1
model.range(:,3) = [0.1; 10];%This selects the colormap range for contrast 2
model.transform = 'axial'; %'axial','coronal','sagittal'
model.axialslice = [-40:5:60]; %[-56:8:86]; % [-40:5:60] %[-72:2:10] for time and z dim switch %[-56:8:86] for normal plots; %This determines the # of slices and thickness that are plotted in the axial plane
model.coronalslice = [-92:8:52]; %This determines the # of slices and thickness that are plotted in the coronal plane

model.imgs{1, 1} = anat; %path to anatomical

%% threshold image;

nii_mask     = readFileNifti(mask);
nii_func     = readFileNifti(func);
nii_thresh   = readFileNifti(funcThresh);
nii_temp     = nii_func; % coregistered nifti. 

%mask out stuff and threshold
data         = int16(nii_func.data).*int16(nii_mask.data >= 1);
data         = data.*int16(abs(nii_thresh.data)>threshval); 
datapos      = data.*int16(data>0);
dataneg      = data.*int16(data<0);

nii_temp.fname       = fullfile(outdir,[outfile '_pos.nii']); 
nii_temp.data       = datapos; 
writeFileNifti(nii_temp); 

nii_temp.fname        = fullfile(outdir,[outfile '_neg.nii']); 
nii_temp.data        = dataneg; 
writeFileNifti(nii_temp);

%% plot stuff
model.imgs{2, 1} = fullfile(outdir,[outfile '_pos.nii']); %Enter the entire path for the first contrast
model.imgs{3, 1} = fullfile(outdir,[outfile '_neg.nii']); %Enter the entire path for the second contrast

display_slices_bai_1 %Function - Confirm that this file is in your path before running this script

print(outfile,'-dpdf', '-r0', '-fillpage') %Creates a PDF of figure 
end

