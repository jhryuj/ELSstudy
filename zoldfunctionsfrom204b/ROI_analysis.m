% ROI_analysis
% Josh Ryu; jhryu25@stanford.edu

% *** run on server!!
% Needs more than 8GB of memory (try 16GB)

%% paths
% on server:
% data_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Data/';
% subj = '006-T1';
% mrVista_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/vistasoft-master'; %add mrVista to path
% roilist_file = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/analysis/aseg+aparc_selected.mat';

% data_dir = '/Volumes/iang/users/lrborch/204b/Data/'

function ROI_analysis(data_dir,subj,mrVista_dir,roilist_file)
    if exist(roilist_file)
        load(roilist_file)
    else
        % manually enter ROIs
        roiNum   = [26,58];
        roiNames = {'Left-Accumbens-area','Right-Accumbens-area'};

        if length(roiNum) ~= length(roiNames)
            error('Different size for roi numbers and roi names')
        end
    end

    %% directories and data
    outroi_dir = fullfile(data_dir,subj,'rois'); if ~exist(outroi_dir), mkdir(outroi_dir);,end

    addpath(genpath(mrVista_dir))
    
    nii = readFileNifti(fullfile(data_dir,subj,'spm','All_crKidMid4D.nii')); % coregistered nifti. 
    nframes = nii.dim(4);
    %% Loop through rois
    %{
    roi = readFileNifti(fullfile(data_dir,subj,'Segmentation/mri/aparc+aseg.nii')); % roi file here
    % Get roidata
    for n = 1:length(roiNum)
        roiidx = (roi.data == roiNum(n)); %Left NAcc
        roiVoxelN = sum(sum(sum(roiidx)));

        if roiVoxelN == 0 
            disp(['No voxels found! Skipping ROI ' num2str(roiNum(n)) ' '  roiName{n}])
            continue
        end

        roidata = nii.data(repmat(roiidx,[1,1,1,nframes]));
        roidata = reshape(roidata,[roiVoxelN, nframes]);

        save(fullfile(outroi_dir,[roiName{n} '.mat']),'roiidx','roidata','roiVoxelN')
    end
    %}
    
    %% whole brain roi
    roi = readFileNifti(fullfile(data_dir,subj,'Segmentation/mri/brain.nii')); % roi file here

    % Get roidata
    roiidx = (roi.data ~= 0); %Left NAcc
    roiVoxelN = sum(sum(sum(roiidx)));

    roidata = nii.data(repmat(roiidx,[1,1,1,nframes]));
    roidata = reshape(roidata,[roiVoxelN, nframes]);

    save(fullfile(outroi_dir,['wholebrain.mat']),'roiidx','roidata','roiVoxelN')    
    
    disp(':::ROI_analysis done!:::')

end

% Notes:
% to recover dimensions to 3d/4d can use the following: 
% roi3d = int16(roiidx);
% roi3d(roiidx) = roidata(:,1);