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
CURRENT_TASK = 'one_back' 
EXPORT_DIR = '/Users/andreirusu/mvpa/datasets'
SPACE = 'full' #'roi'
MASK = 'rmask.nii'
#MASK = 'brwROImask.nii'

def get_chunks():
    chunks = np.arange(1,6).repeat(2*6)
    chunks = np.concatenate((chunks, chunks), axis=0)
    return chunks


def get_labels():
    labels = np.arange(1,3).repeat(6*10)
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
        volumes = volumes[0:120] 
        print(volumes)
        print(len(volumes))
        ds = fmri_dataset(samples = volumes, targets = get_labels(), chunks = get_chunks(), mask=os.path.join(EXPERIMENT_DIR, subject_dir, 'one_back', 'struct', 'PROC', MASK))
        print(ds.shape)
        print(ds.nfeatures)
        print(ds.targets)
        print(ds.chunks)
        ds.save(os.path.join(EXPORT_DIR, CURRENT_TASK + '.' + subject_dir + '.' + SPACE + '.hdf5'))
        ### PRE-PROCESSING TEST
        ds = preprocess(ds)


if __name__ == "__main__" :
    main()

