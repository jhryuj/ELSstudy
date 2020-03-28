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