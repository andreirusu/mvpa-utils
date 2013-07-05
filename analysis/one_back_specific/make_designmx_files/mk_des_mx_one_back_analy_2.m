function   mk_des_mx_one_back_analy_2(all_sub,param) %*change     need to address function file from file that loads up subject specific data ***_____________IF VARIABLES CHANGED *********



%get variables from param
curr_sub=param.curr_sub;
num_sess=param.num_sess;
analy=param.analy;
fs=param.fs;
dir_base=param.dir_base;
%%%%%%%%%

spm_defaults

%specify number of scans
%tt1=length(all_sub(curr_sub).all_movt_data);%i.e. each movt regressor is padded with zeros
SPM.nscan=[104-6+103-6+105-6+105-6+105-6];%tt1;
%TR
SPM.xY.RT          = 3.00;                              % seconds


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
trial_dur=20;



% Trial specification: Onsets, duration (UNITS) and parameters for modulation

% %TO GENERATE VECTORS WITHOUT TOP AND BOTTOM RANKS
% tmp_1=all_sub(curr_sub).task(1).sess(1).stim_ranks(:); %
% tmp_2=length(all_sub(curr_sub).task(1).sess(1).stim_ranks(:));
% 
% tmp_top_R=find(tmp_1==1); 
% tmp_bot_R=find(tmp_1==8); 
% tmp_3=setdiff([1:tmp_2],[tmp_top_R tmp_bot_R]);
% 
% 
% self_onsets=all_sub(curr_sub).task(1).sess(1).onsets'; %
% self_face_rank=all_sub(curr_sub).task(1).sess(1).stim_ranks(:); %
% self_RT=all_sub(curr_sub).task(1).sess(1).RT'; %
% 
% tmp_ind=find(self_RT==0); %i.e. missed
% self_RT(tmp_ind)=mean(self_RT); %replace with mean RT
% 
% 
% other_onsets=all_sub(curr_sub).task(2).sess(1).onsets'; %
% other_face_rank=all_sub(curr_sub).task(2).sess(1).stim_ranks(:); %
% other_RT=all_sub(curr_sub).task(2).sess(1).RT'; %
% 
% tmp_ind=find(other_RT==0); %i.e. missed
% other_RT(tmp_ind)=mean(other_RT); %replace with mean RT
% %%%%%%%%%%%%%

i=1;

cond=1;

SPM.Sess(i).U(cond).name      = {'chair'};
SPM.Sess(i).U(cond).ons       = all_sub(curr_sub).chair_onsets'; %
SPM.Sess(i).U(cond).dur      = trial_dur;
%SPM.Sess(i).U(cond).dur       = repmat(trial_dur, (length(SPM.Sess(i).U(cond).ons)),1);
%% 
SPM.Sess(i).U(cond).P(1).name = 'time';
SPM.Sess(i).U(cond).P(1).P    = all_sub(curr_sub).chair_onsets'; %
SPM.Sess(i).U(cond).P(1).h    = 1; %LINEAR
% 
% SPM.Sess(i).U(cond).P(2).name = 'face_rank';
% SPM.Sess(i).U(cond).P(2).P    = self_face_rank; %
% SPM.Sess(i).U(cond).P(2).h    = 2; %LINEAR AND QUAD


%

cond=cond+1;
SPM.Sess(i).U(cond).name      = {'build'};
SPM.Sess(i).U(cond).ons       = all_sub(curr_sub).build_onsets'; %
SPM.Sess(i).U(cond).dur      = trial_dur;
%SPM.Sess(i).U(cond).P(1).name = 'none';
SPM.Sess(i).U(cond).P(1).name = 'time';
SPM.Sess(i).U(cond).P(1).P    = all_sub(curr_sub).build_onsets'; %
SPM.Sess(i).U(cond).P(1).h    = 1; %LINEAR

