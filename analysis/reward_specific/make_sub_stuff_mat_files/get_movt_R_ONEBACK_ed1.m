function [movt,all_movt_data,param]=get_movt_R_ONEBACK_ed1(the_stuff,param,my_name)
fs          = filesep; %file sep

dir_base   = ['/Users/' my_name '/Documents/Reward_FMRI_2013/functional'];%\Users\guitart\Experiments\RewPunGoN_Pharmcao'; %bse directory
sess_prfx   = 'sess';

curr_sub=param.curr_sub; %current subject
nsess=5;
movt={};
param.nscan=zeros(1,nsess);
%nscan=param.nscan; %e.g. [399 399];

for curr_sess=1:nsess %3 learning sessions
    scanDir = [dir_base fs 's' num2str(curr_sub) fs 'one_back' fs sess_prfx num2str(curr_sess)];
    
    cd(scanDir)
    %select EPI file to match VDM to
    movt_file   = spm_select('List', scanDir, '^rp*.*.txt' ); %movement file
    tmp_movt=spm_load(movt_file);
    %switch curr_sess
     %   case 1
      %      tmp_movt = kron([1 0]',spm_load(movt_file)); %pads with zeros so that it spans all 2 sessions
        %case 2
         %   tmp_movt = kron([0 1]',spm_load(movt_file)); %pads with zeros so that it spans all 2 sessions
      
    %end
    movt{curr_sess}=tmp_movt;
    
    %if curr_sess==2 && curr_sub==2 %subject 2 has uneven number of scans
     %   tmp_1=movt{1}(1:361,:); %movt parameters from first session
       
      %  tmp_2=movt{2}(281:end,:); %from 281:560
       % all_movt_data=[tmp_1;tmp_2];%concatenate
     param.nscan(curr_sess)=size(movt{curr_sess},1); %GET NUMBER OF SCANS   
        
if curr_sess==nsess;
        all_movt_data=[movt{1}; movt{2};movt{3};movt{4};movt{5}]; %
end
    
   % all_movt_data=tmp_movt;
end

