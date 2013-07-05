%started 21st May 2011- to create onsets
function [the_stuff]=make_ons_R_ENC_ed1(ons_ENC,the_stuff,param)
curr_sub=param.curr_sub;
%n_dummies=1;
n_vol=param.nscan; %i.2. 399-6=393 volumes for MOST SUBJECTS
%n_vol=n_vol(1); %i.e. take number of volumes in first session

TR=3.0; %secs
nsess=2;

% the_stuff.sess(k).categ_ind %1= chair 2 =building
% the_stuff.sess(k).reward_status=alltrials_split{1}(4,:):%1=rewarded, 0= unrewarded
% the_stuff.sess(k).feedback_type=theDataREW_ENC.sess(k).feedback.presented_fbck.trial; %0=unrew, 1=rew, 2=neutral.
% the_stuff.sess(k).mem_rating;

for k=1:nsess %sess
    
%     chair_ind=find(the_stuff.sess(k).categ_ind==1);
%     build_ind=find(the_stuff.sess(k).categ_ind==2);
%     rew_ind=find(the_stuff.sess(k).reward_status==1);
%     unrew_ind=find(the_stuff.sess(k).reward_status==0);
%     pos_fb_ind=find(the_stuff.sess(k).feedback_type==1);
%     neg_fb_ind=find(the_stuff.sess(k).feedback_type==0);
%     neut_fb_ind=find(the_stuff.sess(k).feedback_type==2);
    %determine increment
   if k==1
       
        incr=0;%reset increment
    elseif k>1
        incr=incr+(n_vol(k-1)*TR); %i.e. keep increasing INCREMENT 
            
    end
    
    
    tmp_cue_ons=1000*ons_ENC{k}.cue;
    tmp_cue_ons=tmp_cue_ons+incr-ons_ENC{k}.starttime; %add increment and take away starttime
    
    tmp_fb_ons=1000*ons_ENC{k}.feedback;
    tmp_fb_ons=tmp_fb_ons+incr-ons_ENC{k}.starttime; %add increment and take away starttime
    
    tmp_targ_ons=1000*ons_ENC{k}.target;
    tmp_targ_ons=tmp_targ_ons+incr-ons_ENC{k}.starttime; %add increment and take away starttime
    
    
    the_stuff.sess(k).onsets.cue=tmp_cue_ons;
    the_stuff.sess(k).onsets.fb=tmp_fb_ons;
    the_stuff.sess(k).onsets.targ=tmp_targ_ons;
    
end

%Concatenate


the_stuff.all_sess.onsets.cue=[];
the_stuff.all_sess.onsets.fb=[];
the_stuff.all_sess.onsets.targ=[];

for k=1:nsess
    
    
    the_stuff.all_sess.onsets.cue=[the_stuff.all_sess.onsets.cue the_stuff.sess(k).onsets.cue];
    the_stuff.all_sess.onsets.fb=[the_stuff.all_sess.onsets.fb the_stuff.sess(k).onsets.fb];
    the_stuff.all_sess.onsets.targ=[the_stuff.all_sess.onsets.targ the_stuff.sess(k).onsets.targ];
    
    
end

