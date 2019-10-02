function convertMgz2Nii(data_dir,subj)

    fs_dir      = fullfile(data_dir,'ELS_T1_FS_subjdir');

    roimgz      = fullfile(fs_dir,subj,'mri','aparc+aseg.mgz');
    brainmgz    = fullfile(fs_dir,subj,'mri','brain.mgz');
    
    % load freesurfer
    system('ml labs');
    system('ml poldrack');
    system('ml freesurfer/6.0.1');

    system(['mri_convert ' roimgz ' ' roimgz(end-3:end) '.nii']);
    system(['mri_convert ' brainmgz ' ' brainmgz(end-3:end) '.nii']);
end