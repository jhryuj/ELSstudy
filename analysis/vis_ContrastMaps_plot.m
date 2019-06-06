% data_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Data/';
% subj = '006-T1';
% mrVista_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/vistasoft-master'; %add mrVista to path
% spm_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/spm12';
% outfolder = ['Analysis_190520']; 

% data_dir = '/Volumes/iang/users/lrborch/204b/Data/';
% subj = '006-T1';
% mrVista_dir = '/Volumes/iang/users/lrborch/204b/Codes/vistasoft-master'; %add mrVista to path
% spm_dir = '/Volumes/iang/users/lrborch/204b/Codes/spm12'
% outfolder = ['Analysis_190520'];

%% function 
function vis_ContrastMaps_plot(data_dir,subj,mrVista_dir,spm_dir,outfolder)
    contrastNames = {'anteGain-anteLoss'; 'anteGain-anteNeut'; 'anteLoss-anteNeut'; ...
        'gain-loss'; 'gain-nogain'; 'loss-noloss'};
    
    addpath(spm_dir);
    addpath(genpath(mrVista_dir));
    
    GLM_dir = fullfile(data_dir,subj,'GLManalysis',outfolder); 
    contrastout_dir = fullfile(GLM_dir,'contrastMaps'); if ~exist(contrastout_dir), mkdir(contrastout_dir);end    
    
    anat = fullfile(data_dir,subj,'Segmentation','mri','brain.nii');
    mask = fullfile(data_dir,subj,'Segmentation','mri','brain.nii');
    
    for contrastN = 1:length(contrastNames) 
        disp(['Running contrast ' contrastNames{contrastN}])
        func = fullfile(contrastout_dir,['contrast_ ' contrastNames{contrastN} '_raw.nii']);
        
        % threshold by t
        funcThresh = fullfile(contrastout_dir,['contrast_ ' contrastNames{contrastN} '_tvalue.nii']);
        threshval = 2; 
        outfile = ['contrast_ ' contrastNames{contrastN} '_raw_threshT=' num2str(threshval)];
        plot_map_overlay_spm(anat, mask, func, funcThresh, threshval, contrastout_dir,outfile)
        
        % threshold by r2
        funcThresh = fullfile(GLM_dir,'rois/wholebrain/r2.nii');
        threshval = 0.1; 
        outfile = ['contrast_ ' contrastNames{contrastN} '_raw_threshR2=' num2str(threshval)];
        plot_map_overlay_spm(anat, mask, func, funcThresh, threshval, contrastout_dir,outfile)
        
        % threshold t by t
        func = fullfile(contrastout_dir,['contrast_ ' contrastNames{contrastN} '_tvalue.nii']);
        funcThresh = fullfile(contrastout_dir,['contrast_ ' contrastNames{contrastN} '_tvalue.nii']);
        threshval = 2; 
        outfile = ['contrast_ ' contrastNames{contrastN} '_tvalue_threshT=' num2str(threshval)];
        plot_map_overlay_spm(anat, mask, func, funcThresh, threshval, contrastout_dir,outfile)

    end
end