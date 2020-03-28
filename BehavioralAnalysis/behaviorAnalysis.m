% Josh Ryu; jhryu25@stanford.edu

% directories
% data_dir = '/Volumes/iang/users/lrborch/204b/Data/';
% subj = '006-T1';

% Server directories:
% data_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Data';
% subj = '006-T1';

% Server directories:
% data_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Data';
% subj = '006-T1';

function behaviorAnalysis(data_dir,subj)
    behavior_dir = fullfile(data_dir,subj,'Behavioral',subj,'model7');
    cd(behavior_dir);

    behfiles = {'_ant_all.txt', '_delay_all.txt','_outcome_all.txt','_target_all.txt','_missed.txt'};
    behfiles2 = {'_ant_gain.txt', '_ant_loss.txt','_ant_neut.txt','_ant_nongain.txt',...
        '_ant_nonloss.txt','_gain.txt','_loss.txt','_no_gain.txt',...
        '_no_loss.txt','_nongain_neutral.txt','_nonloss_neutral.txt','_outcome_neutral.txt'};

    plottimeline = 0;

    %% save behavior;

    conditionblocks = struct();
    condition_times = struct();

    if plottimeline
        f = figure('visible','off','Position', [42 111 1570 806],'DefaultAxesFontSize',18,'defaultLineLineWidth',2);
        hold on;
    end

    time = 0:0.1:500; %0.1s time resolution;
    behlegends = {};

    for condn = 1:length(behfiles)
        a = load(fullfile(behavior_dir,[subj behfiles{condn}]));
        eventblock = zeros(size(time));

        for eventN = 1:size(a,1)
            eventblock((a(eventN,1) < time) & (time < a(eventN,1)+a(eventN,2))) = 1;
        end

        if plottimeline
            plot(time,eventblock)
        end

        eval(['conditionblocks.', eval('behfiles{condn}(2:end-4)'), '= eventblock/max(eventblock);'])
        behlegends{end+1} = behfiles{condn}(2:end-4);
    end 

    for condn = 1:length(behfiles2)
        a = load(fullfile(behavior_dir,[subj behfiles2{condn}]));
        eventblock = zeros(size(time));

        for eventN = 1:size(a,1)
            eventblock((a(eventN,1) < time) & (time < a(eventN,1)+a(eventN,2))) = 0.95;
        end

        if plottimeline
            plot(time,eventblock)
        end

        eval(['conditionblocks.', eval('behfiles2{condn}(2:end-4)'), '= eventblock/max(eventblock);'])
        behlegends{end+1} = behfiles2{condn}(2:end-4);
    end 

    if plottimeline
        legend(behlegends, 'Interpreter', 'none')
        ylim([0.9,1.1])
    end

    save(fullfile(data_dir,subj,'Behavioral','behconditions.mat'),'conditionblocks','behlegends','time')
end