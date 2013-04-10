%% GET ALL THE PROC directories with functional volumes coming from sessions.


celldisp(cellstr(EXPERIMENT_DIR));

% get all subject dirs
dirs = dir('./s*');


% List of open inputs
% Named Directory Selector: Directory - cfg_files
nrun = size(dirs,1); % enter the number of runs here
jobfile = {strcat(CODE_PATH, '/functional_template_job.m')};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    disp(dirs(crun).name)
    inputs{1, crun} = cellstr(fullfile(pwd, dirs(crun).name)); % Named Directory Selector: Directory - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});
