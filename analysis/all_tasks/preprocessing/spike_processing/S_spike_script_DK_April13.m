% physio_script.m
% Script that calls physio routines to construct physiological regressors
% acquired using the spike data acquisition software.
% This script is for demonstration purposes and may need editing in order
% to generate the required regressors.
% The main routine to create the physio regressors is make_physio_regressors
%
%_______________________________________________________________________
% Refs and Background reading:
%
% The implementation of this toolbox is described in:
% Hutton et al, 2011, NeuroImage.
%
% The methods are based on the following:
% Glover et al, 2000, MRM, (44) 162-167
% Josephs et al, 1997, ISMRM, p1682
% Birn et al, 2006, NeuroImage, (31) 1536-1548
%
%________________________________________________________
% (c) Wellcome Trust Centre for NeuroImaging (2010)

% Chloe Hutton
% $Id: physio_script.m $

%*******************************************
%*****************
%MY NOTES July 2011
%I have altered the make_physio_regressors_DK function so that:
%don't need to specify in advance the number of sessions (which differs
%across subjects, cos of different set up scans)
%saves the relevant scan sessions into the_params and returns
%ALSO note that dummies specified as 0 : then just before saving R-
%truncate dummies and last few scans
%note also that only saving the REAL SESSIONS (but processes all the data)

%hence leave nsessions, ndummies unspecified here
%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
all_sub_spike_data=([]);
%sub_ind=[2:6 8:17 20:26];
sub_ind=[1];
task=1;

%LEARN TASK
switch task
    case 1
        n_realstart_vol=2; %used just before saving R below : i.e. first REAL VOLUME
        n_reallast_vol=105; %i.e. last volume to be used.
        task_prfx='one_back';
    case 2
        %EVAL TASK
        task_prfx='eval';
        n_realstart_vol=7; %used just before saving R below : i.e. first REAL VOLUME
        n_reallast_vol=399; %i.e. last volume to be used.
end

if strcmp(task_prfx,'one_back')
    num_sessions=5;
    %%%%%%%%%%%%%%%%%%%
    
    %LIST OF WHICH FMs relate to WHICH SESSIONS
    list_ex_subs=[];%1 7 18 19]; %list of exception subs (note 25 is not an exception for spike)
    
    ex_subs=([]);
    
    
    %%%%%%
    
elseif strcmp(task_prfx,'eval')
    num_sessions=2;
    %%%%%%%%%%%%%%%%%%%
    
    %LIST OF WHICH FMs relate to WHICH SESSIONS
    list_ex_subs=[]; %list of exception subs
    ex_subs=([]);
    
end





%%%%%%%%%%%%%%
% Add necessary folders to path
[spm_path,name]=fileparts(which('spm'));
physiopath=sprintf('%s%s%s',spm_path,filesep,'toolbox',filesep,'physio');
addpath(physiopath);
sonpath=sprintf('%s%s%s%s%s',spm_path,filesep,'toolbox',filesep,'physio',filesep,'son');
addpath(sonpath);

% Directory set up
fs          = filesep; %file sep
dir_base_spike    = '/Users/dharshan/Documents/Reward_FMRI_2013/analysis/preprocessing/spike_processing/spike_sub_files';%
sess_prfx   = 'sess';
dir_save_spike='/Users/dharshan/Documents/Reward_FMRI_2013/analysis/preprocessing/spike_processing/spike_sub_files';
%scanDir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs sess_prfx num2str(curr_sess)];
try
load list_sub_names_SPIKE.mat %names are a bit different from other stuff
catch
end
%feb13_lh_spike.S2R

