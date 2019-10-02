% check outputs:
% normalize_betas: beta images for each normalization method
% extract_ROI_betas: roi folder with .mat and .xlsx tables. 
% data_dir = '/oak/stanford/groups/iang/users/lrborch/ELSReward/Data';
% subj = '009-T1';

% data_dir = '/Volumes/groups/iang/users/lrborch/ELSReward/Data';
% subj = '009-T1';

function script_190920(data_dir,subj)
    % convertMgz2Nii(data_dir,subj) % done on linux bashes.
    disp('Normalizing betas....')
    normalize_betas(data_dir,subj)
    
    disp('Extracing roi betas....')
    extract_ROI_betas(data_dir,subj)
end