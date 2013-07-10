% % SCRIPT feb13
% % MODIFIED: APR2013 AAR
 
%now doing oneback

clear all
play_var=0; %if play_var=1 use stupid line which is to skip problem with number of extra contrast need to delete



%curr_task=input('enter 1 for learn task, and 2 for categ task:         ')
spm fMRI



curr_task=1; %1= oneback
switch curr_task
    case 1
        task_prfx='reward';

end

sess_prfx   = 'sess';
fs          = filesep; %file sep

dir_start    = '/Volumes/SAMSUNG/mvpa';
dir_base    = '/Volumes/SAMSUNG/mvpa/functional';%'/Users/dharshan/Documents/SELF_FMRI_data/functional';
%dir_behav=['/Users/' my_name '/Documents/Reward_FMRI_2013/analysis'];%'/Users/dharshan/Documents/SELF_FMRI_data/analysis/sub_data';

%SPECIFY WHAT THINGS TO DO: q
quick_test_var = 0; %1 is a test (i.e. just for subject 1). 0 for full run of all subjects 1:n

%curr_sub_ind = [7, 10, 20] ; % %CURRENT NUMBER OF SUBJECTS
curr_sub_ind = 1:21 ; % %CURRENT NUMBER OF SUBJECTS

disp(curr_sub_ind);

analy_ind = 1; %DEFINE EVEN FOR BATCH indices of analyses to run for FIRST LEVEL
analy_rfx_ind = 0; %DEFINE FOR BATCH for RFX analysis
%THIS SECTION IS USED IF RUNNING MULTIPLE MATLABS i.e specify subjects to
%run on this MATLAB, and which analyses (best to run separate subjects on
%different matlabs)
batch_sub_ind=[]; %define this if running a batch analysis across Multiple matlabs
batch_analy=[];  %set this to same as analy_ind (defined above) if running batch (can specify as [4 5])

run_des_mx_var      = 1;
run_estimate_var    = 1;
run_contrasts_var   = 0;
run_rfx_var         = 0;

run_EXTRA_contrasts_var = 0;
email_var=0;
%%%%%%%%%

param=([]);
param.fs=fs;
param.dir_base=dir_base;
param.dir_start=dir_start;
param.task_prfx=task_prfx;

%load relevant files (containing behav data, spike, movt)
if strcmp(task_prfx,'reward')
    load 'sub_stuff_R_ENC_v3.mat'; %has all SUBJECTS inside
    param.num_sess=2;
elseif strcmp(task_prfx,'one_back')
    load sub_stuff_R_ONEBACK_v1.mat %MISSING SUBs 1 and 2 (who need onsets created)
    param.num_sess=5; %number of sessions
end



%FIRST LEVEL DESIGN MATRIX
if run_des_mx_var==1;
    
    for q=1:length(analy_ind)
        analy=analy_ind(q);
        param.analy=analy;
        disp(['!!!!!!!!!!!!! Current analysis: ' num2str(analy)])
        
        %Specify SUBJECTS
        if quick_test_var==1 %i.e. test run
            sub_ind=1;
        elseif ismember(analy,batch_analy)
            sub_ind=batch_sub_ind;
            
        else %GENERAL subject index
            sub_ind=curr_sub_ind;
        end
        %%%
        
        for j=1:length(sub_ind)
            curr_sub=sub_ind(j);
            disp(['!!!!!!!!!!!!! Current subject: ' num2str(curr_sub)])
            param.curr_sub=curr_sub;
            
            %create and go to relevant directory
            spm_mat_Dir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs 'analysis' fs num2str(analy)]; %new_ to distinguish from June analyses
            mkdir(spm_mat_Dir); %makes this Directory
            cd(spm_mat_Dir) ; % so that SPM.mat ends up in subject dir
            
            %specify and execute create design matrix file
            des_mx_file=['mk_des_mx_' task_prfx '_analy_' num2str(analy) '_preproc']; %name of relevant design matrix function
            feval(des_mx_file,all_sub,param); %execute function
            
            %print to screen
            fprintf('Just finished design matrix for subject %d in analysis %d',curr_sub,analy);
            
        end %subject
    end %analysis number
    
else
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%ESTIMATE
if email_var==1
    param.mail_text='first level desmx done for all analyses!';
    [param]=send_gmail(param);
else
end

