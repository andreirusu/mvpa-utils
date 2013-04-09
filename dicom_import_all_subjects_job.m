%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.cfg_named_dir.name = 'subjectDir';
matlabbatch{1}.cfg_basicio.cfg_named_dir.dirs = {{'/Users/andreirusu/mvpa/3 random subjects/'}};
matlabbatch{2}.cfg_basicio.file_fplist.dir(1) = cfg_dep;
matlabbatch{2}.cfg_basicio.file_fplist.dir(1).tname = 'Directory';
matlabbatch{2}.cfg_basicio.file_fplist.dir(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{2}.cfg_basicio.file_fplist.dir(1).tgt_spec{1}(1).value = 'dir';
matlabbatch{2}.cfg_basicio.file_fplist.dir(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{2}.cfg_basicio.file_fplist.dir(1).tgt_spec{1}(2).value = 'e';
matlabbatch{2}.cfg_basicio.file_fplist.dir(1).sname = 'Named Directory Selector: subjectDir(1)';
matlabbatch{2}.cfg_basicio.file_fplist.dir(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.cfg_basicio.file_fplist.dir(1).src_output = substruct('.','dirs', '{}',{1});
matlabbatch{2}.cfg_basicio.file_fplist.filter = '.*ima';
matlabbatch{2}.cfg_basicio.file_fplist.rec = 'FPListRec';
matlabbatch{3}.cfg_basicio.file_filter.files(1) = cfg_dep;
matlabbatch{3}.cfg_basicio.file_filter.files(1).tname = 'Files';
matlabbatch{3}.cfg_basicio.file_filter.files(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{3}.cfg_basicio.file_filter.files(1).tgt_spec{1}(1).value = 'dir';
matlabbatch{3}.cfg_basicio.file_filter.files(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{3}.cfg_basicio.file_filter.files(1).tgt_spec{1}(2).value = 'e';
matlabbatch{3}.cfg_basicio.file_filter.files(1).sname = 'File Selector (Batch Mode): Subdirectories';
matlabbatch{3}.cfg_basicio.file_filter.files(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1});
matlabbatch{3}.cfg_basicio.file_filter.files(1).src_output = substruct('.','dirs');
matlabbatch{3}.cfg_basicio.file_filter.typ = 'dir';
matlabbatch{3}.cfg_basicio.file_filter.filter = '.*sess.*|.*iter.*';
matlabbatch{3}.cfg_basicio.file_filter.frames = 'ignored';
matlabbatch{4}.cfg_basicio.cfg_assignin.name = 'sessionPaths';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1) = cfg_dep;
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).tname = 'Output Item';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).tgt_spec{1}(1).value = 'dir';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).tgt_spec{1}(2).value = 'e';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).sname = 'File Filter: Filtered Files';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).src_exbranch = substruct('.','val', '{}',{3}, '.','val', '{}',{1});
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).src_output = substruct('.','files');
