clear all
spm fmri


%% DEFINE SCRIPT PARAMETERS

dir_base                = '/Volumes/SAMSUNG/mvpa/functional';
sess_prfx               = 'sess';
struct_FM_prfx          = 'one_back'; %DIRECTORY prefix where structural and FM folders are


all_subjects            = 1:21;

sub_ind_tbr_con         = all_subjects;
sub_ind_fieldmap        = all_subjects;
sub_ind_realign         = all_subjects;
sub_ind_coregister      = all_subjects;
sub_ind_segment_struct  = all_subjects;
sub_ind_normalise_EPI   = all_subjects;
sub_ind_normalise_struct= all_subjects;
sub_ind_smoothing       = all_subjects;

fs                      = filesep; %file sep
sendmail                = 0;

%% SET VARIABLES FOR THE CURRENT TASK

for curr_task = 1
    switch curr_task
        case 1
            task_prfx='one_back';
            
            %%% Define what processing we want!
            % note that obv don't need to repeat FIELDMAP (created using fMS
            % functional images before realign step) OR STRUCTURAL processing
            % (i.e. to repeat functional: do TBR/REALIGN/COREG/NORM_EPI/SMOOTH.
            
            tbr_con         = 0; % no TBR CON FOR QUATTRO!!!
            fieldmap        = 0;
            realign         = 0;
            coregister      = 0; % match EPI to struct SMA image
            %segment_EPI    = 1;
            segment_struct  = 0; %
            normalise_EPI   = 0; % using segmented structural
            normalise_struct= 0; %
            smoothing       = 1;
    end
end

%% PROCESS EXCEPTION SUBJECTS
param=([]);
if strcmp(task_prfx,'one_back')
    num_sessions=5;
    %%%%%%%%%%%%%%%%%%%
    
    %LIST OF WHICH FMs relate to WHICH SESSIONS
    list_ex_subs=[]; %list of exception subs (i.e. with 2 fieldmaps)
    
    ex_subs=([]);
    %     ex_subs(7).fm_1.ind=1:2; %i.e. for sub 1, fieldmap 1 matches to sessions 1 and 2
    %     ex_subs(7).fm_2.ind=3;
    %
    %     ex_subs(15).fm_1.ind=1:2; %i.e. for sub 7, fieldmap 1 matches to sessions 1 and 2
    %     ex_subs(15).fm_2.ind=3;
    %
    %     ex_subs(17).fm_1.ind=1:2; %i.e. for sub 7, fieldmap 1 matches to sessions 1 and 2
    %     ex_subs(17).fm_2.ind=3;
    %
    
    %%%%%%
    
elseif strcmp(task_prfx,'*****')
    num_sessions=1;
    %%%%%%%%%%%%%%%%%%%
    
    %LIST OF WHICH FMs relate to WHICH SESSIONS
    list_ex_subs=[]; %list of exception subs
    ex_subs=([]);
    
end


%% DO FUNCTIONAL RECONSTRUCTION
sub_ind=sub_ind_tbr_con;
num_subs=length(sub_ind);

if tbr_con 
    disp('doing TBR reconstr ');
    for k=1:num_subs
        curr_sub=sub_ind(k);
        
        for curr_sess=1:num_sessions
            
            scanDir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs sess_prfx num2str(curr_sess) fs 'PROC'];
            
            [f,d]=spm_select('List',scanDir,'.bz2');
            
            % scanDir2 = [dir_base fs 's' num2str(curr_sub) fs 'learn' fs sess_prfx num2str(curr_sess) fs 'PROC' fs d(2,:)];
            %[dir_base fs name_subj{s0} fs sess_prfx num2str(sess) fs d(2,:)];
            
            %f=spm_select('List',scanDir2,'.*');
            files=cellstr([repmat([scanDir   fs ],size(f,1),1) f]);
            
            matlabbatch{1}.spm.tools.tbr.data = files;
            matlabbatch{1}.spm.tools.tbr.traj = {'/Users/dharshan/Documents/spm8/toolbox/TBR/trajectories/traj_allegra_64x64_theoretical_2008-02-25_19-00.mat'};
            matlabbatch{1}.spm.tools.tbr.params.npar_phase = 72;
            matlabbatch{1}.spm.tools.tbr.params.resol_phase = 3;
            matlabbatch{1}.spm.tools.tbr.params.smooth_par =4;
            matlabbatch{1}.spm.tools.tbr.outdir = {scanDir};
            matlabbatch{1}.spm.tools.tbr.outfilestem = '';
            
            disp(['reconstructing images for subject: ** TASK ',curr_sub,'session_',num2str(curr_sess)])
            spm_jobman('run',matlabbatch);
            clear matlabbatch
        end
    end
