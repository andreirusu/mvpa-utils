%Modified from Transitive inference FMRI experiment EVAL Phase
%started Sep 2012
clear all

%NOTES
%theDataCAT.trials is the alltrials vec
%1st row has rank (1:8 is [1:4 6:9] of Self - i.e. without profile, and
%9:16 is the OTHER ranks)* checked this.
%11th row states whether self or other trial (i.e. 1= self (i.e.
%corresponds to rank of 1:8 in row 1).
%note above holds regardless of subject order.


all_sub=([]);

load self_list_sub_names.mat; %cell with SUBJECT names

%comp_var=input('enter 1 for retina, 2 for macpro:  ');
comp_var=1;
switch comp_var
    case 1 %retina
        my_name='dharsh';
    case 2 %macpro
        my_name='dharshan';
end

dir_start    = ['/Users/' my_name '/Documents/SELF_FMRI_data/analysis'];
file_pfx='CAT.mat';
fs=filesep;
nsess=1; % 1 session
ntask=2; %note here task denotes Self (1), Other (2) - rather than bid vs higher

ind_stim_rank=1; %i.e. row in theDataCAT.trials where stim rank is coded
ind_task=11;  %where self vs other is coded.

num_selftrials=128;


sub_ind=[1:30];
num_subs=length(sub_ind);
for z=1:num_subs
    curr_sub=sub_ind(z);
    disp('Currently on Subject: ');
    curr_sub
    sub_names{curr_sub}
    clear theDataCAT
    clear ons_CAT
    file_name=[sub_names{curr_sub} file_pfx]; %subject specific file with all variables in
    load(file_name);
    
    
    %determine trial numbers for various trial types
    task=([]); %BID=2, HIGHER=1
    param=([]);
    
    
    param.curr_sub=curr_sub;
    
    %specify number of scan volumes in each session for each subject
    if curr_sub==100
        all_sub(curr_sub).nscan=[2000];
        
    else
        all_sub(curr_sub).nscan=[220];
    end
    
    param.nscan=all_sub(curr_sub).nscan; %number of volumes for current subject
    
    
    
    for k=1:nsess %note only 1 session and task is self vs other (1 vs 2)
        for i=1:ntask
            task(i).sess(k).all_tri=find(theDataCAT.trials(ind_task,:)==i); %i.e. index of self vs other
            tmp_1=task(i).sess(k).all_tri; %i.e. list of self/other trials
            task(i).sess(k).RT=theDataCAT.choice.RT.trial(tmp_1); %i.e. RTs
            task(i).sess(k).error=theDataCAT.choice.error.trial(tmp_1); %binary vector 128 long specifying error as 1 (and correct as zero)
            
            switch i
                case 1 %self
                    tmp_1=task(i).sess(k).all_tri; %i.e. list of self trials
                    
                    task(i).sess(k).stim_ranks=theDataCAT.trials(ind_stim_rank,tmp_1); %list of stim ranks for each trial (face left, neb right)
                    task(i).name='self';
                case 2 %bid
                    tmp_1=task(i).sess(k).all_tri; %i.e. list of other trials
                    adj_fact=8; %i.e. top rank of other is coded in theDataCAT.trials as 9
                    task(i).sess(k).stim_ranks=theDataCAT.trials(ind_stim_rank,tmp_1)-adj_fact; %list of stim ranks for each trial (face left, neb right)
                    task(i).name='other';
            end
           
        end
    end
    
    
    %note that because there is only 1 session in self, there is no need
    %to concatenate sessions (as in EVAL)
    
    %now make onsets (naturally SORTED for Eval session)
    
    [task]=make_ons_CATEG_ed1(onsCAT,task,param);
    
    %this bit splits events into high, middle, low ranking faces and neb
    param.split_spec=1; %1=1 bin for each rank, 2= hi (1 2), middle (3 4 5), low (6 7) ranks.
    [task]=categ_split_ranks_ed1(task,param);
    
    %get movement parameters and put in structure
    
    [movt,all_movt_data]=get_movt_CATEG_ed1(task,param,my_name);
    %%
    
    %FOR CORRECT VS INCORRECT ANALYSIS.
    
    for k=1:nsess %
        for i=1:ntask
            
            ind_incorr=find(task(i).sess(k).error); %incorrect trials
            ind_corr=setdiff([1:num_selftrials],find(task(i).sess(k).error)); %correct trials
            task(i).sess(k).corr_onsets=task(i).sess(k).onsets(ind_corr); %onsets for correct trials
            task(i).sess(k).incorr_onsets=task(i).sess(k).onsets(ind_incorr); %onsets for correct trials
            task(i).sess(k).corr_stim_ranks=task(i).sess(k).stim_ranks(ind_corr);
            task(i).sess(k).incorr_stim_ranks=task(i).sess(k).stim_ranks(ind_incorr);
            
            task(i).sess(k).corr_RT=task(i).sess(k).RT(ind_corr); %onsets for correct trials
            task(i).sess(k).incorr_RT=task(i).sess(k).RT(ind_incorr); %onsets for correct trials
            
        end
    end
    
    
    all_sub(curr_sub).task=task;
    all_sub(curr_sub).movt=movt;
    all_sub(curr_sub).all_movt_data=all_movt_data;
    all_sub(curr_sub).name=sub_names{curr_sub};
end

cd(dir_start)
save('sub_stuff_CATEG_v6.mat','all_sub')



disp('done')

