% secondlevel
% subjlist_file = 'ELSt1checklist_preprocessing191007check.xlsx';
% note that this code runs things without cluster correction

function secondlevel(subjlist_file)
%% directories
basedir             = setbasepath;

mrVista_dir = fullfile(basedir,'Codes','vistasoft-master');addpath(genpath(mrVista_dir));
spmdir      = fullfile(basedir,'Codes','spm12');addpath(spmdir);

% define output directories
outdir      = fullfile(basedir,'Data','GroupAnalyses','191007','glmNormSpace');
if ~exist(outdir), mkdir(outdir);,end
% define mask (for stats) and anatomy (for plotting)
mask    = fullfile(basedir,'Codes','ELSstudy','utility','spmMods','Resliced_gray_matter_hypo_nb_septal_roi.nii'); % different dimensions. create new mask?
anat    = fullfile(spmdir,'canonical','single_subj_T1.nii');

%% parts of the code to run
getStats    = 1;
getContrast = 1;
getthresh   = 1; %1 to get thresholds
getFWE      = 1; % 1 to get FWE
getFDR      = 1; % 1 to get FDR
uncorr_vec  = [0.005, 0.001, 0.0001]; %[0.1 0.01 0.001]; %vector of uncorrected thresholds, leave empty if not wanted.

%% define beta
betaNorms       = {'beta','betaSNR', 'betaPCraw'};

% 8 contrasts
contrastNames   = {'antGain - neut', 'antLoss - neut', 'antGain - antLoss', ...
    'gain - neut', 'loss - neut', 'gain - loss', ...
    'gain - antGain', 'loss - antLoss'};

spm('defaults', 'fmri')
spm_jobman('initcfg')
spm_get_defaults('cmdline',true)

%%
glmlist = {'glm_normSpace'}; % dont run glm_nsubjSpace
for glmN = 1:length(glmlist)
    
    % select subjects that have the contrasts generated
    % conditions.spm_glm_nsubjSpace_contrastGen   = 1;
    conditions.spm_glm_normSpace_contrastGen    = 1;
    
    if exist(fullfile(outdir,'subjlist.mat'),'file')
        load(fullfile(outdir,'subjlist.mat'));
    else
        [~, subjlistcell] = generateSubjectList(subjlist_file,conditions);
        Nsubj   = length(subjlistcell);
        save(fullfile(outdir,'subjlist.mat'),'subjlistcell','Nsubj');
    end
       
    for betaTypeN = 1:3 % do raw Beta again to check.
    for contrastN = 1:8
        contrastlist = cell(Nsubj,1);
        % loop over subjects and find the right contrasts for the beta type.
        for subjN = 1:length(subjlistcell)
            subjID = subjlistcell{subjN};
            
            if contains(subjID,'T1'), folder = 'T1';
            elseif contains(subjID,'TK1'), folder = 'TK1';
            end
    
            glmdir      = fullfile(basedir,'Data',folder,subjID,glmlist{glmN}); 
            contrastdir = fullfile(glmdir,'contrasts'); 
            contrastfile = fullfile(contrastdir,[betaNorms{betaTypeN} '_' contrastNames{contrastN} '.nii']);
            contrastlist{subjN,1} = [contrastfile ',1'];
        end
        
        spmoutdir = fullfile(outdir,[betaNorms{betaTypeN} '_' contrastNames{contrastN}]);
        
        %% run stats
        if getStats
            RunStats(spmoutdir,contrastlist,mask); %define mask file
        end
        
        %% generate positive and negative contrasts
        Images = {'Positive', 'Negative'};
        if getContrast
            RunContrastManager(spmoutdir,Images);
        end

        %% Obtain thresholds. 
        if getthresh ==1
            for j=1:2
                [FWEp, FDRp, FWEc, FDRc] = Run_getThresh(spmoutdir,Images,j,mask); % get cluster thresholds too
            end
        end

        %% plot FWE
        if getFWE ==1
            for j=1:2
                load(fullfile(spmoutdir,[Images{j} '_thresh'])); %load thresholds
                probval     = FWEp;
                clusterval  = FWEc;
                cont_names{j} = Run_ThresholdMaps(spmoutdir,Images,j,mask,probval,clusterval,xSPM); % set clusterval = 3            
            end
            
            Run_PlotOverlay(spmoutdir,cont_names,anat,'FWE_0.05')
        end

        %% plot FDR
        if getFDR==1
            for j=1:2
                load(fullfile(spmoutdir,[Images{j} '_thresh'])); %load thresholds
                probval     = FDRp;
                clusterval  = FDRc;
                cont_names{j}  = Run_ThresholdMaps(spmoutdir,Images,j,mask,probval,clusterval,xSPM);
            end
            
            Run_PlotOverlay(spmoutdir,cont_names,anat,'FDR_0.05')
        end

        %% Uncorrected
        for thresh = uncorr_vec
            for j=1:2
                load(fullfile(spmoutdir,[Images{j} '_thresh'])); %load thresholds
                probval     = thresh;
                clusterval  = 3;
                cont_names{j}  = Run_ThresholdMaps(spmoutdir,Images,j,mask,probval,clusterval,xSPM);
            end
            
            Run_PlotOverlay(spmoutdir,cont_names,anat,['Unc_' num2str(thresh)])
        end
    end
    end
