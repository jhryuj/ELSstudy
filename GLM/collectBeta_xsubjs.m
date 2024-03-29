% subjlist_file = 'ELSt1checklist_preprocessing191007check.xlsx';

function collectBeta_xsubjs(subjlist_file)
%% directories
basedir             = setbasepath;

% define output directories
outdir      = fullfile(basedir,'Data','GroupAnalyses','191007','glm_nSubjSpace');
if ~exist(outdir), mkdir(outdir);,end

%% parts of the code to run

%% define beta
betaNorms       = {'beta','betaSNR', 'betaPCraw'};

% 8 contrasts
contrastNames   = {'antGain - neut', 'antLoss - neut', 'antGain - antLoss', ...
    'gain - neut', 'loss - neut', 'gain - loss', ...
    'gain - antGain', 'loss - antLoss'};

% antGain - neut
contrastVectors{1} = zeros(1,11); contrastVectors{1}(1) = 1;  contrastVectors{1}(3) = -1; 
% antLoss - neut
contrastVectors{2} = zeros(1,11); contrastVectors{2}(2) = 1;  contrastVectors{2}(3) = -1;
% antGain - antLoss
contrastVectors{3} = zeros(1,11); contrastVectors{3}(1) = 1;  contrastVectors{3}(2) = -1; 
% gain - neut
contrastVectors{4} = zeros(1,11); contrastVectors{4}(4) = 1;  contrastVectors{4}(6) = -1;
% loss - neut
contrastVectors{5} = zeros(1,11); contrastVectors{5}(5) = 1;  contrastVectors{5}(6) = -1; 
% gain - loss
contrastVectors{6} = zeros(1,11); contrastVectors{6}(4) = 1;  contrastVectors{6}(5) = -1; 
% gain - antGain
contrastVectors{7} = zeros(1,11); contrastVectors{7}(4) = 1;  contrastVectors{7}(1) = -1; 
% loss - antLoss
contrastVectors{8} = zeros(1,11); contrastVectors{8}(5) = 1;  contrastVectors{8}(2) = -1;

%%
glmlist = {'glm_nsubjSpace'}; % dont run glm_normSpace
glmN = 1;

% load subject list
% select subjects that have the contrasts generated
% conditions.spm_glm_nsubjSpace_contrastGen   = 1;
conditions.spm_glm_normSpace_contrastGen    = 1;

if exist(fullfile(outdir,'subjlist.mat'),'file')
    load(fullfile(outdir,'subjlist.mat'));
else
    [~, subjlistcell] = generateSubjectList(subjlist_file,conditions);
    Nsubj   = length(subjlistcell);
    save(fullfile(outdir,'subjlist.mat'),'subjlistcell','Nsubj');
end

% load 
if ispc % assume we're in josh's local machine
    roilist_file    = 'Z:\users\lrborch\ELSReward\Codes\ELSstudy\ROIAnalysis\fsrois.mat'; 
elseif ismac % assume joshs computer
    roilist_file    = '/Volumes/groups/iang/users/lrborch/ELSReward/Codes/ELSstudy/ROIAnalysis/fsrois.mat'; 
else % assume we're in sherlock
    roilist_file    = '/oak/stanford/groups/iang/users/lrborch/ELSReward/Codes/ELSstudy/ROIAnalysis/fsrois.mat'; 
end

load(roilist_file)

for betaTypeN = 1:3 % do raw Beta again to check.
for contrastN = 1:8
    contrastlist = cell(Nsubj,1);
    
    posConIDx = find(contrastVectors{contrastN} == 1);
    negConIDx = find(contrastVectors{contrastN} == -1);
    
    valuemat=[];
    
    % loop over subjects and find the right contrasts for the beta type.
    for subjN = 1:length(subjlistcell)
        subjID = subjlistcell{subjN};

        if contains(subjID,'T1'), folder = 'T1';
        elseif contains(subjID,'TK1'), folder = 'TK1';
        end

        % open the excel files
        glmdir      = fullfile(basedir,'Data',folder,subjID,glmlist{glmN}); 
        contrastdir = fullfile(glmdir,'contrasts'); 
        roidir      = fullfile(glmdir,'rois'); 
        contrastfile = fullfile(roidir,[betaNorms{betaTypeN} '.xlsx']);
        contrastlist{subjN,1} = [contrastfile ',1'];
        
        subj_data       = readtable(contrastfile);
        % save to a table 
        % loop through rois
        for roiN = 1:length(roiNum) 
            valuemat(subjN,roiN) = subj_data{roiN,1+posConIDx} - subj_data{roiN,1+negConIDx};
        end
        
    end
    
    if ~exist(fullfile(outdir,betaNorms{betaTypeN}),'dir')
        mkdir(fullfile(outdir,betaNorms{betaTypeN}));
    end
    outputfile = fullfile(outdir,betaNorms{betaTypeN},[contrastNames{contrastN} '.csv']);
    % save the table
    roiNameChanged = cellfun(@str_min2und, roiName,'UniformOutput',false);
    roiNameChanged = genvarname(roiNameChanged);
    valuetable = array2table(valuemat,'RowNames',subjlistcell,'VariableNames',roiNameChanged);
    writetable(valuetable, outputfile,'WriteRowNames',true)
end
end

    
end

function newstr = str_min2und(str)
    newstr = strrep(str,'-','_');
end