if run_estimate_var==1
    clear sub_ind
    
    for q=1:length(analy_ind)
        analy=analy_ind(q);
        disp(['!!!!!!!!!!!!! Current analysis: ' num2str(analy)])
        param.analy=analy;
        %Specify SUBJECTS
        if quick_test_var==1
            sub_ind=1;
        elseif ismember(analy,batch_analy)
            sub_ind=batch_sub_ind;
            
        else %GENERAL subject index
            sub_ind=curr_sub_ind;
        end
        
        for j=1:length(sub_ind)
            curr_sub=sub_ind(j);
            disp(['!!!!!!!!!!!!! Current subject: ' num2str(curr_sub)])
            param.curr_sub=curr_sub;
            
            param.curr_sub=curr_sub;
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %ESTIMATE
            spm_mat_Dir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs 'analysis' fs num2str(analy)];
            cd(spm_mat_Dir) ; % so that SPM.mat ends up in subject dir
            clear SPM
            load SPM
            SPM=spm_spm(SPM); %do the beta estimates
            fprintf('Just finished estimating for subject %d in analysis %d',curr_sub,analy)
            
            
        end
    end
end

if email_var==1
    param.mail_text='first level estimation done for all analyses and subjects!';
    [param]=send_gmail(param);
else
end



if run_contrasts_var==1
    
    clear sub_ind
    
    for q=1:length(analy_ind)
        analy=analy_ind(q);
        disp(['!!!!!!!!!!!!! Current analysis: ' num2str(analy)])
        param.analy=analy;
        %Specify SUBJECTS
        %Specify SUBJECTS
        if quick_test_var==1
            sub_ind=1;
        elseif ismember(analy,batch_analy)
            sub_ind=batch_sub_ind;
            
        else %GENERAL subject index
             sub_ind=curr_sub_ind;
        end
        
        for j=1:length(sub_ind)
            curr_sub=sub_ind(j);
            disp(['!!!!!!!!!!!!! Current subject: ' num2str(curr_sub)])
            param.curr_sub=curr_sub;
            param.curr_sub_group=all_sub(curr_sub).group; %SUBJECT GROUP *** (needed to specify chair etc contrasts)
            
            
            param.curr_sub=curr_sub;
            spm_mat_Dir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs 'analysis' fs num2str(analy)];
            cd(spm_mat_Dir) ; % so that SPM.mat ends up in subject dir
            clear SPM
            load SPM
            
            %set up contrasts ready to go
            con_setup_file=['run_contrasts_' task_prfx '_analy_' num2str(analy)]; %name of relevant design matrix function
            [param]=feval(con_setup_file,param); %this creates contrasts in param.all_contrasts (vectors) and param.all_con_names
            
            %enter contrasts into SPM structure
            for w=1:size(param.all_contrasts,1) %number contrasts
                c=param.all_contrasts(w,:);
                cname=param.all_con_names{w};
                if w==1 %first contrast
                    SPM.xCon  = spm_FcUtil('Set',cname,'T','c',c(:),SPM.xX.xKXs);
                else %all other contrasts
                    SPM.xCon(end+1)  = spm_FcUtil('Set',cname,'T','c',c(:),SPM.xX.xKXs);
                end
            end
            
            %save contrast names
            tmp_dir=[dir_start fs 'analysis' fs task_prfx  '_specific' fs 'contrast_names_files']; %changed directory structure
            cd(tmp_dir);
            tmp_file=['contrast_names_' task_prfx '_analy_' num2str(analy)];
            save(tmp_file,'param')
            %run contrasts
            spm_contrasts(SPM);
            
            
        end %subs
        
    end %analysis
    
end  %if

if email_var==1
    param.mail_text='first level contrasts done for all analyses and subjects!';
    [param]=send_gmail(param);
else
end

