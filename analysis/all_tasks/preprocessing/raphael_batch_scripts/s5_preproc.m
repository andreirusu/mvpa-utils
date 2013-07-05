%% part 2 of the analys, the T1s need to be manually realigned and saved in a special folder
clear all
%% basic structure
spmfolder='D:\Toolboxes\SPM8\';
addpath(genpath('D:\Toolboxes'))
fs=filesep;

sess_prfx   = 'run_';
%the scripts assumes 6 dummy scands and for the full volumes 6 volumes (so
%it deletes5)
mtpath='D:\Toolboxes\mt_reconstruction';
%% subject list

load('specificationfile.mat')
addpath(ressourcepath)
%depends on sequence
defaultfile='D:\Toolboxes\SPM8\toolbox\FieldMap\pm_defaults_Trio_eFoV_96.m';

delete=0;
fieldmap = 1;
realign = 1;
coregister1 = 1;
coregister2 = 1;
segment_EPI= 1;
segment_STRUCT = 1;
normalise = 1;
smoothing = 1;



% RefSlice = 20; % reference slice for slice timing; middle slice
% SliceOrder = N_slices:-1:1;     % descending slice order for nw_HippParahipp_const: do not know for my sequence; not necessary for my routines

resolT1 = [1 1 1]; %resolution of structural (used during normalization)dfls
resolEPI = [2 2 2]; %resolution of functional (used during normalization)

runlist=[1:22]

