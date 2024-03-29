% movedata 
% unzip the T1 and kidmid for analysis and leave it in the basedir.
% 2019/08/15

basedir             = setbasepath;

data_dir            = fullfile(basedir,'Data');
fs_dir              = fullfile(data_dir,'ELS_T1_FS_subjdir');

subjlist_dir        = fullfile(basedir,'ELSt1checklist_preprocessing190923.xlsx'); % latest progress code.
outputcheck_dir     = fullfile(basedir,'ELSt1checklist_preprocessing191007check.xlsx'); % latest progress code.
subjlist_data = readtable(subjlist_dir);

for subjN = 1:size(subjlist_data,1)
    subjID = subjlist_data{subjN,2}{1}; disp(['Subject ' subjID]);    
    
    if contains(subjID,'T1'), folder = 'T1';
    elseif contains(subjID,'TK1'), folder = 'TK1';
    end
    
    subjdata_dir    = fullfile(data_dir,folder,subjID);
    subjfs_dir      = fullfile(fs_dir,subjID);
    
    % check if the subject is good for analysis
    if subjlist_data.Good4Analysis(subjN) ~= 1
        disp(['... skipping, subject not good for analysis.']) 
        continue
    end
    
    %% check if freesurfer is done
    % mgz exists
    if exist(fullfile(subjfs_dir,'mri','aparc+aseg.mgz'),'file')
        subjlist_data.freesurfer_mgz(subjN)         = 1;
    else
        subjlist_data.freesurfer_mgz(subjN)         = 0;
    end

    % mgz conversion
    if exist(fullfile(subjfs_dir,'mri','aparc+aseg.nii'),'file')
        subjlist_data.freesurfer_convert2nii(subjN)         = 1;
    else
        subjlist_data.freesurfer_convert2nii(subjN)         = 0;
    end

    
    %% check if spm is done
    % coregistered files and smoothed file exists
    if exist(fullfile(subjdata_dir,'spm','crkidmid_3mm_2sec_raw_00250.nii'),'file')
        subjlist_data.spm_coreg(subjN)         = 1;
    else
        subjlist_data.spm_coreg(subjN)         = 0;
        end
    
    if exist(fullfile(subjdata_dir,'spm','swcrkidmid_3mm_2sec_raw_00250.nii'),'file')
        subjlist_data.spm_norm(subjN)         = 1;
    else
        subjlist_data.spm_norm(subjN)         = 0;
    end
    
    %% check if spm glm is done
    % glm in subject space done
    if exist(fullfile(subjdata_dir,'glm_nsubjSpace','Res_0246.nii'),'file')
        subjlist_data.spm_glm_subjSpace(subjN)         = 1;
    else
        subjlist_data.spm_glm_subjSpace(subjN)         = 0;
    end
    
    % glm in normalized space is done.
    if exist(fullfile(subjdata_dir,'glm_normSpace','Res_0246.nii'),'file')
        subjlist_data.spm_glm_normSpace(subjN)         = 1;
    else
        subjlist_data.spm_glm_normSpace(subjN)         = 0;
    end
    
    %% check if betas are normalized
    % glm in normalized space 
    if exist(fullfile(subjdata_dir,'glm_normSpace','betaSNR_0011.nii'),'file')
        subjlist_data.spm_glm_normSpace_normbeta(subjN)         = 1;
    else
        subjlist_data.spm_glm_normSpace_normbeta(subjN)         = 0;
    end
    
    % glm in subject space done
    if exist(fullfile(subjdata_dir,'glm_nsubjSpace','betaSNR_0011.nii'),'file')
        subjlist_data.spm_glm_subjSpace_normbeta(subjN)         = 1;
    else
        subjlist_data.spm_glm_subjSpace_normbeta(subjN)         = 0;
    end

    % check if roi is done
    if exist(fullfile(subjdata_dir,'glm_nsubjSpace','rois','roi_betas.mat'),'file')
        subjlist_data.roi_betaextract(subjN)         = 1;
    else
        subjlist_data.roi_betaextract(subjN)         = 0;
    end
    
    %% check if contrasts are generated
    if exist(fullfile(subjdata_dir,'glm_normSpace','contrasts','betaPCraw_loss - neut.nii'),'file')
        subjlist_data.spm_glm_normSpace_contrastGen(subjN)         = 1;
    else
        subjlist_data.spm_glm_normSpace_contrastGen(subjN)         = 0;
    end
    
    if exist(fullfile(subjdata_dir,'glm_nsubjSpace','contrasts','betaPCraw_loss - neut.nii'),'file')
        subjlist_data.spm_glm_nsubjSpace_contrastGen(subjN)         = 1;
    else
        subjlist_data.spm_glm_nsubjSpace_contrastGen(subjN)         = 0;
    end

    
    %% checks from movedata.
    %{
    %% Check if directory exists
    if ~exist(subjrawdata_dir)
        disp([subjID ': No raw data directory']);        
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
            subjlist_data.kidmidNifti{subjN}        = 0;
            subjlist_data.kidmidNiftiUnzip{subjN}   = 0;
        else
            subjlist_data.kidmidNifti{subjN}            = 1;
            
            if ~exist(subjdata_dir,'dir'),mkdir(subjdata_dir);,end % make destination directory

            if ~exist(fullfile(subjdata_dir,kidmid_niigz.name(1:end-3)),'file') % check if it exists already
                [result, msg] = unzip_niigz(kidmid_niigz.folder,kidmid_niigz.name,subjdata_dir);
                if result == 0 
                    disp([subjID ': Cannot unzip kidmid nifti']);
                    subjlist_data.kidmidNiftiUnzip{subjN}   = 0;
                else
                    subjlist_data.kidmidNiftiUnzip{subjN}   = 1;
                end
            else
                disp(['...' subjID ': Skipping, kidmid nifti already exists']);
                subjlist_data.kidmidNiftiUnzip{subjN}   = 1;
            end
        end
        
        %% copy T1 acpc
        T1_niigz = dir(fullfile(subjrawdata_dir,'T1*raw_acpc.nii.gz'));
        if isempty(T1_niigz)
            disp([subjID ': No T1 acpc nifti']);
            subjlist_data.T1Nifti{subjN}        = 0;
            subjlist_data.T1NiftiUnzip{subjN}   = 0; 
        else
            subjlist_data.T1Nifti{subjN}        = 1;
            
            if ~exist(subjdata_dir),mkdir(subjdata_dir);,end % make destination directory

            if ~exist(fullfile(subjdata_dir,T1_niigz.name(1:end-3)))
                [result, msg] = unzip_niigz(T1_niigz.folder,T1_niigz.name,subjdata_dir);
                if result == 0 
                    disp([subjID ': Cannot unzip T1 nifti']);
                    subjlist_data.T1NiftiUnzip{subjN}   = 0;
                else
                    subjlist_data.T1NiftiUnzip{subjN}   = 1;
                end
            else
                disp(['...' subjID ': Skipping, T1 nifti already exists']);
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
            subjlist_data.behData{subjN} = 0;
        else
            subjlist_data.behData{subjN} = 1;
            copyfile(subj_rawbeh,subj_behv_dir)
        end
    else
        disp(['...' subjID ': Skipping, behavior directory already exists']);
        subjlist_data.behData{subjN} = 1;
    end
    %}
end

writetable(subjlist_data,outputcheck_dir)