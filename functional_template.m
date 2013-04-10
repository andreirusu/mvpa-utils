% List of open inputs
% Named Directory Selector: Directory - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/Users/andreirusu/mvpa/mvpa-utils/functional_template_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Named Directory Selector: Directory - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});
