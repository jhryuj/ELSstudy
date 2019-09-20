function distribution_histogram(x, varName)
%histogram and
% statistics: 
% mean
% std
% kurtosis
fid_hist = figure('Position', [275 53 1389 902],'defaultAxesFontSize',20);
histogram(x,'Normalization', 'pdf');

ylabel('Probability density','FontSize',22); xlabel(varName,'FontSize',22,'interpreter','none')

title({'Histogram', ...
    ['mean = ' num2str(nanmean(x)), '; std = ' num2str(nanstd(x)),...
    '; skew = ' num2str(kurtosis(x)) '; #voxels = ' num2str(length(x))]},'FontSize',22);

saveas(fid_hist, [varName '_hist.fig'])
saveas(fid_hist, [varName '_hist.png'])

close(fid_hist)
end