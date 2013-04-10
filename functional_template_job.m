%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.cfg_named_dir.name = 'subjectDir';
matlabbatch{1}.cfg_basicio.cfg_named_dir.dirs = {'<UNDEFINED>'};
matlabbatch{2}.cfg_basicio.cfg_cd.dir(1) = cfg_dep;
matlabbatch{2}.cfg_basicio.cfg_cd.dir(1).tname = 'Directory';
matlabbatch{2}.cfg_basicio.cfg_cd.dir(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{2}.cfg_basicio.cfg_cd.dir(1).tgt_spec{1}(1).value = 'dir';
matlabbatch{2}.cfg_basicio.cfg_cd.dir(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{2}.cfg_basicio.cfg_cd.dir(1).tgt_spec{1}(2).value = 'e';
matlabbatch{2}.cfg_basicio.cfg_cd.dir(1).sname = 'Named Directory Selector: subjectDir(1)';
matlabbatch{2}.cfg_basicio.cfg_cd.dir(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.cfg_basicio.cfg_cd.dir(1).src_output = substruct('.','dirs', '{}',{1});
matlabbatch{3}.cfg_basicio.file_fplist.dir(1) = cfg_dep;
matlabbatch{3}.cfg_basicio.file_fplist.dir(1).tname = 'Directory';
matlabbatch{3}.cfg_basicio.file_fplist.dir(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{3}.cfg_basicio.file_fplist.dir(1).tgt_spec{1}(1).value = 'dir';
matlabbatch{3}.cfg_basicio.file_fplist.dir(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{3}.cfg_basicio.file_fplist.dir(1).tgt_spec{1}(2).value = 'e';
matlabbatch{3}.cfg_basicio.file_fplist.dir(1).sname = 'Named Directory Selector: subjectDir(1)';
matlabbatch{3}.cfg_basicio.file_fplist.dir(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{3}.cfg_basicio.file_fplist.dir(1).src_output = substruct('.','dirs', '{}',{1});
matlabbatch{3}.cfg_basicio.file_fplist.filter = '^f.*nii$';
matlabbatch{3}.cfg_basicio.file_fplist.rec = 'FPListRec';
matlabbatch{4}.cfg_basicio.cfg_assignin.name = 'selectedFiles';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1) = cfg_dep;
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).tname = 'Output Item';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).tgt_spec{1}(1).name = 'class';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).tgt_spec{1}(1).value = 'cfg_files';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).tgt_spec{1}(2).value = 'e';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).sname = 'File Selector (Batch Mode): Selected Files (^f.*nii$)';
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).src_exbranch = substruct('.','val', '{}',{3}, '.','val', '{}',{1});
matlabbatch{4}.cfg_basicio.cfg_assignin.output(1).src_output = substruct('.','files');
matlabbatch{5}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep;
matlabbatch{5}.spm.spatial.realign.estwrite.data{1}(1).tname = 'Session';
matlabbatch{5}.spm.spatial.realign.estwrite.data{1}(1).tgt_spec{1}(1).name = 'class';
matlabbatch{5}.spm.spatial.realign.estwrite.data{1}(1).tgt_spec{1}(1).value = 'cfg_files';
matlabbatch{5}.spm.spatial.realign.estwrite.data{1}(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{5}.spm.spatial.realign.estwrite.data{1}(1).tgt_spec{1}(2).value = 'e';
matlabbatch{5}.spm.spatial.realign.estwrite.data{1}(1).sname = 'File Selector (Batch Mode): Selected Files (^f.*nii$)';
matlabbatch{5}.spm.spatial.realign.estwrite.data{1}(1).src_exbranch = substruct('.','val', '{}',{3}, '.','val', '{}',{1});
matlabbatch{5}.spm.spatial.realign.estwrite.data{1}(1).src_output = substruct('.','files');
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{5}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{5}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{5}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{5}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{5}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{5}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
