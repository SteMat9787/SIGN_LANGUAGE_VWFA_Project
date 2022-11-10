tic
%This  is the script for the fMRI sign language experiment (created in the
%first version for a pilot in August 2020 and adapted for a new pilot in
%July 2022).

% It presents the ensamble of videos of signs in an event-related fashion

% The scripts works with one external function (tsvwrite) that convert the csv output to a tsv file (for BIDS analyses)

%What is needed to run the script (inputs):
% 1. a folder named Sign_Stimuli containing all the videos in .mp4 format
% 2. tsvwrite.m function 

%What has to be defined to run the script
% 1. The stimuli path
% 2. The stimuli name
% 3. You can decide if present the videos in their original size or in a
% fixed size chosen by you. To do that you need to set the size to 1
% (original) or to 2(modified). In the latter case you have to specify the
% size in pixels.

%Definition of the stimuli  at the beginning of the script
% There are 3 triplets (9 stimuli in total) of meaningfull stimuli, each triplet  includes:
%1.stim= a main stimulus
%2.stimVC=Visual Controls is a stimulus visually similar to the main one
%3.stimSC=Semantic Control is a stimulus semantically similar to the main
%one
% There are also 9 meaningless stimuli: videos of signs that do not have
% any meaning in the sign language.
%For each stimulus there are 2 version, 1 from an actress and 1 from
%an actor


%Task
% - There are 4 targets (catch trials) that can be both meaningful or meaningless videos. These are
%randomly selected.
% - When the target appears there is always a concomitant change in the
% background color (it becomes red).
% - TASK: when the color of the background changes the subject has to
% decide if the sign is the same or different in comparison to the previous
% sign (there will be half of same and half of different signs). 
%It can be also across actors: i.e. the same sign performed by a
% different actor has to be considered as same sign.
% - COMMENT: The change of color has been added to avoid too many mistakes
% especially in non signers. We thought that they might press more often,
% for instance when they see a visually close sign after a main sign.
% Adding the color shift might balance the level of difficulty between the
% signers and the non signers and might avoid that we have to exclude more
% trials in non-signers because they pressed more often.

%Timing of presentation
%Tot signs presented in EACH RUN = (9 meaningfull * 2 actors) + (9 meaningless * 2
%actors)=18+18= 36 unique videos + 4 targets = 40 STIMULI.
%Each video is 2s long
%ISI is 3s long
%Each trial = (2+3)=5s long.
%Baseline: 10s and the beginning + 10s at the end of each run
%Each RUN is (40 stimuli*5s) + 20s baseline= 220s = 3.666666 min (130
%volumi==4m)


%Which output:
%The script will generate a folder named 'output_files'.
%For each participant there will be 3 output files:
% 1. Results.mat file for each run (e.g. 'StMa_Onsetfile_1.mat' for the subject StMa RUN 1)
% including the Onset, Duration, Name, Resp for Target and Non-Target Stimuli.
% 2. A .csv file for  each in which all the variables aboved are saved.
% 3. a .tsv file for  each in which all the variables aboved are saved (this compatible with BIDS analyses).
% N.B. The .csv  file will be saved also in the case the exp. is stopped
% before the end (e.g. forced to stop, the script crash etc.), while the
% mat file will be stored only if the experiment arrives till the end.

%clear all;
clc;
commandwindow; %move the cursor to the command window so responses will not printed on the script




%% SET THE MAIN VARIABLES
global  GlobalExpID GlobalGroupID GlobalSubjectID GlobalRunNumberID

% GlobalExpID=input('Experiment ID (SignExp): ', 's');
GlobalExpID= 'signVWFA';
GlobalGroupID= input ('Group (HNS-HES-HLS-DES):','s'); %%HNS: Hearing non signers; HES:Hearing early signers; HLS:Hearing late signers; DES:Deaf early signers
GlobalSubjectID=input('Subject ID: ', 's'); %% (first 2 letters of Name-first 2 letters of Surname)
GlobalRunNumberID=input('Run Number(1-10): ', 's');

%% TRIGGER
numTriggers = 1;         % num of excluded volumes (first 2 triggers) [NEEDS TO BE CHECKED]
Cfg.triggerKey = 's';        % the keycode for the trigger

%% SETUP OUTPUT DIRECTORY AND OUTPUT FILE
%if it doesn't exist already, make the output folder
output_directory='output_files';
if ~exist(output_directory, 'dir')
    mkdir(output_directory)
