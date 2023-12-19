clear all;
clc;
commandwindow; %move the cursor to the command window so responses will not printed on the script

tic;
%% SET THE MAIN VARIABLES
global  SubjectID

% GlobalGroupID= input ('Group (HNS-HES-HLS-DES):','s'); %%HNS: Hearing non signers; HES:Hearing early signers; HLS:Hearing late signers; DES:Deaf early signers
%GlobalSubjectID=input('Subject ID: ', 's'); %% (first 2 letters of Name-first 2 letters of Surname)
% GlobalRunNumberID=input('Run Number(1-4): ', 's');
% 
% ExperimentID=input('Experiment ID (SignExp): ', 's');
SubjectID=input('Subject ID (write first 2 letters of your Name and first 2 letters of your surname): ', 's');


%% SETUP OUTPUT DIRECTORY AND OUTPUT FILE
%if it doesn't exist already, make the output folder
output_directory='output_files';
if ~exist(output_directory, 'dir')
    mkdir(output_directory)
end
output_file_name=[output_directory '/output_file_' SubjectID '.csv'];

logfile=fopen(output_file_name,'a');%'a'== PERMISSION: open or create file for writing; append data to end of file
fprintf(logfile,'\n');
fprintf(logfile,'subjectID,trial_num,Image_Name,Response_key\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINE THE STIMULI NAME, THE PATH & THE SIZE OF THE STIMULI: this is the only section to be changed%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stim path
main_folder=fileparts(cd);
stim_path=fullfile(main_folder,'Behavioral_rating','Sign_Stimuli/');

%stim names
meaningless_stim={'NoStim1','NoStim2','NoStim3','NoStim4','NoStim5',...
    'NoStim6','NoStim7','NoStim8','NoStim9'};
meaningless_stimF=(strcat(meaningless_stim,{'F'}));
meaningless_stimM=(strcat(meaningless_stim,{'M'}));
ALLmeaningless_stim=[meaningless_stimF,meaningless_stimM];

meaningful_stim={'Stim1','Stim1SC','Stim1VC',...
    'Stim2','Stim2SC','Stim2VC',...
    'Stim3','Stim3SC','Stim3VC'};
meaningful_stimF=(strcat(meaningful_stim,{'F'}));
meaningful_stimM=(strcat(meaningful_stim,{'M'}));
ALLmeaningful_stim=[meaningful_stimF,meaningful_stimM];


All_stim=[ALLmeaningless_stim,ALLmeaningful_stim];
All_stim_shuffle=Shuffle(All_stim);
%STIM SIZE

% % %For the original size open this part
% % %Set the size to 1 to present the video in their original size
% %  size=1;

%For the modified size open this part
%Set the size to 2 to present the video in a different size and select the
% %size (in pixels) (to keep the ratio: 400-225/450-253/500-281
size=2;
Width_modified= 700; %width video 1 in pixels 
Height_modified=394; %height video 1 in pixels


%Set the times
StimLength=2;
timeout=3;
%Baseline times (in sec)
Baseline_start=1;
Baseline_end=1;

% FIX CROSS
crossLength=50;
crossColor=[200 200 200];
crossWidth=7;
%Set start and end point of lines
crossLines=[-crossLength, 0; crossLength, 0; 0, -crossLength; 0, crossLength];
crossLines=crossLines';

% Open the screen
Screen('Preference', 'SkipSyncTests', 1);
[wPtr, rect]= Screen('OpenWindow',max(Screen('Screens'))); %open the screen
Screen('FillRect',wPtr,[125 125 125]); %draw a rectangle (big as all the monitor) on the back buffer
Screen ('Flip',wPtr); %flip the buffer, showing the rectangle
HideCursor(wPtr);

% STIMULUS RECTANGLE (in the center)
screenWidth = rect(3);
screenHeight = rect(4);%-(rect(4)/3); %this part is to have it on the top of te screen
screenCenterX = screenWidth/2;
screenCenterY = screenHeight/2;
%stimulusRect=[screenCenterX-stimSize/2 screenCenterY-stimSize/2 screenCenterX+stimSize/2 screenCenterY+stimSize/2];
 %clear screen

%% OPEN THE SCREEN
try %the 'try and chatch me' part is added to close the screen in case of an error so that you can see the command window and not get stucked with the blank screen)
% %     %clear screen
% %     %Screen('Preference', 'SkipSyncTests', 1);
% %     [wPtr, rect]= Screen('OpenWindow',max(Screen('Screens'))); %open the screen
    
    Screen('FillRect',wPtr,[125 125 125]); %draw a rectangle (big as all the monitor) on the back buffer
    Screen ('Flip',wPtr); %flip the buffer, showing the rectangle
    HideCursor(wPtr);
    
    %% DISPLAY INSTRUCTION
    Screen('TextSize', wPtr, 40);
    DrawFormattedText(wPtr, '\n  WELCOME & THANKS FOR PARTICIPATING IN THIS EXPERIMENT (press ENTER to continue)', 'center','center',[255 255 255],60,[],[],3);
    Screen('Flip', wPtr);
    KbWait( -1, 2 ); %wait for key press
    
    
    DrawFormattedText(wPtr, '\n  IN THIS EXPERIMENT YOU WILL SEE SOME VIDEOS OF SIGNS. At the end of each sign you will have to evaluate how difficult would be for you to recreate the same sign (press ENTER to continue)', 'center','center',[255 255 255],60,[],[],3);
    Screen('Flip', wPtr); %display the info visually
    KbWait( -1, 2 ); %wait for key press
    
%     % Create all the possible pairs given the stimuli and define a random order
%     % to present them (use the function Create_pairs
%     [possible_pairs]=Create_pairs(All_stim);
    
    
    % Instruction
    DrawFormattedText(wPtr, '\n    IN OTHER WORDS, HOW COMPLEX IS THE SIGN from 1 (very easy) to 7 (very complex)?   (press ENTER to continue)', 'center','center',[255 255 255],60,[],[],3);
    %DrawFormattedText(wPtr, '\n   HOW SIMILAR ARE, FROM 1 TO 7, THE TWO VIDEOS FOR THEIR MEANING?', 'center','center',[255 255 255],[60],[],[],[3]);
    
    Screen('Flip', wPtr); %display the info visually
    KbWait( -1, 2 ); %wait for key press
    
    
    DrawFormattedText(wPtr, '\n    Press a number from 1 (very easy) to 7 (very difficult) (press ENTER to continue)', 'center','center',[255 255 255],60,[],[],3);
    Screen('Flip', wPtr); %display the info visually
    KbWait( -1, 2 ); %wait for key press
    
%     DrawFormattedText(wPtr, '\n     If you press "y" you will have to try to guess the meaning of this sign. Write the word or write IDK (I Dont t Know) if you cannot guess(press ENTER to continue)','center','center',[255 255 255],60,[],[],3);
%     
%     Screen('Flip', wPtr); %display the info visually
%     KbWait( -1, 2 ); %wait for key press
%     
%     DrawFormattedText(wPtr, '\n   There will be 3 PAUSES during the experiment in which you can take a break and start again pressing "ENTER" . (press ENTER to continue)','center','center',[255 255 255],60,[],[],3);
%     
%     Screen('Flip', wPtr); %display the info visually
%     KbWait( -1, 2 ); %wait for key press
    
%     DrawFormattedText(wPtr, '\n   ***IMPORTANT*** When the videos start, you can stop the presentation pressing the key "z". Note that all the data will be lost and you will need to start the experiment from the beginning  (press ANY KEY to continue)', 'center','center',[255 255 255],60,[],[],3);
%     Screen('Flip', wPtr); %display the info visually
%     KbWait( -1, 2 ); %wait for key press
    
    DrawFormattedText(wPtr, '\n   PRESS ENTER WHEN YOU ARE READY TO START', 'center','center',[255 255 255],60,[],[],3);
    Screen('Flip', wPtr); %display the info visually
    KbWait( -1, 2 ); %wait for key press
    
    WaitSecs(1); %wait 1 sec before to start
    
    %Draw THE FIX CROSS
    Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[screenCenterX,screenCenterY]);
    % Flip the screen
    Screen('Flip', wPtr);
    WaitSecs(Baseline_start);
    
    LoopStart=GetSecs();
    %% Start the loop for each video
    for iStim=1:length(All_stim_shuffle)
        
        %Set the movie and filename
        pathToMovie=strcat(stim_path,All_stim_shuffle{iStim},'.mp4');
        
        %Set clip info
        toTime=inf; %second to stop in movie
        soundvolume=0; %0 to 1
        
        
        
        
        %stop the loop only when participant presses one of these keys
        %possibleResp={'y','n'}; %accepted responses
        possibleResp={'1!','2@','3#','4$','5%','6^','7&'}; %accepted responses
        responseKey = [];
       
         %show the movie one time   
             for i=1
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
            t=GetSecs();
            
             
                    %loop through each frame of the movie and present it
                    
                    while t<toTime
                        
                        %get the texture
                        tex=Screen('GetMovieImage',wPtr,movie);
                        
                        
                        %if there is no texture in the video, we are at the end
                        %of the movie
                        
                        if tex<=0
                            break;
                        end
                        
                        %draw the texture (in this part you can set the position of the 2
                        Screen('DrawTexture',wPtr,tex,[],stimulusRect);
                        %Screen('Flip', wPtr); %display the info visually
                        t=Screen('Flip',wPtr);
                        
                        %discard this texture
                        Screen('Close',tex);
                        
                    end
                    
                    %Stop the movie
                    Screen('PlayMovie',movie,0);
                    
                    
                    %Close the movie
                    Screen('CloseMovie',movie);
             end
             
             %% display question 1
             
    Screen('TextSize', wPtr, 40);
    DrawFormattedText(wPtr, '\n  HOW DIFFICULT WOULD BE FOR YOU TO RECREATE THIS SIGN from 1 (very easy) to 7 (very complex)?', 'center','center',[255 255 255],60,[],[],3);
    Screen('Flip', wPtr);
    
    
                        [secs, keyCode] =KbWait( -1, 2 );% KbCheck(-1);
                        pressed_keys=(find(keyCode));
                        responseKey =  KbName(pressed_keys(1)); %check which key (if more than 1 were pressed check only the first)
                        %responseKey = KbName(find(keyCode)); %check which key
                        

                            %1: the sub press 1 key between 1 and 7. In
                            %this case the resp will be recorded and the
                            %script will exit the loop
                      while sum(strcmp(responseKey,possibleResp))==0
                        [secs, keyCode] =KbWait( -1, 2 );% KbCheck(-1)
                        pressed_keys=(find(keyCode));
                        responseKey =  KbName(pressed_keys(1)); %check which k
          
                            %2: the key 'z' has been pressed. This will force the
                            %presentation to close.
                      end
    
    
    %Store the response in a mat file
    Resp1{iStim}=KbName(keyCode);%wait for key press; 
        
% % if responseKey=='y'
% %      %% display question 2
% %         DrawFormattedText(wPtr, '\n  TRY TO GUESS THE MEANING OF THE SIGN: type the word (then press the "move right" button and ENTER)', 'center','center',[255 255 255],60,[],[],3);
% %         Screen('Flip', wPtr);
% % %           msg='Guess the meaning of this sign/n';
% % %      [string,terminatorChar] = GetEchoString(wPtr,msg,screenCenterX,screenCenterY,[0 0 0],[],[],[],[1]);
% % %       x(iStim)=string;
% %          x(iStim) = inputdlg({'Guess the meaning'},...
% %               'SIGN MEANING', [1 50]); 
% % elseif responseKey=='n'
% %     x(iStim) = {'no meaning'};
% % end
 %print the variable in the .csv file
     fprintf(logfile,'%s,%d,%s,%s\n',SubjectID,iStim,All_stim_shuffle{iStim},Resp1{iStim});
    end %for iStim
    catch ME %the 'try and chatch me' part is added to close the screen in case of an error so that you can see the command window and not get stucked with the blank screen)
    Screen('CloseAll');
    rethrow(ME);
end %try


%Clear the screen
clear Screen;
sca;

      
toc;

    DrawFormattedText(wPtr, '\n THIS IS THE END OF THE EXPERIMENT! THANKS FOR YOUR HELP!', 'center','center',[255 255 255],60,[],[],3);
    Screen('Flip', wPtr); %display the info visually
    
    WaitSecs(5);
    
    KbWait( -1, 2 ); %wait for key press
    
    