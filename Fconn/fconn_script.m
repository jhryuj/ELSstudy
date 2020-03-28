% subj = '006-T1'

function fconn_script(subj)

basedir = setbasepath; 

if contains(subj,'T1'), folder = 'T1';
elseif contains(subj,'TK1'), folder = 'TK1';
end

data_dir        = fullfile(basedir,'Data',folder);
spm_dir         = fullfile(basedir,'Codes','spm12');
mrVista_dir     = fullfile(basedir,'Codes','vistasoft-master');
roilist_file    = fullfile(basedir,'Codes','ELSstudy','ROIAnalysis','fsrois.mat');
analysis_folder = 'Analysis_191113';

%% run everything
indexROIs(data_dir, subj, mrVista_dir,roilist_file)
extractROItc(data_dir, subj,mrVista_dir,spm_dir,roilist_file)

fConn_analysis(data_dir,subj,roilist_file,analysis_folder)
fConn_analysis_plot(data_dir,subj,analysis_folder)  

end