% addpath(genpath('/oak/stanford/groups/iang/users/lrborch/204b/Codes/analysis'));
% data_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Data/';
% roilist_file = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/analysis/aseg+aparc_selected.mat';
% analysis_folder = ['Analysis_190520'];
% groupdir = '/oak/stanford/groups/iang/users/lrborch/204b/GroupAnalysis';

function group_analysis_fConn(data_dir, roilist_file,groupdir,analysis_folder)

lowELS  = {'100-T1','171-T1','074-T1','088-T1','116-T1','072-T1'};
highELS = {'006-T1', '092-T1','214-T1'};
allsubjs = [lowELS, highELS];

groupout_dir = fullfile(groupdir,analysis_folder);

%% initialize
load(roilist_file);

utri_idx = logical(triu(ones(length(roiNum))));
nConn = sum(sum(utri_idx));

% check indexing:
% utri_idx(logical(utri_idx)) = [1:nConn];
% utri_idx(logical(triu(ones(length(roiNum)))))

group_fConn.subjvals            = nan(nConn,length(allsubjs));
group_fConn.t                   = nan(nConn,4);
group_fConn.sigRoiIdx           = [];
group_fConn.sigRoiName          = {};

group_fConn_err.pearson     = group_fConn;
group_fConn_err.td          = group_fConn;

group_fConn_sign.pearson    = group_fConn;
group_fConn_sign.td         = group_fConn;

group_fConn_tc.pearson      = group_fConn;
group_fConn_tc.td           = group_fConn;

%% fill in matrix
for subjN = 1:length(allsubjs)
    GLMout_dir = fullfile(data_dir,allsubjs{subjN},'GLManalysis',analysis_folder);
    load(fullfile(GLMout_dir,'fconn.mat'))

    group_fConn_err.pearson.subjvals(:,subjN)     = corr_errs.pearson(utri_idx);
    group_fConn_err.td.subjvals(:,subjN)          = corr_errs.td(utri_idx);

    group_fConn_sign.pearson.subjvals(:,subjN)    = corr_sign.pearson(utri_idx);
    group_fConn_sign.td.subjvals(:,subjN)         = corr_sign.td(utri_idx);

    group_fConn_tc.pearson.subjvals(:,subjN)      = corr_tc.pearson(utri_idx);
    group_fConn_tc.td.subjvals(:,subjN)           = corr_tc.td(utri_idx);
end

disp(['::::Running T-tests'])
% roi by roi t-test. 

group_fConn_err.pearson     = ttestInStruct(group_fConn_err.pearson,lowELS,roiName);
group_fConn_err.td          = ttestInStruct(group_fConn_err.td,lowELS,roiName);

group_fConn_sign.pearson    = ttestInStruct(group_fConn_sign.pearson,lowELS,roiName);
group_fConn_sign.td         = ttestInStruct(group_fConn_sign.td,lowELS,roiName);

group_fConn_tc.pearson      = ttestInStruct(group_fConn_tc.pearson,lowELS,roiName);
group_fConn_tc.td           = ttestInStruct(group_fConn_tc.td,lowELS,roiName);


% save for indexing. 
utri_idx = triu(ones(length(roiName)));
nConn = sum(sum(utri_idx));
utri_idx(logical(utri_idx)) = [1:nConn];

save(fullfile(groupout_dir,'group_fconn.mat'),...
    'roiName','lowELS','highELS','allsubjs','utri_idx',...
    'group_fConn_err', 'group_fConn_sign', 'group_fConn_tc')

disp(':::group_analysis done!:::')
end

function connStruct = ttestInStruct(connStruct,lowELS,roiName) 
    utri_idx = triu(ones(length(roiName)));
    nConn = sum(sum(utri_idx));
    utri_idx(logical(utri_idx)) = [1:nConn];

    for connIdx = 1:nConn
        g1 = connStruct.subjvals(connIdx,1:length(lowELS));
        g2 = connStruct.subjvals(connIdx,(length(lowELS)+1):end);
        [h,p,ci,stats] = ttest2(g1,g2);
        connStruct.t(connIdx,:)  = [h,p,stats.tstat,stats.df];
        if h == 1
            [idx1, idx2] = find(utri_idx == connIdx);
            connStruct.sigRoiIdx(end+1,:)  = [idx1 idx2];
            connStruct.sigRoiName(end+1,:) = {roiName{idx1}, roiName{idx2}};
        end
    end
end
