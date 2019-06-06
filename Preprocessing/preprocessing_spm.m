% Josh Ryu; jhryu25@stanford.edu
% 2019/5/13

%% directories
%spmdir = 'D:\Dropbox\Stanford\Current\Psych 204b\Project\Codes\spm12\spm12';
%data_dir = 'D:\Dropbox\Stanford\Current\Psych 204b\Project\Raw Data\';
%subj_id = '100-T1';

function preprocessing_spm(spmdir,data_dir,subj_id)

%% Organize data. 
addpath(spmdir) %path to spm.
% spm('defaults', 'fmri')
% spm_jobman('initcfg')
% spm_get_defaults('cmdline',true)
 
data_subj_dir = fullfile(data_dir,subj_id);
cd(data_subj_dir)

% make spm output directory
prep_dir = fullfile(data_subj_dir,'spm');
mkdir(prep_dir)

% find kidmid file, and T1. unzip in the spm folder
kidmid_niigz = dir('kidmid*.nii.gz');
T1_niigz = dir('T1*raw.nii.gz');
gunzip(fullfile(data_subj_dir,kidmid_niigz.name))
gunzip(fullfile(data_subj_dir,T1_niigz.name))

% figure out how to use ac-pc images. vistasoft has its own datastructure.
% nii = readFileNifti(fullfile(data_subj_dir,T1_niigz.name)); 
% nii.fname = fullfile(prep_dir,T1_niigz.name(1:end-3)); 
% writeFileNifti(nii)
% [status,result] = system(['"C:\Program Files\7za920\7za.exe" -y x ' '"' filename{f} '"' ' -o' '"' outputDir '"']);

kidmid_nii  = dir(fullfile(data_subj_dir,'kidmid*.nii')); %kidmid_nii  = fullfile(kidmid_nii.folder, kidmid_nii.name);
T1_nii      = dir(fullfile(data_subj_dir,'T1*raw.nii')); %T1_nii  = fullfile(T1_nii.folder, T1_nii.name);

%% SPM batch 
cd(prep_dir)

f_raw = spm_select('FPList', data_subj_dir, kidmid_nii.name);
a = spm_select('FPList', data_subj_dir , T1_nii.name);

% split into 3D
matlabbatch{1}.spm.util.split.vol = cellstr(f_raw);
matlabbatch{1}.spm.util.split.outdir = cellstr(prep_dir);
spm_jobman('run',matlabbatch);
matlabbatch = [];

% realign. calculate motion. 
f = spm_select('FPList', prep_dir, '^kidmid.*\.nii$');

matlabbatch{1}.spm.spatial.realign.estwrite.data{1} = cellstr(f); %cfg_dep('4D to 3D File Conversion: Series of 3D Volumes', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','splitfiles'));
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

% coregister
matlabbatch{2}.spm.spatial.coreg.estwrite.ref = cellstr(a);
matlabbatch{2}.spm.spatial.coreg.estwrite.source = cellstr(spm_file(f(1,:),'prefix','mean'));
matlabbatch{2}.spm.spatial.coreg.estwrite.other = cellstr(spm_file(f,'prefix','r'));
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.prefix = 'c';

% normalize
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.vol = cellstr(a);
matlabbatch{3}.spm.spatial.normalise.estwrite.subj.resample = cellstr(spm_file(f,'prefix','cr'));
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.tpm = {fullfile(spmdir, 'tpm','TPM.nii')};
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
matlabbatch{3}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
matlabbatch{3}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
                                                             78 76 85];
matlabbatch{3}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
matlabbatch{3}.spm.spatial.normalise.estwrite.woptions.interp = 4;
matlabbatch{3}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';

% smoothing 
matlabbatch{4}.spm.spatial.smooth.data = cellstr(spm_file(f,'prefix','wcr'));
matlabbatch{4}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{4}.spm.spatial.smooth.dtype = 0;
matlabbatch{4}.spm.spatial.smooth.im = 0;
matlabbatch{4}.spm.spatial.smooth.prefix = 's';

spm_jobman('run',matlabbatch);
matlabbatch =[];

% combine 3D images into 4D
f3D = spm_select('FPList', prep_dir, '^crkidmid.*\.nii$');
matlabbatch{1}.spm.util.cat.vols = cellstr(f3D);
matlabbatch{1}.spm.util.cat.name = 'All_crKidMid4D.nii';
matlabbatch{1}.spm.util.cat.dtype = 4;
matlabbatch{1}.spm.util.cat.RT = NaN;
spm_jobman('run',matlabbatch);
matlabbatch = [];
end