end

output_file_name= strcat(output_directory,'/sub-', GlobalSubjectID, '_ses-',GlobalRunNumberID, '_task-', GlobalExpID, '.csv');
output_file_name_tab= strcat(output_directory,'/sub-', GlobalSubjectID, '_ses-',GlobalRunNumberID, '_task-', GlobalExpID, '.tsv');

logfile=fopen(output_file_name,'a');%'a'== PERMISSION: open or create file for writing; append data to end of file
fprintf(logfile,'\n');

fprintf(logfile,'onset,duration,trial_type,stim_name, time_loop,Target,Same_Target,Response_key,group\n');
     


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINE THE STIMULI NAME, THE PATH & THE SIZE OF THE STIMULI: this is the only section to be changed%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stim path
stim_path=fullfile(cd,'Sign_Stimuli/');

%stim names
stim={'Stim1','Stim2','Stim3'};
stimVC={'Stim1VC','Stim2VC','Stim3VC'};
stimSC={'Stim1SC','Stim2SC','Stim3SC'};
meaningless_stim={'NoStim1','NoStim2','NoStim3',...
    'NoStim4','NoStim5','NoStim6',...
    'NoStim7','NoStim8','NoStim9'};

% %to create the target only among meaningfull stimuli
% meaningful_stim=[stim,stimVC,stimSC];
% tot_meaningful_stim=1:length(meaningful_stim);
% %select 4 target randomy within the meaningful sign
% nT =tot_meaningful_stim(randperm(length(tot_meaningful_stim),4));
% 
% %the first 2 will be F, the second 2 will be male
% nTF=nT(1:2);
% nTM=nT(3:4);
% TargetF= strcat(meaningful_stim(nTF),{'F'});
% TargetM= strcat(meaningful_stim(nTM),{'M'});
% Target=[TargetF,TargetM];

All_stim=[stim,stimVC,stimSC,meaningless_stim];

%% To create the target among all meaningful and meaningless stimuli
tot_all_stim=1:length(All_stim);
%select 4 target randomy within all signs
nT =tot_all_stim(randperm(length(tot_all_stim),4));

%the first 2 will be F, the second 2 will be male
nTF=nT(1:2);
nTM=nT(3:4);
TargetF= strcat(All_stim(nTF),{'F'});
TargetM= strcat(All_stim(nTM),{'M'});
Target=[TargetF,TargetM];

%Set the counter for the target
target_counter=0;
%Define the order of the target that will be same and different compared to
%the previous stimulus (with 4 targets there will be 2 same and 2
%different)
Same_Diff_Tar=Shuffle([1,1,2,2]); %1 means Same; 2 means Different

%% To create the female and male name of all sounds
All_stimF=(strcat(All_stim, {'F'}));
All_stimM=(strcat(All_stim, {'M'}));
All_stim_FM=[All_stimF,All_stimM];
All_stim_shuffle=Shuffle(All_stim_FM);

%STIM SIZE

%For the original size open this part
% %Set the size to 1 to present the video in their original size
size=1;

