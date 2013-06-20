%% CLEANUP
clear
CODE_PATH = pwd;
addpath(CODE_PATH)
spm fmri


%% %%%% MANUAL SET: all that needs to be set manually is in  section
EXPERIMENT_DIR = '/Users/andreirusu/mvpa/3_random_subjects/';

%EXPERIMENT_DIR = '/Volumes/SAMSUNG/mvpa/functional';


%% START PROCESSING
cd(EXPERIMENT_DIR)


%% DICOM IMPORT ALL SUBJECTS IN THE EXPERIMENT_DIR => PROC DIRECTORIES
%dicom_import_all_subjects


%% PRE-PROCESS ALL FUNCTIONAL VOLUMES IN PROC DIRs. => FINAL DIRs.
%functional_all_subjects


%% SEGMENT COREG. STRUCTURAL AND CREATE WHOLE BRAIN MASK
create_brain_masks_all_subjects


%% GO BACK TO CODE DIR
cd(CODE_PATH)