end

%% GENERATE FIELDMAPS
sub_ind=sub_ind_fieldmap;
num_subs=length(sub_ind);
if fieldmap
    disp('Generating fieldmaps ');
    
    for k=1:num_subs
        curr_sub=sub_ind(k);
        
        %determine is subject is preproc exception subject
        if ismember(curr_sub,list_ex_subs)
            sub_ex_var=1; %exception
        else
            sub_ex_var=0;
        end
        %%%%%%%%%%%%%%%%%%%%
        
        disp(['Generating filedmaps for Subject : ', num2str(curr_sub)]);
        
        %structural (just for display) JUST COMMENTED
        %structDir = [dir_base fs 's' num2str(curr_sub) fs 'eval' fs 'struct' fs 'PROC'];
        %fa   = spm_select('List', structDir, '^SMA.*nii' );%
        %AnatImage=cellstr([repmat([structDir   fs ],size(fa,1),1) fa]);
        AnatImage='';
        %SESSIONS
        for curr_sess = 1:num_sessions % if for all sessions seperate FMs than us -> 1:n_sess
            scanDir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs sess_prfx num2str(curr_sess) fs 'PROC'];
            
            %select EPI file to match VDM to
            f   = spm_select('List', scanDir, '^fM*.*000007-01.nii' );
            EPIfiles  = cellstr([repmat([scanDir   fs ],size(f,1),1) f]);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%
            %get relevant fieldmap
            if sub_ex_var==1 %exception subject
                
                if ismember(curr_sess,ex_subs(curr_sub).fm_1.ind) %current session should be matched to FM pair 1
                    fmDir =[dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'FM' fs 'iter1' fs 'PROC'];
                elseif ismember(curr_sess,ex_subs(curr_sub).fm_2.ind) %current session should be matched to FM pair 2
                    fmDir =[dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'FM' fs 'iter2'];
                end
            else
                fmDir =[dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'FM'  fs 'iter1' fs 'PROC'];  %FM directory (note this will need to change for ITER2 subjects)
            end
            %%%%%%%%%%%%%%%%%%%%%
            af   = spm_select('List', fmDir, '^sM.*' ); %
            fp   = af(6,:); %phase image- happens to be 6th item in af list - check this is always the case
            phImage=cellstr([repmat([fmDir   fs ],size(fp,1),1) fp]);
            fm   = af(2,:); %the first mag image is 2nd in the list
            MagImage=cellstr([repmat([fmDir   fs ],size(fm,1),1) fm]);
            %%%%%%%%%%%%
            matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.phase = phImage;
            matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.magnitude = MagImage;
            
            
            matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsfile = {'/Users/dharshan/Documents/spm8/toolbox/FieldMap/pm_defaults_Trio_eFoV_96.m'};%{'C:\SPM8\toolbox\FieldMap\pm_defaults_Allegra_128.m'};
            matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.session.epi = EPIfiles;
            matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.matchvdm = 1;
            matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.sessname = 'session';
            matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.writeunwarped = 0;
            matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.anat = {AnatImage};
            matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.matchanat = 0;
            
            disp(['RUNNING field_maps ' num2str(curr_sub)]);
            spm_jobman('run',matlabbatch);
            
            
            %save session specific vdm file to new folder
            mkdir(fmDir,strcat('vdm_sess',num2str(curr_sess))); %make directory
            v1  = spm_select('List', fmDir, '^vdm.*' );%get names (as characters)
            vdm_images=cellstr([repmat([fmDir   fs ],size(v1,1),1) v1]); %convert to cell array
            vdmDir=strcat(fmDir,strcat('/vdm_sess',num2str(curr_sess))); %vdm dir for current session
            movefile(vdm_images{1},vdmDir); %move vdm file to new directory
            movefile(vdm_images{2},vdmDir); %move vdm file to new directory
            
            
            clear matlabbatch
            
            %
            if k==1 && sendmail==1
                param.curr_time=clock; %get current time
                param.mail_text=strcat('1st sub fieldmap:  ',num2str(param.curr_time));
                [param]=send_gmail(param);
            end
            
        end
    end
