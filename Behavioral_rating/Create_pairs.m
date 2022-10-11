function [possible_pairs] = Create_pairs(All_stim)
%'Create Pairs' is a function that, given all the Stimuli, creates all the
%possible pairs and give as output a file in which is line is composed by
%the name of the 2 pairs.
n_stim=length(All_stim);

%all possible combination
combos = combntns(1:n_stim,2);
combos=combos'; 
combos_mix=Shuffle(combos);
combos_mix=combos_mix';
random_combos = combos_mix(randperm(size(combos_mix, 1)), :);


%create a cell file with the stimuli names
for i=1:length(combos)
possible_pairs(i,1)= All_stim(random_combos(i,1));
possible_pairs(i,2)= All_stim(random_combos(i,2));
end

end

