% Josh Ryu; jhryu25@stanford.edu
% 2019/5/13

%% directories
%spmdir = 'D:\Dropbox\Stanford\Current\Psych 204b\Project\Codes\spm12\spm12';
%data_dir = 'D:\Dropbox\Stanford\Current\Psych 204b\Project\Raw Data\';
%subj_id = '100-T1';

% spmdir = 'Z:\users\lrborch\204b\Codes\spm12';
% data_dir = 'Z:\users\lrborch\204b\Data\';
% subj_id = '074-T1';
% behavior_dir = 'Z:\users\lrborch\204b\Data\072-T1\Behavioral\072-T1\model7'
% 
% spmdir = '/Volumes/groups/iang/users/lrborch/ELSReward/Codes/spm12';
% data_dir = '/Volumes/groups/iang/users/lrborch/ELSReward/Data/T1/';
% subj_id = '074-T1';

function preprocessing_spm(spmdir,data_dir,subj_id)

%% Organize data. 
addpath(spmdir) %path to spm.
spm('defaults', 'fmri')
spm_jobman('initcfg')
spm_get_defaults('cmdline',true)
 
data_subj_dir = fullfile(data_dir,subj_id);
cd(data_subj_dir)

% make spm output directory
prep_dir = fullfile(data_subj_dir,'spm');
if ~exist(prep_dir),mkdir(prep_dir);,end

% figure out how to use ac-pc images. vistasoft has its own datastructure.
% nii = readFileNifti(fullfile(data_subj_dir,T1_niigz.name)); 
% nii.fname = fullfile(prep_dir,T1_niigz.name(1:end-3)); 
% writeFileNifti(nii)
% [status,result] = system(['"C:\Program Files\7za920\7za.exe" -y x ' '"' filename{f} '"' ' -o' '"' outputDir '"']);

kidmid_nii  = dir(fullfile(data_subj_dir,'kidmid*.nii')); %kidmid_nii  = fullfile(kidmid_nii.folder, kidmid_nii.name);
T1_nii      = dir(fullfile(data_subj_dir,'T1*raw_acpc.nii')); %T1_nii  = fullfile(T1_nii.folder, T1_nii.name);

% nii = readFileNifti(fullfile(kidmid_nii.folder,kidmid_nii.name));
%% SPM 
cd(prep_dir)

%% Preprocessing
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

spm_jobman('run',matlabbatch2);
matlabbatch =[];
save('matlabbatch_preprocessing.mat','matlabbatch')

%% GLM analysis
behavior_dir = fullfile(data_dir,subj_id,'Behavioral',subj_id,'model7');

f = spm_select('FPList', prep_dir, '^kidmid.*\.nii$');

TR = 2;
skipscans = 4; % remove 4 scans in the beginning

% specify GLM
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR; 
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

% build regressor 
% remove 3 TRs
% behfiles = {'_ant_all.txt', '_delay_all.txt','_outcome_all.txt','_target_all.txt','_missed.txt',...
%         '_ant_gain.txt', '_ant_loss.txt','_ant_neut.txt','_ant_nongain.txt',...
%         '_ant_nonloss.txt','_gain.txt','_loss.txt','_no_gain.txt',...
%         '_no_loss.txt','_nongain_neutral.txt','_nonloss_neutral.txt','_outcome_neutral.txt'};

behfiles = {'_ant_gain.txt', '_ant_loss.txt','_ant_neut.txt','_gain.txt','_loss.txt','_no_gain.txt','_no_loss.txt',...
        '_outcome_neutral.txt','_delay_all.txt','_target_all.txt','_missed.txt'};
    
for condn = 1:length(behfiles)
    a = load(fullfile(behavior_dir,[subj_id behfiles{condn}]));    
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(condn).name = behfiles{condn}(2:end-4);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(condn).onset = a(:,1); 
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(condn).duration = a(:,2);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(condn).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(condn).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(condn).orth = 1;
end

matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};

rpfile =  spm_select('FPList', prep_dir, '^rp_kidmid.*\.txt$');
mvmt = load(rpfile);
mvmt = mvmt(skipscans+1:end,:);
mvmt_names = {'move_x','move_y','move_z','move_p','move_r','move_y'};

