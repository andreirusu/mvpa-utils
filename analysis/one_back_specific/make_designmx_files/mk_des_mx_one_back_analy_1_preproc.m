function   mk_des_mx_one_back_analy_1_preproc(all_sub,param, all_sub_R_ENC) %*change     need to address function file from file that loads up subject specific data ***_____________IF VARIABLES CHANGED *********


disp('>>>>>>> Using PREPROC version of design matrix building function!')


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
SPM.nscan=sum(all_sub(curr_sub).nscan);
SPM.list_nscan=all_sub(curr_sub).nscan;
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
SPM.xBF.length     = 30;                % length in seconds 32.2
SPM.xBF.order      = 1;                 % order of basis set		DO NOT FIDDLE!	=1
SPM.xBF.T          = 16;                % number of time bins per scan
SPM.xBF.T0         = 8;                 % first time bin (see slice timing)
SPM.xBF.UNITS      = 'secs';            % OPTIONS: 'scans'|'secs' for onsets
SPM.xBF.Volterra   = 1;

filt=180;

block_dur=20; %each block is 20 seconds
targ_dur=0;


% Trial specification: Onsets, duration (UNITS) and parameters for modulation

%%

i=1;

cond=0;

%%%% THIS WILL CREATE 0.7s events
regress_volumes = false;

chair_onsets = all_sub(curr_sub).the_stuff.chair_onsets';
build_onsets = all_sub(curr_sub).the_stuff.build_onsets';

disp(chair_onsets)
disp(build_onsets)

if all_sub_R_ENC(curr_sub).group == 1 ;
    %%% THIS TRIES TO REGRESS OUT 6 INDIVIDUAL VOLUMES FROM EACH BLOCK
    if regress_volumes == true 
        for j=1:size(chair_onsets,1) 
            for l = 1:6
                cond=cond+1;
                SPM.Sess(i).U(cond).name        =   {['chair.' num2str(j) '.' num2str(l)]};
                SPM.Sess(i).U(cond).ons         =   chair_onsets(j) + (l-1)*SPM.xY.RT;
                SPM.Sess(i).U(cond).dur         =   SPM.xY.RT; %block_dur; %repmat(block_dur, (length(SPM.Sess(i).U(cond).ons)),1);
                SPM.Sess(i).U(cond).P(1).name   =   'none';
            end
        end
    else
        disp(cond)
        for j=1:size(chair_onsets,1) 
            cond=cond+1;
            SPM.Sess(i).U(cond).name        =   {['chair.' num2str(j)]};
            SPM.Sess(i).U(cond).ons         =   chair_onsets(j);
            SPM.Sess(i).U(cond).dur         =   block_dur; %repmat(block_dur, (length(SPM.Sess(i).U(cond).ons)),1);
            SPM.Sess(i).U(cond).P(1).name   =   'none';
        end
    end
    %%% THIS TRIES TO REGRESS OUT 6 INDIVIDUAL VOLUMES FROM EACH BLOCK
    if regress_volumes == true 
        for j=1:size(build_onsets,1) 
            for l = 1:6
                cond=cond+1;
                SPM.Sess(i).U(cond).name        =   {['build.' num2str(j) '.' num2str(l)]};
                SPM.Sess(i).U(cond).ons         =   build_onsets(j) + (l-1)*SPM.xY.RT;
                SPM.Sess(i).U(cond).dur         =   SPM.xY.RT; %block_dur; %repmat(block_dur, (length(SPM.Sess(i).U(cond).ons)),1);
                SPM.Sess(i).U(cond).P(1).name   =   'none';
            end
        end
    else
        disp(cond)
        for j=1:size(build_onsets,1) 
            cond=cond+1;
            SPM.Sess(i).U(cond).name        =   {['build.' num2str(j)]};
            SPM.Sess(i).U(cond).ons         =   build_onsets(j);
            SPM.Sess(i).U(cond).dur         =   block_dur; %repmat(block_dur, (length(SPM.Sess(i).U(cond).ons)),1);
            SPM.Sess(i).U(cond).P(1).name   =   'none';
        end
    end
