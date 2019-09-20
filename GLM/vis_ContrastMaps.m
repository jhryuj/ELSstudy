%% directories
% data_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Data/';
% subj = '006-T1';
% mrVista_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/vistasoft-master'; %add mrVista to path
% outfolder = ['Analysis_190520']; 

% data_dir = '/Volumes/iang/users/lrborch/204b/Data/';
% subj = '006-T1';
% mrVista_dir = '/Volumes/iang/users/lrborch/204b/Codes/vistasoft-master'; %add mrVista to path
% outfolder = ['Analysis_190520'];

%% function 
function vis_ContrastMaps(data_dir,subj,mrVista_dir,outfolder)

GLM_dir = fullfile(data_dir,subj,'GLManalysis',outfolder); 
GLMroi_dir = fullfile(GLM_dir,'rois');
contrastout_dir = fullfile(GLM_dir,'contrastMaps'); if ~exist(contrastout_dir), mkdir(contrastout_dir);end
roi_dir = fullfile(data_dir,subj,'rois');

addpath(genpath(mrVista_dir));

% load design matrix and column names
load(fullfile(GLM_dir, 'designmat.mat'))

% define contrasts of interest
contrastNames = {'anteGain-anteLoss'; 'anteGain-anteNeut'; 'anteLoss-anteNeut'; ...
    'gain-loss'; 'gain-nogain'; 'loss-noloss'};
contrastIdx   = [1, 2; 1, 3; 2, 3;4,5; 4,6; 5,7]; % the first column minus the second column.

if length(contrastNames) ~= size(contrastIdx,1)
    error('Check contrast names and indices')
end

%% histograms
% get a histogram of errors
% get histograms of betas

% for each ROI
roiList = dir(GLMroi_dir);
roiList = roiList(3:end); 

for roiN = 1:length(roiList)
    disp(['Histograms: Running Roi ' roiList(roiN).name])
    
    cd(fullfile(roiList(roiN).folder,roiList(roiN).name))
    
    mkdir(fullfile(roiList(roiN).folder,roiList(roiN).name,'Histograms'));
    cd(fullfile(roiList(roiN).folder,roiList(roiN).name,'Histograms'))
    load(fullfile(roiList(roiN).folder,roiList(roiN).name,'regression.mat'))
    
    distribution_histogram(r2, ['r2'])
    
    for betaN = 1:9
        distribution_histogram(betamatrix(:,betaN), ['beta_' columnNames{betaN}])
    end
end

%% get the contrast maps.
disp(['::::: Getting contrast maps :::::'])
cd(fullfile(GLMroi_dir,'wholebrain'))
niitemplate = readFileNifti(fullfile(data_dir,subj,'spm','crkidmid_3mm_2sec_raw_00001.nii')); % coregistered nifti. 
load(fullfile(roi_dir,'wholebrain.mat'))
load(fullfile(GLMroi_dir,'wholebrain','regression.mat'))

N = size(roidata_pc,2);
p = size(designmat,2);
designmat = designmat(end-N+1:end,:);
designvar = pinv(designmat'*designmat);

for contrastN = 1:length(contrastNames) 
    disp(['Running contrast ' contrastNames{contrastN}])
    % select contrasts
    c = zeros(16,1); 
    c(contrastIdx(contrastN,1)) = 1; c(contrastIdx(contrastN,2)) = -1; 
    
    contrast = betamatrix*c;
    contrast_t = zeros(size(contrast));
    contrast_var = c'*designvar*c; 
    
    for voxelN = 1:size(betamatrix,1)
        yvar = 1/(N-p-1)*norm(res(voxelN,:))^2; 
        contrast_t(voxelN,:)   = contrast(voxelN,:)/(sqrt(yvar)*sqrt(contrast_var));
    end
     
    cnii            = niitemplate; 
    cnii.fname      = fullfile(contrastout_dir,['contrast_ ' contrastNames{contrastN} '_raw.nii']); 
    roi3d           = double(roiidx);
    roi3d(roiidx)   = contrast;
    cnii.data       = roi3d; 
    writeFileNifti(cnii); 
    
    cnii.fname      = fullfile(contrastout_dir,['contrast_ ' contrastNames{contrastN} '_tvalue.nii']); 
    roi3d           = double(roiidx);
    roi3d(roiidx)   = contrast_t;
    cnii.data       = roi3d; 
    writeFileNifti(cnii); 
end

disp(['::::vis_ContrastMaps DONE!!!'])
end