sub_names={'feb13_lh_spike'};
num_subs=length(sub_ind);
for k=1:num_subs %subjects
    curr_sub=sub_ind(k);
    
    
    for curr_task=task %sessions
        cd(dir_base_spike) %
        curr_sub_name=sub_names{curr_sub};
        %physiofile=[curr_sub_name '_' 'sess' num2str(curr_task) '.smr']; %sess2.smr is the EVAL TASK
        physiofile='feb13_lh_spike.smr';
        
        
        % Input values that must be defined correctly for specific acquisition
        nslices=48;  % Number of slices in volume
        ndummies=0;  % Set to zero since none for practice
        
        TR=60e-3;       % Slice TR in secs
        TRms=TR*1e3;     % As above
        
        nsessions=[]; % LEAVE BLANK!! this is filled in by the make_physio_regressors_DK modified version
        
        slicenum=30;  %30 is MIDBRAIN (obv varies from sub to sub)
        
        %Slice number to time-lock regressors to
        % The above slice number can be determined from
        % data converted to nifti format. By default, slices
        % will be numbered from bottom to top but the acquisition
        % order can be ascending, descending or interleaved.
        % If slice order is descending or interleaved, the slice number
        % must be adjusted to represent the time at which the slice of
        % interest was acquired:
        sliceorder='descending'; % ALLEGRA efov ROUTINE sequence is descending order
        slicenum=get_slicenum(slicenum,nslices,sliceorder);
        
        % The channel numbers must be assigned as they have been in spike.
        % Unused channels should be set to empty using [];
        % The channel numbers can be checked using the routines
        % show_channels and check_channels as demonstrated below.
        % Once the channels have been set correctly, they should
        % stay the same when using spike with the same set-up and
        % configuration file.
        
        show_channels(physiofile);
        scanner_channel=1;
        cardiacTTL_channel=2;
        cardiacQRS_channel=[];
        resp_channel=4;
        check_channels(physiofile,scanner_channel,cardiacTTL_channel,cardiacQRS_channel,resp_channel);
        
        % Call the main routine for calculating physio regressors
        % NB - currently the cardiacqrs calculation is disabled.
        [cardiac,cardiacqrs,respire,rvt,the_params]=make_physio_regressors_DK(physiofile,nslices,ndummies,TR,...
            slicenum,nsessions,scanner_channel,cardiacTTL_channel,cardiacQRS_channel,resp_channel);
        
        nsessions=the_params.total_nsessions;
        real_sess_ind=the_params.real_sess_ind;
        
        
        
        % Save a record of parameters used for the regressors
        %eval(['save ' spm_str_manip(physiofile,'r') '_physioparams physiofile nslices ndummies TRms slicenum nsessions']);
        filename=[spm_str_manip(physiofile,'r'), '_physioparams'];
        save(filename, 'physiofile', 'nslices', 'ndummies', 'TRms','slicenum','nsessions','sliceorder');
        
        % Save a record of parameters used for the regressors
        %eval(['save ' spm_str_manip(physiofile,'r') '_physioparams physiofile nslices ndummies TRms slicenum nsessions']);
        filename=[spm_str_manip(physiofile,'r'), '_physioparams'];
        save(filename, 'physiofile', 'nslices', 'ndummies', 'TRms','slicenum','nsessions','sliceorder');
        
        % For each session, put regressors in a matrix called R.
        % Each individual set of regressors are saved and also all regressors are saved with the name 'physiofile_R_session%d'.
        % These files can be loaded into an SPM design matrix using the 'Multiple Regressors' option.
        % NB motion parameters can also be concatenated with the physio regressors
        % and saved as a set of regressors called R (see below for example)
        
        for tmp_sessnum=1:length(real_sess_ind)
            sessnum=real_sess_ind(tmp_sessnum); %i.e. actual number of a real session
            new_sessnum=tmp_sessnum; %i.e. session number to save stuff as.
            R=[];
            if ~isempty(cardiac{sessnum}) & ~isempty(cardiac{sessnum})
                cardiac_sess = cardiac{sessnum};
                filename = sprintf('%s_cardiac_session%d',spm_str_manip(physiofile,'r'),sessnum);
                %save(filename, 'cardiac_sess');
                R=cat(2,R,cardiac{sessnum});
            end
            if ~isempty(cardiacqrs{sessnum}) & ~isempty(cardiacqrs{sessnum})
                cardiacqrs_sess = cardiacqrs{sessnum};
                filename = sprintf('%s_cardiacqrs_session%d',spm_str_manip(physiofile,'r'),sessnum);
                %save(filename, 'cardiacqrs_sess');
                R=cat(2,R,cardiacqrs{sessnum}(:,1:6));
            end
            if ~isempty(respire) & ~isempty(respire{sessnum})
                respire_sess = respire{sessnum};
                filename = sprintf('%s_respire_session%d',spm_str_manip(physiofile,'r'),sessnum);
                %save(filename, 'respire_sess');
                R=cat(2,R,respire{sessnum}(:,1:6));
            end
            if ~isempty(rvt) & ~isempty(rvt{sessnum})
                rvt_sess = rvt{sessnum};
                filename = sprintf('%s_rvt_session%d',spm_str_manip(physiofile,'r'),sessnum);
                %save(filename,'rvt_sess');
                R=cat(2,R,rvt{sessnum}(:,1:size(rvt{sessnum},2)));
            end
            nfiles=size(R,1);
            % Save R for all physio only
            if task==2 %i.e. EVAL
                if curr_sub==1
                    n_realstart_vol=7; %used just before saving R below : i.e. first REAL VOLUME
                    n_reallast_vol=367; %i.e. last volume to be used.
                elseif curr_sub==2 && new_sessnum==1
                    n_realstart_vol=7; %used just before saving R below : i.e. first REAL VOLUME
                    n_reallast_vol=367; %i.e. last volume to be used.
                elseif curr_sub==2 && new_sessnum==2
                    n_realstart_vol=7; %used just before saving R below : i.e. first REAL VOLUME
                    n_reallast_vol=286; %i.e. last volume to be used.
                else
                    n_realstart_vol=7; %used just before saving R below : i.e. first REAL VOLUME
                    n_reallast_vol=399; %i.e. last volume to be used.
                end
            end
            
            if nfiles>0
                oR=R;
                Rname = sprintf('%s_R_session%d',spm_str_manip(physiofile,'r'),new_sessnum);
                R=R-repmat(mean(R),nfiles,1);
                
                cd(dir_save_spike)
                
                
                
                %discount dummies and last few scans
                %R=R(n_dummies+1:n_reallast_vol,:); %IGNORE THIS BIT (april 2013)
                R=R;
                
                
                    all_sub_spike_data(curr_sub).sess(new_sessnum).spike_data=R;
                
               
                save(Rname, 'R');
            end
            
        end
    end %sess
end% sub

all_sub_spike_data