end
end

function RunStats(spmoutdir,contrastlist,maskfile)
    clearvars matlabbatch

    matlabbatch{1}.spm.stats.factorial_design.dir = {spmoutdir};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = contrastlist;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {maskfile};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(spmoutdir,'SPM.mat')};
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    spm_jobman('run',matlabbatch);
    cd(spmoutdir);
    save(['matlabbatch_stats.mat'],'matlabbatch')
    clearvars matlabbatch
end

function RunContrastManager(spmoutdir, Images)        %% contrast manager
    clearvars matlabbatch
    matlabbatch{1}.spm.stats.con.spmmat = {fullfile(spmoutdir,'SPM.mat')};
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = Images{1};
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = Images{2};
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = -1;
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{1}.spm.stats.con.delete = 1;        

    spm_jobman('run',matlabbatch);
    cd(spmoutdir);
    save(['matlabbatch_contrastManager.mat'],'matlabbatch')
    clearvars matlabbatch
end

function [FWEp, FDRp, FWEc, FDRc] = Run_getThresh(spmoutdir,Images,j,maskfile)
    xSPM.swd        = spmoutdir;
    xSPM.Ic         = j;
    xSPM.u          = 0.01;
    xSPM.Im         = {maskfile};
    xSPM.pm         = [];
    xSPM.Ex         = 0;
    xSPM.thresDesc  = 'none';
    xSPM.title      = Images{j};
    xSPM.k          = 3;
    xSPM.n          = 1;
    xSPM.units      = {'mm','mm','mm'};
    
    [SPM,xSPM] = spm_getSPM(xSPM);

    %get FWE and FDR thresholds
    FWEp = xSPM.uc(1); FDRp = xSPM.uc(2);
    FWEc = xSPM.uc(3); FDRc = xSPM.uc(4);

    save(fullfile(spmoutdir,[Images{j} '_thresh']),'SPM', ...
        'xSPM', 'FWEp', 'FDRp','FWEc','FDRc')
end

function [cont_names] = Run_ThresholdMaps(spmoutdir,Images,j,maskfile,probval,clusterval,xSPM) % set clusterval = 3
    matlabbatch{1}.spm.stats.results.spmmat = {fullfile(spmoutdir,'SPM.mat')};
    matlabbatch{1}.spm.stats.results.conspec.titlestr = Images{j};
    matlabbatch{1}.spm.stats.results.conspec.contrasts = j;
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{1}.spm.stats.results.conspec.thresh = probval;
    matlabbatch{1}.spm.stats.results.conspec.extent = clusterval;
    matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{1}.spm.stats.results.units = 1;
    matlabbatch{1}.spm.stats.results.export{1}.ps = true;
    spm_jobman('run',matlabbatch);

    contrast_imgName = [Images{j} ' p' num2str(probval) ' c' num2str(clusterval) '.img'];
    cont_names = fullfile(spmoutdir, contrast_imgName);
    spm_write_filtered(xSPM.Z, xSPM.XYZ, xSPM.DIM, xSPM.M, Images{j}, contrast_imgName);
    clear matlabbatch

    % mask image using imcalc.
%     matlabbatch{1}.spm.util.imcalc.input = {[cont_names]; [maskfile,',1']};
%     matlabbatch{1}.spm.util.imcalc.output = [contrast_imgName '.img'];
%     matlabbatch{1}.spm.util.imcalc.outdir = {spmoutdir};
%     matlabbatch{1}.spm.util.imcalc.expression = 'i1.*i2';
%     matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
%     matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
%     matlabbatch{1}.spm.util.imcalc.options.mask = {maskfile};
%     matlabbatch{1}.spm.util.imcalc.options.interp = 1;
%     matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
%     save(fullfile(spmoutdir, [Images{j} 'batch_mask.mat']));
%     spm_jobman('run',matlabbatch);
%     clear matlabbatch  
end

function Run_PlotOverlay(spmoutdir,cont_names,anat,figName)
    % get overlayed image
    files{1} = anat;
    files{2} = cont_names{1};
    files{3} = cont_names{2};

    slover_radiological_convention_jryu('basic_ui',files,1,4);

    fig_name = [figName '_overlay.fig'];
    tiff_name = [figName '_overlay.tiff'];
    figHandles = 1;
    cd(spmoutdir);
    saveas(figHandles,fig_name);
    screen2tiff(tiff_name);
    close all
end