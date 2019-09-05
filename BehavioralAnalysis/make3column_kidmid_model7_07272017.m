% make3column_model7.m makes EV (.txt) files for L1 analysis, records RTs for each trial type, records accuracy for each trial type, 
% total accuracy, and number of trials for each outcome type that goes into
% the model, as well as number of missed trials. The trials included in the
% 3column files exclude trials where no button was pressed (missed trials).

% This script also writes 3 column files for 2 new outcome regressors: 1.
% no_gain (formerly grouped with nongain), and no_loss
% (formerly nonloss).

% make3column_1.m only writes regressor (.txt) files and  3column files include missed
% trials. when in doubt, run both scripts.

% allsubs_behavior.m compiles the behavioral output of this script for every subject.


maindir = '/Volumes/iang/users/colichNL/els2/t1';


sublist = {'124-T1', 	'125-T1', 	'127-T1', 	'130x-T1', 	'132-T1', 	'134x-T1', 	'135-T1', 	'136-T1', 	'137-T1', 	'138-T1', 	'139-T1', 	'140-T1', 	'143-T1', 	'144-T1', 	'145-T1', 	'146-T1', 	'147-T1', 	'148-T1', 	'149-T1', 	'150-T1', 	'151-T1', 	'152-T1', 	'153x-T1', 	'154-T1', 	'155-T1', 	'156-T1', 	'157-T1', 	'158-T1', 	'159-T1', 	'160-T1', 	'161-T1', 	'162-T1', 	'163-T1', 	'164-T1', 	'165-T1', 	'166-T1', 	'168-T1', 	'169-T1', 	'170-T1', 	'171-T1', 	'172-T1', 	'173-T1', 	'174-T1', 	'178-T1', 	'179-T1', 	'180-T1', 	'181-T1', 	'182-T1', 	'183-T1', 	'185-T1', 	'186-T1', 	'187-T1', 	'188-T1', 	'189-T1', 	'191-T1', 	'192-T1', 	'193x-T1', 	'194x-T1', 	'195-T1', 	'197-T1', 	'202-T1', 	'203-T1', 	'205-T1', 	'208-T1', 	'210-T1', 	'213-T1', 	'214-T1', 	'215-T1', 	'217-T1', 	'218-T1'}
sublist2 = {'124', 	'125', 	'127', 	'130', 	'132', 	'134', 	'135', 	'136', 	'137', 	'138', 	'139', 	'140', 	'143', 	'144', 	'145', 	'146', 	'147', 	'148', 	'149', 	'150', 	'151', 	'152', 	'153', 	'154', 	'155', 	'156', 	'157', 	'158', 	'159', 	'160', 	'161', 	'162', 	'163', 	'164', 	'165', 	'166', 	'168', 	'169', 	'170', 	'171', 	'172', 	'173', 	'174', 	'178', 	'179', 	'180', 	'181', 	'182', 	'183', 	'185', 	'186', 	'187', 	'188', 	'189', 	'191', 	'192', 	'193', 	'194', 	'195', 	'197', 	'202', 	'203', 	'205', 	'208', 	'210', 	'213', 	'214', 	'215', 	'217', 	'218'}


