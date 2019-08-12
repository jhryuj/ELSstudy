%% This code is used to overlay functional images onto a structural MRI using SPM. The color, color scale, and brain slices 
%that are displayed can be manipulated in the lines below. 
global model;

model.xacross = 'auto';
model.itype{1} = 'Structural';
model.itype{2} = 'Blobs - Positive';
model.itype{3} = 'Blobs - Negative';
model.imgns{1} = 'Img 1 (Structural)';
model.imgns{2} = 'Img 2 (Blobs - Positive)';
model.imgns{3} = 'Img 3 (Blobs - Negative)';
model.range(:,1) = [0 1];
model.range(:,2) = [3; 8];%This selects the colormap range for contrast 1
model.range(:,3) = [3; 8];%This selects the colormap range for contrast 2
model.transform = 'axial'; %'axial','coronal','sagittal'
model.axialslice = [-56:8:86] %[-72:2:10] for time and z dim switch %[-56:8:86] for normal plots; %This determines the # of slices and thickness that are plotted in the axial plane
model.coronalslice = [-92:8:52]; %This determines the # of slices and thickness that are plotted in the coronal plane

model.imgs{1, 1} = 'F:\HNCT fMRI Study\spm12_radiological\canonical\single_subj_T1.nii' %'F:\HNCT fMRI Study\fMRI Analysis\Analysis Codes\Hacked_anatomical.nii' % Enter the entire path for the strucutral images (e.g., MNI template)

%image_1 = 'F:\HNCT fMRI Study\fMRI Analysis\Paired T-test\SPM\CP-CnP15 time z dim switched\Z_dim 32 CP-CnP15 Activation\positive FWE p 6.0725.img';

Act_img = 'F:\HNCT fMRI Study\fMRI Analysis\Group Analysis\One-sample t-test\CP1-CnP1\Activation FWE p 5.9752.img';

    pos_img = Act_img; %Enter the entire path for the first contrast
    avw = load_nii(pos_img);
    newimg = avw.img*0;
    for x = 1:size(avw.img,1)
        newimg(x,:,:) = avw.img(size(avw.img,1)-x+1,:,:);
    end
    avw.img = newimg;
    save_nii(avw,pos_img)

model.imgs{2, 1} = Act_img; %Enter the entire path for the first contrast

%image_2 = 'F:\HNCT fMRI Study\fMRI Analysis\Paired T-test\SPM\CP-CnP15 time z dim switched\Z_dim 32 CP-CnP15 Deactivation\negative FWE p 6.0723.img';

Deact_img = 'F:\HNCT fMRI Study\fMRI Analysis\Group Analysis\One-sample t-test\CP1-CnP1\Deactivation FWE p 5.9752.img';

    neg_img = Deact_img; %Enter the entire path for the second contrast;
    avw = load_nii(neg_img);
    newimg = avw.img*0;
    for x = 1:size(avw.img,1)
        newimg(x,:,:) = avw.img(size(avw.img,1)-x+1,:,:);
    end
    avw.img = newimg;
    save_nii(avw,neg_img)

model.imgs{3, 1} = Deact_img; %Enter the entire path for the second contrast

display_slices_bai_1 %Function - Confirm that this file is in your path before running this script

cd('F:\HNCT fMRI Study\fMRI Analysis\Group Analysis\One-sample t-test\CP1-CnP1');
%print('CP15-CnP15 one-sample t-test act and deact FWE','-dpdf', '-r0', '-fillpage') %Creates a PDF of figure 