cond=cond+1;
SPM.Sess(i).U(cond).name      = {'scchair'};
SPM.Sess(i).U(cond).ons       = all_sub(curr_sub).scchair_onsets'; %
SPM.Sess(i).U(cond).dur      = trial_dur;
SPM.Sess(i).U(cond).P(1).name = 'time';
SPM.Sess(i).U(cond).P(1).P    = all_sub(curr_sub).scchair_onsets'; %
SPM.Sess(i).U(cond).P(1).h    = 1; %LINEAR
cond=cond+1;
SPM.Sess(i).U(cond).name      = {'scbuild'};
SPM.Sess(i).U(cond).ons       = all_sub(curr_sub).scbuild_onsets'; %
SPM.Sess(i).U(cond).dur      = trial_dur;
SPM.Sess(i).U(cond).P(1).name = 'time';
SPM.Sess(i).U(cond).P(1).P    = all_sub(curr_sub).scbuild_onsets'; %
SPM.Sess(i).U(cond).P(1).h    = 1; %LINEAR
cond=cond+1;
SPM.Sess(i).U(cond).name      = {'fix'};
SPM.Sess(i).U(cond).ons       = all_sub(curr_sub).fix_onsets'; %
SPM.Sess(i).U(cond).dur      = 16;
SPM.Sess(i).U(cond).P(1).name = 'time';
SPM.Sess(i).U(cond).P(1).P    = all_sub(curr_sub).fix_onsets'; %
SPM.Sess(i).U(cond).P(1).h    = 1; %LINEAR
%SPM.Sess(i).U(cond).dur       = repmat(trial_dur, (length(SPM.Sess(i).U(cond).ons)),1);
%SPM.Sess(i).U(cond).P(1).name = 'none';

% SPM.Sess(i).U(cond).P(1).name = 'RT';
% SPM.Sess(i).U(cond).P(1).P    = other_RT; %
% SPM.Sess(i).U(cond).P(1).h    = 1; %LINEAR
% 
% 
% SPM.Sess(i).U(cond).P(2).name = 'other_face_rank';
% SPM.Sess(i).U(cond).P(2).P    = other_face_rank; %
% SPM.Sess(i).U(cond).P(2).h    = 2; %LINEAR AND QUADRATIC


%====================GET FILES FOR EACH SESSION

%SESSION BLOCK EFFECTS (only need 1)
% if curr_sub==2
% blk_eff1=[ones(361,1);zeros(280,1)];  %i.e INCOMPLETE SECOND SESSION
% else
% blk_eff1=[ones(SPM.nscan/num_sess,1);zeros(SPM.nscan/num_sess,1)]; %
% end
blk_eff1=[]; %only 1 session in SELF STUDY (cf 2 in EVAL TINF)
%MOVT REGRESSORS PLUS 1 BLOCK EFFECTS

SPM.Sess(i).C.C    = [];%all_sub(curr_sub).all_movt_data];% blk_eff1];          % [n x c double] covariates
SPM.Sess(i).C.name = {};%'X','Y','Z','x','y','z'};%'blockeff1'};   % [1 x c cell]   names



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
Filter           = '^swuf.*\.img$'; %smoothed normalized images

Directory1        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess1'];
Directory2        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess2'];
Directory3        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess3'];
Directory4        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess4'];
Directory5        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess5'];

files1          = spm_select('ExtFPList',Directory1,Filter);
files2          = spm_select('ExtFPList',Directory2,Filter);
files3          = spm_select('ExtFPList',Directory3,Filter);
files4          = spm_select('ExtFPList',Directory4,Filter);
files5          = spm_select('ExtFPList',Directory5,Filter);

SPM.xY.P        = [files1; files2;files3;files4;files5];

%files1          = spm_select('ExtFPList',Directory1,Filter);
%files2          = spm_select('ExtFPList',Directory2,Filter);

%SPM.xY.P        = [files1];% files2];




% Configure design matrix
%===========================================================================
SPM=spm_fmri_spm_ui(SPM);
