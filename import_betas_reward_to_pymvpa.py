from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py

from tools import *

from ROIinfo import *



EXPERIMENT_DIR = '/Volumes/backup/mvpa/5_random_subjects'
#EXPERIMENT_DIR = '/Volumes/backup/mvpa/functional'
CURRENT_TASK = 'reward' 
EXPORT_DIR = '/Users/andreirusu/mvpa/datasets/gray_all_reward'
SPACE = 'full'
MASK = 'rmask.nii'
#SPACE = 'roi'
#MASK = 'brwROImask.nii'
CLUSTERS = 'srwROIclusters.nii'


def get_chunks():
    chunks = np.arange(1,3).repeat(32)
    chunks = np.concatenate((chunks, chunks), axis=0)
    return chunks


def get_labels():
    labels = np.arange(1,3).repeat(64)
    return labels



def get_class(onsets, sorted_onsets, ind, i):
    if sorted_onsets[i] == onsets[ind[0]] :
        current_class = 0
    else :
        if sorted_onsets[i] == onsets[ind[1]] :
            current_class = 1
        else :
            assert(False)
    return current_class



def main():
    os.chdir(EXPERIMENT_DIR)
    print('Working in '+os.getcwd())
    # assume current directory contains a directory per subject, begining with the symbol 's' 
    contents=glob.glob('s*')
    print('Found subjects: ' + str(contents))
    for subject_dir in contents :
        try:
            print('Subject: ' + subject_dir)
            os.chdir(os.path.join(EXPERIMENT_DIR, subject_dir, CURRENT_TASK, 'analysis', '1'))
            # import clusters 
            clusters_ds = fmri_dataset(samples = os.path.join(EXPERIMENT_DIR, subject_dir, 'one_back', 'struct', 'PROC', CLUSTERS), targets = [-1], chunks = [-1], mask=os.path.join(EXPERIMENT_DIR, subject_dir, 'one_back', 'struct', 'PROC', MASK))
            cluster_ids = np.abs(np.round(clusters_ds.samples[0]))
            print(np.sum(cluster_ids > 0))
            # import volumes
            volumes = glob.glob('beta_*img')
            volumes = volumes[0:256:2] 
            with open('trial_onsets.txt', 'r') as f:
                lines = [line.strip() for line in f]
            onsets = np.array([float(i) for i in lines[0].split(' ')]) 
            print(volumes)
            print(len(volumes))
            ds = fmri_dataset(samples = volumes, targets = get_labels(), chunks = get_chunks(), mask=os.path.join(EXPERIMENT_DIR, subject_dir, 'one_back', 'struct', 'PROC', MASK))
            print(ds.shape)
            print(ds.nfeatures)
            print(ds.targets)
            print(ds.chunks)
            """
            # remove trials which are too close together
            print(onsets)
            sorted_onsets_ids = np.argsort(onsets, axis=0)
            print sorted_onsets_ids
            sorted_onsets = onsets[sorted_onsets_ids]
            print(sorted_onsets)
            ind  = [0, 64]
            experiment_offset = 5 
            valid_offset = 4 + experiment_offset
            valid = [False for onset in onsets]

            # handle the first onset
            i = 0
            current_class = get_class(onsets, sorted_onsets, ind, i)
            next_ind = np.array(ind)
            next_ind[current_class] += 1
            next_class = get_class(onsets, sorted_onsets, next_ind, i+1)
            print(sorted_onsets[i], ind, onsets[ind[0]], onsets[ind[1]], current_class, next_class)
            assert(ds.targets[ind[current_class]] == (current_class + 1))
            assert(ds.targets[ind[next_class]] == (next_class + 1))
            if  ((sorted_onsets[i+1] - sorted_onsets[i]) > valid_offset) :
                valid[ind[current_class]] = True 
            ind[current_class] += 1
            print('Valid_count: ' + str(np.sum(np.array(valid) == True)))

            # handle all intermediary onsets
            for i in range(1, np.size(sorted_onsets)-1,1) :
                prev_class = current_class 
                current_class = get_class(onsets, sorted_onsets, ind, i)
                next_ind = np.array(ind)
                next_ind[current_class] += 1
                next_class = get_class(onsets, sorted_onsets, next_ind, i+1)
                assert(ds.targets[ind[prev_class] - 1] == (prev_class + 1))
                assert(ds.targets[ind[current_class]] == (current_class + 1))
                assert(ds.targets[ind[next_class]] == (next_class + 1))
                print(sorted_onsets[i], ind, onsets[ind[0]], onsets[ind[1]], prev_class, current_class, next_class)
                if (((sorted_onsets[i+1] - sorted_onsets[i]) > valid_offset)  ) and  (((sorted_onsets[i] - sorted_onsets[i-1]) > valid_offset) ) :
                    valid[ind[current_class]] = True 
                ind[current_class] += 1
                print('Valid_count: ' + str(np.sum(np.array(valid) == True)))

            #handle the last onset
            i = np.size(sorted_onsets) - 1
            prev_class = current_class 
            current_class = get_class(onsets, sorted_onsets, ind, i)
            assert(ds.targets[ind[prev_class] - 1] == (prev_class + 1))
            assert(ds.targets[ind[current_class]] == (current_class + 1))
            print(sorted_onsets[i], ind,  prev_class, current_class)
            if ( ((sorted_onsets[i] - sorted_onsets[i-1]) > valid_offset) ) :
                valid[ind[current_class]] = True 
            ind[current_class] += 1
            print('Valid_count: ' + str(np.sum(np.array(valid) == True)))

            assert(ind[0] == (i+1)/2)
            assert(ind[1] == i+1)
            print(valid)
            ds.sa['onsets'] = onsets
            ds.fa['clusters'] = cluster_ids
            ds.sa['valid'] = valid
            ds = ds [ds.sa.valid == True]
            """
            # save dataset
            ds.save(os.path.join(EXPORT_DIR,  CURRENT_TASK + '.' + subject_dir + '.' + SPACE + '.hdf5'))
            ### PRE-PROCESSING TEST
            #ds = preprocess(ds)
        except:
            print('Exception...' + str(sys.exc_info()))
            continue


if __name__ == "__main__" :
    main()

