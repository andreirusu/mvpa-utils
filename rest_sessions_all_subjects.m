%% SELECT ALL SESSION PATHS

celldisp(cellstr(EXPERIMENT_DIR));


% List of open inputs
% Named Directory Selector: Directory - cfg_files
nrun = 1; % enter the number of runs here
jobfile = {strcat(CODE_PATH, '/rest_sessions_select_dirs_job.m')};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(EXPERIMENT_DIR); % Named Directory Selector: Directory - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});


celldisp(sessionPaths);


%% RUN SCRIPT ON EVERY SESSION PATH IN TURN

% List of open inputs
% Named Directory Selector: Directory - cfg_files
nrun = size(sessionPaths,1); % enter the number of runs here
% jobfile = {strcat(CODE_PATH, '/dicom_import_dir_job.m')};
% jobs = repmat(jobfile, 1, nrun);
% inputs = cell(1, nrun);
for crun = 1:nrun
    %   inputs{1, crun} = cellstr(sessionPaths{crun}); % Named Directory Selector: Directory - cfg_files
    %   read all motion parameters for this subject
    
    clear filelist
    cd(sessionPaths{crun})
    cd('..')
    load functional_preprocessing_data
    first = Inf;
    last = Inf;
    for i=1:size(filelist,1)
        indices = strfind(char(filelist(i,1)), 'rest');
        
        if size(indices,1) > 0 
            if first == Inf 
                first = i;
            end
            last = i;
        end
    end
    disp(['Fist vol: ', num2str(first), '; Last vol: ', num2str(last), '; Files: ', num2str(last - first + 1)])
    rest_file_count = 0;
    str = char(filelist(1,1));
    str = strrep(strrep(str, 'nii', 'txt'),'fMQ', 'rp_fmQ');
    disp(str);
    [a,b,c,d,e,f] = textread(str, '%f%f%f%f%f%f');
    figure(9)
    imagesc(cat(2,(a-mean(a))/std(a),(b-mean(b))/std(b),(c-mean(c))/std(c),(d-mean(d))/std(d),(e-mean(e))/std(e),(f-mean(f))/std(f))); colorbar;
    
    %%      GET WHITE MATTER MASK
    clear white_mask
    white_mask = nifti([sessionPaths{crun}, '/../one_back/struct/PROC/rtrimmed_white.nii']);
    disp(white_mask(1).dat.dim)
    white_binary_mask = (white_mask(1).dat(:,:,:) > 0.99);
    disp(size(white_binary_mask));
    disp(sum(sum(sum(white_binary_mask))))
    %%
    % process the 4 rest sessions independently
    for l = 1:4;
       dirstr = [sessionPaths{crun}, '/sess',num2str(l), '/PROC'];
       disp(dirstr)
       cd(dirstr)
       %%%%% TODO: INSERT CARLTON'S CODE HERE %%%%%%%
       [files,dirs] = spm_select('FPList', dirstr,'^srfM.*');
       
       disp(['Files: ', num2str(size(files,1))]);
       N=nifti(files);
        %load all the data into one matrix 
        dim=N(1).dat.dim;
        X=zeros(numel(N),prod(dim));
        %If you have a mask, it can save a lot of time
        %use dummy mask for now
        mask=true(dim(1),dim(2),dim(3));
        white_matter_means = zeros(numel(N),1);
        for i=1:numel(N);
            data = N(i).dat(:,:,:); %this is the wierd part of SPM nifti object, this will convert the file_array into standard matrix
            X(i,:) = data(mask(:));
            white_matter_means(i) = mean(data(white_binary_mask(:)));
            % isp(white_matter_means(i))
        end
        white_matter_means = (white_matter_means - mean(white_matter_means)) / std(white_matter_means);
        
        % then you do some process here
        % Example of simple high-pass filtering using DCT
        dctmtx = cat(2,spm_dctmtx(numel(N),5), a((rest_file_count+1):(rest_file_count + size(files,1))), b( (rest_file_count+1) : (rest_file_count + size(files,1))), c( (rest_file_count+1) : (rest_file_count + size(files,1))), d( (rest_file_count+1) : (rest_file_count + size(files,1))), e( (rest_file_count+1) : (rest_file_count + size(files,1))), f( (rest_file_count+1):(rest_file_count + size(files,1))), white_matter_means);
        
        
        R = eye(numel(N))-dctmtx*pinv(dctmtx);
        detrend_X=R*X;
        %To write the nifti object back, I often just write in a 4D nifti
        N_new=N(1);
        N_new.dat.fname='out.nii';
        N_new.dat.dim=[dim(1),dim(2),dim(3),size(X,1)];
        N_new.dat.dtype='float32';

        %write the nifti object to disk with only header informations 
        create(N_new);
        %Because Matlab is column-major, remember to transpose X
        N_new.dat(:,:,:,:)=reshape(detrend_X',dim(1),dim(2),dim(3),numel(N));
        % display data
        figure(3);
        imagesc(N_new.dat(:,:,20,1)); colorbar;
        figure(4);
        imagesc(N(l).dat(:,:,20)); colorbar;
        figure(5);
        imagesc(dctmtx); colorbar;
        figure(6);
        imagesc(white_mask(1).dat(:,:,20)); colorbar;
        % update count
        rest_file_count = rest_file_count + size(files,1);
    end
    assert(rest_file_count == (last-first+1));
end
% spm('defaults', 'FMRI');
% spm_jobman('serial', jobs, '', inputs{:});
