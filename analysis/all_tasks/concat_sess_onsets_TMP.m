num_sess=5;
num_vols=[0 102 102 102 102 ]; %i.e. don't incrememnt first times
incr=0;
TR=3;

curr_sub=4;

all_chair_onsets=[];
all_build_onsets=[];
all_scchair_onsets=[];
all_scbuild_onsets=[];
all_fix_onsets=[];

for i=1:num_sess
    
    
        
     ind_1=find(alltrials_loc{i}(2,:)==1);
     ind_2=find(alltrials_loc{i}(2,:)==2);
     ind_3=find(alltrials_loc{i}(2,:)==3);
     ind_4=find(alltrials_loc{i}(2,:)==4);
     
     %
     tmp_fix=ons{i}.fixcross_brake*1000-ons{i}.starttime;
     tmp_cue=ons{i}.cue*1000-ons{i}.starttime;
     
     ons_1=tmp_cue(ind_1);
     ons_2=tmp_cue(ind_2);
     ons_3=tmp_cue(ind_3);
     ons_4=tmp_cue(ind_4);
     ons_fix=tmp_fix;
     
     incr=incr+(num_vols(i)*TR);
    
     all_chair_onsets=[all_chair_onsets ons_1+incr];
     all_build_onsets=[all_build_onsets ons_2+incr];
     all_scchair_onsets=[all_scchair_onsets ons_3+incr];
     all_scbuild_onsets=[all_scbuild_onsets ons_4+incr];
     all_fix_onsets=[all_fix_onsets ons_fix+incr];
     
    
end

all_sub(curr_sub).chair_onsets=all_chair_onsets;
all_sub(curr_sub).build_onsets=all_build_onsets;
all_sub(curr_sub).scchair_onsets=all_scchair_onsets;
all_sub(curr_sub).scbuild_onsets=all_scbuild_onsets;
all_sub(curr_sub).fix_onsets=all_fix_onsets;
disp('done')