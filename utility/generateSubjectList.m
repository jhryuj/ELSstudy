% generate a string of subjects to iterate bash files over. 
% 2019/09/30
% conditions is a struct with potentially the following fields
% each of the field is 1/true if we want the list to return subjects who
% have finished the given analysis
% .Good4Analysis
% .freesurfer_mgz
% .freesurfer_convert2nii
% .spm_coreg
% .spm_norm
% .spm_glm_subjSpace
% .spm_glm_subjSpace_normbeta
% .roi_betaextract
% .spm_glm_normSpace
% .spm_glm_normSpace_normbeta

% E.g. 
% subjlist_file = 'ELSt1checklist_preprocessing190930check.xlsx'
% conditions = struct(); conditions.spm_glm_normSpace_normbeta =
% 1;conditions.spm_glm_normSpace = 1;


function [subjliststr, subjlistcell] = generateSubjectList(subjlist_file,conditions,outdir)
if ismac % assume local on josh's mac
    basedir         = '/Volumes/groups/iang/users/lrborch/ELSReward/';
elseif ispc
    basedir         = 'Z:\users\lrborch\ELSReward\';
else % assume sherlock
    basedir         = '/oak/stanford/groups/iang/users/lrborch/ELSReward';
end

data_dir            = fullfile(basedir,'Data');
subjlist_dir        = fullfile(basedir,subjlist_file); % latest progress code.
subjlist_data       = readtable(subjlist_dir);

subjliststr     = ''; 
subjlistcell    = '';

condFields = fields(conditions);

for subjN = 1:size(subjlist_data,1)
    subjID = subjlist_data{subjN,2}{1}; disp(['Subject ' subjID]);    
    
    if contains(subjID,'T1'), folder = 'T1';
    elseif contains(subjID,'TK1'), folder = 'TK1';
    end
    
    subjOk = true; % the subjects are okay in the beginning
    
    for condN = 1:length(condFields)
        condSatisfied   = eval([ 'subjlist_data.' condFields{condN} ' == conditions.' condFields{condN}]);
        if condSatisfied
            subjOk  = subjOk && logical(condSatisfied);
        else
            subjOk  = false;
            break
        end
    end
    
    if subjOk
        subjliststr     = [subjliststr ' ' subjID];
        subjlistcell{end+1} = subjID;
    end
end

if exist('roilist_file','var') 
    save(fullfile(outdir,'subjlist.mat'),'subjliststr','subjlistcell')
end

end