%For the modified size open this part
%Set the size to 2 to present the video in a different size and select the
% %size (in pixels) (to keep the ratio: 400-225/450-253/500-281

% size=2;
% Width_modified= 700; %width video 1 in pixels
% Height_modified=394; %height video 1 in pixels


%Set the times
StimLength=2;
timeout=3;
%Baseline times (in sec)
Baseline_start=10;
Baseline_end=10;

% FIX CROSS
crossLength=50;
crossColor=[200 200 200];
crossColorEnd=[150 150 150]; 
crossWidth=7;
%Set start and end point of lines
crossLines=[-crossLength, 0; crossLength, 0; 0, -crossLength; 0, crossLength];
crossLines=crossLines';


TAR=0; %%i will use it to print target/non target stimuli
Same_target=0;

% Open the screen
Screen('Preference', 'SkipSyncTests', 1);
[wPtr, rect]= Screen('OpenWindow',max(Screen('Screens'))); %open the screen
Screen('FillRect',wPtr,[0 0 0]); %draw a rectangle (big as all the monitor) on the back buffer
Screen ('Flip',wPtr); %flip the buffer, showing the rectangle
HideCursor(wPtr);

% STIMULUS RECTANGLE (in the center)
screenWidth = rect(3);
screenHeight = rect(4);%-(rect(4)/3); %this part is to have it on the top of te screen
screenCenterX = screenWidth/2;
screenCenterY = screenHeight/2;
%stimulusRect=[screenCenterX-stimSize/2 screenCenterY-stimSize/2 screenCenterX+stimSize/2 screenCenterY+stimSize/2];

%save the response keys into a cell array
Resp = num2cell(zeros(1,length(All_stim_shuffle)));
Onset = zeros(1,length(All_stim_shuffle));
Name=num2cell(zeros(1,length(All_stim_shuffle)));
Duration=zeros(1,length(All_stim_shuffle));

Resp_target = num2cell(zeros(1,length(All_stim_shuffle)));
Onset_target = zeros(1,length(All_stim_shuffle));
Name_target=num2cell(zeros(1,length(All_stim_shuffle)));
Duration_target=zeros(1,length(All_stim_shuffle));
%% OPEN THE SCREEN
try %the 'try and chatch me' part is added to close the screen in case of an error so that you can see the command window and not get stucked with the blank screen)
    
    
    %% TRIGGER
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('TextSize', wPtr, 50);%text size
    DrawFormattedText(wPtr, '\n READY TO START', 'center','center',[255 255 255]);
    Screen('Flip', wPtr);
    
    disp ('Wait for trigger...');
    
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
    
    %Draw THE FIX CROSS
    Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[screenCenterX,screenCenterY]);
    % Flip the screen
    Screen('Flip', wPtr);
    
    disp 'Trigger ok: experiment starting!'; %print this on command window
    
    %%Message to print on command window
    if str2num(GlobalRunNumberID)==1
        disp 'Coucou Alice. You just started the first run: COURAGE!';
    elseif str2num(GlobalRunNumberID)==6
        disp 'You are doing great Alice: at the end of this run you are halfway.';
    elseif str2num(GlobalRunNumberID)==10
        disp '10 runs already: BRAVO Alice! Almost done!';
    elseif str2num(GlobalRunNumberID)==12
        disp 'Super, Alice! This might be the last run....unless you are still plenty of time, in that case GO ON';
    end
    
    LoopStart=GetSecs();
    WaitSecs(Baseline_start);
    %% Start the loop for each video
    stim2disp=(0:9:length(All_stim_shuffle));
    for iStim=1:length(All_stim_shuffle)
        
        Screen('FillRect',wPtr,[0 0 0]); %draw a rectangle (big as all the monitor) on the back buffer
        Screen ('Flip',wPtr); %flip the buffer, showing the rectangle
        
        %Find the stim name
        Stim_name=All_stim_shuffle{iStim};
        %Set the movie and filename
        pathToMovie=strcat(stim_path,All_stim_shuffle{iStim},'.mp4');
        
        %Set clip info
        toTime=inf; %second to stop in movie
        soundvolume=0; %0 to 1
        
        %disp on command window
        if ismember(iStim,stim2disp)
            disp (strcat('Presenting stimulus',num2str(iStim)));
        end
        
        responseKey = [];
        
        %show the movie one time
        for i=1
%             Start_time=GetSecs();
            
            %Open the movie
            [movie,dur,fps,width,height]=Screen('OpenMovie',wPtr,pathToMovie);
            
            %Define the size of the videos according to what has been
            %defined at the beginning of the scipt
            
            if size==1 %original size
                stimulusRect=[screenCenterX-width/2 screenCenterY-height/2 screenCenterX+width/2 screenCenterY+height/2];
            elseif size==2 %modified size
                stimulusRect=[screenCenterX-Width_modified/2 screenCenterY-Height_modified/2 screenCenterX+Width_modified/2 screenCenterY+Height_modified/2];
            end
            

            %Play the movie
           Screen('PlayMovie', movie,1,0,soundvolume);
            %Mark starting time
%             t=GetSecs();
            Start_time=GetSecs();
            %loop through each frame of the movie and present it
            
            while Start_time<toTime
                
                % register the keypress
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if keyIsDown && min(~strcmp(KbName(keyCode),Cfg.triggerKey))
                    responseKey = KbName(find(keyCode));
                end
                
                %get the texture
                tex=Screen('GetMovieImage',wPtr,movie);
                
                
                %if there is no texture we are at the end of the movie
                if tex<=0
                    break;
                end
                
                
                %draw the texture (in this part you can set the position
                %of the video on the screen)
                Screen('DrawTexture',wPtr,tex,[],stimulusRect);
                
                %Screen('Flip', wPtr); %display the info visually
