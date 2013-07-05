function   mk_des_mx_reward_analy_1(all_sub,param) %*change     need to address function file from file that loads up subject specific data ***_____________IF VARIABLES CHANGED *********


%get variables from param
curr_sub=param.curr_sub;
num_sess=param.num_sess;
analy=param.analy;
fs=param.fs;
dir_base=param.dir_base;
%%%%%%%%%

spm_defaults

%specify number of scans
tt1=length(all_sub(curr_sub).all_movt_data);%i.e. each movt regressor is padded with zeros
SPM.nscan=tt1;
%TR
SPM.xY.RT          = 3.00;   %Quattro sequence               

% basis functions and timing parameters
%---------------------------------------------------------------------------
% OPTIONS:'hrf'
%         'hrf (with time derivative)'
%         'hrf (with time and dispersion derivatives)'
%         'Fourier set'
%         'Fourier set (Hanning)'
%         'Gamma functions'
%         'Finite Impulse Response'
%---------------------------------------------------------------------------
SPM.xBF.name       = 'hrf';
SPM.xBF.length     = 30;              % length in seconds 32.2
SPM.xBF.order      = 1;                 % order of basis set		DO NOT FIDDLE!	=1
SPM.xBF.T          = 16;                % number of time bins per scan
SPM.xBF.T0         = 8;                 % first time bin (see slice timing)
SPM.xBF.UNITS      = 'secs';            % OPTIONS: 'scans'|'secs' for onsets
SPM.xBF.Volterra   = 1;

filt=180;

%TRIAL DURATIONS
% if curr_sub<3
%     trial_dur=7;
% else
%     trial_dur=8;
% end
trial_dur=0;

rew_ind=find(all_sub(curr_sub).the_stuff.all_sess.reward_status==1); %index rewarded trials
unrew_ind=find(all_sub(curr_sub).the_stuff.all_sess.reward_status==0); %index rewarded trials

rew_mem_rating=all_sub(curr_sub).the_stuff.all_sess.rew_mem_rating;
unrew_mem_rating=all_sub(curr_sub).the_stuff.all_sess.unrew_mem_rating;

 pos_fb_ind=find(all_sub(curr_sub).the_stuff.all_sess.feedback_type==1);
neg_fb_ind=find(all_sub(curr_sub).the_stuff.all_sess.feedback_type==0);


 
 
r_cue_onsets=all_sub(curr_sub).the_stuff.all_sess.onsets.cue(rew_ind);
ur_cue_onsets=all_sub(curr_sub).the_stuff.all_sess.onsets.cue(unrew_ind);
r_pos_fb_onsets=all_sub(curr_sub).the_stuff.all_sess.onsets.fb(pos_fb_ind);%pos feed
r_neg_fb_onsets=all_sub(curr_sub).the_stuff.all_sess.onsets.fb(neg_fb_ind); %neg feed

ur_fb_onsets=all_sub(curr_sub).the_stuff.all_sess.onsets.fb(unrew_ind); %neutral

targ_onsets=all_sub(curr_sub).the_stuff.all_sess.onsets.targ; %TARGET
% %%%%%%%%%%%%%

i=1;

cond=1;

SPM.Sess(i).U(cond).name      = {'r_cue'};
SPM.Sess(i).U(cond).ons       = r_cue_onsets'; %
SPM.Sess(i).U(cond).dur      = 0;
SPM.Sess(i).U(cond).P(1).name = 'Rmem_rating';
SPM.Sess(i).U(cond).P(1).P    = rew_mem_rating'; %
SPM.Sess(i).U(cond).P(1).h    = 1; %LINEAR
 
 
 
%SPM.Sess(i).U(cond).dur       = repmat(trial_dur, (length(SPM.Sess(i).U(cond).ons)),1);
%% 
% SPM.Sess(i).U(cond).P(1).name = 'time';
% SPM.Sess(i).U(cond).P(1).P    = all_sub(curr_sub).chair_onsets'; %
% SPM.Sess(i).U(cond).P(1).h    = 1; %LINEAR
% 
% SPM.Sess(i).U(cond).P(2).name = 'face_rank';
% SPM.Sess(i).U(cond).P(2).P    = self_face_rank; %
% SPM.Sess(i).U(cond).P(2).h    = 2; %LINEAR AND QUAD


