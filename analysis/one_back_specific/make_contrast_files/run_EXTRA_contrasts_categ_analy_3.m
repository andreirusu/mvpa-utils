function [param] = run_EXTRA_contrasts_categ_analy_3(param)

%
all_others=zeros(1,7); %i.e. including movt, 1 x blk effect, 1 x session mean
%DETERMINE NUMBER OF EXISTING CONTRASTS, and STARTING CONTRAST NUMBER

num_exist_contrasts=param.num_exist_contrasts;
curr_num=num_exist_contrasts+1; %i.e. start at next contrast
%%%%%%%%%%%%%%%%%%%%%%
%NEXT CONTRAST
curr_num=curr_num;
param.all_con_names{curr_num}='S_O_R23vs78';

self_pt=[0 1 1 0   0 -1 -1 0];  % 3 onset regressors: hi rank/ mid rank/ low rank (no parametric mod)
other_pt=[0 1 1 0   0 -1 -1 0];%% hi rank/ mid rank/ low rank (no parametric mod)

curr_contrast=[self_pt other_pt all_others];
param.all_contrasts=[param.all_contrasts;curr_contrast];


%DETERMINE NUMBER OF NEW ADDED CONTRASTS
num_total_contrasts=size(param.all_contrasts,1);
num_new_contrasts=num_total_contrasts-num_exist_contrasts; %i.e. number of EXTRA contrasts
param.num_new_contrasts=num_new_contrasts;

