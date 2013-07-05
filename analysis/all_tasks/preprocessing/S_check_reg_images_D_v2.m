%check_reg
close all

fs          = filesep; %file sep
dir_base    = '/Users/dharshan/Documents/Reward_FMRI_2013/functional';%
struct_pfx='one_back';
dir_con_pfx='analysis/1/';
sess_prfx   = 'sess';
num_sess_learn = 1;
sub_ind=[curr_sub];

num_subs=length(sub_ind);

for k=1:num_subs
    curr_sub=sub_ind(k);
    
    f=[];
    
    for curr_sess = 1:1 %
        
        otherImages=[];
        scanDir = [dir_base fs 's' num2str(curr_sub) fs 'reward' fs sess_prfx num2str(curr_sess)];
        cd(scanDir)
        
        f   = spm_select('List', scanDir, '^uf.*000007.*img');%
        
        dir_struct= [dir_base fs 's' num2str(curr_sub) fs 'one_back' fs 'struct'];
        f2   = spm_select('List', dir_struct, '^ms.*.*img');
        %scanDir = [dir_base fs 's' num2str(curr_sub) fs 'eval' fs 'struct'];
        %scanDir = [dir_base fs 's' num2str(curr_sub) fs 'learn' fs 'sess1'];
         %f   = spm_select('List', scanDir, 'con_0001.img');
         %f   = spm_select('List', scanDir, '^wms*.*.img' );
          %f   = spm_select('List', scanDir, '^smwc1*.*.nii' );
          t1=[repmat([scanDir '/'],size(f,1),1) f ',1'];
          t2=[repmat([dir_struct '/'],size(f2,1),1) f2 ',1'];
          
        otherImages  = strvcat(t1,t2);%[[repmat([scanDir '/'],size(f,1),1) f ',1']; [repmat([dir_struct '/'],size(f2,1),1) f2 ',1']]; %i.e. concatenate all images into one lot
    end
end

images=otherImages;
images = spm_vol(images)
spm_check_registration(images)
disp('done')