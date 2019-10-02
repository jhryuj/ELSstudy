% secondlevel

function secondlevel(subjlist_file)
%% directories
if ismac % assume local on josh's mac
    basedir         = '/Volumes/groups/iang/users/lrborch/ELSReward/';
elseif ispc % assume josh's pc at home
    basedir         = 'Z:\users\lrborch\ELSReward\';
else % assume sherlock
    basedir         = '/oak/stanford/groups/iang/users/lrborch/ELSReward/';
end

if contains(subjID,'T1'), folder = 'T1';
elseif contains(subjID,'TK1'), folder = 'TK1';
end

mrVista_dir = fullfile(basedir,'Codes','vistasoft-master');addpath(genpath(mrVista_dir));
spmdir      = fullfile(basedir,'Codes','spm12');addpath(spmdir);

%% 
betaNorms       = {'beta','betaSNR', 'betaPCraw'};

% 8 contrasts
contrastNames   = {'antGain - neut', 'antLoss - neut', 'antGain - antLoss', ...
    'gain - neut', 'loss - neut', 'gain - loss', ...
    'gain - antGain', 'loss - antLoss'};

spm('defaults', 'fmri')
spm_jobman('initcfg')
spm_get_defaults('cmdline',true)

%%
glmlist = {'glm_nsubjSpace','glm_normSpace'};
for glmN = 1:length(glmlist)
    
    % check subjects to loop over.
    conditions.
    
    
    [~, subjlistcell] = generateSubjectList(subjlist_file,conditions);
    
    % loop over subjects and find the right contrasts for the beta type.
    
    
    glmdir      = fullfile(basedir,'Data',folder,subjID,glmlist{glmN}); 
    spmmat      = fullfile(glmdir,'SPM.mat');
    contrastdir = fullfile(glmdir,'contrasts'); 
    
    % make non-raw beta contrasts
    for betaTypeN = 1:3 % do raw Beta again to check.
    for contrastN = 1:8
        betaN_pos = find(contrastVectors{contrastN} == 1);
        betaN_neg = find(contrastVectors{contrastN} == -1);
        
        betafile_pos        = fullfile(glmdir,sprintf([betaNorms{betaTypeN} '_%04d.nii'],betaN_pos));
        betanii_pos         = readFileNifti(betafile_pos);
        betafile_neg        = fullfile(glmdir,sprintf([betaNorms{betaTypeN} '_%04d.nii'],betaN_neg));
        betanii_neg         = readFileNifti(betafile_neg);

        contrast_nii         = betanii_pos;
        contrast_nii.data    = (betanii_pos.data) - (betanii_neg.data);
        contrast_nii.fname   = ...
            fullfile(contrastdir,[betaNorms{betaTypeN} '_' contrastNames{contrastN} '.nii']);
        writeFileNifti(contrast_nii);
    end
    end
end
end