elseif all_sub_R_ENC(curr_sub).group == 2 ;
    %%% THIS TRIES TO REGRESS OUT 6 INDIVIDUAL VOLUMES FROM EACH BLOCK
    if regress_volumes == true 
        for j=1:size(build_onsets,1) 
            for l = 1:6
                cond=cond+1;
                SPM.Sess(i).U(cond).name        =   {['build.' num2str(j) '.' num2str(l)]};
                SPM.Sess(i).U(cond).ons         =   build_onsets(j) + (l-1)*SPM.xY.RT;
                SPM.Sess(i).U(cond).dur         =   SPM.xY.RT; %block_dur; %repmat(block_dur, (length(SPM.Sess(i).U(cond).ons)),1);
                SPM.Sess(i).U(cond).P(1).name   =   'none';
            end
        end
    else
        disp(cond)
        for j=1:size(build_onsets,1) 
            cond=cond+1;
            SPM.Sess(i).U(cond).name        =   {['build.' num2str(j)]};
            SPM.Sess(i).U(cond).ons         =   build_onsets(j);
            SPM.Sess(i).U(cond).dur         =   block_dur; %repmat(block_dur, (length(SPM.Sess(i).U(cond).ons)),1);
            SPM.Sess(i).U(cond).P(1).name   =   'none';
        end
    end
    %%% THIS TRIES TO REGRESS OUT 6 INDIVIDUAL VOLUMES FROM EACH BLOCK
    if regress_volumes == true 
        for j=1:size(chair_onsets,1) 
            for l = 1:6
                cond=cond+1;
                SPM.Sess(i).U(cond).name        =   {['chair.' num2str(j) '.' num2str(l)]};
                SPM.Sess(i).U(cond).ons         =   chair_onsets(j) + (l-1)*SPM.xY.RT;
                SPM.Sess(i).U(cond).dur         =   SPM.xY.RT; %block_dur; %repmat(block_dur, (length(SPM.Sess(i).U(cond).ons)),1);
                SPM.Sess(i).U(cond).P(1).name   =   'none';
            end
        end
    else
        disp(cond)
        for j=1:size(chair_onsets,1) 
            cond=cond+1;
            SPM.Sess(i).U(cond).name        =   {['chair.' num2str(j)]};
            SPM.Sess(i).U(cond).ons         =   chair_onsets(j);
            SPM.Sess(i).U(cond).dur         =   block_dur; %repmat(block_dur, (length(SPM.Sess(i).U(cond).ons)),1);
            SPM.Sess(i).U(cond).P(1).name   =   'none';
        end
    end
else
    error 'Wrong group'
    return;
end

disp(cond)

cond=cond+1;
SPM.Sess(i).U(cond).name      = {'scrchair'};
SPM.Sess(i).U(cond).ons       = all_sub(curr_sub).the_stuff.scrchair_onsets'; %
SPM.Sess(i).U(cond).dur       = repmat(block_dur, (length(SPM.Sess(i).U(cond).ons)),1);
SPM.Sess(i).U(cond).P(1).name = 'time';
SPM.Sess(i).U(cond).P(1).P    = all_sub(curr_sub).the_stuff.scrchair_onsets'; %
SPM.Sess(i).U(cond).P(1).h    = 1; %LINEAR


%****************
%ONLY SUBJECTS 1-4 HAVE SCRBUILDING CONDITION
if curr_sub<=4
cond=cond+1;
SPM.Sess(i).U(cond).name      = {'scrbuild'};
SPM.Sess(i).U(cond).ons       = all_sub(curr_sub).the_stuff.scrbuild_onsets'; %
SPM.Sess(i).U(cond).dur       = repmat(block_dur, (length(SPM.Sess(i).U(cond).ons)),1);
SPM.Sess(i).U(cond).P(1).name = 'time';
SPM.Sess(i).U(cond).P(1).P    = all_sub(curr_sub).the_stuff.scrbuild_onsets'; %
SPM.Sess(i).U(cond).P(1).h    = 1; %LINEAR
else
end

