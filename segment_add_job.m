%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.cfg_named_dir.name = 'subjectDir';
matlabbatch{1}.cfg_basicio.cfg_named_dir.dirs = {
                                                 '<UNDEFINED>'
                                                 '<UNDEFINED>'
                                                 }';
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
matlabbatch{3}.cfg_basicio.file_fplist.filter = '^c.*nii';
matlabbatch{3}.cfg_basicio.file_fplist.rec = 'FPList';
matlabbatch{4}.cfg_basicio.file_fplist.dir(1) = cfg_dep;
matlabbatch{4}.cfg_basicio.file_fplist.dir(1).tname = 'Directory';
matlabbatch{4}.cfg_basicio.file_fplist.dir(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{4}.cfg_basicio.file_fplist.dir(1).tgt_spec{1}(1).value = 'dir';
matlabbatch{4}.cfg_basicio.file_fplist.dir(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{4}.cfg_basicio.file_fplist.dir(1).tgt_spec{1}(2).value = 'e';
matlabbatch{4}.cfg_basicio.file_fplist.dir(1).sname = 'Named Directory Selector: subjectDir(2)';
matlabbatch{4}.cfg_basicio.file_fplist.dir(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{4}.cfg_basicio.file_fplist.dir(1).src_output = substruct('.','dirs', '{}',{2});
matlabbatch{4}.cfg_basicio.file_fplist.filter = '^mean.*nii';
matlabbatch{4}.cfg_basicio.file_fplist.rec = 'FPList';
matlabbatch{5}.spm.spatial.coreg.write.ref(1) = cfg_dep;
matlabbatch{5}.spm.spatial.coreg.write.ref(1).tname = 'Image Defining Space';
matlabbatch{5}.spm.spatial.coreg.write.ref(1).tgt_spec{1}(1).name = 'class';
matlabbatch{5}.spm.spatial.coreg.write.ref(1).tgt_spec{1}(1).value = 'cfg_files';
matlabbatch{5}.spm.spatial.coreg.write.ref(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{5}.spm.spatial.coreg.write.ref(1).tgt_spec{1}(2).value = 'e';
matlabbatch{5}.spm.spatial.coreg.write.ref(1).sname = 'File Selector (Batch Mode): Selected Files (^mean.*nii)';
matlabbatch{5}.spm.spatial.coreg.write.ref(1).src_exbranch = substruct('.','val', '{}',{4}, '.','val', '{}',{1});
matlabbatch{5}.spm.spatial.coreg.write.ref(1).src_output = substruct('.','files');
matlabbatch{5}.spm.spatial.coreg.write.source(1) = cfg_dep;
matlabbatch{5}.spm.spatial.coreg.write.source(1).tname = 'Images to Reslice';
matlabbatch{5}.spm.spatial.coreg.write.source(1).tgt_spec{1}(1).name = 'class';
matlabbatch{5}.spm.spatial.coreg.write.source(1).tgt_spec{1}(1).value = 'cfg_files';
matlabbatch{5}.spm.spatial.coreg.write.source(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{5}.spm.spatial.coreg.write.source(1).tgt_spec{1}(2).value = 'e';
matlabbatch{5}.spm.spatial.coreg.write.source(1).sname = 'File Selector (Batch Mode): Selected Files (^c.*nii)';
matlabbatch{5}.spm.spatial.coreg.write.source(1).src_exbranch = substruct('.','val', '{}',{3}, '.','val', '{}',{1});
matlabbatch{5}.spm.spatial.coreg.write.source(1).src_output = substruct('.','files');
matlabbatch{5}.spm.spatial.coreg.write.roptions.interp = 1;
matlabbatch{5}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{5}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{5}.spm.spatial.coreg.write.roptions.prefix = 'r';
matlabbatch{6}.spm.util.imcalc.input(1) = cfg_dep;
matlabbatch{6}.spm.util.imcalc.input(1).tname = 'Input Images';
matlabbatch{6}.spm.util.imcalc.input(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{6}.spm.util.imcalc.input(1).tgt_spec{1}(1).value = 'image';
matlabbatch{6}.spm.util.imcalc.input(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{6}.spm.util.imcalc.input(1).tgt_spec{1}(2).value = 'e';
matlabbatch{6}.spm.util.imcalc.input(1).sname = 'Coregister: Reslice: Resliced Images';
matlabbatch{6}.spm.util.imcalc.input(1).src_exbranch = substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{6}.spm.util.imcalc.input(1).src_output = substruct('.','rfiles');
matlabbatch{6}.spm.util.imcalc.output = 'rmask.nii';
matlabbatch{6}.spm.util.imcalc.outdir = {''};
matlabbatch{6}.spm.util.imcalc.expression = 'i1+i2 > 0.25';
matlabbatch{6}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{6}.spm.util.imcalc.options.mask = 0;
matlabbatch{6}.spm.util.imcalc.options.interp = 1;
matlabbatch{6}.spm.util.imcalc.options.dtype = 4;
matlabbatch{7}.spm.util.imcalc.input(1) = cfg_dep;
matlabbatch{7}.spm.util.imcalc.input(1).tname = 'Input Images';
matlabbatch{7}.spm.util.imcalc.input(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{7}.spm.util.imcalc.input(1).tgt_spec{1}(1).value = 'image';
matlabbatch{7}.spm.util.imcalc.input(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{7}.spm.util.imcalc.input(1).tgt_spec{1}(2).value = 'e';
matlabbatch{7}.spm.util.imcalc.input(1).sname = 'Coregister: Reslice: Resliced Images';
matlabbatch{7}.spm.util.imcalc.input(1).src_exbranch = substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{7}.spm.util.imcalc.input(1).src_output = substruct('.','rfiles');
matlabbatch{7}.spm.util.imcalc.output = 'rtrimmed_white.nii';
matlabbatch{7}.spm.util.imcalc.outdir = {''};
matlabbatch{7}.spm.util.imcalc.expression = 'i2 > 0.8';
matlabbatch{7}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{7}.spm.util.imcalc.options.mask = 0;
matlabbatch{7}.spm.util.imcalc.options.interp = 1;
matlabbatch{7}.spm.util.imcalc.options.dtype = 4;
