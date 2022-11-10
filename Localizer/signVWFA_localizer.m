tic
%%%%%VWFA EXPERIMENT: localizer %%%%%%%
% Categories of stimuli = 4 (words, bodies, hands and faces); 12 exemplars per category.
% Tot num stimuli = 48;
% There are 16 blocks in a run.

%%BLOCK DESCRIPTION
% In each block all the 12 stimuli from a category are presented in random
% order. 500 msec for each image + 500 msec ISI (=central fixation cross).
% In each block there are either 0, 1 or 2 (this is randomly decided) target
% stimuli: a target is the repetition of the previous stimulus. The
% participant has to press when he/she sees a target.
% Each block has a duration of 12, 13 or 14 s (depending if 0, 1 or 2 targets).

%PAUSES
%At the start of the experiment there is a pause of 13s, in which the participant has to fixate
%the fixation cross in the middle of the screen. There is also an 8s pause
%every 4 blocks (the repetition of the 4 categories) and at the end of the
% experiment. In betweenthe others block there is 1s IBI.

%TASK
% N-back task: participants has to presss when they see a stimulus identical
% to the previous one. There can be either 0, 1 or 2 target(s) in each block.

%TIME CALCULATION for each RUN
% 4 categories with 12 stimulus each one;
% trial duration= 500msec stimulus + 500 msec ISI =1s;
% block duration = 1 category in each block + 0/1/2 targets = 12s/13s/14s
% 16 blocks per run: minimum 192s / maximum 224s (according to 0, 1 or 2
% targets)
% 1 pauses of 13s at the beginning of each run
% 4 pauses of 8s in each run (after block  4,8,12 amd 16) = 32s
% a 1s pause between blocks (except for block 4, 8 and 12) = 12s
% MINIMUM DURATION = 249s (4.15 min) / MAXIMUM DURATION = 281s (4.68 min)

%TWO VARIANT OF THE LOCALIZER (to chose in the Global variable setting)
%1. Line drawing stimuli
%2. 3D Volumetric stimuli
%IMPORTANT: After a first pilot we fixed the Global variable setting to 3D Volumetric
%stimuli

%ACTION and VARIABLE SETTING
%The only variable you need to manually change is Cfg.device at the
%beginning of the script. Put either 'PC' or 'Scanner'.
%Once you will Run the script you will be asked to select some variables:
%1. Group (HNS-HES-HLS-DES): %%HNS: Hearing non signers; HES:Hearing early
%signers; HLS:Hearing late signers; DES:Deaf early signers.
%2. SubID : a number with 3 digit (e.g. 001).
%3. Run Number (2 digit: e.g. 01).


clear all;
clc;
Screen('Preference', 'SkipSyncTests', 1);

%% Device
Cfg.device = 'PC'; %(Change manually: 'PC' or 'Scanner')

fprintf('Connected Device is %s \n\n',Cfg.device);


%% SET THE MAIN VARIABLES
global GlobalExpID GlobalGroupID GlobalSubjectID GlobalRunNumberID GlobalStimuliID

GlobalExpID= 'loc';
GlobalGroupID= input ('Group (HNS-HES-HLS-DES):','s'); %%HNS: Hearing non signers; HES:Hearing early signers; HLS:Hearing late signers; DES:Deaf early signers
GlobalSubjectID=input('Subject ID: e.g. 01', 's'); 
GlobalRunNumberID=input('Run Number(01-02): ', 's');
GlobalStimuliID= '3D'; %input('Stimuli style (line - 3D):','s'); % specify if you use line drawing or 3D volumetric stimuli

% if strcmp(GlobalStimuliID,'line')
% fprintf('Localizer Experiment: line drawing stimuli \n\n');
% elseif strcmp(GlobalStimuliID,'3D')
% fprintf('Localizer Experiment: 3D volumetric stimuli \n\n');
% else
% %if the input is empty take automatically line drawing
% GlobalStimuliID='3D';
% fprintf('Localizer Experiment: line drawing stimuli \n\n');
% end

%% TRIGGER
numTriggers = 1;         % num of excluded volumes (first 2 triggers) [NEEDS TO BE CHECKED]
Cfg.triggerKey = 's';        % the keycode for the trigger

