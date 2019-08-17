% movedata 
% unzip the T1 and kidmid for analysis and leave it in the basedir.
% 2019/08/15

rawdata_dir = '/oak/stanford/groups/iang/ELS_data';
basedir = '/oak/stanford/groups/iang/users/lrborch/ELSReward';
data_dir = fullfile(basedir, 'Data');
subjlist_dir = fullfile(basedir,'ELSt1checklist_preprocessing.xlsx');

subjlist_data = readtable(subjlist_dir);

for subjN = 1:size(subjlist_data,1)
    subjID = subjlist_data{subjN,2}{1}; disp(['....copying ' subjID]);    
    
    if contains(subjID,'T1'), folder = 'ELS-T1';
    elseif contains(subjID,'TK1'), folder = 'ELS-TK1';
    end
    
    subjrawdata_dir     = fullfile(rawdata_dir,folder,subjID);
    subjrawevfile_dir   = fullfile(data_dir,folder(5:end),kidmid_EV_bx);
    
    %% Check if directory exists
    if ~exist(subjrawdata_dir)
        disp([subjID ': No raw data directory']);
        subjlist_data.DirCheck{subjID} = 'No raw data directory';
        continue
    end

    %% find kidmid file, and T1. unzip in the spm folder
    kidmid_niigz = dir(fullfile(subjrawdata_dir,'kidmid*.nii.gz'));
    T1_niigz = dir(fullfile(subjrawdata_dir,'T1*raw_acpc.nii.gz'));
    
    if isempty(kidmid_niigz)
        subjlist_data.DirCheck{subjID} = 'No kidmid nifti';
        continue
    elseif isempty(kidmid_niigz)
        subjlist_data.DirCheck{subjID} = 'No T1 acpc nifti';
        continue
    end
    
    % if it exists, make subj folder and unzip them there
    subjdata_dir = fullfile(data_dir,folder(5:end),subjID);
    if ~exist(subjdata_dir),mkdir(subjdata_dir);,end
    
    try 
        gunzip(fullfile(kidmid_niigz.folder,kidmid_niigz.name),...
            subjdata_dir)
    catch error
        subjlist_data.DirCheck{subjID} = 'Cannot unzip kidmid nifti';
        continue
    end
    
    try
        gunzip(fullfile(T1_niigz.folder,T1_niigz.name),...
            subjdata_dir)
    catch error
        subjlist_data.DirCheck{subjID} = 'Cannot unzip T1 nifti';
        contin1ue
    end
    
    %% find kidmid behavior and move them there
    subj_behv_dir   = fullfile(subjdata_dir,'Behavioral');
    subj_rawbeh     = fullfile(subjrawevfile_dir,[subjID '*']); 
    
    if ~isempty(dir(subj_rawbeh))
        subjlist_data.DirCheck{subjID} = 'No behavior data';
    else
        copyfile subj_rawbeh subj_behv_dir
    end
end

newlistfile = fullfile(basedir,'ELSt1checklist_preprocessing1.xlsx');
writetable(subjlist_data,newlistfile)