spm fmri

     %% fieldmap
    for zz=1
    if fieldmap
        disp(['running Fieldmaps']);
        for sub=runlist
        %first volumes of each run
           %first volume of everyrun, assuming 6 dummies
        for r=1:runs
            if 10>origin(sub).folders(r)
                rr{r,1}=[import_dir slist{sub} fs 'run_' num2str(r) fs 'bf' scode{sub} '-000' num2str(origin(sub).folders(r)) '-00007-000007-01.img,1'];
            elseif 9<origin(sub).folders(r)
                rr{r,1}=[import_dir slist{sub} fs 'run_' num2str(r) fs 'bf' scode{sub} '-00' num2str(origin(sub).folders(r)) '-00007-000007-01.img,1']; 
            end
        end

        %phase is the fieldmap that is alone in a run
        r=7;% 7 is the second of the functional fieldmap
            if 10>origin(sub).folders(r)
                phase=[import_dir slist{sub} fs 'field_maps' fs 's' scode{sub} '-000' num2str(origin(sub).folders(r)) '-00001-000001-02.img,1'];
            elseif 9<origin(sub).folders(r)
                phase=[import_dir slist{sub} fs 'field_maps'  fs 's' scode{sub} '-00' num2str(origin(sub).folders(r)) '-00001-000001-02.img,1']; 
            end
        %magnitude is the very fist of the 3

            r=6;% 6 is the first of the functional fieldmap
            if 10>origin(sub).folders(r)
                magnitude=[import_dir slist{sub} fs 'field_maps' fs 's' scode{sub} '-000' num2str(origin(sub).folders(r)) '-00001-000001-01.img,1'];
            elseif 9<origin(sub).folders(r)
                magnitude=[import_dir slist{sub} fs 'field_maps'  fs 's' scode{sub} '-00' num2str(origin(sub).folders(r)) '-00001-000001-01.img,1']; 
            end

        %modified T1
        %anat=[import_dir2 slist{sub} fs 'T1w.nii,1' ]
        %anat=[import_dir slist{sub} fs 'structurals\anat\s' scode{sub} '-00' num2str(origin(sub).folders(11))  '-00001-000176-01_T1w.nii,1']
        anat='';
        
        matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.phase = {phase};
        matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.magnitude = {magnitude};
        matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsfile = {defaultfile};
        for r=1:runs
            matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.session(r).epi =  {rr{r,1}};
        end
        matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.matchvdm = 1;
        matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.sessname = 'session';
        matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.writeunwarped = 0;
        matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.anat = {anat};
        matlabbatch{1}.spm.tools.fieldmap.presubphasemag.subj.matchanat = 0;


            disp(['apply fieldmap for subject ' slist{sub}])
            spm_jobman('run',matlabbatch);
            clear matlabbatch
        end
    end
    end
    

    %% realign
    for zz=1
    if realign
        disp(['Realign: Realignment & UnWarp for MEAN and ALL images ']);
        for sub=runlist         
            % loop to define new session in job
            for r = 1:runs
                % define epi files in the session
                scanDir = [import_dir slist{sub} fs  sess_prfx num2str(r)];
                % select scans and assign to job
                f   = spm_select('List', scanDir, '^bfM*.*img');
                files  = cellstr([repmat([scanDir fs],size(f,1),1) f]);
                matlabbatch{1}.spm.spatial.realignunwarp.data(1).scans = files;
                % clear temporary variables for next run
                f = []; files = [];

                fmDir = [import_dir slist{sub}  fs 'field_maps'];
                fvdm5   = spm_select('List', fmDir, ['^vdm5*.' '*session' num2str(r) '.img'] );
                vdm5Image = cellstr([repmat([fmDir fs],size(fvdm5,1),1) fvdm5]);
                
                matlabbatch{1}.spm.spatial.realignunwarp.data(1).pmscan = vdm5Image;   % Note address the cell first with {}, then the structure with (), then put in cell... confusing!
                fvdm5=[]; vdm5Image=[];
            
            
            
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
        
            disp(['RUNNING realign and unwarp '  slist{sub}]);
            spm_jobman('run' , matlabbatch);
            clear matlabbatch
            end
        end
    end
    end
    
    %coregister all the runs to the first one
    for zz=1
    if coregister1 
        disp(['running coregister']);
        for sub=runlist  
        for r=2:runs
            % first specify the structural as reference image
            stDir = [import_dir  slist{sub} fs  sess_prfx '1'];
            fT1  = spm_select('List', stDir, '^meanubf.*\.img$');
            refImage = [stDir fs fT1];

            matlabbatch{1}.spm.spatial.coreg.estimate.ref = {refImage,'1'};

            % then specify the MT as source image
            %         fMT  = spm_select('List', stDir, '^sM*.*MTw.nii');
            %         sourceImage = [stDir fs fMT];
            %         matlabbatch{1}.spm.spatial.coreg.estimate.source = {sourceImage,'1'};

            % then specify the meanEPI as source image
            sourceDir = [import_dir  slist{sub} fs  sess_prfx num2str(r)];
            fmean  = spm_select('List', sourceDir, '^meanubf.*\.img$');
            sourceImage = [sourceDir fs fmean];
            matlabbatch{1}.spm.spatial.coreg.estimate.source = {sourceImage,'1'};

            % then specify other image, all EPIs
            otherImages=[]; f=[];
            
                %define epi's to be used in the session
                scanDir =[import_dir slist{sub} fs  sess_prfx num2str(r)];
                %select scans and assign to job
                f  = spm_select('List', scanDir, '^ubfMQ*.*img');
                otherImages = [otherImages; cellstr([repmat([scanDir '/'],size(f,1),1) f])];
            
            
            matlabbatch{1}.spm.spatial.coreg.estimate.other = otherImages;


            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

            disp(['RUNNING corregister ' slist{sub}]);
            spm_jobman('run' , matlabbatch);
            clear matlabbatch
        end
        end
    end
    end
    
    
    
    %%coregister2    
    for zz=1
    if coregister2
        disp(['running coregister']);
        for sub=runlist  
        
            % first specify the structural as reference image
            stDir = [import_dir slist{sub} fs 'structurals\anat' ];
                        if sub==20
            fT1  = spm_select('List', stDir, '^sM*.*T1wFORpreproc.nii');
            else
            fT1  = spm_select('List', stDir, '^sM*.*T1w.nii');
            end
            refImage = [stDir fs fT1];

            matlabbatch{1}.spm.spatial.coreg.estimate.ref = {refImage,'1'};

            % then specify the MT as source image
            %         fMT  = spm_select('List', stDir, '^sM*.*MTw.nii');
            %         sourceImage = [stDir fs fMT];
            %         matlabbatch{1}.spm.spatial.coreg.estimate.source = {sourceImage,'1'};

            % then specify the meanEPI as source image
            sourceDir = [import_dir  slist{sub} fs  sess_prfx '1'];
            fmean  = spm_select('List', sourceDir, '^meanubf.*\.img$');
            sourceImage = [sourceDir fs fmean];
            matlabbatch{1}.spm.spatial.coreg.estimate.source = {sourceImage,'1'};

            % then specify other image, all EPIs
            otherImages=[]; f=[];
            for r = 1:runs
                %define epi's to be used in the session
                scanDir =[import_dir slist{sub} fs  sess_prfx num2str(r)];
                %select scans and assign to job
                f  = spm_select('List', scanDir, '^ubfMQ*.*img');
                otherImages = [otherImages; cellstr([repmat([scanDir '/'],size(f,1),1) f])];
            end
            
            matlabbatch{1}.spm.spatial.coreg.estimate.other = otherImages;


            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

            disp(['RUNNING corregister2 ' slist{sub}]);
            spm_jobman('run' , matlabbatch);
            clear matlabbatch
        end
    end
    end
    
    %% segment_EPI    
    for zz=1
    if segment_EPI
        disp(['running segment EPI']);
        for sub=runlist
            
         wdir = [import_dir slist{sub} fs  'whole_volume'];
            fwholeEPI = spm_select('List', wdir, '^f.*\.img$');
            wholeEPI = [wdir fs fwholeEPI];

            matlabbatch{1}.spm.spatial.preproc.data = {wholeEPI,'1'};
            matlabbatch{1}.spm.spatial.preproc.output.GM = [1 0 1];
            matlabbatch{1}.spm.spatial.preproc.output.WM = [0 0 1];
            matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 0];
            matlabbatch{1}.spm.spatial.preproc.output.biascor = 1;
            matlabbatch{1}.spm.spatial.preproc.output.cleanup = 0;
            matlabbatch{1}.spm.spatial.preproc.opts.tpm = {
               [ spmfolder 'tpm\grey.nii']
               [spmfolder 'tpm\white.nii']
               [spmfolder 'tpm\csf.nii']
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

        
            disp(['RUNNING corregister '  slist{sub}]);
            spm_jobman('run' , matlabbatch);
            clear matlabbatch
        end
    end
    end
    
    %%segment_STRUCT
    for zz=1
    if segment_STRUCT
        disp(['running segment struct']);
        for sub=runlist

            %T1
            stDir = [import_dir slist{sub} fs  'structurals\anat'];
            if sub==20
            fT1  = spm_select('List', stDir, '^sM*.*T1wFORpreproc.nii');
            else
            fT1  = spm_select('List', stDir, '^sM*.*T1w.nii');
            end
            stFile = [stDir fs fT1];

            matlabbatch{1}.spm.spatial.preproc.data = {stFile,'1'};
            matlabbatch{1}.spm.spatial.preproc.output.GM = [1 0 1];
            matlabbatch{1}.spm.spatial.preproc.output.WM = [0 0 1];
            matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 0];
            matlabbatch{1}.spm.spatial.preproc.output.biascor = 1;
            matlabbatch{1}.spm.spatial.preproc.output.cleanup = 0;
            matlabbatch{1}.spm.spatial.preproc.opts.tpm = {
               [ spmfolder 'tpm\grey.nii']
               [spmfolder 'tpm\white.nii']
               [spmfolder 'tpm\csf.nii']
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
            
            
            
            disp(['RUNNING segmemtation T1 images ' slist{sub}]);
            spm_jobman('run',matlabbatch);
            clear matlabbatch
        end
    end
    end
    
    %%normalise
    for zz=1
    if normalise
        disp(['running normalise']);
        for sub=runlist 
        
            wdir = [import_dir slist{sub} fs  'structurals\anat'];
            cd(wdir);

            % select T1 normalization parameters
            fparam   = spm_select('List', wdir, '.*seg_sn\.mat$');
            Paramfile  = {[wdir fs fparam]};

            matlabbatch{1}.spm.spatial.normalise.write.subj.matname = Paramfile;

            %%%% for the structurals
            %             f = []; files = []; conCat_files = [];
            %             stDir = [import_dir fs name_subj{s0} fs dir_session fs dir_struct];
            %             f  = spm_select('List', stDir, '^sM*.*T1w.nii');
            %             files  = cellstr([repmat([stDir fs],size(f,1),1) f]); conCat_files = [conCat_files; files];
            %             f  = spm_select('List', stDir, '^sM*.*MTw.nii');
            %             files  = cellstr([repmat([stDir fs],size(f,1),1) f]); conCat_files = [conCat_files; files];


            %%%% for the con images
            %         f = []; files = []; conCat_files = [];
            %         scanDir = [import_dir fs name_subj{s0} fs dir_results];
            %         % select slice time corrected images
            %         f   = spm_select('List', scanDir, 'con*');
            %         files  = cellstr([repmat([scanDir fs],size(f,1),1) f]);
            %         conCat_files = [conCat_files; files];       % concatenate all files over runs
            
            
            
            % Loop over sessions for epi's
            conCat_files=[];
            for r = 1:runs
                scanDir = [import_dir slist{sub} fs  sess_prfx num2str(r)];
                % select slice time corrected images
                f   = spm_select('List', scanDir, '^ubfMQ*.*img$');
                files  = cellstr([repmat([scanDir fs],size(f,1),1) f]);
                conCat_files = [conCat_files; files];       % concatenate all files over runs
                f = []; files = [];
            end

            matlabbatch{1}.spm.spatial.normalise.write.subj.resample = conCat_files;


            % %         %%%%% for the functionals
            % %         f   = spm_select('List', wdir, 'w.*nii$');
            % %         files  = cellstr([repmat([wdir fs],size(f,1),1) f])
            % %
            % %         matlabbatch{1}.spm.spatial.normalise.write.subj.resample = files;

            matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
            matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -50; 78 76 85];
            matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [2 2 2];
            matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
            matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
            
            
        
            disp(['RUNNING normalization' slist{sub}]);
            spm_jobman('run',matlabbatch);
            clear matlabbatch
        end
    end
    end
    
    
