clear

%% SELECT ALL SESSION PATHS

% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {'/Users/andreirusu/mvpa/dicom_import_all_subjects_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
    % import all DICOM files
end

% run the first job
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});

celldisp(sessionPaths);


%% RUN DICOM IMPORT SCRIPT ON EVERY SESSION PATH IN TURN

% List of open inputs
% Named Directory Selector: Directory - cfg_files
nrun = size(sessionPaths,1); % enter the number of runs here
jobfile = {'/Users/andreirusu/mvpa/dicom_import_dir_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(sessionPaths{crun}); % Named Directory Selector: Directory - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});

