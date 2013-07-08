%% SELECT ALL SESSION PATHS

celldisp(cellstr(EXPERIMENT_DIR));


% List of open inputs
% Named Directory Selector: Directory - cfg_files
nrun = 1; % enter the number of runs here
jobfile = {'/Users/andreirusu/mvpa/mvpa-utils/create_brain_masks_all_subjects_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(EXPERIMENT_DIR); % Named Directory Selector: Directory - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});

celldisp(sessionPaths);


%%
% List of open inputs
% Named Directory Selector: Directory - cfg_files
nrun = size(sessionPaths,1); % enter the number of runs here
jobfile = {'/Users/andreirusu/mvpa/mvpa-utils/create_subject_ROI_mask.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(strcat(sessionPaths{crun}, '/PROC')); % Named Directory Selector: Directory - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});