end


%% REALIGN
sub_ind=sub_ind_realign;
num_subs=length(sub_ind);
if realign
    disp('Realign: Realignment & UnWarp for MEAN and ALL images ');
    
    for k=1:num_subs
        curr_sub=sub_ind(k);
        
        disp(['Generating filedmaps for Subject : ', num2str(curr_sub)]);
        
        %determine is subject is preproc exception subject
        if ismember(curr_sub,list_ex_subs)
            sub_ex_var=1; %exception
        else
            sub_ex_var=0;
        end
        %%%%%%%%%%%%%%%%%%%%
        
        
        %fmDir =[dir_base fs 's' num2str(curr_sub) fs 'learn' fs 'FM'  fs 'iter1' fs 'PROC'];
        
        for curr_sess = 1:num_sessions %
            scanDir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs sess_prfx num2str(curr_sess) fs 'PROC'];
            
            
            f   = spm_select('List', scanDir, '^fM*.*nii');
            files  = cellstr([repmat([scanDir   fs ],size(f,1),1) f]);
            matlabbatch{1}.spm.spatial.realignunwarp.data(curr_sess).scans = files;
            % clear temporary variables for next run
            f = []; files = [];
            
            %get relevant vdm map (which is stored in separate iter
            %directory if more than one fieldmap)
            if sub_ex_var==1 %exception subject
                
                if ismember(curr_sess,ex_subs(curr_sub).fm_1.ind) %vdm file is in iter1 directory
                    vdmDir =[dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'FM' fs 'iter1' fs 'PROC' fs 'vdm_sess' num2str(curr_sess)];
                elseif ismember(curr_sess,ex_subs(curr_sub).fm_2.ind) %vdm file in iter2 dir
                    vdmDir =[dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'FM' fs 'iter2' fs 'vdm_sess' num2str(curr_sess)];
                end
            else
                vdmDir =[dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'FM'  fs 'iter1' fs 'PROC'];  %FM directory (note this will need to change for ITER2 subjects)
            end
            
            %%%%%%%%%%%%%%%%%
            
            
            fvdm5   = spm_select('List', vdmDir, '^vdm5*.*01.nii'  );
            vdm5Image = cellstr([repmat([vdmDir   fs ],size(fvdm5,1),1) fvdm5]);
            
            matlabbatch{1}.spm.spatial.realignunwarp.data(curr_sess).pmscan = vdm5Image;   % Note address the cell first with {}, then the structure with (), then put in cell... confusing!
        end
        
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.quality = 1;
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.sep = 4;
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm = 0;
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.einterp = 2;
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.ewrap = [0 1 0];
        matlabbatch{1}.spm.spatial.realignunwarp.eoptions.weight = {''};
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.jm = 0;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.sot = 1;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.rem = 1;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.noi = 5;
        matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
        matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
        matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
        matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.wrap = [0 1 0];
        matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.mask = 1;
        matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
        
        
        spm_jobman('run' , matlabbatch);
        clear matlabbatch
        
        %
        if k==1 && sendmail==1
            param.curr_time=clock; %get current time
            param.mail_text=strcat('1st sub realigned:  ',num2str(param.curr_time));
            [param]=send_gmail(param);
        end
        
    end
end


