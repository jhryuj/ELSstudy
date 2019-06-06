% directories
% data_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Data/';
% subj = '006-T1';
% roilist_file = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/analysis/aseg+aparc_selected.mat';
% analysisfolder = ['Analysis_190520']; 

% data_dir = '/Volumes/iang/users/lrborch/204b/Data/';
% subj = '201-T1';
% roilist_file = '/Volumes/iang/users/lrborch/204b/Codes/analysis/aseg+aparc_selected.mat';
% analysisfolder = ['Analysis_190520']; 


function roi_plottimecourses(data_dir, subj,roilist_file,analysisfolder)
    beh_dir = fullfile(data_dir,subj,'Behavioral'); 
    GLMout_dir = fullfile(data_dir,subj,'GLManalysis',analysisfolder); 
    GLMoutroi_dir = fullfile(GLMout_dir,'rois'); 
    load(roilist_file);
    load(fullfile(GLMout_dir,'designmat.mat'))
    load(fullfile(beh_dir,'behconditions.mat')); 
    
    for n = 1:length(roiNum)
        if exist(fullfile(GLMoutroi_dir,roiName{n},['regression.mat']))
            disp(['Running Roi ' roiName{n}])
            plottimecourses_run(GLMoutroi_dir,roiName{n},dmParams,conditionblocks) 
            % plottimecourses_condition(GLMoutroi_dir,roiName,dmParams,conditionblocks) 
        end
    end    
    
    disp(':::roi_plottimecourses done!:::')
end

function plottimecourses_run(GLMoutroi_dir,roiName,dmParams,conditionblocks) 
    load(fullfile(GLMoutroi_dir,roiName,['regression.mat']))

    %% time courses for the run
    mean_timecourses = mean(roidata_pc,1); 
    std_timecourses  = std(roidata_pc,0,1); 

    mean_model       = mean(predmodel,1);
    std_model        = std(predmodel,0,1);

    save(fullfile(GLMoutroi_dir,roiName,['timecourses_run.mat']),...
        'roidata_pc','mean_timecourses','std_timecourses','mean_model','std_model')

    % plot 
    f = figure('Position', [42 111 1570 806]);
    % f = figure('Position', [42 111 1570 806])
    ax_BOLDdata = subplot(4,1,[1:3]);hold on; 
    plot(dmParams.scantimes((end-length(mean_timecourses)+1):end),mean_timecourses,'r','LineWidth',3); 
    plot(dmParams.scantimes((end-length(mean_timecourses)+1):end),mean_model,'Color',[0 0 1],'LineWidth',3); 
    
    % plot errors
    plot(dmParams.scantimes((end-length(mean_timecourses)+1):end),mean_timecourses-std_timecourses,'r:'); 
    plot(dmParams.scantimes((end-length(mean_timecourses)+1):end),mean_model-std_model,'b:'); 

    plot(dmParams.scantimes((end-length(mean_timecourses)+1):end),mean_timecourses+std_timecourses,'r:'); 
    plot(dmParams.scantimes((end-length(mean_timecourses)+1):end),mean_model+std_model,'b:'); 

    legend('Mean data(across voxels)', 'Mean model (across voxels)', ...
        'Std','Std')
    title({roiName ['Avg Variance Explained = ' num2str(mean(r2))]}, 'interpreter', 'none')
    ylabel('Percent Change')
    xlabel('Time (s) since start of scan'); 
        
    ax_behdata = subplot(4,1,4);hold on; 
    scatter(dmParams.condtimes(mytological(conditionblocks.ant_all)),...
        zeros(nansum(conditionblocks.ant_all),1),'filled','MarkerFaceColor',[1 1 0]); 
    scatter(dmParams.condtimes(mytological(conditionblocks.target_all)),...
        zeros(nansum(conditionblocks.target_all),1),'filled','MarkerFaceColor',[1 0.66 0.33]); 
    scatter(dmParams.condtimes(mytological(conditionblocks.delay_all)),...
        zeros(nansum(conditionblocks.delay_all),1),'filled','MarkerFaceColor',[1 0.33 0.66]); 
    scatter(dmParams.condtimes(mytological(conditionblocks.outcome_all)),...
        zeros(nansum(conditionblocks.outcome_all),1),'filled','MarkerFaceColor',[1 0 1]); 
    scatter(dmParams.condtimes(mytological(conditionblocks.missed)),...
        0.1*ones(nansum(conditionblocks.missed),1),'x','MarkerFaceColor',[0.9 0.9 0.9]); 
    
    scatter(dmParams.condtimes(mytological(conditionblocks.ant_gain)),...
        -0.1*ones(nansum(conditionblocks.ant_gain),1),'filled','MarkerFaceColor',[0 1 0]); 
    scatter(dmParams.condtimes(mytological(conditionblocks.ant_loss)),...
        -0.1*ones(nansum(conditionblocks.ant_loss),1),'*','MarkerEdgeColor',[1 0 0]); 
    scatter(dmParams.condtimes(mytological(conditionblocks.ant_neut)),...
        -0.1*ones(nansum(conditionblocks.ant_neut),1),'d','MarkerEdgeColor',[0 0 1]); 
    scatter(dmParams.condtimes(mytological(conditionblocks.gain)),...
        -0.1*ones(nansum(conditionblocks.gain),1),'filled','MarkerFaceColor',[0 1 0]); 
    scatter(dmParams.condtimes(mytological(conditionblocks.loss)),...
        -0.1*ones(nansum(conditionblocks.loss),1),'*','MarkerEdgeColor',[1 0 0]); 
    scatter(dmParams.condtimes(mytological(conditionblocks.outcome_neutral)),...
        -0.1*ones(nansum(conditionblocks.outcome_neutral),1),'d','MarkerEdgeColor',[0 0 1]); 
    
    l = legend('ant_all', 'target_all', 'delay_all', 'outcome_all', 'missed', ...
        'ant_gain','ant_loss','ant_neut','gain','loss','outcome_neutral');
    l.Position = [0.9178 0.1153 0.0662 0.2060];l.Interpreter = 'none';    
    
    linkaxes([ax_BOLDdata,ax_behdata],'x')
    xlabel('Time (s) since start of scan'); 

    saveas(f,fullfile(GLMoutroi_dir,roiName,['timecourse_run.fig'])); % this is invisible. turn on visible when opening. 
    saveas(f,fullfile(GLMoutroi_dir,roiName,['timecourse_run.png']));

    % generate 100 random timecourses from the roi
    f2 = figure('Position', [42 111 1570 806]);hold on; 
    for repeat = 1:100
        idx = randsample(size(roidata_pc,1),1);
        plot(dmParams.scantimes((end-length(mean_timecourses)+1):end),roidata_pc(idx,:)); 
    end
    title([roiName ' 100 random voxels'], 'interpreter', 'none')
    ylabel('Percent Change')
    xlabel('Time (s) since start of scan'); 

    saveas(f2,fullfile(GLMoutroi_dir,roiName,['timecourse_run_randVoxels.fig'])); % this is invisible. turn on visible when opening. 
    saveas(f2,fullfile(GLMoutroi_dir,roiName,['timecourse_run_randVoxels.png']));    
