%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.file_fplist.dir = {'/Volumes/SAMSUNG/mvpa/functional/'};
matlabbatch{1}.cfg_basicio.file_fplist.filter = '^c1.*nii$';
matlabbatch{1}.cfg_basicio.file_fplist.rec = 'FPListRec';
matlabbatch{2}.spm.util.checkreg.data(1) = cfg_dep;
matlabbatch{2}.spm.util.checkreg.data(1).tname = 'Images to Display';
matlabbatch{2}.spm.util.checkreg.data(1).tgt_spec{1}(1).name = 'class';
matlabbatch{2}.spm.util.checkreg.data(1).tgt_spec{1}(1).value = 'cfg_files';
matlabbatch{2}.spm.util.checkreg.data(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{2}.spm.util.checkreg.data(1).tgt_spec{1}(2).value = 'e';
matlabbatch{2}.spm.util.checkreg.data(1).sname = 'File Selector (Batch Mode): Selected Files (^c1.*nii$)';
matlabbatch{2}.spm.util.checkreg.data(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.spm.util.checkreg.data(1).src_output = substruct('.','files');
