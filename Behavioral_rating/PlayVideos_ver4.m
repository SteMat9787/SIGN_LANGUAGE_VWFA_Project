%In this script I define all the video stimuli I want to include in the
%experiment, I present them in all the possible pair combinations, I ask
%the participant to judge how similar (visually or semantically) are the 2
%videos from 1 to 7 and I collect the responses. In this experiment for each
%pair of video clips I ask the participant first to do the VISUAL rating and then to do the
%SEMANTIC rating. The order of the 2 tasks is fixed.

%What is needed to run the script (inputs):
% 1. the function 'Create_pairs' (that create all the possible combinations
% of videos to be presented and put them in a random order).
% 2. a folder containing all the videos in .mp4 format

%What has to be defined to run the script
% 1. The stimuli path
% 2. The stimuli name
% 3. You can decide if present the videos in their original size or in a
% fixed size chosen by you. To do that you need to set the size to 1
% (original) or to 2(modified). In the latter case you have to specify the
% size in pixels for both videos.

%Which are the output
%The script will generate a folder named 'output_files', inside it another
%folder will be generated for each subject (using the Subject ID selected
%at the beginning, e.g. 'output_StMa'). For each participant there will be
%2 output files:
% 1. Results.mat file   including the pairs names in the order they have
% been presented, the rating responses for the 2 tasks (respVis and
% respSem) and the reaction time for each response (RTvis and RTsem).
% 2. A .csv file in which all the variables aboved are saved.
% N.B. The .csv file will be saved also in the case the exp. is stopped
% before the end (e.g. forced to stop, the script crash etc.), while the
% mat file will be stored only if the experiment arrives till the end.

%Important info:
% **** What's different from ver3:  For each pair of video clip I present
% before the stimulus on the left alone (1 time), then the stimulus on the 
% right alone (1 time). Then the 2 together with the word VISUAL or MEANING
% on the bottom part.
% 1. If you want to force the script to stop, for any reason, press the key
% 'z'. This will automatically and immediately stop the script and close
% the screen. The data collected till this moment will be stored in the .csv
% file (but the .mat file will not be saved).
% 2. The script only accept responses from 1 to 7. If the participant press
% any other key, this will not be registered and the same 2 videos will keep
% going. Only when the participant press a number from 1 to 7 the videos
% will stop and the next pair of videos will be pesented.
% 3. If the subject press 2 numbers or more in a row only the first number will be recorded.
% 4. ***BE CAREFUL*** If the 2 videos have a different length, the script will take the
% shortest one. This means that the longest video will be cut.
% 5. There are three (fixed) pauses after 1/4, the half and 3/4 of the
% experiment. Subject can take a break and press a key to start again.


clear all;
clc;
commandwindow; %move the cursor to the command window so responses will not printed on the script

tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINE THE STIMULI NAME, THE PATH & THE SIZE OF THE STIMULI: this is the only section to be changed%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stim path
stim_path= strcat(cd,'/Sign_Stimuli/'); %take the same stimuli used in the fMRI exp.
%stim_path=fullfile(cd,'Sign_Stimuli/');

%stim names
%stim names
stim={'Stim1','Stim2','Stim3'};
stimVC={'Stim1VC','Stim2VC','Stim3VC'};
stimSC={'Stim1SC','Stim2SC','Stim3SC'};
All_stim_noGender=[stim,stimVC,stimSC];
All_stimF=(strcat(All_stim_noGender, {'F'}));
All_stimM=(strcat(All_stim_noGender, {'M'}));
All_stim=[All_stimF,All_stimM];

%This is to do that only with female stimuli
% stim={'Stim1F','Stim2F','Stim3F','StimF'};
% stimVC={'Stim1VCF','Stim2VCF','Stim3VCF','Stim4VCF'};
% stimSC={'Stim1SCF','Stim2SCF','Stim3SCF','Stim4SCF'};
% All_stim=[stim,stimVC,stimSC];

%stim size

%For the original size open this part
% %Set the size to 1 to present the video in their original size
% size=1;

%For the modified size open this part
%Set the size to 2 to present the video in a different size and select the
%size (in pixels)
size=2;
Width1_modified= 650; %width video 1 in pixels
Height1_modified=366; %height video 1 in pixels
Width2_modified=650; %width video 2 in pixels
Height2_modified=366; %height video 2 in pixels


