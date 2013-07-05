%Removes directory and contents
%note that rmdir will fail if the directory does not exist. 
%caviar version 

clear all
task_prfx='categ';
sess_prfx   = 'sess';
fs          = filesep; %file sep
%dir_start    = '/Users/dharshankumaran/Documents/TINF_FMRI_data';
dir_base    = '/Users/dharsh/Documents/Self_FMRI_data/functional';%\Users\guitart\Experiments\RewPunGoN_Pharmcao'; %bse directory
%dir_behav='/Users/dharshankumaran/Documents/TINF_FMRI_data/behav_analysis/sub_data';
num_sess=1;
sub_ind=[21:30];

for j=1:length(sub_ind)
    curr_sub=sub_ind(j);

    %go to relevant directory
    for curr_sess=1:num_sess
    tmp_Dir = [dir_base fs 's' num2str(curr_sub) fs task_prfx fs 'sess' num2str(curr_sess)]; %new_ to distinguish from June analyses
    cd(tmp_Dir) ; %
    delete  swufMA*-*-000227.* %*.%bz2
    delete  swufMA*-*-000228.* %*.%bz2
    
    %remove directory and all contents
    %rmdir('6','s')
    
    disp(['deleted files for subject:  ',num2str(curr_sub),'session_',num2str(curr_sess)])
    end
end
disp('done')