%% SETUP OUTPUT DIRECTORY AND OUTPUT FILE

%if it doesn't exist already, make the output folder
output_directory='output_files';
if ~exist(output_directory, 'dir')
    mkdir(output_directory)
end
output_file_name= strcat(output_directory,'/sub-', GlobalGroupID, GlobalSubjectID, '_task-', GlobalExpID,'_run-',GlobalRunNumberID,'_events',  '.csv');
output_file_name_tab= strcat(output_directory,'/sub-',GlobalGroupID, GlobalSubjectID,'_task-', GlobalExpID,  '_run-',GlobalRunNumberID,'_events', '.tsv'); %will be usedd for tsv converted output file

logfile=fopen(output_file_name,'a');%'a'== PERMISSION: open or create file for writing; append data to end of file
fprintf(logfile,'\n');
%new
fprintf(logfile,'onset,duration,trial_type,stim_name,Block_num, trial_num, time_loop,Target,Response_key,group\n');



%% SET THE STIMULI/CATEGORY
CAT_W={'W1','W2','W3','W4','W5','W6','W7','W8','W9','W10','W11','W12'}; %words
CAT_F={'F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12'}; %faces
CAT_B={'B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12'}; %bodies
CAT_H={'H1','H2','H3','H4','H5','H6','H7','H8','H9','H10','H11','H12'}; %hands
%Set the block order
All_cat={'W','F','B','H'};
All_cat_rep=[Shuffle(All_cat),Shuffle(All_cat),Shuffle(All_cat),Shuffle(All_cat)];
N_block=[1:length(All_cat_rep)];

Block_order=All_cat_rep;


fmri_run = str2num(GlobalRunNumberID);

TAR=0; %%i will use it to print target/non target stimuli

%OPEN THE SCREEN
[wPtr, rect]= Screen(('OpenWindow'),max(Screen('Screens'))); %open the screen
Screen('FillRect',wPtr,[0 0 0]); %draw a black rectangle (big as all the monitor) on the back buffer
Screen ('Flip',wPtr); %flip the buffer, showing the rectangle
%HideCursor(wPtr);

% STIMULI SETTING
stimSize=400;
stimTime=0.85;
timeout=0.15; %Inter Stimulus Interval
trial_duration=1;
cross_time=0;

% STIMULUS RECTANGLE (in the center)
screenWidth = rect(3);
screenHeight = rect(4);%-(rect(4)/3); %this part is to have it on the top of te screen
screenCenterX = screenWidth/2;
screenCenterY = screenHeight/2;
stimulusRect=[screenCenterX-stimSize/2 screenCenterY-stimSize/2 screenCenterX+stimSize/2 screenCenterY+stimSize/2];

% STIMULI FOLDER
stimFolder = 'Stimuli_3D';

t='.jpeg';


% FIX CROSS
crossLength=50;
crossColor=[200 200 200];
crossWidth=7;
%Set start and end point of lines
crossLines=[-crossLength, 0; crossLength, 0; 0, -crossLength; 0, crossLength];
crossLines=crossLines';


%save the response keys into a cell array
Resp = num2cell(zeros(length(Block_order),length(CAT_W))); %%%need to change the number of stimuli if it changes (now it is 12 in each condition with 2 repetition one with and one without motion)
Onset = zeros(length(Block_order),(length(CAT_W)));
Name=num2cell(zeros(length(Block_order),(length(CAT_W))));
Duration=zeros(length(Block_order),(length(CAT_W)));