%% COREGISTER
sub_ind=sub_ind_coregister;
num_subs=length(sub_ind);
if coregister
    disp('Coregister: Estimate structural (change postition file (.hdr) to match postition of Structural)');
    % %
    for k=1:num_subs
        curr_sub=sub_ind(k);
        
        disp(['CoRegister for Subject : ', num2str(curr_sub)]);
        
        %structural
        structDir = [dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'struct' fs 'PROC'];
        fa   = spm_select('List', structDir, '^sMQ.*nii' );%
        refImage=cellstr([repmat([structDir   fs ],size(fa,1),1) fa]);
        
        matlabbatch{1}.spm.spatial.coreg.estimate.ref = refImage;%{refImage,'1'};
        
        %Source image (mean first functional session)
        sourceDir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs sess_prfx '1' fs 'PROC'];%i.e. USE first session MEAN
        disp(sourceDir)
        fmean  = spm_select('List', sourceDir, '^mean.*\.nii$');
        disp(fmean)
        
        sourceImage=cellstr([repmat([sourceDir   fs ],size(fmean,1),1) fmean]);
        
        
        matlabbatch{1}.spm.spatial.coreg.estimate.source = sourceImage;%{sourceImage,'1'};
        
        % then specify other image, all EPIs and CONCATENATE into one lot
        % (i.e. different from realign etc)
        otherImages=[];
        f=[];
        
        for curr_sess = 1:num_sessions %
            scanDir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs sess_prfx num2str(curr_sess) fs 'PROC'];
            f   = spm_select('List', scanDir, '^rfMQ*.*nii');
            otherImages  = [otherImages; cellstr([repmat([scanDir   fs ],size(f,1),1) f])]; %i.e. concatenate all images into one lot
        end
        
        matlabbatch{1}.spm.spatial.coreg.estimate.other = otherImages;
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
        
        
        spm_jobman('run' , matlabbatch);
        clear matlabbatch
        
        %
        if k==1 && sendmail==1
            param.curr_time=clock; %get current time
            param.mail_text=strcat('1st sub coregistered:  ',num2str(param.curr_time));
            [param]=send_gmail(param);
        end
        
        
        
        
    end
end



%% SEGMENT
%note that one can use either struct or EPI
%this writes out an seg_sn.mat file in struct directory for use in
%normalization
sub_ind=sub_ind_segment_struct;

num_subs=length(sub_ind);

if segment_struct
    disp('Segmentation: Produce gray matter (native & modulated normalized) & white matter (native) from structural image');
    for k=1:num_subs
        curr_sub=sub_ind(k);
        
        disp(['CoRegister for Subject : ', num2str(curr_sub)]);
        
        %structural
        structDir = [dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'struct' fs 'PROC'];
        fa   = spm_select('List', structDir, '^sMQ.*nii' );%
        stFile=cellstr([repmat([structDir   fs ],size(fa,1),1) fa]);
        
        %defaults (copied from batch viewer)
        matlabbatch{1}.spm.spatial.preproc.data = stFile;%{'/Users/dharshan/Documents/TINF_FMRI_data/functional/s5/eval/struct/sMA07745-0008-00001-000176-00.nii,1'};
        matlabbatch{1}.spm.spatial.preproc.output.GM = [0 0 1];
        matlabbatch{1}.spm.spatial.preproc.output.WM = [0 0 1];
        matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 0];
        matlabbatch{1}.spm.spatial.preproc.output.biascor = 1;
        matlabbatch{1}.spm.spatial.preproc.output.cleanup = 0;
        matlabbatch{1}.spm.spatial.preproc.opts.tpm = {
            '/Users/andreirusu/software/spm8/tpm/grey.nii'
            '/Users/andreirusu/software/spm8/tpm/white.nii'
            '/Users/andreirusu/software/spm8/tpm/csf.nii'
            };
        matlabbatch{1}.spm.spatial.preproc.opts.ngaus = [2
            2
            2
            4];
        matlabbatch{1}.spm.spatial.preproc.opts.regtype = 'mni';
        matlabbatch{1}.spm.spatial.preproc.opts.warpreg = 1;
        matlabbatch{1}.spm.spatial.preproc.opts.warpco = 25;
        matlabbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;
        matlabbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;
        matlabbatch{1}.spm.spatial.preproc.opts.samp = 3;
        matlabbatch{1}.spm.spatial.preproc.opts.msk = {''};
        
        
        
        spm_jobman('run',matlabbatch);
        clear matlabbatch
        
        %
        if k==1 && sendmail==1
            param.curr_time=clock; %get current time
            param.mail_text=strcat('1st sub struct segmented:  ',num2str(param.curr_time));
            [param]=send_gmail(param);
        end
        
        
    end
end



