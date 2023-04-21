
%set the subID
sub_ID='sub-HNS01'; %%insert the correctsub ID here

[respSemF_reord,respSemF_reord_norm,respVisF_reord,respVisF_reord_norm]=Analyze_ratings_plotDSMs_FemaleActor(sub_ID);
[respSemM_reord,respSemM_reord_norm,respVisM_reord,respVisM_reord_norm]=Analyze_ratings_plotDSMs_MaleActor(sub_ID);

respSem_reord_norm= (respSemF_reord_norm+respSemM_reord_norm)/2;
respVis_reord_norm= (respVisF_reord_norm+respVisM_reord_norm)/2;


%% Reorder the stimuli to create the DSM 
All_stim_vec={'Stim1';...
'Stim1SC';...
'Stim1VC';...
'Stim2';...
'Stim2SC';...
'Stim2VC';...
'Stim3';...
'Stim3SC';...
'Stim3VC'};


labels=All_stim_vec;
n_stim=length(All_stim_vec);


figure(1)
%visual ratings
subplot(3,2,5);

Vis_DSM=squareform(respVis_reord_norm);
Vis_DSM_tril=tril(Vis_DSM);
imagesc(Vis_DSM_tril);
colorbar;
set(colorbar,'FontName','Avenir','FontSize',18, 'FontWeight','bold',...
    'LineWidth',2.5,'TickDir','out', 'TickLength', [0]);
title (strcat( 'Visual Ratings Averaged-',sub_ID));
set(gca, 'YTick',(1:length(labels)),'YTickLabel',labels);
set(gca, 'XTick',(1:length(labels)),'XTickLabel',labels);
xtickangle(45);
set(gca,'FontName','Avenir','FontSize',18, 'FontWeight','bold',...
    'LineWidth',2.5,'TickDir','out', 'TickLength', [0,0]);


%semantic ratings
subplot(3,2,6);


Sem_DSM=squareform(respSem_reord_norm);
Sem_DSM_tril=tril(Sem_DSM);
imagesc(Sem_DSM_tril);
colorbar;
set(colorbar,'FontName','Avenir','FontSize',18, 'FontWeight','bold',...
    'LineWidth',2.5,'TickDir','out', 'TickLength', [0]);
title (strcat( 'Semantic Ratings Averaged-',sub_ID));
set(gca, 'YTick',(1:length(labels)),'YTickLabel',labels);
set(gca, 'XTick',(1:length(labels)),'XTickLabel',labels);
xtickangle(45);
set(gca,'FontName','Avenir','FontSize',18, 'FontWeight','bold',...
    'LineWidth',2.5,'TickDir','out', 'TickLength', [0,0]);

save(strcat(sub_ID,'_task-rating_beh_actorMERGED'),'respSem_reord_norm','respVis_reord_norm');