responseKey = [];
try  % safety loop: close the screen if code crashes
    %% TRIGGER
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('TextSize', wPtr, 50);%text size
    DrawFormattedText(wPtr, '\n READY TO START', 'center','center',[255 255 255]);
    Screen('Flip', wPtr);
    
    disp('Wait for trigger...');
    
    %%%
    triggerCounter=0;
    while triggerCounter < numTriggers
        
        [keyIsDown, ~, keyCode, ~] = KbCheck(-1);
        
        if strcmp(KbName(keyCode),Cfg.triggerKey)
            triggerCounter = triggerCounter+1;
            
            DrawFormattedText(wPtr,[num2str(numTriggers-triggerCounter)],... %%countdown for the trigger
                'center', 'center',[255 255 255] );
            Screen('Flip', wPtr);
            
            while keyIsDown
                [keyIsDown, ~, keyCode, ~] = KbCheck(-1);
            end
            
        end
    end
    
    disp('Triggeer ok: experiment starting!');
    
    %Draw THE FIX CROSS
    Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[screenCenterX,screenCenterY]);
    % Flip the screen
    Screen('Flip', wPtr);
    
    
    LoopStart = GetSecs();
    trial_start = LoopStart;
    
    WaitSecs(13); %wait 13 sec at the beginning of the run
    
    for b=1:length(Block_order)
        block_start=GetSecs();
        %Select the stimuli for this block
        if strcmp(Block_order{b}(1),'W')
            Stimuli=Shuffle(CAT_W);
        elseif strcmp(Block_order{b}(1),'F')
            Stimuli=Shuffle(CAT_F);
        elseif strcmp(Block_order{b}(1),'B')
            Stimuli=Shuffle(CAT_B);
        elseif strcmp(Block_order{b}(1),'H')
            Stimuli=Shuffle(CAT_H);
        end
        
        Stimuli=strcat(Stimuli,t);
        %Set the target for this block
        num_targets=[0 1 2]; %it will randomly pick one of the 3 possibilities: either 2 or 3 targets
        nT = num_targets(randperm(length(num_targets),1));
        nStim=length(CAT_W); %this is the number of stimuli of each category
        [~,idx]=sort(rand(1,nStim)); %sort randomly the stimuli in the block
        posT=sort((idx(1:nT))); %select the position of the target(s)
        
        disp (strcat('Block',num2str(b),'_STARTING'));
        for n = 1:length(Stimuli)%% num of stimuli in each block
            Start=GetSecs();
            keyIsDown=0;
            
            % LOAD AN IMAGE
            file{n} = Stimuli{n};
            [img] = imread(fullfile(stimFolder,file{n}));
            
            %DRAW THE STIMULUS
            imageDisplay = Screen('MakeTexture',wPtr, img);
            
            
            
            
            Screen('DrawTexture', wPtr, imageDisplay, [], stimulusRect);
            % FLIP SCREEN TO SHOW THE STIMULUS(after the cue has been on screen for the ISI)
            time_stim=Screen('Flip', wPtr);
            
            while (GetSecs-time_stim)<=(stimTime)
                
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if keyIsDown && min(~strcmp(KbName(keyCode),Cfg.triggerKey))
                    responseKey = KbName(find(keyCode));
                end
            end
            
            
            %Draw THE FIX CROSS
            %                 Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[screenCenterX,screenCenterY]);
            %                 % Flip the screen
            cross_time= Screen('Flip', wPtr,time_stim+stimTime);
            %                  responseKey = [];
            while (GetSecs-(cross_time))<=(timeout)
                % register the keypress
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if keyIsDown && min(~strcmp(KbName(keyCode),Cfg.triggerKey))
                    responseKey = KbName(find(keyCode));
                end
            end
            
            
            loop_end=GetSecs();
            
            trial_type=Stimuli{n}(1);
            
            %%add n/a in the repo col when there is no response
            if responseKey
                %do nothing
            else
                responseKey='n/a';
            end
            
            fprintf (logfile, '%d,%d,%s,%s,%d,%d,%d,%d,%s,%s \n' ,time_stim-LoopStart,stimTime,trial_type,Stimuli{n},b,n,(cross_time+timeout)-Start,TAR,responseKey,GlobalGroupID);
            
            
            while GetSecs()-trial_start<trial_duration
                % do nothing
            end
            
            trial_start=trial_start+trial_duration;
            TAR=0;%reset the Target hunter as 0 (==no target stimulus);
            
            Name(b,n)=Stimuli(n);
            Resp(b,n) = {responseKey};
            Onset(b,n)= time_stim-LoopStart;
            Duration(b,n)= stimTime;
            
            %% if this is a target repeat the same stimulus
            
            if sum(n==posT)==1
                TAR=1;
                %DRAW THE STIMULUS
                imageDisplay = Screen('MakeTexture',wPtr, img);
                
                
                Screen('DrawTexture', wPtr, imageDisplay, [], stimulusRect);
                % FLIP SCREEN TO SHOW THE STIMULUS(after the cue has been on screen for the ISI)
                time_stim=Screen('Flip', wPtr);
                while (GetSecs-time_stim)<=(stimTime)
                    
                    [keyIsDown, secs, keyCode] = KbCheck(-1);
                    if keyIsDown && min(~strcmp(KbName(keyCode),Cfg.triggerKey))
                        responseKey = KbName(find(keyCode));
                    end
                end
                %responseKey = [];
                %Draw THE FIX CROSS
                %                     Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[screenCenterX,screenCenterY]);
                %                     % Flip the screen
                cross_time= Screen('Flip', wPtr,time_stim+stimTime);
                
                while (GetSecs-(cross_time))<=(timeout)
                    
                    [keyIsDown, secs, keyCode] = KbCheck(-1);
                    if keyIsDown && min(~strcmp(KbName(keyCode),Cfg.triggerKey))
                        responseKey = KbName(find(keyCode));
                    end
                    
                end
                
                
                
                loop_end=GetSecs();
                
                
                
                trial_type='target';
                
                %%add n/a in the repo col when there is no response
                if responseKey
                    %do nothing
                else
                    responseKey='n/a';
                end
                
                fprintf (logfile, '%d,%d,%s,%s,%d,%d,%d,%d,%s,%s \n' ,time_stim-LoopStart,stimTime,trial_type,Stimuli{n},b,n,(cross_time+timeout)-Start,TAR,responseKey,GlobalGroupID);
                
                while GetSecs()-trial_start<trial_duration
                    % do nothing
                end
                
                trial_start=trial_start+trial_duration;
                TAR=0;%reset the Target hunter as 0 (==no target stimulus);
                
                Name_target(b,n)=Stimuli(n);
                Resp_target(b,n) = {responseKey};
                Onset_target(b,n)= time_stim-LoopStart;
                Duration_target(b,n)= stimTime;
                
                responseKey = [];
            end %if this is a target
            responseKey = [];
        end % for n stimuli
        block_end=GetSecs();
        block_duration=block_end-block_start;
        disp (strcat('Block duration:',num2str(block_duration)));
        
        %Draw THE FIX CROSS
        Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[screenCenterX,screenCenterY]);
        % Flip the screen
        cross_time= Screen('Flip', wPtr);
        
        if rem(b,length(All_cat))==0
            WaitSecs(8);%if we are in the block 4-8-12-16 wait 8 sec before to finish the block
        else
            WaitSecs(1);
        end
    end%for b(lock)
    
    LoopEnd=GetSecs();
    
    disp (strcat( 'The time for the run took min:', num2str ((LoopEnd-LoopStart)/60)));
    %%%%%This part it is added to if the script end before the data
    %%%%%acquisitions the subject  will se the fix cross and not the matlab
    %%%%%screen.
    %wait for any key pressed to close the screen
    disp 'Press SPACE to quit';
    
    ActiveKey= [KbName('space')];%select the key you want to stay active for kbwait
    RestrictKeysForKbCheck(ActiveKey); % make it active
    KbWait(-1); %will only work with  space
    
    %create a .tsv file with tab delimiter (better for BIDS analyses)
    table= readtable(output_file_name);
    
    tsvwrite(output_file_name_tab,table)
    %save the variables in the .mat files
    
catch
    clear Screen;
    %% Close serial port of the scanner IF CRASH OF THE CODE
    if strcmp(Cfg.device,'Scanner')
        CloseSerialPort(SerPor);
    end
    error(lasterror)
end
% WaitSecs(1)%wait 1 sec before to finish

% clear the screen
Screen(wPtr,'Close');
sca;

cd('output_files')
save(strcat (GlobalSubjectID,'_',GlobalStimuliID,'_Onsetfile_',GlobalRunNumberID,'.mat'),'Onset','Name','Duration','Resp','Onset_target','Name_target','Duration_target','Resp_target');

toc
