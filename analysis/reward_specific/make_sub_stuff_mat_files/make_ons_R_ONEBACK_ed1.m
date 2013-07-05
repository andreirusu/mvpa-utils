%started 21st May 2011- to create onsets
function [the_stuff]=make_ons_R_ONEBACK_ed1(ons_LOC,the_stuff,param)
curr_sub=param.curr_sub;
%n_dummies=1;
n_vol=param.nscan; 

TR=3.0; %62.5ms per slice; 48 slices total (inc oversampling - i think of 20%). 2mm isotropic sequence. 
nsess=5;

for k=1:nsess %sess
    %determine increment
    if k==1
       
        incr=0;%reset increment
    elseif k>1
        incr=incr+(n_vol(k-1)*TR); %i.e. keep increasing INCREMENT 
            
    end
    
    num_trials_sess=length(ons_LOC{k}.cue); %i.e. number of individual pictures in a session (80 or 60 for most subs)
    blkstart_ind=[1:10:num_trials_sess];% index of the start block trials (i.e. 8 or 6 blocks per session)
    the_stuff.blkstart_ind=blkstart_ind; %store blkstart index (it's the same for all sessions)
    
    %ONSETS as BLOCKS (e.g. 6)
    tmp_blkstart_ons=1000*ons_LOC{k}.cue(blkstart_ind);
    tmp_blkstart_ons=tmp_blkstart_ons+incr-ons_LOC{k}.starttime; %add increment and take away starttime
    %AS INDIVIDUAL STIMULI *e.g. 60)
     tmp_stim_ons=1000*ons_LOC{k}.cue;
    tmp_stim_ons=tmp_stim_ons+incr-ons_LOC{k}.starttime; %add increment and take away starttime
    
  
    the_stuff.sess(k).onsets.blkstart=tmp_blkstart_ons;
    the_stuff.sess(k).onsets.stim=tmp_stim_ons;
    
    
end

%Concatenate


the_stuff.all_sess.onsets.blkstart=[];
the_stuff.all_sess.onsets.stim=[];


for k=1:nsess
    
    
    the_stuff.all_sess.onsets.blkstart=[the_stuff.all_sess.onsets.blkstart the_stuff.sess(k).onsets.blkstart];
    the_stuff.all_sess.onsets.stim=[the_stuff.all_sess.onsets.stim the_stuff.sess(k).onsets.stim];
    
    
    
end

