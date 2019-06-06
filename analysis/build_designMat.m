% Josh Ryu; jhryu25@stanford.edu

%% directories and parameters
% on server: 
% data_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Data';
% subj = '006-T1';
% spmdir = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/spm12';
%
% local:
% data_dir = '/Volumes/iang/users/lrborch/204b/Data/'; %/oak/stanford/groups/iang/users/lrborch/204b/Data
% subj = '006-T1';
% spmdir = '/Volumes/iang/users/lrborch/204b/Codes/spm12'; %'/oak/stanford/groups/iang/users/lrborch/204b/Codes/spm12';

function build_designMat(data_dir,subj,spmdir)
    % conditions to include:
    conditionnames = {'ant_gain', 'ant_loss','ant_neut', 'gain','loss','no_gain','no_loss','outcome_neutral', 'missed'};

    % short descriptions of the design
    outfolder = ['Analysis_190520']; %datestr(now,'yymmdd')]
    description = 'Initial Analysis. Gain, Loss, Neutral, Conditions';

    %% organize data
    % directories
    behavior_basedir = fullfile(data_dir,subj,'Behavioral');
    preprocessSPM_dir = fullfile(data_dir,subj,'spm');
    GLM_dir = fullfile(data_dir,subj,'GLManalysis'); 
    
    if ~exist(GLM_dir), mkdir(GLM_dir);,end
    mkdir(fullfile(GLM_dir,outfolder));

    % add softwares and paths
    addpath(spmdir);

    % specify HRF to use.
    hrf = spm_hrf(0.1);
    % TR
    TR          = 2;

    % organize all the parameters in a struct.
    dmParams = struct(); dmParams.outfolder = outfolder; dmParams.subj = subj;
    dmParams.description = description; dmParams.data_dir = data_dir; 
    dmParams.conditionnames = conditionnames; dmParams.hrf = hrf;

    %% create design matrix
    % get motion plots
    rpfile = dir(fullfile(preprocessSPM_dir,'rp_*.txt'));
    rpdata = load(fullfile(rpfile.folder,rpfile.name));
    nframes = size(rpdata,1); 

    % get timepoints (downsample convolved response)
    scantimes = 0:TR:(TR*(nframes-1));

    % add behavioral conditions
    load(fullfile(data_dir,subj,'Behavioral','behconditions.mat'))

    designmat = [];
    designmat_conds = [];
    designmat_conds_conv = []; 
    designmat_conds_conv_ds = []; 

    for columnN = 1:length(conditionnames)
        designmat_conds(:,columnN) = eval(['conditionblocks.', eval('conditionnames{columnN}')]);
        convcol = conv(designmat_conds(:,columnN),hrf);
        designmat_conds_conv(:,columnN) = convcol(1:length(time));
        designmat_conds_conv_ds(:,columnN) = ...
            interp1(time,designmat_conds_conv(:,columnN),scantimes);
    end
    % *** maybe build a conditionDesign without convolution, for visualization

    % add run regressor, and motion regressor
    designmat = [designmat_conds_conv_ds, ones(nframes,1), rpdata];

    extraNames  = {'Run','x (mm)', 'y (mm)', 'z (mm)',  ...
        'pitch (rad)', 'roll (rad)', 'yaw (rad)'};
    columnNames = [conditionnames, extraNames];    

    %% update relevant parameters and save 
    dmParams.nframes = nframes; dmParams.scantimes = scantimes; dmParams.condtimes = time; 
    dmParams.columnNames = columnNames;
    save(fullfile(GLM_dir,outfolder,'designmat.mat'),...
        'dmParams','designmat','designmat_conds_conv','designmat_conds','columnNames')

    %% plot design matrix
    f = figure('visible','off','Position', [42 111 1570 806]);
    imagesc(designmat); c = colorbar; c.Label.String = 'A.U. (depending on column)';
    ylabel('Frames'); set(gca,'XTick',[1:length(columnNames)],'XTickLabel',columnNames);
    saveas(f,fullfile(GLM_dir,outfolder,'designmat.fig')); % this is invisible. turn on visible when opening. 
    saveas(f,fullfile(GLM_dir,outfolder,'designmat.png'));
    
    disp('DesignMatrix Done...')
end