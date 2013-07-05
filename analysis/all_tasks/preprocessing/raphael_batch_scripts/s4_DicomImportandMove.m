%script to do dicom import for all subjects, then move into the folder
%structure

%% basic structure

%the scripts assumes 6 dummy scands and for the full volumes 6 volumes (so
%it deletes5)

%% subject list
clear all, close all

load('specificationfile.mat')


spm fmri
for sub=runlist
    %% DICOM IMPORT for functionals
    
    %all functional scans
    

        
        %go into folder that has the raw data
        cd([raw_sub_dir fs slist{sub} fs ])
        listing=dir;
        %find name of folder
        for l=1:length(listing)
            if length(listing(l).name)>8 && strcmp(listing(l).name(end-(length(scode{sub})-1):end), scode{sub})
                rightname=[cd fs listing(l).name fs];
            end
        end
        
        files=[];
        for r=1:runs+1 %plus1 for the whole volume
            scanDir=[rightname scode{sub} '.' num2str(origin(sub).folders(r))];
                

        f=spm_select('List',scanDir,'.*');
        f2=cellstr([repmat([scanDir '/'],size(f,1),1) f]); %add adress
        files=[files ; f2];
        end
    
    
    matlabbatch{1}.spm.util.dicom.data = files;
    %values for the dicom import
    matlabbatch{1}.spm.util.dicom.root = 'flat';
    matlabbatch{1}.spm.util.dicom.outdir = {[import_dir slist{sub}  fs]};
    matlabbatch{1}.spm.util.dicom.convopts.format = 'img';
    matlabbatch{1}.spm.util.dicom.convopts.icedims = 0;

    
    
        disp(['reconstructing functional images for subject ',slist{sub}])
        spm_jobman('run',matlabbatch);
        clear matlabbatch
    
    cd([import_dir fs slist{sub} fs])
    %% DIRs
        for r=1:runs
            
           if exist(['run_' num2str(r)])==7
                [status, message, messageid] = rmdir(['run_' num2str(r)],'s');    
           end
                mkdir(['run_' num2str(r)])
            
    
            
            if 10>origin(sub).folders(r)
                movefile (['fMQ*-000' num2str(origin(sub).folders(r)) '-*.*'], ['run_' num2str(r)])
            elseif 9<origin(sub).folders(r)
                movefile (['fMQ*-00' num2str(origin(sub).folders(r))  '-*.*'], ['run_' num2str(r)]);
            end
            
       end
    
    %other folders
    if exist('whole_volume')==7
       [status, message, messageid] = rmdir('whole_volume','s');
    end
    mkdir whole_volume;
    %move the whole volume
         if 10>origin(sub).folders(5)
            movefile (['fMQ*-000' num2str(origin(sub).folders(5)) '-*.*'], 'whole_volume')
        elseif 9<origin(sub).folders(5)
            movefile (['fMQ*-00' num2str(origin(sub).folders(5))  '-*.*'], 'whole_volume');
         end
         
         
    
    if exist('field_maps')==7
       [status, message, messageid] = rmdir('field_maps','s');
    end
    mkdir field_maps;
    
    if exist('structurals')==7
       [status, message, messageid] = rmdir('structurals','s');    
    end
    mkdir structurals/field_map;
    mkdir structurals/b1;
    mkdir structurals/anat;
    
    %remove dummy scans
    for r=1:runs
        cd(['run_' num2str(r)])
        ! del fMQ*-000001-* fMQ*-000002-* fMQ*-000003-* fMQ*-000004-* fMQ*-000005-* fMQ*-000006-*
        cd ..
    end
    
    cd whole_volume
    ! del fMQ*-*000001-* fMQ*-*000002-* fMQ*-*000003-* fMQ*-*000004-* fMQ*-*000005-*
    cd ..
    
    %% DICOM IMPORT THE FIELDMAP
    
            files=[];
        for r=6:7 %adress of fieldmap
            scanDir=[rightname scode{sub} '.' num2str(origin(sub).folders(r))];
            f=spm_select('List',scanDir,'.*');
            f2=cellstr([repmat([scanDir fs],size(f,1),1) f]); %add adress
            files=[files ; f2];
        end
    
        matlabbatch{1}.spm.util.dicom.data = files;
        matlabbatch{1}.spm.util.dicom.root = 'flat';
        matlabbatch{1}.spm.util.dicom.outdir = {[import_dir slist{sub}  fs 'field_maps\']};
        matlabbatch{1}.spm.util.dicom.convopts.format = 'img';
        matlabbatch{1}.spm.util.dicom.convopts.icedims = 0;
    
        disp(['reconstructing functional fieldmap for subject ',slist{sub}])
        spm_jobman('run',matlabbatch);
        clear matlabbatch
        %% reconstruct the anatomy
        %as nifti
        %the structural fieldmap
            files=[];
        for r=8:9 %adress of fieldmap
            scanDir=[rightname scode{sub} '.' num2str(origin(sub).folders(r))];
            f=spm_select('List',scanDir,'.*');
            f2=cellstr([repmat([scanDir '/'],size(f,1),1) f]); %add adress
            files=[files ; f2];
        end
    
        matlabbatch{1}.spm.util.dicom.data = files;
        matlabbatch{1}.spm.util.dicom.root = 'flat';
        matlabbatch{1}.spm.util.dicom.outdir = {[import_dir slist{sub}  fs 'structurals\' 'field_map\']};
        matlabbatch{1}.spm.util.dicom.convopts.format = 'nii';
        matlabbatch{1}.spm.util.dicom.convopts.icedims = 0;
    
        disp(['reconstructing structural fieldmap for subject ',slist{sub}])
        spm_jobman('run',matlabbatch);
        clear matlabbatch
    
        %the B1
            files=[];
            scanDir=[rightname scode{sub} '.' num2str(origin(sub).folders(10))];
            f=spm_select('List',scanDir,'.*');
            f2=cellstr([repmat([scanDir '/'],size(f,1),1) f]); %add adress
            files=[files ; f2];
            
            
        matlabbatch{1}.spm.util.dicom.data = files;
        matlabbatch{1}.spm.util.dicom.root = 'flat';
        matlabbatch{1}.spm.util.dicom.outdir = {[import_dir slist{sub}  fs 'structurals\' 'b1\']};
        matlabbatch{1}.spm.util.dicom.convopts.format = 'nii';
        matlabbatch{1}.spm.util.dicom.convopts.icedims = 0;
        
        disp(['reconstructing structural b1 for subject ',slist{sub}])
        spm_jobman('run',matlabbatch);
        clear matlabbatch
        
        
        %the anat
                files=[];
        for r=11:16 %adress of fieldmap
            scanDir=[rightname scode{sub} '.' num2str(origin(sub).folders(r))];
            f=spm_select('List',scanDir,'.*');
            f2=cellstr([repmat([scanDir '/'],size(f,1),1) f]); %add adress
            files=[files ; f2];
        end
    
        matlabbatch{1}.spm.util.dicom.data = files;
        matlabbatch{1}.spm.util.dicom.root = 'flat';
        matlabbatch{1}.spm.util.dicom.outdir = {[import_dir slist{sub}  fs 'structurals\' 'anat\']};
        matlabbatch{1}.spm.util.dicom.convopts.format = 'nii';
        matlabbatch{1}.spm.util.dicom.convopts.icedims = 0;
    
        disp(['reconstructing structural fieldmap for subject ',slist{sub}])
        spm_jobman('run',matlabbatch);
        clear matlabbatch
        
        %% 
        addpath(genpath(mtpath))
        
        %field map
        
        b0_im=[import_dir slist{sub}  fs 'structurals\' 'field_map\'];
        f=spm_select('List',b0_im,'sMQ');
        Q=[repmat([import_dir   slist{sub}  fs 'structurals\' 'field_map\'],size(f,1),1) f repmat([',1'],size(f,1),1)];
        
        b1_im=[import_dir slist{sub}  fs 'structurals\' 'b1\'];
        f=spm_select('List',b1_im,'.*');
        P=[repmat([import_dir   slist{sub}  fs 'structurals\' 'b1\'],size(f,1),1) f repmat([',1'],size(f,1),1)];
        
        T1=1192;
        B1map_v2(P,Q,T1)
        
        
        %% Processing of the Multi Parameter data
        % http://intranet.fil.ion.ucl.ac.uk/pmwiki/pmwiki.php/Main/MultiParameterMapping
        if sub==21 | sub==22 | sub==23
        f=spm_select('List',[import_dir   slist{sub}  fs 'structurals\' 'anat\'],[ num2str(exception(sub).folders(11)) '-00001-']);
        P_mtw=[repmat([import_dir   slist{sub}  fs 'structurals\' 'anat\'],size(f,1),1) f repmat([',1'],size(f,1),1)];
        
        %pd is 8 pairs
        f=spm_select('List',[import_dir   slist{sub}  fs 'structurals\' 'anat\'],[ num2str(exception(sub).folders(13)) '-00001-']);
        P_pdw=[repmat([import_dir   slist{sub}  fs 'structurals\' 'anat\'],size(f,1),1) f repmat([',1'],size(f,1),1)];
        
        %t1 last (should be)
        f=spm_select('List',[import_dir   slist{sub}  fs 'structurals\' 'anat\'],[ num2str(exception(sub).folders(15)) '-00001-']);
        P_t1w=[repmat([import_dir   slist{sub}  fs 'structurals\' 'anat\'],size(f,1),1) f repmat([',1'],size(f,1),1)];     
        else
        f=spm_select('List',[import_dir   slist{sub}  fs 'structurals\' 'anat\'],[ num2str(origin(sub).folders(11)) '-00001-']);
        P_mtw=[repmat([import_dir   slist{sub}  fs 'structurals\' 'anat\'],size(f,1),1) f repmat([',1'],size(f,1),1)];
        
        %pd is 8 pairs
        f=spm_select('List',[import_dir   slist{sub}  fs 'structurals\' 'anat\'],[ num2str(origin(sub).folders(13)) '-00001-']);
        P_pdw=[repmat([import_dir   slist{sub}  fs 'structurals\' 'anat\'],size(f,1),1) f repmat([',1'],size(f,1),1)];
        
        %t1 last (should be)
        f=spm_select('List',[import_dir   slist{sub}  fs 'structurals\' 'anat\'],[ num2str(origin(sub).folders(15)) '-00001-']);
        P_t1w=[repmat([import_dir   slist{sub}  fs 'structurals\' 'anat\'],size(f,1),1) f repmat([',1'],size(f,1),1)];
        end
        %b1 map+t1w
        clear f
        f(2,:)=[import_dir   slist{sub}  fs 'structurals\' 'b1\' spm_select('List',[import_dir   slist{sub}  fs 'structurals\' 'b1\'],['smuB1map_'])];
        f(1,1:length([import_dir   slist{sub}  fs 'structurals\' 'b1\' spm_select('List',[import_dir   slist{sub}  fs 'structurals\' 'b1\'],['uSumOfSq.nii'])]))=[import_dir   slist{sub}  fs 'structurals\' 'b1\' spm_select('List',[import_dir   slist{sub}  fs 'structurals\' 'b1\'],['uSumOfSq.nii'])];
        P_trans=f;
        P_receiv=[]; %left empty
        %use altered version that accepts additional input argument
       % MT_analysis(P_mtw,P_pdw,P_t1w) normal unaltered function that does
       % not work
        MT_analysis_altered(P_mtw,P_pdw,P_t1w,P_trans,P_receiv)
        
        %% biascorrection
           addpath(genpath('D:\Toolboxes\bias_correction'))
        for r=1:runs
        spm_biascorrect([import_dir   slist{sub}  fs 'run_' num2str(r)])
        end
        
       disp(['Done with subject ' num2str(sub) ' from ' num2str(length(slist))])
end
try
send_mail_message(emailadd,['dicom and move is done for' modelname],'-')
end 
disp('ALL DONE! NOW REALIGN THE T1 IMAGES BY HAND!!')