%

cond=cond+1;
SPM.Sess(i).U(cond).name      = {'ur_cue'};
SPM.Sess(i).U(cond).ons       = ur_cue_onsets'; %
SPM.Sess(i).U(cond).dur      = 0;
SPM.Sess(i).U(cond).P(1).name = 'URmem_rating';
 SPM.Sess(i).U(cond).P(1).P    = unrew_mem_rating'; %
 SPM.Sess(i).U(cond).P(1).h    = 1; %LINEAR
 

cond=cond+1;
SPM.Sess(i).U(cond).name      = {'r_pos_feed'};
SPM.Sess(i).U(cond).ons       = r_pos_fb_onsets'; %
SPM.Sess(i).U(cond).dur      = 0;
SPM.Sess(i).U(cond).P(1).name = 'none';

cond=cond+1;
SPM.Sess(i).U(cond).name      = {'r_neg_feed'};
SPM.Sess(i).U(cond).ons       = r_neg_fb_onsets'; %
SPM.Sess(i).U(cond).dur      = 0;
SPM.Sess(i).U(cond).P(1).name = 'none';


cond=cond+1;
SPM.Sess(i).U(cond).name      = {'ur_feed'};
SPM.Sess(i).U(cond).ons       = ur_fb_onsets'; %
SPM.Sess(i).U(cond).dur      = 0;
SPM.Sess(i).U(cond).P(1).name = 'none';

% cond=cond+1;
% SPM.Sess(i).U(cond).name      = {'targ'};
% SPM.Sess(i).U(cond).ons       = targ_onsets'; %
% SPM.Sess(i).U(cond).dur      = 0;
% SPM.Sess(i).U(cond).P(1).name = 'none';


%====================GET FILES FOR EACH SESSION

%SESSION BLOCK EFFECTS (only need 1)
% if curr_sub==2
% blk_eff1=[ones(361,1);zeros(280,1)];  %i.e INCOMPLETE SECOND SESSION
% else
 blk_eff1=[ones(SPM.nscan/num_sess,1);zeros(SPM.nscan/num_sess,1)]; %
% end
%blk_eff1=[]; %only 1 session in SELF STUDY (cf 2 in EVAL TINF)
%MOVT REGRESSORS PLUS 1 BLOCK EFFECTS

SPM.Sess(i).C.C    = [all_sub(curr_sub).all_movt_data blk_eff1];          % [n x c double] covariates
SPM.Sess(i).C.name = {'X','Y','Z','x','y','z' 'blockeff1'};   % [1 x c cell]   names



% global normalization: OPTINS:'Scaling'|'None'
%---------------------------------------------------------------------------
SPM.xGX.iGXcalc    = 'None';
SPM.xGX.sGMsca     = '<no grand Mean scaling>';


% low frequency confound: high-pass cutoff (secs) [Inf = no filtering]
%---------------------------------------------------------------------------
SPM.xX.K.HParam    = filt ;


% intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
%-----------------------------------------------------------------------
SPM.xVi.form       = 'AR(0) + w';  %? mistake ? change AR (0)


% specify data: matrix of filenames and TR
%===========================================================================
Filter           = '^srf.*\.nii$'; %smoothed normalized images

Directory1        =[dir_base fs 's' num2str(curr_sub) fs 'reward' fs 'sess1' fs 'PROC'];
Directory2        =[dir_base fs 's' num2str(curr_sub) fs 'reward' fs 'sess2' fs 'PROC'];
%Directory3        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess3'];
%Directory4        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess4'];
%Directory5        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess5'];

files1          = spm_select('ExtFPList',Directory1,Filter);
files2          = spm_select('ExtFPList',Directory2,Filter);
%files3          = spm_select('ExtFPList',Directory3,Filter);
%files4          = spm_select('ExtFPList',Directory4,Filter);
%files5          = spm_select('ExtFPList',Directory5,Filter);

SPM.xY.P        = [files1; files2];%files3;files4;files5];

%files1          = spm_select('ExtFPList',Directory1,Filter);
%files2          = spm_select('ExtFPList',Directory2,Filter);

%SPM.xY.P        = [files1];% files2];




% Configure design matrix
%===========================================================================
SPM=spm_fmri_spm_ui(SPM);
