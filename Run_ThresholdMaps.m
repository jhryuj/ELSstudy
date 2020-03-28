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