%% Don't change anything form here on
%% SET THE MAIN VARIABLES
global  ExperimentID SubjectID

ExperimentID='Stim_rating';
SubjectID=input('Subject ID (write first 2 letters of your Name and first 2 letters of your surname): ', 's');

%% SETUP OUTPUT DIRECTORY AND OUTPUT FILE

output_directory='output_files';
%create a subfolder for each Partecipant
output_subject_directory= strcat('output_',SubjectID);
mkdir(output_directory,output_subject_directory);
output_file_name=[output_directory '/' output_subject_directory '/output_file_matrix_pilot' ExperimentID  '_SubID' SubjectID  '.csv'];
fid=fopen(output_file_name,'a');%Global
fprintf(fid,'\n');
fprintf(fid,'subjectID,experimentID, Task,N_trial,Video_1,Video_2, Rating, RT,\n');

%% OPEN THE SCREEN
try %the 'try and chatch me' part is added to close the screen in case of an error so that you can see the command window and not get stucked with the blank screen)
    %clear screen
    Screen('Preference', 'SkipSyncTests', 1);
    [wPtr, rect]= Screen('OpenWindow',max(Screen('Screens'))); %open the screen
    
    Screen('FillRect',wPtr,[125 125 125]); %draw a rectangle (big as all the monitor) on the back buffer
    Screen ('Flip',wPtr); %flip the buffer, showing the rectangle
    HideCursor(wPtr);
    
    %% DISPLAY INSTRUCTION
    Screen('TextSize', wPtr, 40);
    DrawFormattedText(wPtr, '\n  WELCOME & THANKS FOR PARTICIPATING IN THIS EXPERIMENT (press ANY KEY to continue)', 'center','center',[255 255 255],60,[],[],3);
    Screen('Flip', wPtr);
    KbWait( -1, 2 ); %wait for key press
    
    
    DrawFormattedText(wPtr, '\n  IN THIS EXPERIMENT YOU WILL SEE 2 VIDEOS AT TIME, ONE ON THE LEFT SIDE AND ONE ON THE RIGHT SIDE OF THE SCREEN (press ANY KEY to continue)', 'center','center',[255 255 255],60,[],[],3);
    Screen('Flip', wPtr); %display the info visually
    KbWait( -1, 2 ); %wait for key press
    
    % Create all the possible pairs given the stimuli and define a random order
    % to present them (use the function Create_pairs
    [possible_pairs]=Create_pairs(All_stim);
    
    
    %According semantic/visual task, present the correct instruction
    DrawFormattedText(wPtr, '\n   For each pair of videos you have to rate HOW SIMILAR ARE, FROM 1 TO 7, THE TWO VIDEOS for their VISUAL APPEARENCE or for their SEMANTIC MEANING. (press ANY KEY to continue)', 'center','center',[255 255 255],60,[],[],3);
    %DrawFormattedText(wPtr, '\n   HOW SIMILAR ARE, FROM 1 TO 7, THE TWO VIDEOS FOR THEIR MEANING?', 'center','center',[255 255 255],[60],[],[],[3]);
    
    Screen('Flip', wPtr); %display the info visually
    KbWait( -1, 2 ); %wait for key press
    
    
    DrawFormattedText(wPtr, '\n   When you see the word "VISUAL" under the videos, you have to rate HOW SIMILAR THEY ARE, FROM 1 TO 7, FOR THEIR VISUAL APPEARENCE. Do not take into account different actors/colors. Your rating should be based ONLY on the VISUAL shape of the GESTURE itself  (press ANY KEY to continue)', 'center','center',[255 255 255],60,[],[],3);
    Screen('Flip', wPtr); %display the info visually
    KbWait( -1, 2 ); %wait for key press
    
    DrawFormattedText(wPtr, '\n   When you see the word "MEANING" under the videos,you have to rate HOW SIMILAR THEY ARE, FROM 1 TO 7, FOR THEIR MEANING, without taking into account any visual property. Only the meaning. (press ANY KEY to continue)','center','center',[255 255 255],60,[],[],3);
    
    Screen('Flip', wPtr); %display the info visually
    KbWait( -1, 2 ); %wait for key press
    
    DrawFormattedText(wPtr, '\n   There will be 3 PAUSES during the experiment in which you can take a break and start again pressing "ENTER" . (press ENTER to continue)','center','center',[255 255 255],60,[],[],3);
    
    Screen('Flip', wPtr); %display the info visually
    KbWait( -1, 2 ); %wait for key press
    
    DrawFormattedText(wPtr, '\n   ***IMPORTANT*** When the videos start, you can stop the presentation pressing the key "z". Note that all the data will be lost and you will need to start the experiment from the beginning  (press ANY KEY to continue)', 'center','center',[255 255 255],60,[],[],3);
    Screen('Flip', wPtr); %display the info visually
    KbWait( -1, 2 ); %wait for key press
    
    DrawFormattedText(wPtr, '\n   PRESS ANY KEY WHEN YOU ARE READY TO START', 'center','center',[255 255 255],60,[],[],3);
    Screen('Flip', wPtr); %display the info visually
    KbWait( -1, 2 ); %wait for key press
    
    WaitSecs(1); %wait 1 sec before to start
    
    
    
    %% Start the loop for each possible pair of videos
    for i_pairs=1:length(possible_pairs)
        
        % Repeat each pair for both task (visual and semantic)
        for i_task=1:2
            if i_task==1
                task='Visual';
            elseif i_task==2
                task='Semantic';
            end
            %Set the movie and filename
            pathToMovie1=strcat(stim_path,possible_pairs{i_pairs,1},'.mp4');
            pathToMovie2=strcat(stim_path,possible_pairs{i_pairs,2},'.mp4');
            
            %Set clip info
            toTime=inf; %second to stop in movie
            soundvolume=0; %0 to 1
            
            
            possibleResp={'1!','2@','3#','4$','5%','6^','7&'}; %accepted responses
            responseKey = []; %set the responseKey variable to empty
            
            %only at the beginning of the visual trial show only video 1
            %for once and then video 2 for once 
            if i_task==1
                for i=1
                    %Open the movie
                    [movie1,dur1,fps1,width1,height1]=Screen('OpenMovie',wPtr,pathToMovie1);
                    
                    
                    % Define the position of the 2 videos in the screen (here I
                    % present them in the middle of the y axis, on on the right one
                    % on the left, at the same distance from the center).
                    
                    screenWidth = rect(3);
                    screenHeight = rect(4);
                    screenCenterX = screenWidth/4; %I have 2 stimuli
                    screenCenterY = screenHeight/2;
                    
                    %Define the size of the videos according to what has been
                    %defined at the beginning of the scipt
                    
                    if size==1 %original size
                        stimulusRect1=[screenCenterX-width1/2 screenCenterY-height1/2 screenCenterX+width1/2 screenCenterY+height1/2];
                    elseif size==2 %modified size
                        stimulusRect1=[screenCenterX-Width1_modified/2 screenCenterY-Height1_modified/2 screenCenterX+Width1_modified/2 screenCenterY+Height1_modified/2];
                    end
                    
                    %Play the movie
                    Screen('PlayMovie', movie1,1,0,soundvolume);
                    
                    
                    
                    %Mark starting time
                    t=GetSecs();
                    
                    %loop through each frame of the movie and present it
                    
                    while t<toTime
                        
                        %get the texture
                        tex1=Screen('GetMovieImage',wPtr,movie1);
                        
                        
                        %if there is no texture in the video, we are at the end
                        %of the movie
                        
                        if tex1<=0
                            break;
                        end
                        
                        %draw the texture (in this part you can set the position of the 2
                        Screen('DrawTexture',wPtr,tex1,[],stimulusRect1);
                        %Screen('Flip', wPtr); %display the info visually
                        t=Screen('Flip',wPtr);
                        
                        %discard this texture
                        Screen('Close',tex1);
                        
                    end
                    
                    %Stop the movie
                    Screen('PlayMovie',movie1,0);
                    
                    
                    %Close the movie
                    Screen('CloseMovie',movie1);
                end
                
                %show only video 2 for once
                for i=1
                    %Open the movie
                    [movie2,dur2,fps2,width2,height2]=Screen('OpenMovie',wPtr,pathToMovie2);
                    
                    
                    % Define the position of the 2 videos in the screen (here I
                    % present them in the middle of the y axis, on on the right one
                    % on the left, at the same distance from the center).
                    
                    screenWidth = rect(3);
                    screenHeight = rect(4);
                    screenCenterX = screenWidth/4; %I have 2 stimuli
                    screenCenterY = screenHeight/2;
                    
                    %Define the size of the videos according to what has been
                    %defined at the beginning of the scipt
                    
  
                    if size==1 %original size
                        stimulusRect2=[(screenCenterX*3)-width2/2 screenCenterY-height2/2 (screenCenterX*3)+width2/2 screenCenterY+height2/2];
                    elseif size==2 %modified size
                        stimulusRect2=[(screenCenterX*3)-Width2_modified/2 screenCenterY-Height2_modified/2 (screenCenterX*3)+Width2_modified/2 screenCenterY+Height2_modified/2];
                    end
                
                    
                    %Play the movie
                    Screen('PlayMovie', movie2,1,0,soundvolume);
                    
                    
                    
                    %Mark starting time
                    t=GetSecs();
                    
                    %loop through each frame of the movie and present it
                    
                    while t<toTime
                        
                        %get the texture
                        tex2=Screen('GetMovieImage',wPtr,movie2);
                        
                        
                        %if there is no texture in the video, we are at the end
                        %of the movie
                        
                        if tex2<=0
                            break;
                        end
                        
                        %draw the texture (in this part you can set the position of the 2
                        Screen('DrawTexture',wPtr,tex2,[],stimulusRect2);
                        %Screen('Flip', wPtr); %display the info visually
                        t=Screen('Flip',wPtr);
                        
                        %discard this texture
                        Screen('Close',tex2);
                        
                    end
                    
                    %Stop the movie
                    Screen('PlayMovie',movie2,0);
                    
                    
                    %Close the movie
                    Screen('CloseMovie',movie2);
                end
                
                
            end %if i_task==1
            
            Start_time=GetSecs();
            %stop the loop only when participant presses one of these keys
            while sum(strcmp(responseKey,possibleResp))==0

                %Open the movie
                [movie1,dur1,fps1,width1,height1]=Screen('OpenMovie',wPtr,pathToMovie1);
                [movie2,dur2,fps2,width2,height2]=Screen('OpenMovie',wPtr,pathToMovie2);
                
                
                % Define the position of the 2 videos in the screen (here I
                % present them in the middle of the y axis, on on the right one
                % on the left, at the same distance from the center).
                
                screenWidth = rect(3);
                screenHeight = rect(4);
                screenCenterX = screenWidth/4; %I have 2 stimuli
                screenCenterY = screenHeight/2;
                
                %Define the size of the videos according to what has been
                %defined at the beginning of the scipt
                
                if size==1 %original size
                    stimulusRect1=[screenCenterX-width1/2 screenCenterY-height1/2 screenCenterX+width1/2 screenCenterY+height1/2];
                    stimulusRect2=[(screenCenterX*3)-width2/2 screenCenterY-height2/2 (screenCenterX*3)+width2/2 screenCenterY+height2/2];
                elseif size==2 %modified size
                    stimulusRect1=[screenCenterX-Width1_modified/2 screenCenterY-Height1_modified/2 screenCenterX+Width1_modified/2 screenCenterY+Height1_modified/2];
                    stimulusRect2=[(screenCenterX*3)-Width2_modified/2 screenCenterY-Height2_modified/2 (screenCenterX*3)+Width2_modified/2 screenCenterY+Height2_modified/2];
                end
                
                %Play the movie
                Screen('PlayMovie', movie1,1,0,soundvolume);
                Screen('PlayMovie', movie2,1,0,soundvolume);
                
                
                %Mark starting time
                t=GetSecs();
                
                %loop through each frame of the movie and present it
                
                while t<toTime
                    
                    %record the responses
                    [keyIsDown, secs, keyCode] = KbCheck(-1);
                    
                    if keyIsDown %if a key has been pressed
                        pressed_keys=(find(keyCode));
                        responseKey =  KbName(pressed_keys(1)); %check which key (if more than 1 were pressed check only the first)
                        %responseKey = KbName(find(keyCode)); %check which key
                        

                            %1: the sub press 1 key between 1 and 7. In
                            %this case the resp will be recorded and the
                            %script will exit the loop
                      if sum(strcmp(responseKey,possibleResp))>0
                            resp(i_pairs,1)=str2double(responseKey(1));
                            r=str2double(responseKey(1));
                            RT(i_pairs,1)=secs-Start_time;
                            rt=secs-Start_time;
                                  % Save response under the correct .mat task (visual or semantic)
                                if i_task==1
                                    respVis(i_pairs,1)=r;
                                    RTvis(i_pairs,1)=rt;
                                elseif i_task==2
                                    respSem(i_pairs,1)=r;
                                    RTsem(i_pairs,1)=rt;
                                end
                            %2: the key 'z' has been pressed. This will force the
                            %presentation to close.
                        elseif  strcmp (responseKey,'z')
                            Screen('CloseAll');
                            disp 'Forced to close';
                      end
                        
%                         % Save response under the correct .mat task (visual or semantic)
%                         if i_task==1
%                             respVis(i_pairs,1)=r;
%                             RTvis(i_pairs,1)=rt;
%                         elseif i_task==2
%                             respSem(i_pairs,1)=r;
%                             RTsem(i_pairs,1)=rt;
%                         end
%                         
                    end
                    %get the texture
                    tex1=Screen('GetMovieImage',wPtr,movie1);
                    tex2=Screen('GetMovieImage',wPtr,movie2);
                    
                    %if there is no texture in one of the 2 videos, we are at the end of the movie
                    if tex2<=0
                        break;
                    end
                    
                    if tex1<=0
                        break;
                    end
                    
                    %draw the texture (in this part you can set the position of the 2
                    Screen('DrawTexture',wPtr,tex1,[],stimulusRect1);
                    Screen('DrawTexture',wPtr,tex2,[],stimulusRect2);
                    if i_task==1
                        DrawFormattedText(wPtr, '\n   VISUAL', 'center',600,[255 255 255],60,[],[],3);
                    elseif i_task==2
                        DrawFormattedText(wPtr, '\n   MEANING', 'center',600,[255 255 255],60,[],[],3);
                    end
                    %Screen('Flip', wPtr); %display the info visually
                    t=Screen('Flip',wPtr);
                    
                    %discard this texture
                    Screen('Close',tex1);
                    Screen('Close',tex2);
                end
                
                %Stop the movie
                Screen('PlayMovie',movie1,0);
                Screen('PlayMovie',movie2,0);
                
                %Close the movie
                Screen('CloseMovie',movie1);
                Screen('CloseMovie',movie2);
            end
            
            %print the variable in the .csv file
            fprintf(fid,'%s,%s,%s,%d,%s,%s,%d,%d\n',SubjectID,ExperimentID, task,i_pairs,possible_pairs{i_pairs,1},possible_pairs{i_pairs,2},resp(i_pairs,1),RT(i_pairs,1));
            
        end %for i_task
        
        %Set a break after each quarter of experiment
        %first pause
        if i_pairs== round(length(possible_pairs)/4)
            DrawFormattedText(wPtr, '\n  THIS IS THE FIRST PAUSE! Press ANY KEY when you want to continue', 'center','center',[255 255 255],60,[],[],3);
            Screen('Flip', wPtr);
            KbWait( -1, 2 ); %wait for key press
            %second pause
        elseif i_pairs== round((length(possible_pairs)/4))*2
            DrawFormattedText(wPtr, '\n  THIS IS THE SECOND PAUSE! Press ANY KEY when you want to continue', 'center','center',[255 255 255],60,[],[],3);
            Screen('Flip', wPtr);
            KbWait( -1, 2 ); %wait for key press
            %third pause
        elseif i_pairs== round((length(possible_pairs)/4))*3
            DrawFormattedText(wPtr, '\n  THIS IS THE THIRD and LAST PAUSE! Press ANY KEY when you want to continue', 'center','center',[255 255 255],60,[],[],3);
            Screen('Flip', wPtr);
            KbWait( -1, 2 ); %wait for key press
        end %pause loop
        
    end%for i_pairs
    DrawFormattedText(wPtr, '\n  THIS IS THE END OF THE EXPERIMENT! Thanks for your help! Press ANY KEY to close', 'center','center',[255 255 255],60,[],[],3);
    Screen('Flip', wPtr);
    KbWait( -1, 2 ); %wait for key press
    %save the variables in the .mat files
    save (fullfile(output_directory,output_subject_directory,'Results'), 'RTvis','RTsem','respVis','respSem','possible_pairs');
    
catch ME %the 'try and chatch me' part is added to close the screen in case of an error so that you can see the command window and not get stucked with the blank screen)
    Screen('CloseAll');
    rethrow(ME);
end %try


%Clear the screen
clear Screen;
sca;
toc
