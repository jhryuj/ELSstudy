% GLM_analysis
% Josh Ryu; jhryu25@stanford.edu

%% directories
% data_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Data/';
% subj = '006-T1';
% mrVista_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/vistasoft-master'; %add mrVista to path
% spm_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/spm12';
% roilist_file = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/analysis/aseg+aparc_selected.mat';
% outfolder = ['Analysis_190520']; 

%%
function extractROItc(data_dir, subj,mrVista_dir,spm_dir,roilist_file)
    behavior_basedir    = fullfile(data_dir,subj,'Behavioral');
    preprocessSPM_dir   = fullfile(data_dir,subj,'spm');
    GLM_dir             = fullfile(data_dir,subj,'glm_nsubjSpace'); 
    GLMout_dir          = fullfile(GLM_dir); if ~exist(GLMout_dir), mkdir(GLMout_dir);,end;
    outroi_dir          = fullfile(data_dir,subj,'glm_nsubjSpace_rois');
    niitemplate         = readFileNifti(fullfile(data_dir,subj,'spm','crkidmid_3mm_2sec_raw_00001.nii')); % coregistered nifti. 
    spmmat              = fullfile(GLM_dir,'SPM.mat');
    load(spmmat)
    
    % load residuals
    resfiles    = dir(fullfile(GLM_dir,'Res_*.nii'));
    resnii      = readFileNifti(fullfile(GLMout_dir,resfiles(1).name));
    nframes     = length(resfiles);
    resdata     = nan([size(resnii.data) length(resfiles)]);
    for resT = 1:nframes
        resnii                  = readFileNifti(fullfile(glmdir,resfiles(resT).name));
        resdata(:,:,:,resT)    = resnii.data;
    end
    
    resStdnii   = readFileNifti(fullfile(GLMout_dir,'ResSTD.nii'));
    resStd      = resStdnii.data;
    
    % load betas
    betaVals = {};
    for betaN = 1:18
        betanii         = readFileNifti(fullfile(GLM_dir,sprintf('beta_%04d.nii',betaN))); % coregistered nifti. 
        betaVals{betaN} = betanii.data; 
    end
    
    load(roilist_file);
    roi = readFileNifti(fullfile(data_dir,'ELS_T1_FS_subjdir',subj,'Segmentation/mri/aparc+aseg.nii')); % roi file here

    for n = 1:length(roiNum)
        disp(['Running Roi ' roiName{n}])
        load(fullfile(outroi_dir,[roiName '.mat'])) %'roiidx','roidata','roiVoxelN'

        % find roi index
        roiidx = (roi.data == roiNum(n)); %Left NAcc
        roiVoxelN = sum(sum(sum(roiidx)));
        if roiVoxelN == 0 
            disp(['No voxels found! Skipping ROI ' num2str(roiNum(n)) ' '  roiName{n}])
            continue
        end
        
        % reconstruct signal from beta and residuals
        predmodel   = nan(size(roidata));
        for betaN = 1:18
            betaData            = betaVals{betaN}(repmat(roiidx,[1,1,1]));
            betaData            = reshape(roidata,[roiVoxelN, 1]);
            betamatrix(:,betaN) = betaData;
            for nvoxel = 1:roiVoxelN
                predmodel(nvoxel,:) = predmodel(nvoxel,:) + betaData(nvoxel,:)*SPM.xX.X(:,betaN); % coregistered nifti. 
            end
        end
        
        res         = resdata(repmat(roiidx,[1,1,1,nframes]));
        res         = reshape(res,[roiVoxelN, nframes]);
        roidata     = res + predmodel;
        
        r2         = nan(roiVoxelN,1);
        for nvoxel = 1:roiVoxelN
            r2(nvoxel,1) = 1 - var(res(nvoxel,:))/var(roidata(nvoxel,:));
        end
    
        % change to percent change
        roidata_pc      = roidata./repmat(mean(roidata,2),[1 size(roidata,2)]);
        roidata_pc      = (roidata_pc - 1)*100;
        
        roidata_snr     = (roidata-repmat(mean(roidata,2),[1 size(roidata,2)]))./repmat(resStd,[1 size(resStd,2)]);
        
        save(fullfile(outroi_dir,roiName,['regression.mat']), ...
            'roidata','roidata_pc','roidata_snr','betamatrix','predmodel','res','r2','columnNames','-v7.3')
        
    end

    disp(':::extractROItc done!:::')
end

%% finish implementing...2019/06/04
function wb2roi(GLMout_dir,outroi_dir,designmat,roiName,preprocessSPM_dir,niitemplate,columnNames)        
    %{
    load(fullfile(outroi_dir,[roiName '.mat'])) %'roiidx','roidata','roiVoxelN



    save(fullfile(GLMout_dir,roiName,['regression.mat']), ...
        'roidata_pc','betamatrix','predmodel','res','r2','columnNames','-v7.3')




    for betaN = 1:length(betaTypeList)
        savedir = fullfile(outroi_dir,roiName,betaTypeList{betaN});
        if ~exist(savedir,'dir'), mkdir(savedir);,end
        
        
        
        save(savedir,['regression.mat'], ...
            'roidata_pc','predmodel','res','r2','columnNames','-v7.3'
    end
 
    fullfile(GLMout_dir,'wholebrain',['regression.mat'])
    
    load(fullfile(outroi_dir,[roiName '.mat'])) %'roiidx','roidata','roiVoxelN'
    


    % save file
    mkdir(fullfile(GLMout_dir,roiName));
    save(fullfile(GLMout_dir,roiName,['regression.mat']), ...
        'roidata_pc','betamatrix','predmodel','res','r2','columnNames','-v7.3')
    
    cd(fullfile(GLMout_dir,roiName))    

%}
end