for P=1:length(preproc_branches)
    %%smoothing 
    for zz=1
    if smoothing
        for sub=runlist

            cd([import_dir fs slist{sub} fs ]);

            f = []; files = []; conCat_files = [];
            
             for r = 1:runs
                scanDir =[import_dir slist{sub} fs  sess_prfx num2str(r)];
                f   = spm_select('List', scanDir, '^wubfMQ*.*img');
                files  = cellstr([repmat([scanDir fs],size(f,1),1) f]);
                conCat_files = [conCat_files; files];       % concatenate all files over runs
                f = []; files = [];
            end

            matlabbatch{1}.spm.spatial.smooth.data = conCat_files;

            matlabbatch{1}.spm.spatial.smooth.fwhm = [FWHM(P) FWHM(P) FWHM(P)];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            

            disp(['RUNNING smoothing ' slist{sub}]);
            spm_jobman('run',matlabbatch);
            clear matlabbatch
        end
    end
    end
    
    %% copy files
    %copfile
    for sub=runlist
        for r=1:runs
            if  exist([import_dir slist{sub} fs 'preproc_branches' fs preproc_branches{P} fs 'run_' num2str(r)])==7
            rmdir([import_dir slist{sub} fs 'preproc_branches' fs preproc_branches{P} fs 'run_' num2str(r)],'s')
            end
      % mkdir([import_dir slist{sub} fs 'preproc_branches' fs preproc_branches{P} fs 'run_' num2str(r)]) 
      copyfile([import_dir slist{sub} fs  'run_' num2str(r) fs 'swubf*'],[import_dir slist{sub} fs 'preproc_branches' fs preproc_branches{P} fs 'run_' num2str(r)],'f')
        end
    end  
 end
    
try
%send_mail_message(emailadd,['preproc is done for' modelname],'-')
end
disp(['DONE!!']);
