% addpath(genpath('/oak/stanford/groups/iang/users/lrborch/204b/Codes/analysis'));
% analysis_folder = ['Analysis_190520'];
% groupdir = '/oak/stanford/groups/iang/users/lrborch/204b/GroupAnalysis';

% addpath(genpath('Z:\users\lrborch\204b\Codes\analysis'));
% analysis_folder = ['Analysis_190520'];
% groupdirbase = 'Z:\users\lrborch\204b\GroupAnalysis';

function group_plotResults(groupdirbase,analysis_folder)
    load(fullfile(groupdirbase,analysis_folder,'group_fconn.mat'))
    load(fullfile(groupdirbase,analysis_folder,'group_results.mat'))
    
    groupdir = fullfile(groupdirbase,analysis_folder);
    
    % interested regions
    roitoplot_names = {'Left-Hippocampus';'Right-Hippocampus';'Left-Amygdala';'Right-Amygdala';...
        'Left-Accumbens-area'; 'Right-Accumbens-area';'ctx-lh-insula';'ctx-rh-insula'};
    roitoplot_idx  = [8,18,9,19,10,20,57,93];

    disp(':::Contrast Plots:::')
    
    for cN = 1:length(contrastNames)
        contrast_outdir = fullfile(groupdir,'contrasts',contrastNames{cN});
        if ~exist(contrast_outdir), mkdir(contrast_outdir); end
        
        % interested regions
        for rN = 1:length(roitoplot_names)
            roi_idx = roitoplot_idx(rN);
            
            barscatterPlot(group_contrast(cN).contrast(roi_idx,:),...
                group_contrast(cN).std(roi_idx,:),...
                lowELS,...
                fullfile(contrast_outdir,['contrast_' roitoplot_names{rN}]),...
                ['beta contrast ' roitoplot_names{rN}],'beta contrast')
            
            barscatterPlot(group_cTval(cN).contrastTval(roi_idx,:),...
                group_cTval(cN).std(roi_idx,:),...
                lowELS,...
                fullfile(contrast_outdir,['cTval_' roitoplot_names{rN}]),...
                ['t-value of contrast ' roitoplot_names{rN}],'t-value of contrast')
        end
        
        % significant contrasts
        for roi_idx = group_contrast(cN).sigRoiIdx
            barscatterPlot(group_contrast(cN).contrast(roi_idx,:),...
                group_contrast(cN).std(roi_idx,:),...
                lowELS,...
                fullfile(contrast_outdir,['contrast_' roiName{roi_idx}]),...
                ['beta contrast ' roiName{roi_idx}],'beta contrast')
        end
        
        % significant cTvals
        for roi_idx = group_cTval(cN).sigRoiIdx
            barscatterPlot(group_cTval(cN).contrastTval(roi_idx,:),...
                group_cTval(cN).std(roi_idx,:),...
                lowELS,...
                fullfile(contrast_outdir,['cTval_' roiName{roi_idx}]),...
                ['t-value of contrast ' roiName{roi_idx}],'t-value of contrast')
        end
    end
    
    disp(':::Beta Plots:::')
    
    for cN = 1:length(betaNames)
        beta_outdir = fullfile(groupdir,'betas',betaNames{cN});
        if ~exist(beta_outdir), mkdir(beta_outdir); end

        % significant betas
        for roi_idx = group_betas(cN).sigRoiIdx
            barscatterPlot(group_betas(cN).beta(roi_idx,:),...
                group_betas(cN).std(roi_idx,:),...
                lowELS,...
                fullfile(beta_outdir,['beta_' roiName{roi_idx}]),...
                ['beta ' roiName{roi_idx}],'beta value')
        end
    end
    
    disp(':::Connectivity Plots:::')
    
    outdir = fullfile(groupdir,'fconn','errors'); if ~exist(outdir),mkdir(outdir);end
    mkdir(fullfile(outdir,'pearson'));
    mkdir(fullfile(outdir,'td'));
    group_plot_fconn(group_fConn_err.pearson,lowELS,utri_idx,...
        fullfile(outdir,'pearson'),...
        ['Error Pearson Correlation'],roitoplot_names,roitoplot_idx)
    group_plot_fconn(group_fConn_err.td,lowELS,utri_idx,...
        fullfile(outdir,'td'),...
        ['Error Time Derivative Correlation'],roitoplot_names,roitoplot_idx)
    
    outdir = fullfile(groupdir,'fconn','tasksignal'); if ~exist(outdir),mkdir(outdir);end
    mkdir(fullfile(outdir,'pearson'));
    mkdir(fullfile(outdir,'td'));
    group_plot_fconn(group_fConn_sign.pearson,lowELS,utri_idx,...
        fullfile(outdir,'pearson'),...
        ['Task-related signal Pearson Correlation'],roitoplot_names,roitoplot_idx)
    group_plot_fconn(group_fConn_sign.td,lowELS,utri_idx,...
        fullfile(outdir,'td'),['Task-related signal Time Derivative Correlation'],roitoplot_names,roitoplot_idx)
    
    outdir = fullfile(groupdir,'fconn','fulltimecourse'); if ~exist(outdir),mkdir(outdir);end
    mkdir(fullfile(outdir,'pearson'));
    mkdir(fullfile(outdir,'td'));
    group_plot_fconn(group_fConn_tc.pearson,lowELS,utri_idx,...
        fullfile(outdir,'pearson'),...
        ['Full timecourse Pearson Correlation'],roitoplot_names,roitoplot_idx)
    group_plot_fconn(group_fConn_tc.td,lowELS,utri_idx,...
        fullfile(outdir,'td'),['Full timecourse Time Derivative Correlation'],roitoplot_names,roitoplot_idx) 
    
    
    disp(':::Done!')
