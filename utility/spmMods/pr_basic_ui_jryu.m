function obj = pr_basic_ui_jryu(imgs, dispf, num_slices)
% GUI to request parameters for slover routine
% FORMAT obj = pr_basic_ui(imgs, dispf)
%
% GUI requests choices while accepting many defaults
%
% imgs  - string or cell array of image names to display
%         (defaults to GUI select if no arguments passed)
% dispf - optional flag: if set, displays overlay (default = 1)
% num_slices   - number of slices (added by RK). 2 (2x2 slices), 3 (3x3 slices) OR 4
% (4x4 slices)
%
% $Id: pr_basic_ui.m,v 1.1 2005/04/20 15:05:00 matthewbrett Exp $
 
if nargin < 1
  imgs = '';
end
if isempty(imgs)
  imgs = spm_select(Inf, 'image', 'Image(s) to display');
end
if ischar(imgs)
  imgs = cellstr(imgs);
end
if nargin < 2
  dispf = 1;
end
  
spm_input('!SetNextPos', 1);

% load images
nimgs = size(imgs);
nimgs = nimgs(2);

% process names
nchars = 20;
imgns = spm_str_manip(imgs, ['rck' num2str(nchars)]);

% Get new default object
obj = slover_radiological_convention;

% identify image types
cscale = [];
deftype = 1;
obj.cbar = [];
for i = 1:nimgs
  obj.img(i).vol = spm_vol(imgs{i});
  options = {'Structural','Truecolour', ...
      'Blobs','Negative blobs','Contours'};
  switch i 
      case 1
          options = options(1); % RK - structural for the single study canonical image
      case 2
          options = options(3); % RK - blobs
      case 3
          options = options(4); % RK - negative blobs
  end
  % if there are SPM results in the workspace, add this option
%   [XYZ Z M] = pr_get_spm_results;
  XYZ = [];
  if ~isempty(XYZ)
    options = {'Structural with SPM blobs', options{:}};
  end
  itype = spm_input(sprintf('Img %d: %s - image type?', i, imgns{i}), '+1', ...
            'm', char(options),options, deftype);
  imgns(i) = {sprintf('Img %d (%s)',i,itype{1})};
  [mx mn] = slover_radiological_convention('volmaxmin', obj.img(i).vol);
  if ~isempty(strmatch('Structural', itype))
    obj.img(i).type = 'truecolour';
    obj.img(i).cmap = gray;
    obj.img(i).range = [mn mx];
    deftype = 2;
    cscale = [cscale i];
    if strcmp(itype,'Structural with SPM blobs')
      obj = add_spm(obj);
    end
  else
      if i == 2
          obj.img(i).type = 'split';
          dcmap = 'hot';
          drange = [0.01 max(1,mx)];
          obj.img(i).prop = 1;
          obj.cbar = [obj.cbar i];
          dcmap = 'hot';
      end
      if i == 3
          obj.img(i).type = 'split';
          dcmap = 'winter';
          drange = [0.01 max(1,mx)];
          obj.img(i).prop = 1;
          obj.cbar = [obj.cbar i];
          dcmap = 'winter';
      end
    cprompt = ['Colormap: ' imgns{i}];
%     switch itype{1}
%      case 'Truecolour'
%       obj.img(i).type = 'truecolour';
%       dcmap = 'flow.lut';
%       drange = [mn mx];
%       cscale = [cscale i];
%       obj.cbar = [obj.cbar i];
%      case 'Blobs'
%       obj.img(i).type = 'split';
%       dcmap = 'hot';
%       drange = [0.01 8];
%       obj.img(i).prop = 1;
%       obj.cbar = [obj.cbar i];
%      case 'Negative blobs'
%       obj.img(i).type = 'split';
%       dcmap = 'winter';
%       drange = [0.01 8];
%       obj.img(i).prop = 1;
%       obj.cbar = [obj.cbar i];
%      case 'Contours'
%       obj.img(i).type = 'contour';
%       dcmap = 'white';
%       drange = [mn mx];
%       obj.img(i).prop = 1;
%     end
    obj.img(i).cmap = sf_return_cmap(cprompt, dcmap);
    obj.img(i).range = [0.01 8];
  end
end
ncmaps=length(cscale);
if ncmaps == 1
  obj.img(cscale).prop = 1;
else
  remcol=1;
  for i = 1:ncmaps
    ino = cscale(i);
    obj.img(ino).prop = spm_input(sprintf('%s intensity',imgns{ino}),...
                 '+1', 'e', ...
                 remcol/(ncmaps-i+1),1);
    remcol = remcol - obj.img(ino).prop;
  end
end
 
% obj.transform = deblank(spm_input('Image orientation', '+1', ['Axial|' ...
%             ' Coronal|Sagittal'], strvcat('axial','coronal','sagittal'), ...
%             1));
obj.transform = 'axial';       


% obj.transform = deblank(spm_input('Image orientation', '+1', ['Axial|' ...
%             ' Coronal|Sagittal'], strvcat('axial','coronal','sagittal'), ...
%             1));


% use SPM figure window
obj.figure = spm_figure('GetWin', 'Graphics');

% slices for display
obj = fill_defaults(obj);
slices = obj.slices;
% obj.slices = spm_input('Slices to display (mm)', '+1', 'e', ...
%               sprintf('%0.0f:%0.0f:%0.0f',...
%                   slices(1),...
%                   mean(diff(slices)),...
%                   slices(end))...
%           );
if num_slices == 5
    obj.slices = [-48:8:68];
    obj.slices = [-8:16:56];
elseif num_slices == 4
    obj.slices = [-52:8:44,56];   
   % obj.slices = [-52:8:52];
elseif num_slices == 3
    obj.slices = [-24:16:56];
elseif num_slices == 2
    obj.slices = [-8:16:40];
elseif num_slices == 0
    obj.slices = [-8 8 24 40];
%     obj.slices = [-56:8:64];
end

% and do the display
if dispf, obj = paint(obj); end

return


% Subfunctions 
% ------------
function cmap = sf_return_cmap(prompt,defmapn)
% RK - defmapn is either 'hot' or 'winter'
cmap = [];
while isempty(cmap)
  [cmap w]= slover_radiological_convention('getcmap', defmapn);
  if isempty(cmap), disp(w);end
end
return
