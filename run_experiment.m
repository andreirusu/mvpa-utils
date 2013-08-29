%% CLEANUP
clear
CODE_PATH = pwd;
addpath(CODE_PATH)
spm fmri


%% %%%% MANUAL SET: all that needs to be set manually is in  section
% EXPERIMENT_DIR = '/Users/andreirusu/mvpa/3_random_subjects/';
EXPERIMENT_DIR = '/Volumes/SAMSUNG/mvpa/3_random_subjects';
% EXPERIMENT_DIR = '/Volumes/SAMSUNG/mvpa/functional';


% %% DICOM IMPORT ALL SUBJECTS IN THE EXPERIMENT_DIR => PROC DIRECTORIES
% cd(EXPERIMENT_DIR)
% dicom_import_all_subjects


% %% PRE-PROCESS ALL FUNCTIONAL VOLUMES IN PROC DIRs. => FINAL DIRs.
% cd(EXPERIMENT_DIR)
% functional_all_subjects


% %% SEGMENT COREG. STRUCTURAL AND CREATE WHOLE BRAIN MASK
% cd(EXPERIMENT_DIR)
% create_brain_masks_all_subjects


%% SEGMENT COREG. STRUCTURAL AND CREATE WHOLE BRAIN MASK
cd(EXPERIMENT_DIR)
create_ROIs_all_subjects


% %% PRE-PROCESS REST SESSIONS INDEPENDENTLY
% cd(EXPERIMENT_DIR)
% rest_sessions_all_subjects;


%% GO BACK TO CODE DIR
cd(CODE_PATH)


% %% COMPUTE BETA MAPS
% R_FMRI_batch_Feb13v2_AAR_one_back


