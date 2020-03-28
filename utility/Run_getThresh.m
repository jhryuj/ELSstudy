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