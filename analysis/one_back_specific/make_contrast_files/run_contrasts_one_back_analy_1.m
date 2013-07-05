function [param] = run_contrasts_one_back_analy_1(param)

%description of first level des mx
%CHAIR/BUILD/SCRCHAIR/(SCRBUILD-only subs1-4)/TARG

curr_sub=param.curr_sub;
%note EVENT DURATION modelled as ZERO 
curr_sub_group=param.curr_sub_group; %i.e. SUBJECT GROUP


all_others=zeros(1,11); %i.e. including movt,, 4x block eff,1 x session mean 
param.all_contrasts=[];
param.all_con_names={};

%%%PAD contrast vector for subjects 1-4 (who have scr_build)
if curr_sub<=4
extra_reg=[0 0]; %i.e. to specify contrast
else
extra_reg=[];
end
%%%%%%%%%%

%FIRST CONTRAST
curr_num=1;
param.all_con_names{curr_num}='chair_vs_scrchair';

cue_pt=[1 0  0 0   -1 0];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];

%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='build_vs_chair';

cue_pt=[-1 0  1 0   0 0];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];


%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='chair_vs_build';

cue_pt=[1 0  -1 0   0 0];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];

%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='build_vs_scrchair';

cue_pt=[0 0  1 0   -1 0];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];

%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='chair';

cue_pt=[1 0  0 0   0 0];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];
%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='build';

cue_pt=[0 0  1 0   0 0];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];
%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='scrchair';

cue_pt=[0 0  0 0   1 0];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];
%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='targ';

cue_pt=[0 0  0 0   0 0];  %3 categories chair/build/scrchair
oth_pt=[1 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];



%%ADAPTATION
%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='Adapt_chair_vs_scrchair';

cue_pt=[0 -1  0 0   0 1];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];



%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='Adapt_build_vs_chair';

cue_pt=[0 1  0 -1   0 0];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];



%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='Adapt_chair_vs_build';

cue_pt=[0 -1  0 1   0 0];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];


%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='Adapt_targ';

cue_pt=[0 0  0 0   0 0];  %3 categories chair/build/scrchair
oth_pt=[0 -1 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];



%%ADAPTATION+ME combined
%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='Stim+Adapt_chair_vs_scrchair';

cue_pt=[1 -1  0 0   -1 1];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];



%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='Stim+Adapt_build_vs_chair';

cue_pt=[-1 1  1 -1   0 0];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];



%NEXT CONTRAST
curr_num=curr_num+1;
param.all_con_names{curr_num}='Stim+Adapt_chair_vs_build';

cue_pt=[1 -1  -1 1   0 0];  %3 categories chair/build/scrchair
oth_pt=[0 0 ];% target

curr_contrast=[cue_pt   extra_reg     oth_pt  all_others]; %+extra reg 
param.all_contrasts=[param.all_contrasts;curr_contrast];









