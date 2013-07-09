from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *

import matplotlib, scipy, os, glob, h5py, sys, getopt, nibabel, gc, warnings, tempfile, shutil

import numpy as inp

EXPERIMENT_DIR  = '../3_random_subjects'
EXPORT_DIR      = '../datasets'
TRAIN_PREFIX    = 'one_back'
#TRAIN_PREFIX    = 'reward'
#SPACE           = 'full'
SPACE           = 'roi'


def main():
    print(DELIM1)
    os.chdir(EXPERIMENT_DIR)
    contents=glob.glob('s*')

    os.chdir(EXPORT_DIR)

    for dsname in contents :
        # get training data
        train_ds = h5load(TRAIN_PREFIX + '.' + dsname + '.' + SPACE + '.hdf5')
        print('Processing: ' + dsname)
        ds = preprocess(train_ds)
        print('New dataset shape: ' + str(ds.shape))
        print(DELIM)
        measure = configure_sl(ds)
        res = measure(ds)
        h5save('SL.R_'+str(SL_RADIUS)+'.'+TRAIN_PREFIX + '.' +  SPACE + '.' + dsname+ '.hdf5', res)
        print(res.samples)
        cvmeans = 1 - np.mean(res.samples, axis=0)
        pl.figure()
        cvmeans = cvmeans*100
        pl.hist(cvmeans, 100)
        cvmeans[cvmeans<60] = 0
        print(DELIM1)
        print('Best mean accuracy: '+str(np.max(cvmeans)))
        print(DELIM1)
        print('Mapping measure back into original voxel space!')
        map_voxels(ds.fa.voxel_indices, cvmeans, TRAIN_PREFIX + '.' + dsname + '.' + SPACE + '.hdf5', 'SL.R_'+str(SL_RADIUS)+'.'+TRAIN_PREFIX + '.' +  SPACE + '.' + dsname+ '.nii')
        print('Done\n')
    pl.show()


if __name__ == "__main__" :
    main()


if __debug__:
    debug.active += ["SLC"]


