from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py

from tools import *


#EXPERIMENT_DIR = '/Users/andreirusu/mvpa/3_random_subjects'
EXPERIMENT_DIR = '/Volumes/SAMSUNG/mvpa/3_random_subjects'
#EXPERIMENT_DIR = '/Volumes/SAMSUNG/mvpa/functional'
CURRENT_TASK = 'reward' 
EXPORT_DIR = '/Users/andreirusu/mvpa/datasets'
SPACE = 'full'
MASK = 'rmask.nii'
#SPACE = 'roi'
#MASK = 'brwROImask.nii'



def get_chunks():
    chunks = np.arange(1,3).repeat(32)
    chunks = np.concatenate((chunks, chunks), axis=0)
    return chunks


def get_labels():
    labels = np.arange(1,3).repeat(64)
    return labels


def main():
    os.chdir(EXPERIMENT_DIR)
    print('Working in '+os.getcwd())
    # assume current directory contains a directory per subject, begining with the symbol 's' 
    contents=glob.glob('s*')
    print('Found subjects: ' + str(contents))
    for subject_dir in contents :
        print('Subject: ' + subject_dir)
        os.chdir(os.path.join(EXPERIMENT_DIR, subject_dir, CURRENT_TASK, 'analysis', '1'))
        volumes = glob.glob('beta_*img')
        volumes = volumes[0:256:2] 
        with open('trial_onsets.txt', 'r') as f:
            lines = [line.strip() for line in f]
        onsets = [float(i) for i in lines[0].split(' ')] 
        print(onsets)
        print(volumes)
        print(len(volumes))
        ds = fmri_dataset(samples = volumes, targets = get_labels(), chunks = get_chunks(), mask=os.path.join(EXPERIMENT_DIR, subject_dir, 'one_back', 'struct', 'PROC', MASK))
        print(ds.shape)
        print(ds.nfeatures)
        print(ds.targets)
        print(ds.chunks)
        ds.sa['onsets'] = onsets
        # remove trials which are too close together
        sorted_onsets = sorted(ds.sa.onsets)
        ind  = [0, 64]
        valid_offset = 9
        valid = [False for onset in onsets]

        # handle the first onset
        i = 0
        print(sorted_onsets[i], ind)
        if sorted_onsets[i] == onsets[ind[0]] :
            current_class = 0
        else :
            if sorted_onsets[i] == onsets[ind[1]] :
                current_class = 1
            else :
                assert(False)

        if ((sorted_onsets[i+1] - sorted_onsets[i]) > valid_offset) :
            valid[ind[current_class]] = True 

        ind[current_class] += 1

        # handle all intermediary onsets
        for i in range(1, np.size(sorted_onsets)-1,1) :
            print(sorted_onsets[i], ind, onsets[ind[0]], onsets[ind[1]])
            if sorted_onsets[i] == onsets[ind[0]] :
                current_class = 0
            else :
                if sorted_onsets[i] == onsets[ind[1]] :
                    current_class = 1
                else :
                    assert(False)

            if ((sorted_onsets[i] - sorted_onsets[i-1]) > valid_offset) and ((sorted_onsets[i+1] - sorted_onsets[i]) > valid_offset) :
                valid[ind[current_class]] = True 

            ind[current_class] += 1

        #handle the last onset
        i = np.size(sorted_onsets) - 1
        print(sorted_onsets[i], ind)
        if sorted_onsets[i] == onsets[ind[0]] :
            current_class = 0
        else :
            if sorted_onsets[i] == onsets[ind[1]] :
                current_class = 1
            else :
                assert(False)

        if ((sorted_onsets[i] - sorted_onsets[i-1]) > valid_offset) :
            valid[ind[current_class]] = True 

        ind[current_class] += 1

        assert(ind[0] == (i+1)/2)
        assert(ind[1] == i+1)
        print(valid)
        ds.sa['valid'] = valid
        ds = ds [ds.sa.valid == True]
        print('Valid_count: ' + str(np.sum(np.array(valid) == True)))
        # save dataset
        ds.save(os.path.join(EXPORT_DIR,  CURRENT_TASK + '.' + subject_dir + '.' + SPACE + '.hdf5'))
        ### PRE-PROCESSING TEST
        ds = preprocess(ds)



if __name__ == "__main__" :
    main()

