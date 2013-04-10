%% GET ALL THE PROC directories with functional volumes coming from sessions.

celldisp(cellstr(EXPERIMENT_DIR));


% List of open inputs
% Named Directory Selector: Directory - cfg_files
nrun = 1; % enter the number of runs here
jobfile = {'/Users/andreirusu/mvpa/mvpa-utils/functional_all_subjects_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(EXPERIMENT_DIR); % Named Directory Selector: Directory - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});

celldisp(sessionPROCPaths);


%% PROCESS FUNCTIONAL VOLUMES IN THOSE FOLDERS
% List of open inputs
% Named Directory Selector: Directory - cfg_files
nrun = size(sessionPROCPaths, 1); % enter the number of runs here
jobfile = {'/Users/andreirusu/mvpa/mvpa-utils/functional_template_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(sessionPROCPaths{crun}); % Named Directory Selector: Directory - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});
