function basedir = setbasepath
    
if ismac % assume local on josh's mac
    basedir         = '/Volumes/groups/iang/users/lrborch/ELSReward/';
    addpath(fullfile(basedir,'Codes','utility'));
elseif ispc
    basedir         = 'Z:\users\lrborch\ELSReward\';
else % assume sherlock
    basedir         = '/oak/stanford/groups/iang/users/lrborch/ELSReward';
end

end