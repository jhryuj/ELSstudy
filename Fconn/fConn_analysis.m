% addpath(genpath('/oak/stanford/groups/iang/users/lrborch/204b/Codes/analysis'));
% data_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Data/';
% roilist_file = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/analysis/aseg+aparc_selected.mat';
% subj         = '006-T1'; 
% analysis_folder = ['Analysis_190520'];

function fConn_analysis(data_dir,subj,roilist_file,analysis_folder)
    
GLMout_dir = fullfile(data_dir,subj,'GLManalysis',analysis_folder);

% roilist_file = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/analysis/aseg+aparc_selected.mat';
load(roilist_file)

roiList = roiName; %{'Left-Hippocampus';'Left-Amygdala';'Left-Accumbens-area';'Right-Hippocampus';'Right-Amygdala';'Right-Accumbens-area';'ctx-lh-insula';'ctx-rh-insula'};
roiIdx  = 1:length(roiName); %[8,9,10,18,19,20,57,93];

% initialize results
corr_errs.pearson       = nan(length(roiIdx));
corr_errs.pearson_std   = nan(length(roiIdx),1);
corr_errs.td            = nan(length(roiIdx));
corr_errs.td_std        = nan(length(roiIdx),1);

corr_sign.pearson       = nan(length(roiIdx));
corr_sign.pearson_std   = nan(length(roiIdx),1);
corr_sign.td            = nan(length(roiIdx));
corr_sign.td_std        = nan(length(roiIdx),1);

corr_tc.pearson     = nan(length(roiIdx));
corr_tc.pearson_std = nan(length(roiIdx),1);
corr_tc.td          = nan(length(roiIdx));
corr_tc.td_std      = nan(length(roiIdx),1);

load(fullfile(GLMout_dir,'designmat.mat')) % load design matrix

for roiN1 = 1:length(roiIdx)
disp(['Running Roi ' num2str(roiN1) ' of ' num2str(length(roiIdx))]);
if exist(fullfile(GLMout_dir,'rois',roiList{roiN1},['regression.mat']))
    load(fullfile(GLMout_dir,'rois',roiList{roiN1},['regression.mat']))

%     err_roi1    = standardize(res);
%     tc_roi1     = standardize(roidata_pc); 
%     sign_roi1   = standardize(betamatrix(:,1:9)*designmat((end-size(roidata_pc,2)+1):end,1:9)'); 

    err_roi1    = res;
    tc_roi1     = roidata_pc; 
    sign_roi1   = betamatrix(:,1:9)*designmat((end-size(roidata_pc,2)+1):end,1:9)'; 

    % errors
    corr_errs.pearson(roiN1,roiN1)      = 1;
    corr_errs.pearson_std(roiN1)        = mean(nanstd(err_roi1));
    corr_errs.td(roiN1,roiN1)           = 1;
    corr_errs.td_std(roiN1)             = mean(nanstd(diff(err_roi1')'));

    % signal
    corr_sign.pearson(roiN1,roiN1)      = 1;
    corr_sign.pearson_std(roiN1)        = mean(nanstd(sign_roi1));
    corr_sign.td(roiN1,roiN1)           = 1;
    corr_sign.td_std(roiN1)             = mean(nanstd(diff(sign_roi1')));
    
    % timecourse
    corr_tc.pearson(roiN1,roiN1)        = 1;
    corr_tc.pearson_std(roiN1)          = mean(nanstd(tc_roi1));
    corr_tc.td(roiN1,roiN1)             = 1;
    corr_tc.td_std(roiN1)               = mean(nanstd(diff(tc_roi1')'));
    
    for roiN2 = (roiN1+1):length(roiIdx)       
    if exist(fullfile(GLMout_dir,'rois',roiList{roiN2},['regression.mat']))
            
        load(fullfile(GLMout_dir,'rois',roiList{roiN2},['regression.mat']))
%         err_roi2    = standardize(res);
%         tc_roi2     = standardize(roidata_pc); 
%         sign_roi2   = standardize(betamatrix(:,1:9)*designmat((end-size(roidata_pc,2)+1):end,1:9)'); 
        
        err_roi2    = res;
        tc_roi2     = roidata_pc; 
        sign_roi2   = betamatrix(:,1:9)*designmat((end-size(roidata_pc,2)+1):end,1:9)'; 

        % errors 
        pcorr = mycorrelation(err_roi1,err_roi2);
        tcorr = mycorrelation(diff(err_roi1')',diff(err_roi2')');
        corr_errs.pearson(roiN1,roiN2) = pcorr;
        corr_errs.td(roiN1,roiN2)      = tcorr;

        % signal
        pcorr = mycorrelation(sign_roi1,sign_roi2);
        tcorr = mycorrelation(diff(sign_roi1')',diff(sign_roi2')');
        corr_sign.pearson(roiN1,roiN2) = pcorr;
        corr_sign.td(roiN1,roiN2)      = tcorr;

        % timecourse
        pcorr = mycorrelation(tc_roi1,tc_roi2);
        tcorr = mycorrelation(diff(tc_roi1')',diff(tc_roi2')');
        corr_tc.pearson(roiN1,roiN2)   = pcorr;
        corr_tc.td(roiN1,roiN2)        = tcorr;
    end
    end
end
end

save(fullfile(GLMout_dir,'fconn.mat'),...
    'roiList', 'roiIdx', 'corr_errs','corr_sign','corr_tc')

disp(':::Done!')
end

function Z = standardize(X)
    meanmat = repmat(nanmean(X,2),[1 size(X,2)]);
    stdmat  = repmat(nanstd(X,[],2),[1 size(X,2)]);
    Z = (X-meanmat)./stdmat;
end

function c = mycorrelation(x,y)
    roi1_mean = nanmean(x,1); roi1_mean = roi1_mean - nanmean(roi1_mean);
    roi2_mean = nanmean(y,1); roi2_mean = roi2_mean - nanmean(roi2_mean);
    c = roi1_mean*roi2_mean';
    c = c/(length(roi1_mean)*nanstd(roi1_mean)*nanstd(roi2_mean));
end