end

function barscatterPlot(vals,valstd,lowELS,outname,titlename,ylabelname)

g1.vals = vals(1:length(lowELS));
g1.std  = valstd(1:length(lowELS));

g2.vals = vals((length(lowELS)+1):end);
g2.std  = valstd((length(lowELS)+1):end);

% Draw error bar chart with means and standard deviations
fid = figure;hold on;
errorbar(1+(-length(g1.vals)/2:length(g1.vals)/2-1)/20,g1.vals, g1.std,'s')
errorbar(2+(-length(g2.vals)/2:length(g2.vals)/2-1)/20,g2.vals, g2.std,'s')
% Add title and axis labels
title(['Mean/std (across voxels in roi) of ' titlename])
ylabel(ylabelname)
box on
% Change the labels for the tick marks on the x-axis
xlabel = {'Low Els', 'High Els'};
xlim([0.5,2.5])
set(gca, 'XTick', 1:2, 'XTickLabel', xlabel)

saveas(fid,[outname '.fig'])
saveas(fid,[outname '.png'])

end

function group_plot_fconn(struct,lowELS,utri_idx,outdir,measureName,roitoplot_names,roitoplot_idx)
    %rois
    for rN1 = 1:length(roitoplot_names)
        for rN2 = (rN1+1):length(roitoplot_names)
            roi_idx =  utri_idx(roitoplot_idx(rN1),roitoplot_idx(rN2));
            if roi_idx == 0 
                roi_idx =  utri_idx(roitoplot_idx(rN2),roitoplot_idx(rN1));
            end
            
            connName = [roitoplot_names{rN1} ' to ' roitoplot_names{rN2}];
        
            barscatterPlot_fconn(struct.subjvals(roi_idx,:),lowELS,...
                fullfile(outdir,connName),...
                    {measureName, connName} )
            
        end
    end

    %significant rois
    for idx = 1:length(struct.sigRoiIdx)
        roi_idx = utri_idx(struct.sigRoiIdx(idx,1),struct.sigRoiIdx(idx,2));
        connName = [struct.sigRoiName{idx,1} ' to ' struct.sigRoiName{idx,2}];
        
        barscatterPlot_fconn(struct.subjvals(roi_idx,:),lowELS,...
            fullfile(outdir,connName),...
            {measureName, connName} )
    end
end

function barscatterPlot_fconn(vals,lowELS,outname,titlename)
    g1.vals = vals(1:length(lowELS));
    g2.vals = vals((length(lowELS)+1):end);

    % Draw error bar chart with means and standard deviations
    fid = figure;hold on;
    scatter(1+(-length(g1.vals)/2:length(g1.vals)/2-1)/20,g1.vals, 'g')
    scatter(2+(-length(g2.vals)/2:length(g2.vals)/2-1)/20,g2.vals, 'r')
    % Add title and axis labels
    title(titlename,'interpreter','none')
    ylabel('Correlation')
    box on
    % Change the labels for the tick marks on the x-axis
    xlabel = {'Low Els', 'High Els'};
    xlim([0.5,2.5])
    legend({'Low Els', 'High Els'});
    set(gca, 'XTick', 1:2, 'XTickLabel', xlabel)

    saveas(fid,[outname '.fig'])
    saveas(fid,[outname '.png'])

end