fsdir = '/Volumes/iang/users/lrborch/204b/Codes/freesurfer6.0.0/';
%fsdir = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/freesurfer6.0.0/';

fslist = fullfile(fsdir,'freesurfer/FreeSurferColorLUT.txt');

roiNum = [];
roiName = {};

fid = fopen(fslist);
tline = fgetl(fid);
while ischar(tline)
    if isempty(tline) || isnan(str2double(tline(1))) || ...
        str2double(tline(1)) == 0
    else
        disp(tline)
        splitline = strsplit(tline);
        roiNum(end+1) = str2num(splitline{1});
        roiName{end+1} = splitline{2};
    end
    tline = fgetl(fid);
end
fclose(fid);

save(fullfile(fsdir,'fsrois.mat'),'roiNum','roiName')


