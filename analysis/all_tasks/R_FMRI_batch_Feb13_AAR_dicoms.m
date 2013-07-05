clear all


%spm5dir = 'C:/Documents/SPM8';
fs          = filesep; %file sep
%n_sess      = 4; % no of sessions (runs)
dir_base    = '/Volumes/SAMSUNG/mvpa/functional';%\Users\guitart\Experiments\RewPunGoN_Pharmcao'; %bse directory
sess_prfx='sess';
task_prfx={'one_back'};
struct_FM_prfx='one_back'; %DIRECTORY prefix where structural and FM folders are
sendmail=0; %gmail or not
num_sessions=5;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DICOM CONVERT STRUCT AND FIELDMAP



spm fmri



% [AR]: ACTIVATE IN ORDER TO IMPORT DICOMs
do_epi=0;
do_struct=0;
do_fieldmap=0;
sub_ind_recon_epi=[];
sub_ind_recon_fieldmap=[];
sub_ind_recon_struct=[];



%LIST OF WHICH FMs relate to WHICH SESSIONS
list_ex_subs=[]; %ALSO DEFINE BELOW!!list of exception subs (i.e. with 2 fieldmaps 


%%structural scan reconstruct
sub_ind = sub_ind_recon_epi;
num_subs = length(sub_ind);

if do_epi
    disp(['reconstructing EPI (IMA) ']);
    
    %%%%%%%%%%%structural (note this is in categ folder (i.e. task 2)
    for k=1:num_subs
        curr_sub=sub_ind(k);
        
        for curr_sess=1:num_sessions
            
        scanDir = [dir_base fs 's' num2str(curr_sub) fs task_prfx{1} fs sess_prfx num2str(curr_sess) ];
        
        cd(scanDir)
        
        [f,d]=spm_select('List',scanDir,'.*');
        files=cellstr([repmat([scanDir '/'],size(f,1),1) f]);
        P=files;%cellstr([repmat([scanDir '/'],size(f,1),1) f]);
        %P = spm_get('Files',scanDir,'*');
        hdr = spm_dicom_headers_DK(P);
        spm_dicom_convert(hdr)
        end
    end
    
end

%%structural scan reconstruct
sub_ind=sub_ind_recon_struct;
num_subs=length(sub_ind);

if do_struct
    disp('reconstructing struct ');
    
    %%%%%%%%%%%structural (note this is in categ folder (i.e. task 2)
    for k=1:num_subs
        curr_sub=sub_ind(k);
        
        scanDir = [dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'struct'];
        
        cd(scanDir)
        
        [f,d]=spm_select('List',scanDir,'.*');
        files=cellstr([repmat([scanDir '/'],size(f,1),1) f]);
        P=files;%cellstr([repmat([scanDir '/'],size(f,1),1) f]);
        %P = spm_get('Files',scanDir,'*');
        hdr = spm_dicom_headers_DK(P);
        spm_dicom_convert(hdr)
        
    end
    
end

%%fieldmap scan reconstruct
sub_ind=sub_ind_recon_fieldmap;
num_subs=length(sub_ind);

if do_fieldmap
    disp(['reconstructing fieldmap ']);
    
    %%%%%%%%%%%LEARN TASK
    for k=1:num_subs
        curr_sub=sub_ind(k);
        
        %determine is subject is preproc exception subject
        if ismember(curr_sub,list_ex_subs)
            sub_ex_var=1; %exception
        else
            sub_ex_var=0;
        end
        
        scanDir = [dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'FM' fs 'iter1'];
          cd(scanDir)
        [f,d]=spm_select('List',scanDir,'.*');
        files=cellstr([repmat([scanDir '/'],size(f,1),1) f]);
        P=files;%cellstr([repmat([scanDir '/'],size(f,1),1) f]);
        %P = spm_get('Files',scanDir,'*');
        hdr = spm_dicom_headers_DK(P);
        spm_dicom_convert(hdr)
        
        if sub_ex_var==1   %i.e. 2 fieldmaps to use in LEARNING SESSION
            
            
        scanDir = [dir_base fs 's' num2str(curr_sub) fs struct_FM_prfx fs 'FM' fs 'iter2'];
          cd(scanDir)
        [f,d]=spm_select('List',scanDir,'.*');
        files=cellstr([repmat([scanDir '/'],size(f,1),1) f]);
        P=files;%cellstr([repmat([scanDir '/'],size(f,1),1) f]);
        %P = spm_get('Files',scanDir,'*');
        hdr = spm_dicom_headers_DK(P);
        spm_dicom_convert(hdr)
        end
        
%         %categ task (i.e. all subjects have only 1 fieldmap here)
%         
%         scanDir = [dir_base fs 's' num2str(curr_sub) fs task_prfx{2} fs 'FM' fs 'iter1'];
%           cd(scanDir)
%         [f,d]=spm_select('List',scanDir,'.*');
%         files=cellstr([repmat([scanDir '/'],size(f,1),1) f]);
%         P=files;%cellstr([repmat([scanDir '/'],size(f,1),1) f]);
%         %P = spm_get('Files',scanDir,'*');
%         hdr = spm_dicom_headers_DK(P);
%         spm_dicom_convert(hdr)
 
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