%sublist = {'004-T1', '005-T1', 	'006-T1', 	'009-T1', 	'010-T1', 	'013-T1', 	'014-T1', 	'016-T1', 	'017-T1', 	'020-T1', 	'021-T1', 	'022-T1', 	'023-T1', 	'024-T1', 	'025-T1', 	'026-T1', 	'028-T1', 	'030-T1', 	'031-T1', 	'032-T1', 	'033-T1', 	'034-T1', 	'035-T1', 	'036-T1', 	'037-T1', 	'038-T1', 	'039-T1', 	'040-T1', 	'041-T1', 	'042-T1', 	'045x-T1', 	'047-T1', 	'049-T1', 	'050-T1', 	'054-T1', 	'055x-T1', 	'056-T1', 	'058-T1', 	'059-T1', 	'060-T1', 	'061-T1', 	'062-T1', 	'064-T1', 	'065-T1', 	'068-T1', 	'069-T1', 	'070-T1', 	'072-T1', 	'073-T1', 	'074-T1', 	'075-T1', 	'076-T1', 	'077-T1', 	'079-T1', 	'081-T1', 	'083-T1', 	'085-T1', 	'086x-T1', 	'087-T1', 	'088-T1', 	'090-T1', 	'091-T1', 	'093-T1', 	'095-T1', 	'097-T1', 	'098-T1', 	'099-T1', 	'100-T1', 	'102-T1', 	'103-T1', 	'106-T1', 	'107-T1', 	'108-T1', 	'111-T1', 	'112-T1', 	'113-T1', 	'115-T1', 	'117-T1', 	'118-T1', 	'120-T1', 	'121-T1', 	'122-T1', 	'123-T1', 	'124-T1', 	'125-T1', 	'127-T1', 	'130x-T1', 	'132-T1', 	'134x-T1', 	'135-T1', 	'136-T1', 	'137-T1', 	'138-T1', 	'139-T1', 	'140-T1', 	'143-T1', 	'144-T1', 	'145-T1', 	'146-T1', 	'147-T1', 	'148-T1', 	'149-T1', 	'150-T1', 	'151-T1', 	'152-T1', 	'153x-T1', 	'154-T1', 	'155-T1', 	'156-T1', 	'157-T1', 	'158-T1', 	'159-T1', 	'160-T1', 	'161-T1', 	'162-T1', 	'163-T1', 	'164-T1', 	'165-T1', 	'166-T1', 	'168-T1', 	'169-T1', 	'170-T1', 	'171-T1', 	'172-T1', 	'173-T1', 	'174-T1', 	'178-T1', 	'179-T1', 	'180-T1', 	'181-T1', 	'182-T1', 	'183-T1', 	'185-T1', 	'186-T1', 	'187-T1', 	'188-T1', 	'189-T1', 	'191-T1', 	'192-T1', 	'193x-T1', 	'194x-T1', 	'195-T1', 	'197-T1', 	'202-T1', 	'203-T1', 	'205-T1', 	'208-T1', 	'210-T1', 	'213-T1', 	'214-T1', 	'215-T1', 	'217-T1', 	'218-T1'}
%sublist2 = {'004', '005', 	'006', 	'009', 	'010', 	'013', 	'014', 	'016', 	'017', 	'020', 	'021', 	'022', 	'023', 	'024', 	'025', 	'026', 	'028', 	'030', 	'031', 	'032', 	'033', 	'034', 	'035', 	'036', 	'037', 	'038', 	'039', 	'040', 	'041', 	'042', 	'045', 	'047', 	'049', 	'050', 	'054', 	'055', 	'056', 	'058', 	'059', 	'060', 	'061', 	'062', 	'064', 	'065', 	'068', 	'069', 	'070', 	'072', 	'073', 	'074', 	'075', 	'076', 	'077', 	'079', 	'081', 	'083', 	'085', 	'086', 	'087', 	'088', 	'090', 	'091', 	'093', 	'095', 	'097', 	'098', 	'099', 	'100', 	'102', 	'103', 	'106', 	'107', 	'108', 	'111', 	'112', 	'113', 	'115', 	'117', 	'118', 	'120', 	'121', 	'122', 	'123', 	'124', 	'125', 	'127', 	'130', 	'132', 	'134', 	'135', 	'136', 	'137', 	'138', 	'139', 	'140', 	'143', 	'144', 	'145', 	'146', 	'147', 	'148', 	'149', 	'150', 	'151', 	'152', 	'153', 	'154', 	'155', 	'156', 	'157', 	'158', 	'159', 	'160', 	'161', 	'162', 	'163', 	'164', 	'165', 	'166', 	'168', 	'169', 	'170', 	'171', 	'172', 	'173', 	'174', 	'178', 	'179', 	'180', 	'181', 	'182', 	'183', 	'185', 	'186', 	'187', 	'188', 	'189', 	'191', 	'192', 	'193', 	'194', 	'195', 	'197', 	'202', 	'203', 	'205', 	'208', 	'210', 	'213', 	'214', 	'215', 	'217', 	'218'}


