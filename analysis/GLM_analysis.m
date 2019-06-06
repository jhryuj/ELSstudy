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
function GLM_analysis(data_dir, subj,mrVista_dir,spm_dir,roilist_file,outfolder)
    skipframe = 4;

    behavior_basedir = fullfile(data_dir,subj,'Behavioral');
    preprocessSPM_dir = fullfile(data_dir,subj,'spm');
    GLM_dir = fullfile(data_dir,subj,'GLManalysis',outfolder); 
    GLMout_dir = fullfile(GLM_dir,'rois'); if ~exist(GLMout_dir), mkdir(GLMout_dir);,end;
    outroi_dir = fullfile(data_dir,subj,'rois');

    % save(fullfile(GLM_dir,outfolder,'designmat.mat'),...
    %        'dmParams','designmat','designmat_conds_conv','designmat_conds','columnNames
    load(fullfile(GLM_dir,'designmat.mat'));
    addpath(genpath(mrVista_dir));
    addpath(spm_dir);

    niitemplate = readFileNifti(fullfile(data_dir,subj,'spm','crkidmid_3mm_2sec_raw_00001.nii')); % coregistered nifti. 

    designmat = designmat((skipframe+1):end,:);
    % *** consider demeaning the designmatrix; or whitening..

    % run whole brain
    disp(['Running Whole Brain Regression'])
    runGLM(GLMout_dir,outroi_dir,designmat,'wholebrain',niitemplate,skipframe,columnNames)
    
    % run rois
    % extract values from the whole brain
    load(roilist_file);
    for n = 1:length(roiNum)
        if exist(fullfile(outroi_dir,[roiName{n} '.mat']))
            disp(['Running Roi ' roiName{n}])
            runGLM(GLMout_dir,outroi_dir,designmat,roiName{n},niitemplate,skipframe,columnNames)
        end
    end

    disp(':::GLM_analysis done!:::')
end

function runGLM(GLMout_dir,outroi_dir,designmat,roiName,niitemplate,skipframe,columnNames)        

    load(fullfile(outroi_dir,[roiName '.mat'])) %'roiidx','roidata','roiVoxelN'
    
    roidata = double(roidata(:,(skipframe+1):end));
    
    % change to percent change
    roidata = roidata./repmat(mean(roidata,2),[1 size(roidata,2)]);
    roidata_pc = (roidata - 1)*100;
    
    % initialize outputs
    betamatrix = nan(roiVoxelN,size(designmat,2));
    predmodel  = nan(roiVoxelN,size(roidata,2)); 
    res        = nan(roiVoxelN,size(roidata,2)); 
    r2         = nan(roiVoxelN,1);
    
    % run regression
    for nvoxel = 1:roiVoxelN
        betamatrix(nvoxel,:) = designmat\roidata_pc(nvoxel,:)';
        predmodel(nvoxel,:)  = designmat*betamatrix(nvoxel,:)'; 
        res(nvoxel,:)        = roidata_pc(nvoxel,:) - predmodel(nvoxel,:);
        r2(nvoxel,1)         = 1 - var(res(nvoxel,:))/var(roidata_pc(nvoxel,:));
    end

    % save file
    mkdir(fullfile(GLMout_dir,roiName));
    save(fullfile(GLMout_dir,roiName,['regression.mat']), ...
        'roidata_pc','betamatrix','predmodel','res','r2','columnNames','-v7.3')
    
    cd(fullfile(GLMout_dir,roiName))
    
    %% generate images
    % beta image
    for regN = 1:size(designmat,2)
        betanii      =  niitemplate; 
        betanii.fname = fullfile(GLMout_dir,roiName,['beta ' num2str(regN) '.nii']); 
        
        roi3d           = double(roiidx);
        roi3d(roiidx)   = betamatrix(:,regN);
        betanii.data    = roi3d; 
        
        writeFileNifti(betanii); 
    end
    
    % r2 image
    r2nii           = niitemplate; 
    r2nii.fname     = fullfile(GLMout_dir,roiName,'r2.nii'); 
    roi3d           = double(roiidx);
    roi3d(roiidx)   = r2;
    r2nii.data      = roi3d;
    
    writeFileNifti(r2nii);
    
end

%% finish implementing...2019/06/04
function wb2roi(GLMout_dir,outroi_dir,designmat,roiName,niitemplate,skipframe,columnNames)        
    fullfile(GLMout_dir,'wholebrain',['regression.mat'])
    
    load(fullfile(outroi_dir,[roiName '.mat'])) %'roiidx','roidata','roiVoxelN'
    
    roidata = double(roidata(:,(skipframe+1):end));
    
    % change to percent change
    roidata = roidata./repmat(mean(roidata,2),[1 size(roidata,2)]);
    roidata_pc = (roidata - 1)*100;
    
    % initialize outputs
    betamatrix = nan(roiVoxelN,size(designmat,2));
    predmodel  = nan(roiVoxelN,size(roidata,2)); 
    res        = nan(roiVoxelN,size(roidata,2)); 
    r2         = nan(roiVoxelN,1);
    
    % run regression
    for nvoxel = 1:roiVoxelN
        betamatrix(nvoxel,:) = designmat\roidata_pc(nvoxel,:)';
        predmodel(nvoxel,:)  = designmat*betamatrix(nvoxel,:)'; 
        res(nvoxel,:)        = roidata_pc(nvoxel,:) - predmodel(nvoxel,:);
        r2(nvoxel,1)         = 1 - var(res(nvoxel,:))/var(roidata_pc(nvoxel,:));
    end

    % save file
    mkdir(fullfile(GLMout_dir,roiName));
    save(fullfile(GLMout_dir,roiName,['regression.mat']), ...
        'roidata_pc','betamatrix','predmodel','res','r2','columnNames','-v7.3')
    
    cd(fullfile(GLMout_dir,roiName))
    
    %% generate images
    % beta image
    for regN = 1:size(designmat,2)
        betanii      =  niitemplate; 
        betanii.fname = fullfile(GLMout_dir,roiName,['beta ' num2str(regN) '.nii']); 
        
        roi3d           = double(roiidx);
        roi3d(roiidx)   = betamatrix(:,regN);
        betanii.data    = roi3d; 
        
        writeFileNifti(betanii); 
    end
    
    % r2 image
    r2nii           = niitemplate; 
    r2nii.fname     = fullfile(GLMout_dir,roiName,'r2.nii'); 
    roi3d           = double(roiidx);
    roi3d(roiidx)   = r2;
    r2nii.data      = roi3d;
    
    writeFileNifti(r2nii);
    
end