end

%% this part is unfinished. 6/4/2019
% average by each condition.
function plottimecourses_conditions(GLMoutroi_dir,roiName,dmParams,conditionblocks) 
    load(fullfile(GLMoutroi_dir,roiName,['regression.mat']))

    condNames = fields(conditionblocks);
    tbefore = 5; %secs
    tafter  = 30; %secs
    tres = 0.1; 
    
    skipframes = 4; 
    
    for condN = 1:length(condNames)
        block = eval(['conditionblocks.', condNames{condN}]);
        startidx = ([0 diff(block)] == 1);
        startidx(dmParams.condtimes<dmParams.scantimes(skipframes)) = 0; % ignore everything before 
        
        times = tbefore:tres:tafter; 
        roi_tc = nan(size(roidata_pc,1),length(times));        
        
        for voxelN = 1:size(roidata_pc,1)
            voxeltc = interp1(dmParams.scantimes,roidata_pc(voxelN,:),dmParams.condtimes,'spline');
        end
       
        %% time courses for the run
        mean_timecourses = mean(roidata_pc,1); 
        std_timecourses  = std(roidata_pc,0,1); 

        mean_model       = mean(predmodel,1);
        std_model        = std(predmodel,0,1);

        save(fullfile(GLMoutroi_dir,roiName,['timecourses_run.mat']),...
            'roidata_pc','mean_timecourses','std_timecourses','mean_model','std_model')

        % plot 
        f = figure('Position', [42 111 1570 806]);

        saveas(f,fullfile(GLMoutroi_dir,roiName,['timecourse_run.fig'])); % this is invisible. turn on visible when opening. 
        saveas(f,fullfile(GLMoutroi_dir,roiName,['timecourse_run.png']));

        % generate 100 random timecourses from the roi
        f2 = figure('Position', [42 111 1570 806]);hold on; 
        for repeat = 1:100
            idx = randsample(size(roidata_pc,1),1);
            plot(time((end-length(mean_timecourses)+1):end),roidata_pc(idx,:)); 
        end
        title([roiName ' 100 random voxels'], 'interpreter', 'none')
        ylabel('Percent Change')
        xlabel('Time (s) since start of scan'); 

        saveas(f2,fullfile(GLMoutroi_dir,roiName,['timecourse_run_randVoxels.fig'])); % this is invisible. turn on visible when opening. 
        saveas(f2,fullfile(GLMoutroi_dir,roiName,['timecourse_run_randVoxels.png']));
    
    end
    
end

function logicalvec = mytological(x)
    if any(isnan(x))
        logicalvec = false(size(x));
    else
        logicalvec = logical(x);
    end

end