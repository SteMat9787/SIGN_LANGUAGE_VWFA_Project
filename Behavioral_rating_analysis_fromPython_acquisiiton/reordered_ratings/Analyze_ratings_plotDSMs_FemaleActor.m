function [respSemF_reord,respSemF_reord_norm,respVisF_reord,respVisF_reord_norm]=Analyze_ratings_plotDSMs_FemaleActor(sub_ID)

%% set the variables and load the results
% sub_ID='AlVa'; %%insert the correctsub ID here
%% 


 %load the Results.mat
 load (strcat(sub_ID,'_task-rating_beh.mat'));
 
 
%% Reorder the stimuli to create the DSM 
%stim names
All_stim_vec={'Stim1F';...
'Stim1SCF';...
'Stim1VCF';...
'Stim2F';...
'Stim2SCF';...
'Stim2VCF';...
'Stim3F';...
'Stim3SCF';...
'Stim3VCF'};


labels=All_stim_vec;
n_stim=length(All_stim_vec);


%all possible combination
combos = combntns(1:n_stim,2);
combos=combos'; 
for i=1:length(combos)
order_pairs(i,1)= All_stim_vec(combos(1,i));
order_pairs(i,2)= All_stim_vec(combos(2,i));
end

%find the position of each pair
for p=1:length(combos)
    stim_one=order_pairs(p,1);
    stim_two=order_pairs(p,2);
 
 pos=find(strcmp(possible_pairs(:,1),stim_one) & strcmp(possible_pairs(:,2),stim_two));
if isempty (pos)
   pos=find(strcmp(possible_pairs(:,2),stim_one) & strcmp(possible_pairs(:,1),stim_two));  
end
 actual_pos(p,1)=pos;
end %for p(airs)

%reorder the visual and semantic ratings according to the position you
%want to give them

for vr=1:length(combos)
    respVisF_reord(vr,1)=respVis(actual_pos(vr));
end % for vr (visual ratings)

for sr=1:length(combos)
    respSemF_reord(sr,1)=respSem(actual_pos(sr));
end % for sr (semantic ratings)

%% visualize the DSMs
figure(1);
set(gcf,'color','w');
%visual ratings
subplot(3,2,1);

respVisF_reord=1-respVisF_reord;
respVisF_reord_norm=mat2gray(respVisF_reord);
Vis_DSM=squareform(respVisF_reord_norm);
Vis_DSM_tril=tril(Vis_DSM);
imagesc(Vis_DSM_tril);
colorbar;
set(colorbar,'FontName','Avenir','FontSize',18, 'FontWeight','bold',...
       'LineWidth',2.5,'TickDir','out', 'TickLength', [0]);
title (strcat( 'Visual Ratings Female-',sub_ID));
set(gca, 'YTick',(1:length(labels)),'YTickLabel',labels);
set(gca, 'XTick',(1:length(labels)),'XTickLabel',[]);
xtickangle(45);
set(gca,'FontName','Avenir','FontSize',18, 'FontWeight','bold',...
       'LineWidth',2.5,'TickDir','out', 'TickLength', [0,0]);

%semantic ratings
subplot(3,2,2);

respSemF_reord=1-respSemF_reord;
respSemF_reord_norm=mat2gray(respSemF_reord);
Sem_DSM=squareform(respSemF_reord_norm);
Sem_DSM_tril=tril(Sem_DSM);
imagesc(Sem_DSM_tril);
colorbar;
set(colorbar,'FontName','Avenir','FontSize',18, 'FontWeight','bold',...
       'LineWidth',2.5,'TickDir','out', 'TickLength', [0]);
title (strcat( 'Semantic Ratings Female-',sub_ID));
set(gca, 'YTick',(1:length(labels)),'YTickLabel',labels);
set(gca, 'XTick',(1:length(labels)),'XTickLabel',[]);
xtickangle(45);
set(gca,'FontName','Avenir','FontSize',18, 'FontWeight','bold',...
       'LineWidth',2.5,'TickDir','out', 'TickLength', [0,0]);
end