%_________________________________________
cond=cond+1;
SPM.Sess(i).U(cond).name      = {'targ'};
SPM.Sess(i).U(cond).ons       = all_sub(curr_sub).the_stuff.targ_onsets'; %
SPM.Sess(i).U(cond).dur       = repmat(targ_dur, (length(SPM.Sess(i).U(cond).ons)),1);
SPM.Sess(i).U(cond).P(1).name = 'time';
SPM.Sess(i).U(cond).P(1).P    = all_sub(curr_sub).the_stuff.targ_onsets'; %
SPM.Sess(i).U(cond).P(1).h    = 1; %LINEAR



%====================GET FILES FOR EACH SESSION

%SESSION BLOCK EFFECTS (nsess-1)

blk_eff1=[ones(SPM.list_nscan(1),1);zeros(SPM.list_nscan(2),1);zeros(SPM.list_nscan(3),1);zeros(SPM.list_nscan(4),1);zeros(SPM.list_nscan(5),1)]; %
blk_eff2=[zeros(SPM.list_nscan(1),1);ones(SPM.list_nscan(2),1);zeros(SPM.list_nscan(3),1);zeros(SPM.list_nscan(4),1);zeros(SPM.list_nscan(5),1)]; %
blk_eff3=[zeros(SPM.list_nscan(1),1);zeros(SPM.list_nscan(2),1);ones(SPM.list_nscan(3),1);zeros(SPM.list_nscan(4),1);zeros(SPM.list_nscan(5),1)]; %
blk_eff4=[zeros(SPM.list_nscan(1),1);zeros(SPM.list_nscan(2),1);zeros(SPM.list_nscan(3),1);ones(SPM.list_nscan(4),1);zeros(SPM.list_nscan(5),1)]; %




%MOVT REGRESSORS PLUS 1 BLOCK EFFECTS

load('../../../functional_preprocessing_data.mat')
first = Inf;
last = Inf;
for l=1:size(filelist,1)
    indices = strfind(char(filelist(l,1)), 'one_back');

    if size(indices,1) > 0 
        if first == Inf 
            first = l;
        end
        last = l;
    end
end
disp(['Fist vol: ', num2str(first), '; Last vol: ', num2str(last), '; Files: ', num2str(last - first + 1)])

str = char(filelist(1,1));
str = strrep(strrep(str, 'nii', 'txt'),'rfMQ', 'rp_fMQ');
disp(str);
[a,b,c,d,e,f] = textread(str, '%f%f%f%f%f%f');
%figure(9); imagesc(cat(2, a(first:last), b(first:last), c(first:last), d(first:last), e(first:last), f(first:last)))

SPM.Sess(i).C.C    = [a(first:last) b(first:last) c(first:last) d(first:last) e(first:last) f(first:last) blk_eff1 blk_eff2 blk_eff3 blk_eff4];          % [n x c double] covariates
SPM.Sess(i).C.name = {'X','Y','Z','x','y','z' 'blockeff1' 'blockeff2' 'blockeff3' 'blockeff4'};   % [1 x c cell]   names



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

Directory1        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess1' fs 'PROC'];
Directory2        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess2' fs 'PROC'];
Directory3        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess3' fs 'PROC'];
Directory4        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess4' fs 'PROC'];
Directory5        =[dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'sess5' fs 'PROC'];

files1          = spm_select('ExtFPList',Directory1,Filter);
files2          = spm_select('ExtFPList',Directory2,Filter);
files3          = spm_select('ExtFPList',Directory3,Filter);
files4          = spm_select('ExtFPList',Directory4,Filter);
files5          = spm_select('ExtFPList',Directory5,Filter);

SPM.xY.P        = [files1; files2;files3;files4;files5];




% Configure design matrix
%===========================================================================
SPM=spm_fmri_spm_ui(SPM);