%                 t=Screen('Flip',wPtr);
                Screen('Flip',wPtr);
                %discard this texture
                Screen('Close',tex);
                
            end
            %if the 2 sec did not pass stay on the last fotogramma
            while (GetSecs-Start_time)<=(StimLength)
               
                %do nothing
            end
            %Stop the movie
            Screen('PlayMovie',movie,0);
            
            
            %Close the movie
            Screen('CloseMovie',movie);
        end
        Video_end_time=GetSecs();
        Duration(iStim)= Video_end_time-Start_time; %%
        %%%FIX CROSS
        
        Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[screenCenterX,screenCenterY]);
        % Flip the screen
        cross_time= Screen('Flip', wPtr);
        
%         while (GetSecs-(cross_time))<=(timeout)
            
         while (GetSecs-(cross_time))<=(5-Duration(iStim)) %%
            [keyIsDown, secs, keyCode] = KbCheck(-1);
            if keyIsDown && min(~strcmp(KbName(keyCode),Cfg.triggerKey))
                responseKey = KbName(find(keyCode));
            end
        end
        End_time=GetSecs();
        TAR=0; %reset the target =0 (no target)
        Same_target=0;
        Name(iStim) = All_stim_shuffle(iStim);
        Resp(iStim) = {responseKey};
        Onset(iStim)=  Start_time-LoopStart;
        
        if Name{1,iStim}(1)=='N'
            trial_type='no_sign';
        else
            trial_type='sign';
        end
        
        if Resp{iStim}
            %do nothing
        else
            Resp{iStim}='n/a';
        end
        %         Duration(iStim)= Video_end_time-Start_time;
        %print the variable in the .csv file
        %fprintf(logfile,'%s,%s,%d,%d,%s,%d,%d,%d,%d,%d,%s\n', GlobalGroupID,GlobalSubjectID,str2double(GlobalRunNumberID),iStim,All_stim_shuffle{iStim},Duration(iStim),Onset(iStim),End_time-Start_time,TAR,Same_target,Resp{iStim});
      fprintf(logfile,'%d,%d,%s,%s,%d,%d,%d,%s,%s\n', Onset(iStim),Duration(iStim),trial_type,All_stim_shuffle{iStim},End_time-Start_time,TAR,Same_target,Resp{iStim},GlobalGroupID); 
       
        %% if this is a target repeat the same stimulus but with the opposite gender
        if find(ismember(Target, Stim_name))
            TAR=1; %this is a target (we'll print this in the .csv and .mat output)
            target_counter=target_counter+1; %this is to keep the count of the targets
            
            
            %%%%%%%%change the screen color %%%%%%%%%%%%%%
            Screen('FillRect',wPtr,[140 40 60]); %draw a rectangle (big as all the monitor) on the back buffer
            Screen ('Flip',wPtr); %flip the buffer, showing the rectangle
            
%             % decide it will be the same sign or not randomly
%             possibility=[1 2]; %it will randomly pick one of the 2 possibilities
%             SameT = possibility(randperm(length(possibility),1));
  
            % decide it will be the same sign or not (2 same and 2
            % different)
            SameT = Same_Diff_Tar(target_counter);


            if SameT==1 %same stimulus
                Same_target=1;
                %select randomly the gender for the target
                gender=[1,2];
                pick_gender= gender(randperm(length(gender),1));
                if pick_gender==1
                    Stim_name_target=strcat(Stim_name(1:end-1),'F');
                elseif pick_gender==2
                    Stim_name_target=strcat(Stim_name(1:end-1),'M');
                end
            elseif SameT==2 %different stimulus
                Same_target=2;
                %select 4 targets randomy within the meaningful sign
                DiffT =tot_all_stim(randperm(length(tot_all_stim),1));
                while DiffT==iStim
                    DiffT =tot_all_stim(randperm(length(tot_all_stim),1));
                end
                
                Stim_name_different=All_stim_shuffle{DiffT}; %We select this stimulus from the list of the names
                %select randomly the gender for the target
                gender=[1,2];
                pick_gender= gender(randperm(length(gender),1));
                if pick_gender==1
                    Stim_name_target=strcat(Stim_name_different(1:end-1),'F');
                elseif pick_gender==2
                    Stim_name_target=strcat(Stim_name_different(1:end-1),'M');
                end
            end
            %Set the movie and filename
            pathToMovie=strcat(stim_path,Stim_name_target,'.mp4');
            
            %Set clip info
            toTime=inf; %second to stop in movie
            soundvolume=0; %0 to 1
            
            %disp in the command window
            disp 'This is a TARGET!'
            
            %stop the loop only when participant presses one of these keys
            
            responseKey = [];
            
            %show the movie one time
            for i=1
%                 Start_time=GetSecs();
                %Open the movie
                [movie,dur,fps,width,height]=Screen('OpenMovie',wPtr,pathToMovie);
                
                
                %Define the size of the videos according to what has been
                %defined at the beginning of the scipt
                
                if size==1 %original size
                    stimulusRect=[screenCenterX-width/2 screenCenterY-height/2 screenCenterX+width/2 screenCenterY+height/2];
                elseif size==2 %modified size
                    stimulusRect=[screenCenterX-Width_modified/2 screenCenterY-Height_modified/2 screenCenterX+Width_modified/2 screenCenterY+Height_modified/2];
                end
                
                %Play the movie
                Screen('PlayMovie', movie,1,0,soundvolume);
                %Mark starting time
                Start_time=GetSecs();
                
                %loop through each frame of the movie and present it
                
                while Start_time<toTime
                    
                    % register the keypress
                    [keyIsDown, secs, keyCode] = KbCheck(-1);
                    if keyIsDown && min(~strcmp(KbName(keyCode),Cfg.triggerKey))
                        responseKey = KbName(find(keyCode));
                    end
                    
                    %get the texture
                    tex=Screen('GetMovieImage',wPtr,movie);
                    
                    
                    %if there is no texture in one of the 2 videos, we are at the end of the movie
                    if tex<=0
                        break;
                    end
                    
                    
                    %draw the texture
                    Screen('DrawTexture',wPtr,tex,[],stimulusRect);
                    
                    %Screen('Flip', wPtr); %display the info visually
                    Screen('Flip',wPtr);
                    
                    %discard this texture
                    Screen('Close',tex);
                    
                end
                %if the 2 sec did not pass say on the last fotogramma
                while (GetSecs-Start_time)<=(StimLength)
                    %do nothing
                end
                %Stop the movie
                Screen('PlayMovie',movie,0);
                
                
                %Close the movie
                Screen('CloseMovie',movie);
            end
            Video_end_time=GetSecs();
            Duration_target(iStim)= Video_end_time-Start_time;%
            %%%FIX CROSS
            %change the screen color back to the original color
            Screen('FillRect',wPtr,[0 0 0]); %draw a rectangle (big as all the monitor) on the back buffer
            Screen ('Flip',wPtr); %flip the buffer, showing the rectangle
            
            Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[screenCenterX,screenCenterY]);
            % Flip the screen
            cross_time= Screen('Flip', wPtr);
            
            %while (GetSecs-(cross_time))<=(timeout)
            while (GetSecs-(cross_time))<=(5-Duration_target(iStim))    
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if keyIsDown && min(~strcmp(KbName(keyCode),Cfg.triggerKey))
                    responseKey = KbName(find(keyCode));
                end
            end
            End_time=GetSecs();
            
            Name_target(iStim) = {Stim_name_target};
            Resp_target(iStim) = {responseKey};
            Onset_target(iStim)=  Start_time-LoopStart;
            
            trial_type='target';
            
            %%add n/a in the resp col when there is no response
            if Resp_target{iStim}
                %do nothing
            else
                Resp_target{iStim}='n/a';
            end
        %    
%             Duration_target(iStim)= Video_end_time-Start_time;
            %print the variable in the .csv file
           fprintf(logfile,'%d,%d,%s,%s,%d,%d,%d,%s,%s\n', Onset_target(iStim),Duration_target(iStim),trial_type,Stim_name_target,End_time-Start_time,TAR,Same_target,Resp_target{iStim},GlobalGroupID);     

        end % if target
    end%for iStim
    
    WaitSecs(Baseline_end);
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
   
    cd('output_files')
    save(strcat (GlobalSubjectID,'_Onsetfile_',GlobalRunNumberID,'.mat'),'Onset','Name','Duration','Resp','Onset_target','Name_target','Duration_target','Resp_target');

    
catch ME %the 'try and chatch me' part is added to close the screen in case of an error so that you can see the command window and not get stucked with the blank screen)
    Screen('CloseAll');
    rethrow(ME);
end %try


%Clear the screen
clear Screen;
sca;

toc

