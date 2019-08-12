% excluded subjects (oops): 
% - 201-T1: no neutral behavior?
% - 157-T1: could not segment
% - 097-T1: could not unzip kidmid file. 

% data_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Data/';
% roilist_file = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/analysis/aseg+aparc_selected.mat';
% analysis_folder = ['Analysis_190520'];
% mrVista_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/vistasoft-master'; %add mrVista to path
% groupdir = '/oak/stanford/groups/iang/users/lrborch/204b/GroupAnalysis';

function group_analysis(data_dir, roilist_file,mrVista_dir,groupdir,analysis_folder)

lowELS  = {'100-T1','171-T1','074-T1','088-T1','116-T1','072-T1'};
highELS = {'006-T1', '092-T1','214-T1'};
allsubjs = [lowELS, highELS];

contrastNames = {'anteGain-anteLoss'; 'anteGain-anteNeut'; 'anteLoss-anteNeut'; ...
    'gain-loss'; 'gain-nogain'; 'loss-noloss'};
betaNames = {'ant_gain','ant_loss','ant_neut','gain','loss','no_gain','no_loss','outcome_neutral','missed'};
groupout_dir = fullfile(groupdir,analysis_folder);

%% initialize
addpath(genpath(mrVista_dir))
load(roilist_file);

for bN = 1:9
    group_betas(bN).beta    = nan(length(roiNum),length(allsubjs));
    group_betas(bN).std     = nan(length(roiNum),length(allsubjs));
    group_betas(bN).t       = nan(length(roiNum),4);
    group_betas(bN).sigRoiIdx  = [];
    group_betas(bN).sigRoiName  = {};
end

group_r2.r2     = nan(length(roiNum),length(allsubjs));
group_r2.std    = nan(length(roiNum),length(allsubjs));
group_r2.t      = nan(length(roiNum),4);
group_r2.sigRoiIdx  = [];
group_r2.sigRoiName  = {};

for cN = 1:length(contrastNames)
    group_contrast(cN).contrast = nan(length(roiNum),length(allsubjs));
    group_contrast(cN).std      = nan(length(roiNum),length(allsubjs));
    group_contrast(cN).t        = nan(length(roiNum),4);
    group_contrast(cN).sigRoiIdx   = [];
    group_contrast(cN).sigRoiName  = {};

    group_cTval(cN).contrastTval = nan(length(roiNum),length(allsubjs));
    group_cTval(cN).std          = nan(length(roiNum),length(allsubjs));
    group_cTval(cN).t            = nan(length(roiNum),4);
    group_cTval(cN).sigRoiIdx    = [];
    group_cTval(cN).sigRoiName   = {};
end

%% fill in matrix
for roiN = 1:length(roiNum)
    disp(['Running Roi ' roiName{roiN}])
    for subjN = 1:length(allsubjs)
        
        GLMout_dir = fullfile(data_dir,allsubjs{subjN},'GLManalysis',analysis_folder); 
        
    if exist(fullfile(GLMout_dir,'rois',roiName{roiN},['regression.mat']))
        
        % load roi regression
        subroi_reg = fullfile(GLMout_dir,'rois',roiName{roiN},['regression.mat']);
        load(subroi_reg)
        
        % load roi indices
        subroi_idx = fullfile(data_dir,allsubjs{subjN},'rois',[ roiName{roiN} '.mat']);
        load(subroi_idx)
        
        for bN = 1:9
            group_betas(bN).beta(roiN,subjN)    = nanmean(betamatrix(:,bN));
            group_betas(bN).std(roiN,subjN)     = nanstd(betamatrix(:,bN));
        end

        group_r2.r2(roiN,subjN)     = nanmean(r2);
        group_r2.std(roiN,subjN)    = nanstd(r2);

        for cN = 1:length(contrastNames)
            contrastout_dir = fullfile(GLMout_dir,'contrastMaps');
            contrast_nii = readFileNifti(fullfile(contrastout_dir,['contrast_ ' contrastNames{cN} '_raw.nii'])); 
            cTval_nii    = readFileNifti(fullfile(contrastout_dir,['contrast_ ' contrastNames{cN} '_tvalue.nii'])); 
            
            roicontrasts = contrast_nii.data(roiidx);
            roicTvals    = cTval_nii.data(roiidx);
            
            group_contrast(cN).contrast(roiN,subjN)  = nanmean(roicontrasts);
            group_contrast(cN).std(roiN,subjN)       = nanstd(roicontrasts);

            group_cTval(cN).contrastTval(roiN,subjN) = nanmean(roicTvals);
            group_cTval(cN).std(roiN,subjN)          = nanmean(roicTvals);
        end
        
    end
    end
end    

disp(['::::Running T-tests'])
% roi by roi t-test. 

for roiN = 1:length(roiNum)
    % betas
    for bN = 1:9
        g1 = group_betas(bN).beta(roiN,1:length(lowELS));
        g2 = group_betas(bN).beta(roiN,(length(lowELS)+1):end);
        [h,p,ci,stats] = ttest2(g1(~isnan(g1)),g2(~isnan(g2)));
        group_betas(bN).t(roiN,:)  = [h,p,stats.tstat,stats.df];
        if h == 1
            group_betas(bN).sigRoiIdx(end+1)   = roiN;
            group_betas(bN).sigRoiName{end+1}  = roiName{roiN};
        end
    end
    
    % r-squared
    g1 = group_r2.r2(roiN,1:length(lowELS));
    g2 = group_r2.r2(roiN,(length(lowELS)+1):end);
    [h,p,ci,stats] = ttest2(g1(~isnan(g1)),g2(~isnan(g2)));
    group_r2.t(roiN,:)  = [h,p,stats.tstat,stats.df];
    if h == 1
        group_r2.sigRoiIdx(end+1)   = roiN;
        group_r2.sigRoiName{end+1}  = roiName{roiN};
    end

    for cN = 1:length(contrastNames)
        g1 = group_contrast(cN).contrast(roiN,1:length(lowELS));
        g2 = group_contrast(cN).contrast(roiN,(length(lowELS)+1):end);
        [h,p,ci,stats] = ttest2(g1(~isnan(g1)),g2(~isnan(g2)));
        group_contrast(cN).t(roiN,:)  = [h,p,stats.tstat,stats.df];
        if h == 1
            group_contrast(cN).sigRoiIdx(end+1)  = roiN;
            group_contrast(cN).sigRoiName{end+1}  = roiName{roiN};
        end
        
        g1 = group_cTval(cN).contrastTval(roiN,1:length(lowELS));
        g2 = group_cTval(cN).contrastTval(roiN,(length(lowELS)+1):end);
        [h,p,ci,stats] = ttest2(g1(~isnan(g1)),g2(~isnan(g2)));
        group_cTval(cN).t(roiN,:)  = [h,p,stats.tstat,stats.df];
        if h == 1
            group_cTval(cN).sigRoiIdx(end+1)   = roiN;
            group_cTval(cN).sigRoiName{end+1}  = roiName{roiN};
        end
    end
end

save(fullfile(groupout_dir,'group_results.mat'),...
    'contrastNames','betaNames','roiName','lowELS','highELS','allsubjs',...
    'group_betas', 'group_r2', 'group_contrast', 'group_cTval')

disp(':::group_analysis done!:::')
end