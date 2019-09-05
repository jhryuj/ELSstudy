% movedata 
% unzip the T1 and kidmid for analysis and leave it in the basedir.
% 2019/08/15

rawdata_dir     = '/oak/stanford/groups/iang/ELS_data';
basedir         = '/oak/stanford/groups/iang/users/lrborch/ELSReward';
mrvista_path    = '/oak/stanford/groups/iang/users/lrborch/ELSReward/Codes/vistasoft-master'; addpath(genpath(mrvista_path));
data_dir        = fullfile(basedir, 'Data');
subjlist_dir    = fullfile(basedir,'ELSt1checklist_preprocessing.xlsx');
logfile         = '/oak/stanford/groups/iang/users/lrborch/ELSReward/Codes_logs/preprocessing/190817/modedatalog.txt';

if exist(logfile), delete(logfile);,end
diary(logfile); diary on;

subjlist_data = readtable(subjlist_dir);
if isnumeric(subjlist_data.DirCheck), subjlist_data.DirCheck = num2cell(subjlist_data.DirCheck);,end

% subjlist_data.rawDataDir
% subjlist_data.kidmidNifti
% subjlist_data.kidmidNiftiUnzip
% subjlist_data.T1Nifti
% subjlist_data.T1NiftiUnzip
% subjlist_data.behData

for subjN = 1:size(subjlist_data,1)
    subjID = subjlist_data{subjN,2}{1}; disp(['....copying ' subjID]);    
    
    if contains(subjID,'T1'), folder = 'ELS-T1';
    elseif contains(subjID,'TK1'), folder = 'ELS-TK1';
    end
    
    subjrawdata_dir     = fullfile(rawdata_dir,folder,subjID);
    subjrawevfile_dir   = fullfile(data_dir,folder(5:end),'kidmid_EV_bx');
    
    %% Check if directory exists
    if ~exist(subjrawdata_dir)
        disp([subjID ': No raw data directory']);
        subjlist_data.DirCheck{subjN} = '::No raw data directory::';
        
        subjlist_data.rawDataDir{subjN}         = 0;
        subjlist_data.kidmidNifti{subjN}        = 0;
        subjlist_data.kidmidNiftiUnzip{subjN}   = 0;
        subjlist_data.T1Nifti{subjN}            = 0;
        subjlist_data.T1NiftiUnzip{subjN}       = 0;
        
    else % if raw data directory exists
        subjlist_data.rawDataDir{subjN} = 1;
        subjdata_dir = fullfile(data_dir,folder(5:end),subjID);
        
        %% find kidmid file. unzip in the folder
        kidmid_niigz = dir(fullfile(subjrawdata_dir,'kidmid*_raw.nii.gz'));
        if isempty(kidmid_niigz)
            disp([subjID ': No kidmid nifti']);
            subjlist_data.DirCheck{subjN} = '::No kidmid nifti::';
            subjlist_data.kidmidNifti{subjN}        = 0;
            subjlist_data.kidmidNiftiUnzip{subjN}   = 0;
        else
            subjlist_data.kidmidNifti{subjN}            = 1;
            
            if ~exist(subjdata_dir),mkdir(subjdata_dir);,end % make destination directory

            if ~exist(fullfile(subjdata_dir,kidmid_niigz.name)) % check if it exists already
                [result, msg] = unzip_niigz(kidmid_niigz.folder,kidmid_niigz.name,subjdata_dir);
                if result == 0 
                    disp([subjID ': Cannot unzip kidmid nifti']);
                    subjlist_data.DirCheck{subjN} = '::Cannot unzip kidmid nifti::';
                    subjlist_data.kidmidNiftiUnzip{subjN}   = 0;
                else
                    subjlist_data.kidmidNiftiUnzip{subjN}   = 1;
                end
            else
                subjlist_data.kidmidNiftiUnzip{subjN}   = 1;
            end
        end
        
        %% copy T1 acpc
        T1_niigz = dir(fullfile(subjrawdata_dir,'T1*raw_acpc.nii.gz'));
        if isempty(T1_niigz)
            disp([subjID ': No T1 acpc nifti']);
            subjlist_data.DirCheck{subjN} = [subjlist_data.DirCheck{subjN} '::No T1 acpc nifti::'];
            
            subjlist_data.T1Nifti{subjN}        = 0;
            subjlist_data.T1NiftiUnzip{subjN}   = 0; 
        else
            subjlist_data.T1Nifti{subjN}        = 1;
            
            if ~exist(subjdata_dir),mkdir(subjdata_dir);,end % make destination directory

            if ~exist(fullfile(subjdata_dir,T1_niigz.name))
                [result, msg] = unzip_niigz(T1_niigz.folder,T1_niigz.name,subjdata_dir);
                if result == 0 
                    disp([subjID ': Cannot unzip T1 nifti']);
                    subjlist_data.DirCheck{subjN} = [subjlist_data.DirCheck{subjN} '::Cannot unzip T1 nifti::'];
                    subjlist_data.T1NiftiUnzip{subjN}   = 0;
                else
                    subjlist_data.T1NiftiUnzip{subjN}   = 1;
                end
            else
                subjlist_data.T1NiftiUnzip{subjN}   = 1;
            end
        end
    end

    
    %% find kidmid behavior and move them there
    subj_behv_dir   = fullfile(subjdata_dir,'Behavioral');
    subj_rawbeh     = fullfile(subjrawevfile_dir,[subjID '*']); 
    
    if ~exist(fullfile(subj_behv_dir,subjID,'model7')) % check if the behavior is already copied over.
        if isempty(dir(subj_rawbeh))
            disp([subjID 'No behavior data']);
            subjlist_data.DirCheck{subjN} = [subjlist_data.DirCheck{subjN} '::No behavior data::'];
            subjlist_data.behData{subjN} = 0;
        else
            subjlist_data.behData{subjN} = 1;
            copyfile(subj_rawbeh,subj_behv_dir)
        end
    else
        subjlist_data.behData{subjN} = 1;
    end
end

newlistfile = fullfile(basedir,'ELSt1checklist_preprocessing1.xlsx');
writetable(subjlist_data,newlistfile)

diary off;