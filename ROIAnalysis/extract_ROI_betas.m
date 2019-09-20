% data_dir = 'Z:\users\lrborch\ELSReward\Data\';
% subj = '205-T1';

function extract_ROI_betas(data_dir,subj,roilist_file)
%% directories and data
% mrVista for loading niftis
if ispc % assume we're in josh's local machine
    mrVista_dir     = 'Z:\users\lrborch\ELSReward\Codes\vistasoft-master';
    roilist_file    = 'Z:\users\lrborch\ELSReward\Codes\ELSstudy\ROIAnalysis\fsrois.mat'; 
else % assume we're in sherlock
    mrVista_dir = '/oak/stanford/groups/iang/users/lrborch/ELSReward/Codes/vistasoft-master';
end
addpath(genpath(mrVista_dir))

if exist(roilist_file) % check for roilist file 
    load(roilist_file)
else % load all freesurfer ROIs
    load('/oak/stanford/groups/iang/users/lrborch/ELSReward/Codes/ELSstudy/ROIAnalysis/fsrois.mat')
end
    
fs_dir      = fullfile(data_dir,'ELS_T1_FS_subjdir');
glmdir      = fullfile(data_dir,'T1',subj,'glm_nsubjSpace'); 
outroi_dir  = fullfile(glmdir,'rois'); if ~exist(outroi_dir), mkdir(outroi_dir);,end

%% Initialize stuff.
% Load all the beta files
betaTypeList = {'beta','betaSNR','betaPCraw'};
for betaTypeN = 1:length(betaTypeList)
for betaN = 1:11
    eval([betaTypeList{betaTypeN} num2str(betaN) '_file = fullfile(glmdir,sprintf(''' betaTypeList{betaTypeN} '_%04d.nii'',betaN));']);
    eval([betaTypeList{betaTypeN} num2str(betaN) '_nii = readFileNifti(' betaTypeList{betaTypeN} num2str(betaN) '_file);']);
end
end

% load SPM names
load(fullfile(glmdir,'SPM.mat'),'SPM')
varNames = {SPM.Vbeta.descrip};
varNames = varNames(1:11);
takeoutprefix = @(x)(x(29:end-6));
varNames = cellfun(takeoutprefix, varNames, 'UniformOutput',false);

%% Loop through rois
roi = readFileNifti(fullfile(fs_dir,subj,'mri','aparc+aseg.nii')); % roi file here
    
for roiN = 1:length(roiNum)
    roiidx = (roi.data == roiNum(roiN)); %Left NAcc
    roiVoxelN = sum(sum(sum(roiidx)));
    
    disp(['ROI: ' roiName{roiN}])
    
    if roiVoxelN == 0 
        disp(['.No voxels found! Skipping ROI ' num2str(roiNum(roiN)) ' '  roiName{roiN}])
        continue
    end
    
    for betaTypeN = 1:length(betaTypeList)
    for betaN = 1:17
        eval(['beta_nii = ' betaTypeList{betaTypeN} num2str(betaN) '_nii.data']);
        roidata = beta_nii.data(roiidx);
        roidata = roidata(:); % vectorize
        
        eval([betaTypeList{betaTypeN} '_meanmat(roiN,betaN) = nanmean(roidata);']) 
        eval([betaTypeList{betaTypeN} '_stdmat(roiN,betaN) = nanstd(roidata);'])
    end
    end
end

disp('::::::::::::::Saving Files::::::::::::::')

for betaTypeN = 1:length(betaTypeList)
    eval([betaTypeList{betaTypeN} '_table = table(' betaTypeList{betaTypeN} '_meanmat',...
        '''RowNames'',roiName,''VariableNames'',varNames);']);
    filename = fullfile(outroi_dir,[betaTypeList{betaTypeN} '.xlsx']);
    eval(['writetable(' betaTypeList{betaTypeN} '_table,filename)']);
end

save(fullfile(outroi_dir,'roi_betas.mat'),'*_table');
    
disp('::::::::::::::ROI_analysis done!::::::::::::::')
end