for s = 1:length(sublist)
    subID = sublist{s}
    subID2 = sublist2{s}
   
    
    
    evdir = fullfile(maindir, 'kidmid_EV_bx', subID);  %where EV files get dumped when doing bx analyses
    %evdir = fullfile(maindir, 'kidmid_EV', subID);  %where EV files get dumped when creating regressors
    if ~exist (evdir)  %if doesnt exits
        mkdir (evdir)   %make dir
    end
    misseddir = fullfile(maindir, 'kidmid_EV_bx', subID, 'no.missed_model7'); %where EV files get dumped for excluding missed trials
    if ~exist (misseddir)
        mkdir (misseddir)
    end
    model7dir = fullfile(maindir, 'kidmid_EV_bx', subID, 'model7'); %where EV files get dumped for excluding missed trials
    if ~exist (model7dir)
        mkdir (model7dir)
    end
    
    behavdir = fullfile(maindir, 'kidmid_EV_bx');

    datadir = fullfile(maindir, subID, 'behavioral');  %where E-prime data lives
    cd(datadir) 
    
    [num,txt,raw] = xlsread(['kidmid_behavior_' subID '.xlsx']);  %load in data;
  
    %%% this loads 3 diff variables in the workspace named 'num', 'txt',
    %%% and 'raw' which each represent the data file in a different format.
    %%% We're going to use 'raw', which looks closest to the Excel file.
    
    
    if strcmp(subID,'002-T1')
        trigtime = raw{2,41};
        range = 3:74;
    elseif strcmp(subID2, '021') 
        range = 4:73;  %only 70 trials
        trigtime = raw{3,41};
    elseif strcmp(subID2,'029') 
        range = 4:66; %only 63 trials acquired
        trigtime = raw{3,41};
    else
        trigtime = raw{3,41};  %trigtime  raw{3,41}
        range = 4:75;
    end
    disdaqs = 8000;
    adjust = trigtime + disdaqs;  %total time to be subtracted
    
    %%% setting up empty vectors to represent the first 2 colummns in EV files (time
    %%% and duration) for each regressor: gain_ant, loss_ant, neut_ant,
    %%% gain_outcome, loss_outcome, neut_outcome, {no_loss_neutral_outcome, no_gain_neutral_outcome},
    %%% target, delay2, feedback (collapsed across all conditions),
    %%% anticipation (collapsed across all conditions).
    
    %anticipation regressors (4)
    gain_ant_time = [];  %1. anticipation of potential gain, time colummn
    loss_ant_time = [];  %2. anticipation of potential loss, time column
    neut_ant_time = [];  %3. anticipation of not winning or losing, time column
    antall_time = [];    %4. anticipation for all trials (used in Outcome model), time column
    nongain_ant_time = []; %5. anticipation of nongain, time
    nonloss_ant_time = []; %6. anticipation of nonloss, time
    
    
    gain_ant_dur = [];  %anticipation of potential gain, duration colummn
    loss_ant_dur = [];  %anticipation of potential loss, duration column
    neut_ant_dur = [];  %anticipation of not winning or losing, duration column
    antall_dur = [];       %anticipation for all trials (used in Outcome model), duration column
    nongain_ant_dur = [];
    nonloss_ant_dur = [];
    
    
    %outcome regressors (8; 6 are used in model7; 4 are used in Model4)
    gain_outcome_time = [];        %1. winning feedback, time column
    loss_outcome_time = [];        %2. losing feedback, time column
    neut_outcome_time = [];        %3. neither win nor lose, time column
    no_gain_neutral_outcome_time = [];     %4. nongain feedback during nongain trials, time column
    no_loss_neutral_outcome_time = [];     %5. nonloss feedback during nonloss trials, time column
    feedback_time = [];            %6. feedback phase (used in Anticipation model), time column
    no_gain_time = [];         %7. didn't win - unsuccessful on gain trials, time column
    no_loss_time = [];     %8. didn't lose - successfully avoided loss on loss trials, time column 
    
    
    gain_outcome_dur = [];    %winning feedback, duration column
    loss_outcome_dur = [];    %losing feedback, duration column
    neut_outcome_dur = [];    %neither win nor lose, duration column
    no_gain_neutral_outcome_dur = []; %didn't win, duration column
    no_loss_neutral_outcome_dur = []; %avoid losing, duration column
    feedback_dur = [];        %feedback phase (used in Anticipation model), duration column
    no_gain_dur = [];     %didn't win - unsuccessful on gain trials, duration column
    no_loss_dur = []; %didn't lose - successfully avoided loss on loss trials, duration column
    
    %target
    target_time = [];   %target
    target_dur = [];
    
    %Delay2 (period in between target offset and feedback onset)
    delay_time = [];
    delay_dur = [];
    
    %missed trials
    missed_time = [];
    missed_dur = [];
    
    %accuracy and trial-type counts 
    gain_succ = 0;
    gain_count = 0;
    no_gain_count = 0;
    nongain_neutral_succ = 0;
    loss_succ = 0;
    loss_count = 0;
    no_loss_count = 0;
    nonloss_neutral_succ = 0;
    missed_count = 0;

    
    %rt
    gain_rt = []; %rt for all potential gain trials
    loss_rt = [];
    nongain_neutral_rt = [];
    nonloss_neutral_rt = [];
    
    %number of trials per trialtype(condition)
    antgain_count = 0; %should be 18 or 24
    antloss_count = 0; %should be 18 or 24
    antnongain_neutral_count = 0; %should be 18 or 12
    antnonloss_neutral_count = 0;
    nongain_neutral_count = 0; %should be 18 or 12
    nonloss_neutral_count = 0; %should be 18 or 12
    
    %%%condition types, identified by target image name:
    %%%1. sqr2 = you CAN lose 5 points
    %%%2. cir2 = you CAN win 5 points
    %%%3. sqr = you don't lose anything
    %%%4. cir = you don't win anything
    
    %looping through each trial
    for i = range  %i is the row, so trials are from row 4-75; 3:74 for 002
        
        if strcmp(raw{i,62},'dist_resized/cir2.bmp')  %if cir2
            antgain_count = antgain_count + 1;
        elseif strcmp(raw{i,62},'dist_resized/sqr2.bmp')  %if sqr2
            antloss_count = antloss_count + 1;
        elseif strcmp(raw{i,62},'dist_resized/cir.bmp')  %if cir
            antnongain_neutral_count = antnongain_neutral_count + 1;
        elseif strcmp(raw{i,62},'dist_resized/sqr.bmp')  %if sqr
            antnonloss_neutral_count = antnonloss_neutral_count + 1;
        end
               
        
        if isnan(raw{i,64}) == 1 && isnan(raw{i,50}) == 1 %if Tg.RESP (col BL, 64) = NaN (return TRUE) and Dly2.RESP (col AX, 50) = NaN, i.e., no button-press for trial
            missed_time = [missed_time (raw{i,44} - adjust)/1000]; 
            missed_dur = [missed_dur (raw{i+1,44}-raw{i,44})/1000]; %duration is entire length of trial
            missed_count = missed_count + 1;
            
        else
            
        %first, fill regressors for which condition is irrelevant (should include all 72 trials, length should be 72)
        antall_time = [antall_time (raw{i,44} - adjust)/1000]; %col 44: {'Cue.OnsetTime';}
        antall_dur = [antall_dur (raw{i,63}-raw{i,44})/1000];  %col 63 - 44: {'Tgt.OnsetTime';} - {'Cue.OnsetTime';}
        feedback_time = [feedback_time (raw{i,54} - adjust)/1000]; %col 54: {'fbk.OnsetTime';}
        feedback_dur = [feedback_dur (raw{i+1,44}-raw{i,54})/1000]; %col 44 for subsequent trial - col 54, then 1.5: {'Cue.OnsetTime';} - {'fbk.OnsetTime';}
        target_time = [target_time (raw{i,63} - adjust)/1000]; %col 63: {'Tgt.OnsetTime';}
        target_dur = [target_dur (raw{i,66})/1000]; %col 66: {'TgtDur[Trial]';}
        delay_time = [delay_time (raw{i,49} - adjust)/1000]; %col 49: {'Dly2.OnsetTime';}
        delay_dur = [delay_dur (raw{i,54}-raw{i,49})/1000]; %col 54 - 49: {'fbk.OnsetTime';} - {'Dly2.OnsetTime';}
        
        %if condition is neutral; column 62 refers to the shape image name
        if strcmp(raw{i,62},'dist_resized/cir.bmp') || strcmp(raw{i,62},'dist_resized/sqr.bmp')  %if cir OR sqr
            neut_ant_time = [neut_ant_time (raw{i,44} - adjust)/1000]; %col 44: {'Cue.OnsetTime';}
            neut_ant_dur = [neut_ant_dur (raw{i,63}-raw{i,44})/1000]; %col 63 - 44: {'Tgt.OnsetTime';} - {'Cue.OnsetTime';
            neut_outcome_time = [neut_outcome_time (raw{i,54} - adjust)/1000]; %col 54: {'fbk.OnsetTime';}
            neut_outcome_dur = [neut_outcome_dur (raw{i+1,44}-raw{i,54})/1000]; %col 44 for subsequent trial - col 54, then 1.5: {'Cue.OnsetTime';} - {'fbk.OnsetTime';}
            if strcmp(raw{i,62},'dist_resized/cir.bmp')  %if cir, no gain (nongain)
                nongain_ant_time = [nongain_ant_time (raw{i,44} - adjust)/1000];
                nongain_ant_dur = [nongain_ant_dur (raw{i,63}-raw{i,44})/1000];
                no_gain_neutral_outcome_time = [no_gain_neutral_outcome_time (raw{i,54} - adjust)/1000];  %col 54: {'fbk.OnsetTime';}
                no_gain_neutral_outcome_dur = [no_gain_neutral_outcome_dur (raw{i+1,44}-raw{i,54})/1000];  %col 44 for subsequent trial - col 54, then 1.5: {'Cue.OnsetTime';} - {'fbk.OnsetTime';}
                nongain_neutral_count = nongain_neutral_count + 1;
                if raw{i,64} == 1 %if trial is successful
                    nongain_neutral_succ = nongain_neutral_succ + 1;
                    nongain_neutral_rt = [nongain_neutral_rt raw{i,65}];  %{'Tgt.RT';}
                else nongain_neutral_rt = [nongain_neutral_rt raw{i,66}+raw{i,51}];
                end
            else  %sqr, no loss (nonloss) 
                nonloss_ant_time = [nonloss_ant_time (raw{i,44} - adjust)/1000];
                nonloss_ant_dur = [nonloss_ant_dur (raw{i,63}-raw{i,44})/1000];
                no_loss_neutral_outcome_time = [no_loss_neutral_outcome_time (raw{i,54} - adjust)/1000];
                no_loss_neutral_outcome_dur = [no_loss_neutral_outcome_dur (raw{i+1,44}-raw{i,54})/1000];
                nonloss_neutral_count = nonloss_neutral_count + 1;
                if raw{i,64} == 1 %if trial is successful
                    nonloss_neutral_succ = nonloss_neutral_succ + 1;
                    nonloss_neutral_rt = [nonloss_neutral_rt raw{i,65}];  %{'Tgt.RT';}
                else nonloss_neutral_rt = [nonloss_neutral_rt raw{i,66}+raw{i,51}];
                end
            end
            
            %if condition is potential win
        elseif strcmp(raw{i,62},'dist_resized/cir2.bmp')  %if cir2
            gain_ant_time = [gain_ant_time (raw{i,44} - adjust)/1000];
            gain_ant_dur = [gain_ant_dur (raw{i,63}-raw{i,44})/1000];
            if raw{i,64} == 1 %if trial is successful, win 5 points: if {'Tgt.RESP';} == 1; col 64
                gain_outcome_time = [gain_outcome_time (raw{i,54} - adjust)/1000];
                gain_outcome_dur = [gain_outcome_dur (raw{i+1,44}-raw{i,54})/1000];
                gain_succ = gain_succ + 1;
                gain_count = gain_count + 1;
                gain_rt = [gain_rt raw{i,65}];  %{'Tgt.RT';} 
            else   %if trial is unsuccessful, or no_gain
                no_gain_time = [no_gain_time (raw{i,54} - adjust)/1000];
                no_gain_dur = [no_gain_dur (raw{i+1,44}-raw{i,54})/1000];
                no_gain_count = no_gain_count + 1;
            end
            
            %if condition is potential loss
        elseif strcmp(raw{i,62},'dist_resized/sqr2.bmp')  %if sqr2
            loss_ant_time = [loss_ant_time (raw{i,44} - adjust)/1000];
            loss_ant_dur = [loss_ant_dur (raw{i,63}-raw{i,44})/1000];
            if raw{i,64} == 1  %if trial is successful, neutral or no_loss outcome
                no_loss_time = [no_loss_time (raw{i,54} - adjust)/1000];
                no_loss_dur = [no_loss_dur (raw{i+1,44}-raw{i,54})/1000];
                no_loss_count = no_loss_count + 1;
                loss_succ = loss_succ + 1;
                loss_rt = [loss_rt raw{i,65}];
            else  %if trial is unsuccessful, lose 5 points
                loss_outcome_time = [loss_outcome_time (raw{i,54} - adjust)/1000];
                loss_outcome_dur = [loss_outcome_dur (raw{i+1,44}-raw{i,54})/1000];
                loss_count = loss_count + 1;
            end
        end
            
            
        end
              
        
    end
    
    %change duration of feedback for each trial on all regressors from NA to
    %1.51
    feedback_dur(find(isnan(feedback_dur))) = 1.51;
    neut_outcome_dur(find(isnan(neut_outcome_dur))) = 1.51;
    gain_outcome_dur(find(isnan(gain_outcome_dur))) = 1.51;
    loss_outcome_dur(find(isnan(loss_outcome_dur))) = 1.51;
    no_gain_neutral_outcome_dur(find(isnan(no_gain_neutral_outcome_dur))) = 1.51;
    no_loss_neutral_outcome_dur(find(isnan(no_loss_neutral_outcome_dur))) = 1.51;
    missed_dur(find(isnan(missed_dur))) = 6.00;
    no_gain_dur(find(isnan(no_gain_dur))) = 1.51;
    no_loss_dur(find(isnan(no_loss_dur))) = 1.51;
    
    
    %weight column: set up vectors of ones for every regressor based on the length (number of trials) of that regressor.
    gain_weight = ones(1,length(gain_ant_time))'; %row of 1s - for weights, ' makes vertical
    loss_weight = ones(1,length(loss_ant_time))';
    neut_weight = ones(1,length(neut_ant_time))';
    antall_weight = ones(1,length(antall_time))'; %should be 72, should be same for target, delay, and feedback
    gain_outcome_weight = ones(1,length(gain_outcome_time))';
    loss_outcome_weight = ones(1,length(loss_outcome_time))';
    no_gain_neutral_outcome_weight = ones(1,length(no_gain_neutral_outcome_time))';
    no_loss_neutral_outcome_weight = ones(1,length(no_loss_neutral_outcome_time))';
    neut_outcome_weight = ones(1,length(neut_outcome_time))';
    nongain_weight = ones(1,length(nongain_ant_time))';
    nonloss_weight = ones(1,length(nonloss_ant_time))';
    missed_weight = ones(1,length(missed_time))';
    no_gain_weight = ones(1,length(no_gain_time))';
    no_loss_weight = ones(1,length(no_loss_time))';
    
    
    %if there are not 72 trials - all_weight is a vector of ones for how
    %many trials there are.
%     if strcmp(subID, '021') || strcmp(subID,'029')
%         all_weight = ones(1,70)';
%     else all_weight = ones(1,72)';
%     end
    
    %create 3-column arrays - concatenate time, dur, and weight vectors
    ant_all = [antall_time' antall_dur' ones(1,length(antall_time))']; %anticipation regressor 4 (collapsed across all conditions)
    feedback = [feedback_time' feedback_dur' ones(1,length(feedback_time))'];  %feedback/outcome regressor 6 (collapsed across all conditions)
    target = [target_time' target_dur' ones(1,length(target_time))']; %target nuissance regressor
    delay = [delay_time' delay_dur' ones(1,length(delay_time))']; %delay2 nuissance regressor (between target and feedback)
    
    ant_potential_gain = [gain_ant_time' gain_ant_dur' gain_weight]; %anticipation of potential gain regressor 1
    ant_potential_loss = [loss_ant_time' loss_ant_dur' loss_weight]; %anticipation of potential loss regressor 2
    ant_neutral = [neut_ant_time' neut_ant_dur' neut_weight];  %anticipation of not winning or losing regressor 3
    ant_nongain = [nongain_ant_time' nongain_ant_dur' nongain_weight];
    ant_nonloss = [nonloss_ant_time' nonloss_ant_dur' nonloss_weight];
    
    
    gain = [gain_outcome_time' gain_outcome_dur' gain_outcome_weight]; %winning feedback regressor 1
    loss = [loss_outcome_time' loss_outcome_dur' loss_outcome_weight]; %losing feedback regressor 2
    nongain_neutral = [no_gain_neutral_outcome_time' no_gain_neutral_outcome_dur' no_gain_neutral_outcome_weight]; %non-gain feedback regressor 4
    nonloss_neutral = [no_loss_neutral_outcome_time' no_loss_neutral_outcome_dur' no_loss_neutral_outcome_weight]; %non-loss feedback regressor 5
    neutral = [neut_outcome_time' neut_outcome_dur' neut_outcome_weight];  %neutral feedback regressor 3 
    no_gain = [no_gain_time' no_gain_dur' no_gain_weight]; %unsuccessful gain - didn't win regressor 7
    no_loss = [no_loss_time' no_loss_dur' no_loss_weight]; %successfully avoided loss - didn't lose regressor 8
   
    missed = [missed_time' missed_dur' missed_weight]; %nuisance regressor for missed trials 
    
    %calculate accuracy
    gain_acc = (gain_succ/antgain_count);
    loss_acc = (loss_succ/antloss_count);
    nongain_neutral_acc = (nongain_neutral_succ/nongain_neutral_count);
    nonloss_neutral_acc = (nonloss_neutral_succ/nonloss_neutral_count);
    total_acc = (gain_succ + loss_succ + nongain_neutral_succ + nonloss_neutral_succ)/(antgain_count + antloss_count + nongain_neutral_count + nonloss_neutral_count);
    missed_percent = missed_count/(antgain_count + antloss_count + antnongain_neutral_count + antnonloss_neutral_count);
    gain_count_regressors = length(gain_outcome_weight);
    loss_count_regressors = length(loss_outcome_weight);
    nongain_neutral_count_regressors = length(no_gain_neutral_outcome_weight);
    nonloss_neutral_count_regressors = length(no_loss_neutral_outcome_weight);
    no_gain_count_regressors = length(no_gain_weight);
    no_loss_count_regressors = length(no_loss_weight);
  
    
    %write out text files into EV folder
    %cd(misseddir)
    cd(model7dir)
    
    dlmwrite([subID '_ant_all.txt'], ant_all, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_outcome_all.txt'], feedback, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_target_all.txt'], target, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_delay_all.txt'], delay, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_ant_gain.txt'], ant_potential_gain, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_ant_loss.txt'], ant_potential_loss, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_ant_neut.txt'], ant_neutral, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_gain.txt'], gain, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_loss.txt'], loss, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_nongain_neutral.txt'], nongain_neutral, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_nonloss_neutral.txt'], nonloss_neutral, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_outcome_neutral.txt'], neutral, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_ant_nongain.txt'], ant_nongain, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_ant_nonloss.txt'], ant_nonloss, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_missed.txt'], missed, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_no_gain.txt'], no_gain, 'delimiter','\t','newline','unix', 'precision', 7);
    dlmwrite([subID '_no_loss.txt'], no_loss, 'delimiter','\t','newline','unix', 'precision', 7);
    
    
    cd(behavdir)
    
    all_rt = [gain_rt loss_rt nongain_neutral_rt nonloss_neutral_rt];
    
    header = {'subID2','rt_gain','rt_loss','rt_nongain_neutral','rt_nonloss_neutral','rt_mean','gain_succ','gain_acc','loss_succ','loss_acc','nongain_neutral_succ','nongain_neutral_acc','nonloss_neutral_succ','nonloss_neutral_acc','total_acc','gain_count','loss_count','no_gain_count','no_loss_count','antnongain_neutral_count','nongain_neutral_count','antnonloss_neutral_count','nonloss_neutral_count','gain_count_regressors','loss_count_regressors','nongain_neutral_count_regressors','nonloss_neutral_count_regressors','no_gain_count_regressors','no_loss_count_regressors','missed_count','missed_percent','min_targettime', 'max_targettime','mean_targettime','Grange'};
    behavdata = [str2num(subID2), mean(gain_rt), mean(loss_rt), mean(nongain_neutral_rt), mean(nonloss_neutral_rt), mean(all_rt), gain_succ, gain_acc, loss_succ, loss_acc, nongain_neutral_succ, nongain_neutral_acc, nonloss_neutral_succ, nonloss_neutral_acc,total_acc, gain_count, loss_count, no_gain_count, no_loss_count,antnongain_neutral_count,nongain_neutral_count, antnonloss_neutral_count, nonloss_neutral_count, gain_count_regressors,loss_count_regressors,nongain_neutral_count_regressors,nonloss_neutral_count_regressors, no_gain_count_regressors,no_loss_count_regressors,missed_count, missed_percent, min(target_dur), max(target_dur), mean(target_dur), raw{6,10}];
    behavdata = dataset({behavdata,header{:}}); %concatenates and converts to dataset format
    
    rt_header = {'gainRT', 'lossRT', 'nongain_neutral_RT', 'nonloss_neutral_RT'};
    rt = NaN * ones(24,4); %creates a 24 X 4 matrix of NaNs
    rt(1:length(gain_rt),1) = gain_rt; %fill matrix with rts for each trial by trial type
    rt(1:length(loss_rt),2) = loss_rt;
    rt(1:length(nongain_neutral_rt),1) = nongain_neutral_rt; %fill matrix with rts for each trial by trial type
    rt(1:length(nonloss_neutral_rt),1) = nonloss_neutral_rt; %fill matrix with rts for each trial by trial type
    %singletrial_rt = dataset({rt,rt_header{:}});
    
    behavior = cell(1,2);
    behavior{1} = behavdata;
    %behavior{2} = singletrial_rt;
    
    output1 = fullfile(behavdir, [subID '_behavior_summary.mat']);
    save(output1, 'behavior')
    
    
    
    end

cd(maindir)
%cd(maindir)


