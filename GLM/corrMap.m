% secondlevel
% subjlist_file = 'ELSt1checklist_preprocessing191007check.xlsx';
% note that this code runs things without cluster correction

function corrMap(subjlist_file)
%% directories
basedir = setbasepath; 
outbase = '/Volumes/group/users/borchersLR/reward_temp_josh'; % outbase = basedir;

mrVista_dir = fullfile(basedir,'Codes','vistasoft-master');addpath(genpath(mrVista_dir));
spmdir      = fullfile(basedir,'Codes','spm12');addpath(spmdir);

% define outpyut directories
outdir      = fullfile(outbase,'Data','GroupAnalyses','191007_corrs','glmNormSpace');
if ~exist(outdir), mkdir(outdir);,end
% define mask (for stats) and anatomy (for plotting)
mask    = fullfile(basedir,'Codes','ELSstudy','utility','spmMods','Resliced_gray_matter_hypo_nb_septal_roi.nii'); % different dimensions. create new mask?
anat    = fullfile(spmdir,'canonical','single_subj_T1.nii');

uncorr_vec  = [0.001, 0.01, 0.05, 0.1, 0.2]; %[0.1 0.01 0.001]; %vector of uncorrected thresholds, leave empty if not wanted.

%% define beta
betaNorms       = {'beta','betaSNR', 'betaPCraw'};

% 8 contrasts
contrastNames   = {'antGain - neut', 'antLoss - neut', 'antGain - antLoss', ...
    'gain - neut', 'loss - neut', 'gain - loss', ...
    'gain - antGain', 'loss - antLoss'};

%% load the demographics and ELS behavior
behbase = '/Volumes/group/users/borchersLR/R_code';

subjreward_data = readtable(fullfile(outbase,'rewardels.csv'));

%% generate subject list
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

% behaviors to look for.
% (objective report, subjective measure, depression,anxiety)
beh = {'sumsev_type_t1', 'sumsub_type_t1', 'cdi_TOTAL_T1','masctot_T1'};

glmlist = {'glm_normSpace'}; % dont run glm_nsubjSpace
for glmN = 1:length(glmlist)
    for betaTypeN = 1:3 % do raw Beta again to check.
    for contrastN = 1:8
        savedir = fullfile(outdir,betaNorms{betaTypeN},contrastNames{contrastN},beh{1});
        if ~exist(fullfile(savedir,'corrs.mat'),'file')
            % initialize stuff.
            templatefile  = fullfile(basedir,'Data','T1','006-T1','glm_normSpace','beta_0001.nii');        
            templatenii   = readFileNifti(templatefile);
            subjdatamat   = nan([size(templatenii.data),length(subjlistcell)]);

            % loop over subjects and find the right contrasts for the beta type.
            for subjN = 1:length(subjlistcell)
                subjID = subjlistcell{subjN};

                if contains(subjID,'T1'), folder = 'T1';
                elseif contains(subjID,'TK1'), folder = 'TK1';
                end

                glmdir       = fullfile(basedir,'Data',folder,subjID,glmlist{glmN}); 
                contrastdir  = fullfile(glmdir,'contrasts'); 
                contrastfile = fullfile(contrastdir,[betaNorms{betaTypeN} '_' contrastNames{contrastN} '.nii']);

                subjnii     = readFileNifti(contrastfile);
                subjdatamat(:,:,:,subjN) = subjnii.data;
            end

            % find behavior arrays
            variates        = nan(length(subjlistcell),length(beh));
            covariates      = nan(length(subjlistcell),4);
            correlations    = nan([size(templatenii.data),length(beh)]);
            pvals           = nan([size(templatenii.data),length(beh)]);
            for subjN = 1:length(subjlistcell)
                subjID = subjlistcell{subjN};
                idx = find(strcmp(subjreward_data.id_x,subjID));

                for behN = 1:length(beh)
                    val = eval(['subjreward_data.' beh{behN} '(' num2str(idx) ')']);
                    if iscell(val)
                        if ~isempty(str2num(val{1}))
                            variates(subjN,behN) = str2num(val{1});
                        end
                    else
                        variates(subjN,behN) = val;
                    end
                end

                covariates(subjN,1) = subjreward_data.Age_at_Scan_1(idx);
                covariates(subjN,2) = strcmp(subjreward_data.T1_Child_Sex(idx),'2'); %female
                covariates(subjN,3) = strcmp(subjreward_data.T1_Child_Sex(idx),'1');
                covariates(subjN,4) = subjreward_data.Time_btwn_T1S1_and_Scan_1_Days(idx);
            end
            % covariates(:,5) = ones(size(covariates,1),1); % don't need since
            % we have male/female means

            [idx1, idx2, idx3] = meshgrid(1:size(subjdatamat,1),1:size(subjdatamat,2),1:size(subjdatamat,3));
            idx1 = idx1(:); idx2 = idx2(:); idx3 = idx3(:);
            for voxelN = 1:prod(size(templatenii.data))
                x = idx1(voxelN);
                y = idx2(voxelN);
                z = idx3(voxelN);

                if sum(abs(subjdatamat(x,y,z,:))) > eps && (sum(subjdatamat(x,y,z,:)>0) > (length(subjlistcell)/2))
                    warning('off','stats:regress:RankDefDesignMat')
                    % regress out covariates
                    [b,bint,r] = regress(reshape(subjdatamat(x,y,z,:),[length(subjlistcell),1]),covariates);            
                    % find correlations with the variables of interest
                    [correlations(x,y,z,:) pvals(x,y,z,:)] = corr(r,variates,'rows','complete');
                end
            end
        
        else
            load(fullfile(savedir,'corrs.mat'))
        end
        
        %% save correlation and pval maps
        for behN = 1:length(beh)
            savedir = fullfile(outdir,betaNorms{betaTypeN},contrastNames{contrastN},beh{behN});
            if ~exist(savedir,'dir'), mkdir(savedir);,end
            
            % write positive and negative correlation image
            Images = {'Positive', 'Negative'};
            templatefile  = fullfile(basedir,'Data','T1','006-T1','glm_normSpace','beta_0001.nii');        
            templatenii   = readFileNifti(templatefile);
            templatenii.fname   = fullfile(savedir,['pvals.nii']); 
            templatenii.data    = reshape(pvals(:,:,:,behN),[size(correlations,1), size(correlations,2), size(correlations,3)]);
            writeFileNifti(templatenii);
            
            for thresh = uncorr_vec %generate images for these thresholds
                for imN = 1:2
                    data = reshape(correlations(:,:,:,behN),[size(correlations,1), size(correlations,2), size(correlations,3)]);
                    data(pvals(:,:,:,behN)>thresh) = 0;
                    if imN == 1
                        data(data<0) = 0; % take positive data
                        templatenii.data = data;
                    else
                        data(data>0) = 0; % take negative data
                        templatenii.data = -data;
                    end
                    cont_names{imN}     = fullfile(savedir,['corr_p=' num2str(thresh) '_' Images{imN} '.nii']); 
                    templatenii.fname   = cont_names{imN}; 
                    writeFileNifti(templatenii);
                end
                
                % change line 120 in pr_basic_ui_jryu.m to [0,1]
                Run_PlotOverlay(savedir,cont_names,anat,['corr_p=' num2str(thresh)])
            end
            
            save(fullfile(savedir,'corrs.mat'),'correlations','pvals')
        end
    end
    end
end
end