if run_EXTRA_contrasts_var==1
    
    clear sub_ind
    
    for q=1:length(analy_ind)
        analy=analy_ind(q);
        disp(['!!!!!!!!!!!!! Current analysis: ' num2str(analy)])
        param.analy=analy;
        %Specify SUBJECTS
        %Specify SUBJECTS
        if quick_test_var==1
            sub_ind=1;
        elseif ismember(analy,batch_analy)
            sub_ind=batch_sub_ind;
            
        else %GENERAL subject index
            sub_ind=curr_sub_ind;
        end
        
        for j=1:length(sub_ind)
            curr_sub=sub_ind(j);
            disp(['!!!!!!!!!!!!! Current subject: ' num2str(curr_sub)])
            param.curr_sub=curr_sub;
            
            param.curr_sub=curr_sub;
            
            param.curr_sub_group=all_sub(curr_sub).group; %SUBJECT GROUP *** (needed to specify chair etc contrasts)
            
            spm_mat_Dir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs 'analysis' fs num2str(analy)];
            cd(spm_mat_Dir) ; % so that SPM.mat ends up in subject dir
            clear SPM
            load SPM
            
            %load saved file with existing contrasts and contrast names
            tmp_dir=[dir_start fs 'analysis' fs task_prfx '_specific' fs 'contrast_names_files']; %changed directory structure
            cd(tmp_dir);
            tmp_file=['contrast_names_' task_prfx '_analy_' num2str(analy)];
            load(tmp_file)
            
            
            %determine number of existing contrasts
            num_exist_contrasts=size(param.all_contrasts,1);
            param.num_exist_contrasts=num_exist_contrasts;
            
            %set up extra contrasts
            con_setup_file=['run_EXTRA_contrasts_' task_prfx '_analy_' num2str(analy)]; %name of relevant design matrix function
            [param]=feval(con_setup_file,param); %this creates contrasts in param.all_contrasts (vectors) and param.all_con_names
            
            %number of new contrasts (determined by function above)
            %DETERMINE NUMBER OF NEW ADDED CONTRASTS
            num_total_contrasts=size(param.all_contrasts,1);
            num_new_contrasts=num_total_contrasts-num_exist_contrasts; %i.e. number of EXTRA contrasts
            param.num_new_contrasts=num_new_contrasts;
            
            
            %enter contrasts into SPM structure USE OF PLAY VARIABLE!
            for w=1:num_new_contrasts %number contrasts
                if play_var==1
                    
                
                c=param.all_contrasts(17+w,:);
                cname=param.all_con_names{18+w};
                SPM.xCon(end+1)  = spm_FcUtil('Set',cname,'T','c',c(:),SPM.xX.xKXs);
                else
                    
                     c=param.all_contrasts(num_exist_contrasts+w,:);
                cname=param.all_con_names{num_exist_contrasts+w};
                SPM.xCon(end+1)  = spm_FcUtil('Set',cname,'T','c',c(:),SPM.xX.xKXs);
                end
                
                
                
                
            end
            
            
            
            %run contrasts
            spm_contrasts(SPM);
            
            if curr_sub==sub_ind(1); %i.e. only for first subject
                %save file
                cd(tmp_dir);
                tmp_file=['contrast_names_' task_prfx '_analy_' num2str(analy)];
                save(tmp_file,'param')
            end
        end %subs
        
    end %analysis
    
end  %if




