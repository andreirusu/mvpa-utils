%started April 2013
clear all


sub_ind=[1:21];

    all_sub_group=[ 1     1     1     1     2     2     2     2     2     2     1     2     1     1     1     1     2     2     2     2     1]; %GROUP
all_sub=([]);

load R_list_sub_names.mat; %cell with SUBJECT names
load the_subseq_mem.mat %has subseq memory
%comp_var=input('enter 1 for retina, 2 for macpro:  ');
comp_var=2;
switch comp_var
    case 1 %retina
        my_name='dharsh';
    case 2 %macpro
        my_name='dharshan';
end

dir_start    = ['/Users/' my_name '/Documents/Reward_FMRI_2013/analysis'];
file_pfx='_session2REW_ENC.mat';
fs=filesep;
nsess=2; % 2 session
ntask=1; %note here task denotes Self (1), Other (2) - rather than bid vs higher

num_subs=length(sub_ind);
for z=1:num_subs
    curr_sub=sub_ind(z);
    disp('Currently on Subject: ');
    curr_sub
    all_sub_names{curr_sub}
    clear theDataREW_ENC
    clear ons_enc
    file_name=[all_sub_names{curr_sub} file_pfx]; %subject specific file with all variables in
    load(file_name);
    
    ons_ENC=ons_enc;
    
    
    %determine trial numbers for various trial types
    the_stuff=([]); %
    param=([]);
    
    
    param.curr_sub=curr_sub;
    
    all_sub(curr_sub).group=all_sub_group(curr_sub); %GROUP 
    
    %specify number of scan volumes in each session for each subject
    if curr_sub==100
        all_sub(curr_sub).nscan=[2000];
        
    else
        all_sub(curr_sub).nscan=[190];
    end
    
    param.nscan=all_sub(curr_sub).nscan; %number of volumes for current subject
    
    the_stuff.all_sess.categ_ind=[];
    the_stuff.all_sess.reward_status=[];
    the_stuff.all_sess.feedback_type=[];
    %the_stuff.all_sess.mem_rating=[];
    
    
    for k=1:nsess %note only 1 session and task is self vs other (1 vs 2)
        
        
        the_stuff.sess(k).categ_ind=alltrials_split{k}(2,:); %1= chair 2 =building
        the_stuff.sess(k).reward_status=alltrials_split{1}(4,:);%1=rewarded, 0= unrewarded
        the_stuff.sess(k).feedback_type=theDataREW_ENC.sess(k).feedback.presented_fbck.trial; %0=unrew, 1=rew, 2=neutral. 
        
        
        %
        the_stuff.all_sess.categ_ind=[the_stuff.all_sess.categ_ind the_stuff.sess(k).categ_ind];
        the_stuff.all_sess.reward_status=[the_stuff.all_sess.reward_status the_stuff.sess(k).reward_status];
        the_stuff.all_sess.feedback_type=[the_stuff.all_sess.feedback_type the_stuff.sess(k).feedback_type];
        
        %MEMORY
        the_stuff.all_sess.rew_mem_rating=the_mem(curr_sub).rew_mem_rating; %i.e. 1-6 ratings for all REWARDED items (across both sessions)
        the_stuff.all_sess.unrew_mem_rating=the_mem(curr_sub).unrew_mem_rating; %i.e. 1-6 ratings for all REWARDED items (across both sessions)
        
        
    end
    
    %now make onsets (naturally SORTED for Eval session)
    
    [the_stuff]=make_ons_R_ENC_ed1(ons_ENC,the_stuff,param);
    
    
    %get movement parameters and put in structure
    
    [movt,all_movt_data]=get_movt_R_ENC_ed1(the_stuff,param,my_name);
    %%
    
    %FOR CORRECT VS INCORRECT ANALYSIS.
    
    
    
    all_sub(curr_sub).the_stuff=the_stuff;
    all_sub(curr_sub).movt=movt;
    all_sub(curr_sub).all_movt_data=all_movt_data;
    all_sub(curr_sub).name=all_sub_names{curr_sub};
end

cd(dir_start)
save('sub_stuff_R_ENC_v2.mat','all_sub')



disp('done')

