%% load the data (there is  aproblem with csv files so I needd to convvert the file into xltx to be able to upload them)
sub_label='sub-HNS01';
result_table=readtable(strcat(sub_label,'_task-rating_beh.xltx'));

%% delete the lines and the begenning and at the end if there are NAN values --> need to check this manually
result_table(1,:)=[];
result_table(end-1:end,:)=[];
%result_table(end,:)=[];

%% convert the visual and semantic ratings into .mat files (apparently the number of col change from 1 sub to the other!!!)
%Extract the col with visual rating into a cell 
%In our table the visual ratings are in col  10 (sub HNS01) and 11 (sub
%HNS02)
visual_rating_cell=table2cell(result_table(:,10));
%Extract the col with semantic rating into a cell 
%In our table the semantic ratings are in col  12 (sub HNS01) and 13 (sub
%HNS02)
semantic_rating_cell=table2cell(result_table(:,12));

%Convert the string in the cell into number
for i=1:length(visual_rating_cell)
  respVis(i,1)=str2num(visual_rating_cell{i}(3));
  respSem(i,1)=str2num(semantic_rating_cell{i}(3));
end %for i

%% convert the pairs of stimuli name into cell
%Extract These filenames from col 1 and 2
pairs_cell= table2cell(result_table(:,[1,2])); 

% create your variable possible_pairs with only the part of the stimuli name
for i=1:size(pairs_cell,1)
    possible_pairs{i,1}=pairs_cell{i,1}(14:end-4);
    possible_pairs{i,2}=pairs_cell{i,2}(14:end-4);
end %for i

%create the output folder if it does not exist
if (~exist('reordered_ratings', 'dir')); mkdir('reordered_ratings');end%if

save(strcat('reordered_ratings/',sub_label,'_task-rating_beh'),'respVis','respSem','possible_pairs');