%% NORMALIZE
sub_ind=sub_ind_normalise_EPI;
num_subs=length(sub_ind);
if normalise_EPI
    disp(['Normalizing EPI ... ']);
    
    for k=1:num_subs
        curr_sub=sub_ind(k);
        
        disp(['Normalizing for Subject : ', num2str(curr_sub)]);
        
        %take parameters generated from struct segmentation
        structDir = [dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'struct' fs 'PROC'];
        
        cd(structDir);
        fa   = spm_select('List', structDir, '.*seg_sn\.mat$' );%
        stFile=cellstr([repmat([structDir   fs ],size(fa,1),1) fa]);
        
        
        
        matlabbatch{1}.spm.spatial.normalise.write.subj.matname = stFile;
        
        otherImages=[];
        f=[];
        %concatenate all the EPI files into one (as for coregister step)
        for curr_sess = 1:num_sessions %
            scanDir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs sess_prfx num2str(curr_sess) fs 'PROC'];
            f   = spm_select('List', scanDir, '^ufMQ*.*nii');
            otherImages  = [otherImages; cellstr([repmat([scanDir   fs ],size(f,1),1) f])]; %i.e. concatenate all images into one lot
            
        end
        
        
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = otherImages;
        
        matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
        matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -50; 78 76 85];
        matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [2 2 2]; %default from GUI
        matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
        matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
        
        
        spm_jobman('run',matlabbatch);
        clear matlabbatch
        
        %
        if k==1 && sendmail==1
            param.curr_time=clock; %get current time
            param.mail_text=strcat('1st sub EPI normalized:  ',num2str(param.curr_time));
            [param]=send_gmail(param);
        end
        
        
    end
end


%% NORMALIZE STRUCT
sub_ind=sub_ind_normalise_struct;
num_subs=length(sub_ind);

if normalise_struct
    disp(['Normalizing STRUCT... ']);
    
    for k=1:num_subs
        curr_sub=sub_ind(k);
        
        disp(['Normalizing for Subject : ', num2str(curr_sub)]);
        
        %structural
        %parameters from segmentation
        structDir = [dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'struct' fs 'PROC'];
        
        cd(structDir);
        fa   = spm_select('List', structDir, '.*seg_sn\.mat$' );%
        stFile=cellstr([repmat([structDir   fs ],size(fa,1),1) fa]);
        
        matlabbatch{1}.spm.spatial.normalise.write.subj.matname = stFile;
        
        %structural image
        
        fa   = spm_select('List', structDir, '^ms.*nii' );%take coregistered structural file
        anatImage=cellstr([repmat([structDir   fs ],size(fa,1),1) fa]);
        
        
        
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = anatImage;
        
        matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
        matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -50; 78 76 85];
        matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [1 1 1]; %use 1x1x1 for structural
        matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
        matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
        
        
        spm_jobman('run',matlabbatch);
        clear matlabbatch
        
        %
        if k==1 && sendmail==1
            param.curr_time=clock; %get current time
            param.mail_text=strcat('1st sub struct normalized:  ',num2str(param.curr_time));
            [param]=send_gmail(param);
        end
        
        
        
        
    end
end



%% SMOOTHING
FWHM=6; %smoothing kernel

sub_ind=sub_ind_smoothing;
num_subs=length(sub_ind);

if smoothing
    disp('Smoothing... ');
    
    for k=1:num_subs
        curr_sub=sub_ind(k);
        
        disp(['smoothing for Subject : ', num2str(curr_sub)]);
        
        otherImages=[];
        f=[];
        %concatenate all the EPI files into one (as for coregister step)
        for curr_sess = 1:num_sessions %
            scanDir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs sess_prfx num2str(curr_sess) fs 'PROC'];
            f   = spm_select('List', scanDir, '^rfMQ*.*nii');
            otherImages  = [otherImages; cellstr([repmat([scanDir   fs ],size(f,1),1) f])]; %i.e. concatenate all images into one lot
        end
        
        
        matlabbatch{1}.spm.spatial.smooth.data = otherImages;
        matlabbatch{1}.spm.spatial.smooth.fwhm = [FWHM FWHM FWHM];
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = 's';
        
        
        
        spm_jobman('run',matlabbatch);
        clear matlabbatch
        
        %
        if k==1 && sendmail==1
            param.curr_time=clock; %get current time
            param.mail_text=strcat('1st sub smoothed:  ',num2str(param.curr_time));
            [param]=send_gmail(param);
        end
        
        
    end
end