for idx = 1:6
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(idx).name = mvmt_names{idx};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(idx).val  = mvmt(:,idx);
end

matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;

%% glm in subject space
cd(data_subj_dir); glm_dir = fullfile(data_subj_dir,'glm_nsubjSpace'); mkdir(glm_dir); cd(glm_dir);

% specify
matlabbatch{1}.spm.stats.fmri_spec.dir = {glm_dir};
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_file(f(skipscans+1:end,:),'prefix','cr'));% remove 4 TRs 
spm_jobman('run',matlabbatch(1));

% plot design matrix before whitening
SPM = load(fullfile(glm_dir,'SPM.mat'));
fid = figure('Position', [120 39 1694 957],'DefaultAxesFontSize',18,'defaultLineLineWidth',2);
imagesc(SPM.SPM.xX.X);c=colorbar;ylabel('images');xlabel('Parameters');c.Label.String = 'au (depends on parameter)';
ax1 = gca;ax1.XTick = 1:length(SPM.SPM.xX.name); ax1.XTickLabel = SPM.SPM.xX.name;
set(ax1,'TickLabelInterpreter', 'none');ax1.XTickLabelRotation = 45;
title([subj_id ' design matrix'])
saveas(fid,fullfile(glm_dir,['designmatrix.fig']))    
fid.PaperPositionMode = 'auto';
print(fullfile(glm_dir,['designmatrix']),'-dpng','-r0');
close(fid);

% estimate
matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(glm_dir,'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

spm_jobman('run',matlabbatch(2));
save('matlabbatch_glm_subjspace.mat','matlabbatch')

%% glm in normalized space
cd(data_subj_dir);glm_dir = fullfile(data_subj_dir,'glm_normSpace');mkdir(glm_dir);cd(glm_dir)

% specify
matlabbatch{1}.spm.stats.fmri_spec.dir = {glm_dir};
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_file(f(skipscans+1:end,:),'prefix','swcr')); % remove 4 TRs
spm_jobman('run',matlabbatch(1));

% plot design matrix before whitening
SPM = load(fullfile(glm_dir,'SPM.mat'));
fid = figure('Position', [120 39 1694 957],'DefaultAxesFontSize',18,'defaultLineLineWidth',2);
imagesc(SPM.SPM.xX.X);c=colorbar;ylabel('images');xlabel('Parameters');c.Label.String = 'au (depends on parameter)';
ax1 = gca;ax1.XTick = 1:length(SPM.SPM.xX.name); ax1.XTickLabel = SPM.SPM.xX.name;
set(ax1,'TickLabelInterpreter', 'none');ax1.XTickLabelRotation = 45;
title([subj_id ' design matrix'])
saveas(fid,fullfile(glm_dir,['designmatrix_prewhiten.fig']))    
fid.PaperPositionMode = 'auto';
print(fullfile(glm_dir,['designmatrix_prewhiten']),'-dpng','-r0');
close(fid);

% estimate
matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(glm_dir,'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

spm_jobman('run',matlabbatch(2));
save('matlabbatch_glm_normspace.mat','matlabbatch')

%% combine 3D images into 4D for visualization
f3D = spm_select('FPList', prep_dir, '^crkidmid.*\.nii$');
matlabbatch{1}.spm.util.cat.vols    = cellstr(f3D);
matlabbatch{1}.spm.util.cat.name    = 'All_crKidMid4D.nii';
matlabbatch{1}.spm.util.cat.dtype   = 4;
matlabbatch{1}.spm.util.cat.RT      = TR;

f3D = spm_select('FPList', prep_dir, '^swcrkidmid.*\.nii$');
matlabbatch{2}.spm.util.cat.vols    = cellstr(f3D);
matlabbatch{2}.spm.util.cat.name    = 'All_swcrKidMid4D.nii';
matlabbatch{2}.spm.util.cat.dtype   = 4;
matlabbatch{2}.spm.util.cat.RT      = TR;

spm_jobman('run',matlabbatch);
matlabbatch = [];
end