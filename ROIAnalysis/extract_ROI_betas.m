% data_dir = 'Z:\users\lrborch\ELSReward\Data\';
% subj = '205-T1';

function extract_ROI_betas(data_dir,subj,roilist_file)
%% directories and data
% mrVista for loading niftis
if ispc % assume we're in josh's local machine
    mrVista_dir     = 'Z:\users\lrborch\ELSReward\Codes\vistasoft-master';
    if ~exist('roilist_file','var') 
    roilist_file    = 'Z:\users\lrborch\ELSReward\Codes\ELSstudy\ROIAnalysis\fsrois.mat'; 
    end
elseif ismac % assume joshs computer
    mrVista_dir     = '/Volumes/groups/iang/users/lrborch/ELSReward/Codes/vistasoft-master';
    if ~exist('roilist_file','var') 
    roilist_file    = '/Volumes/groups/iang/users/lrborch/ELSReward/Codes/ELSstudy/ROIAnalysis/fsrois.mat'; 
    end
else % assume we're in sherlock
    mrVista_dir     = '/oak/stanford/groups/iang/users/lrborch/ELSReward/Codes/vistasoft-master';
    if ~exist('roilist_file','var') 
    roilist_file    = '/oak/stanford/groups/iang/users/lrborch/ELSReward/Codes/ELSstudy/ROIAnalysis/fsrois.mat'; 
    end
end

addpath(genpath(mrVista_dir))
load(roilist_file)

if contains(subj,'T1'), datafolder = 'T1';
elseif contains(subj,'TK1'), datafolder = 'TK1';
end
    
fs_dir      = fullfile(data_dir,'ELS_T1_FS_subjdir');
glmdir      = fullfile(data_dir,datafolder,subj,'glm_nsubjSpace'); 
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

% initialize result matrices
for betaTypeN = 1:length(betaTypeList)
for betaN = 1:11
    eval([betaTypeList{betaTypeN} '_meanmat = nan(length(roiNum),length(varNames));']) 
    eval([betaTypeList{betaTypeN} '_stdmat  = nan(length(roiNum),length(varNames));'])
end
end


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
    for betaN = 1:11
        eval(['beta_nii = ' betaTypeList{betaTypeN} num2str(betaN) '_nii.data;']);
        roidata = beta_nii(roiidx);
        roidata = roidata(:); % vectorize
        
        eval([betaTypeList{betaTypeN} '_meanmat(roiN,betaN) = nanmean(roidata);']) 
        eval([betaTypeList{betaTypeN} '_stdmat(roiN,betaN) = nanstd(roidata);'])
    end
    end
end

disp('::::::::::::::Saving Files::::::::::::::')

for betaTypeN = 1:length(betaTypeList)
    eval([betaTypeList{betaTypeN} '_table = array2table(' betaTypeList{betaTypeN} '_meanmat,',...
        '''RowNames'',roiName,''VariableNames'',varNames);']);
    filename = fullfile(outroi_dir,[betaTypeList{betaTypeN} '.xlsx']);
    % filename = fullfile(outroi_dir,[betaTypeList{betaTypeN} '.csv']); 
    eval(['writetable(' betaTypeList{betaTypeN} '_table,filename,''WriteRowNames'',true);']);
end

save(fullfile(outroi_dir,'roi_betas.mat'),'*_table');
    
disp('::::::::::::::ROI_analysis done!::::::::::::::')
end