%%RFX Stage
if run_rfx_var==1
    %clear sub_ind
    
    for q=1:length(analy_rfx_ind)
        analy_rfx=analy_rfx_ind(q);
        param.analy_rfx=analy_rfx;
        
        if  analy_rfx==300 || analy_rfx==222%exception
            %sub_ind=[2:6 8:17 20:24 26]; %
            sub_ind=[1:3 5:18 20:23 25:29]; %
            num_subs=length(sub_ind);
            
            
            analy=3; %i.e. RFX number is the same as the 1st level analysis number
            
            tmp_dir=[dir_start fs 'analysis' fs task_prfx '_specific' fs 'contrast_names_files']; %changed directory structure
            cd(tmp_dir);
            tmp_file=['contrast_names_' task_prfx '_analy_' num2str(analy)];
            load(tmp_file);
            num_contrasts=1; %i.e. number of columns!
            contrast_numbers=[14];
           
              %num_contrasts=1;%size(param.all_con_names,2); %i.e. number of columns!
            %contrast_numbers=[29];
            
            
            
        %NORMAL MODE  
        else
            %sub_ind=[1:7 9 11:15 17:19];
            analy=analy_rfx; %i.e. RFX number is the same as the 1st level analysis number
            
            tmp_dir=[dir_start fs 'analysis' fs task_prfx '_specific' fs 'contrast_names_files']; %changed directory structure
            cd(tmp_dir);
            tmp_file=['contrast_names_' task_prfx '_analy_' num2str(analy)];
            load(tmp_file);
            num_contrasts=size(param.all_con_names,2); %i.e. number of columns!
            contrast_numbers=[1:num_contrasts];
        end
        
        spm fMRI
        spm_defaults
        global defaults
        
        defaults.modality='FMRI';
        
        exp_masking = 0;                           % explict masking yes(1) or no (0)? %CHANGE
        num_subs=length(sub_ind);
        ncont=length(contrast_numbers);
        
        
        for i=1:num_contrasts %ie LOOP FOR EACH CONTRAST (ie con image)
            cont = contrast_numbers(i); %ie cont is NUMBER (ie file number) of each Con image for that contrast
            conn = param.all_con_names{cont}; %ie conn is NAME Of contrast
            
            clear SPM
            RFX_dir = [dir_base fs task_prfx fs 'RFX' fs num2str(analy_rfx) fs conn];
            mkdir(RFX_dir); %makes this Directory
            cd(RFX_dir); %goes to this directory
            
            %-Assemble SPM structure
            %=======================================================================
            SPM.swd=RFX_dir;       %SPM.swd is directory it is working in
            SPM.nscan = num_subs;
            
            for s=1:num_subs %num_subs =number of subjects
                curr_sub = sub_ind(s); %select subject number
                
                if strcmp(task_prfx,'reward')
                    
                    
                    SPM.xY.P{s}=[dir_start sprintf('/functional/s%d/reward/analysis/%d/con_%04d.img',curr_sub,analy,cont)];
                        %sprintf('/Users/dharshan/Documents/SELF_FMRI_data/functional/s%d/learn/analysis/%d/con_%04d.img',curr_sub,analy,cont);
                    
                elseif strcmp(task_prfx,'***')
                    
                    SPM.xY.P{s}=[dir_start sprintf('/functional/s%d/categ/analysis/%d/con_%04d.img',curr_sub,analy,cont)];
                    %sprintf('/Users/dharshan/Documents/SELF_FMRI_data/functional/s%d/categ/analysis/%d/con_%04d.img',curr_sub,analy,cont);
                    
                end
                
                SPM.xY.VY(s) = spm_vol(SPM.xY.P{s});
            end
            %======================================================
            SPM.xX = struct( 'X', ones(num_subs,1),...                             %SPM.xX=design matrix
                'iH',1,'iC',zeros(1,0),'iB',zeros(1,0),'iG',zeros(1,0),...
                'name',{{'mean'}},'I',[[1:num_subs]' ones(num_subs,3)],...
                'sF',{{'obs' '' '' ''}});
            
            SPM.xC = [];
            
            SPM.xGX = struct(...
                'iGXcalc',1,    'sGXcalc','omit',       'rg',[],...
                'iGMsca',9,     'sGMsca','<no grand Mean scaling>',...
                'GM',0,         'gSF',ones(num_subs,1),...
                'iGC',  12,     'sGC',  '(redundant: not doing  AnCova)', 'gc',[],...
                'iGloNorm',9,   'sGloNorm','<no global normalisation>');
            
            SPM.xVi     = struct('iid',1,'V',speye(num_subs)); %speye forms M by N sparse matrix   % to do with correction for NON SPHERICITY (i think)
            
            
            % no masking, replace em by 'No'
            
            Mdes        = struct(...
                'Analysis_threshold', {'None (-Inf)'},...
                'Implicit_masking',   {'Yes: NaNs treated as missing'},...
                'Explicit_masking',   'No'...
                );
            
            %For masking
            %Mdes.Explicit_masking={'Yes: mask images :''/Brigitte/Sparse_imaging/secondlevel/mask_all.img'};
            
            %VM = spm_vol('/Brigitte/Sparse_imaging/secondlevel/mask_all.img');
            
            if exp_masking == 1 %defined as 0 at top
                Mdes.Explicit_masking   =   {'Yes: mask images :', maskima};
                VM=spm_vol(maskima);
            end
            
            
            
            
            SPM.xM      = struct(...
                'T',-Inf,...
                'TH',ones(num_subs,1)*-Inf,...
                'I',1,...
                'VM',[],...
                'xs',Mdes ...
                );
            
            if exp_masking == 1
                SPM.xM.VM = VM;
            end
            Pdes        = {{'1 condition, +0 covariate, +0 block, +0 nuisance'; '1 total, having 1 degrees of freedom'; ['leaving ' num2str(num_subs - 1) ' degrees of freedom from ' num2str(num_subs) ' images']}};
            
            
            SPM.xsDes = struct( 'Design', {'One sample t-test'},...
                'Global_calculation',   {'omit'},...
                'Grand_mean_scaling',   {'<no grand Mean scaling>'},...
                'Global_normalisation', {'<no global normalisation>'},...
                'Parameters', Pdes);
            
            SPM.SPMid   = 'SPM2: spm_spm_ui (v2.49)';
            
            % Estimate parameters
            %===========================================================================
            SPM = spm_spm(SPM);
            
            % Contrasts
            %======================================================================
            xCon = spm_FcUtil('Set',conn,'T','c',[1],SPM.xX.xKXs);
            SPM.xCon=xCon;
            SPM.xCon(end+1) = spm_FcUtil('Set',sprintf('-%s',conn),'T','c',[-1],SPM.xX.xKXs);
            
            spm_contrasts(SPM);
            cd(RFX_dir)
            
        end
        
    end
else
end



