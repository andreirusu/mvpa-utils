function [param] = run_contrasts_reward_analy_2(param)

%description of first level des mx
%REW cue: ONSET, memory rating / UNREW cue: ONSET, mem rating
%Pos feedback/ Neg feedback/neutral feedback
%TARG


%note EVENT DURATION modelled as ZERO 
curr_sub_group=param.curr_sub_group; %i.e. SUBJECT GROUP


all_others=zeros(1,8); %i.e. including movt,, 1x block eff,1 x session mean 
param.all_contrasts=[];
param.all_con_names={};

%FIRST CONTRAST
curr_num=1;
param.all_con_names{curr_num}='cue_rew_vs_unrew';

cue_pt=[1 0  -1 0];  %REW: event, mem rating UNREW: event, mem rating
oth_pt=[0 0 0 0];%Feedback pos,neg,neut + TARG: event only

curr_contrast=[cue_pt oth_pt all_others];
param.all_contrasts=[param.all_contrasts;curr_contrast];

%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='ME_subs_mem';

cue_pt=[0 1  0 1];  %REW: event, mem rating UNREW: event, mem rating
oth_pt=[0 0 0 0];%Feedback pos,neg,neut + TARG: event only

curr_contrast=[cue_pt oth_pt all_others];
param.all_contrasts=[param.all_contrasts;curr_contrast];


%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='rew_subs_mem';

cue_pt=[0 1  0 0];  %REW: event, mem rating UNREW: event, mem rating
oth_pt=[0 0 0 0];%Feedback pos,neg,neut + TARG: event only

curr_contrast=[cue_pt oth_pt all_others];
param.all_contrasts=[param.all_contrasts;curr_contrast];

%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='unrew_subs_mem';

cue_pt=[0 0  0 1];  %REW: event, mem rating UNREW: event, mem rating
oth_pt=[0 0 0 0];%Feedback pos,neg,neut + TARG: event only

curr_contrast=[cue_pt oth_pt all_others];
param.all_contrasts=[param.all_contrasts;curr_contrast];


%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='subs_mem_rew>unrew';

cue_pt=[0 1  0 -1];  %REW: event, mem rating UNREW: event, mem rating
oth_pt=[0 0 0 0];%Feedback pos,neg,neut + TARG: event only

curr_contrast=[cue_pt oth_pt all_others];
param.all_contrasts=[param.all_contrasts;curr_contrast];
%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='targ';

cue_pt=[0 0  0 0];  %REW: event, mem rating UNREW: event, mem rating
oth_pt=[0 0 0 1];%Feedback pos,neg,neut + TARG: event only

curr_contrast=[cue_pt oth_pt all_others];
param.all_contrasts=[param.all_contrasts;curr_contrast];

%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='rew_fb_vs_neut';

cue_pt=[0 0  0 0];  %REW: event, mem rating UNREW: event, mem rating
oth_pt=[1 1 -2 0];%Feedback pos,neg,neut + TARG: event only

curr_contrast=[cue_pt oth_pt all_others];
param.all_contrasts=[param.all_contrasts;curr_contrast];
%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='pos_fbvsneg';

cue_pt=[0 0  0 0];  %REW: event, mem rating UNREW: event, mem rating
oth_pt=[1 -1 0 0];%Feedback pos,neg,neut + TARG: event only

curr_contrast=[cue_pt oth_pt all_others];
param.all_contrasts=[param.all_contrasts;curr_contrast];

%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='ME_cue';

cue_pt=[1 0  1 0];  %REW: event, mem rating UNREW: event, mem rating
oth_pt=[0 0 0 0];%Feedback pos,neg,neut + TARG: event only

curr_contrast=[cue_pt oth_pt all_others];
param.all_contrasts=[param.all_contrasts;curr_contrast];



switch curr_sub_group
    case 1 %i.e. chairs = rew
%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='chairs_vs_build';

cue_pt=[1 0  -1 0];  %REW: event, mem rating UNREW: event, mem rating
oth_pt=[0 0 0 0];%Feedback pos,neg,neut + TARG: event only

curr_contrast=[cue_pt oth_pt all_others];
param.all_contrasts=[param.all_contrasts;curr_contrast];
    case 2
%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='*****'; %i.e. CHAIR vs BUILDINGS !!!

cue_pt=[-1 0  1 0];  %REW: event, mem rating UNREW: event, mem rating
oth_pt=[0 0 0 0];%Feedback pos,neg,neut + TARG: event only

curr_contrast=[cue_pt oth_pt all_others];
param.all_contrasts=[param.all_contrasts;curr_contrast];
end

