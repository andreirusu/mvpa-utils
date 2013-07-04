from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py
import sys
import nibabel
from progress_bar import *
import warnings
import tempfile, shutil
from subprocess import *
from datetime import *
import gc as gc	

from tools import *

random.seed(0)

EXPERIMENT_DIR  = '../3_random_subjects'
EXPORT_DIR      = '../datasets'
TRAIN_PREFIX    = 'one_back'
SPACE           = 'full'


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
        h5save('SL.R_'+str(SL_RADIUS)+'.'+ SPACE + '.' + dsname+ '.hdf5', res)
        print(res.samples)
        cvmeans = 1 - np.max(res.samples, axis=0)
        pl.figure()
        cvmeans = cvmeans*100
        pl.hist(cvmeans, 100)
        print(DELIM1)
        print('Best min accuracy: '+str(np.max(cvmeans)))
        print(DELIM1)
        print('Mapping measure back into original voxel space!')
        map_voxels(ds.fa.voxel_indices, cvmeans, TRAIN_PREFIX + '.' + dsname + '.' + SPACE + '.hdf5', 'SL.R_'+str(SL_RADIUS)+'.'+ SPACE + '.' + dsname+ '.nii')
        print('Done\n')
    pl.show()


if __name__ == "__main__" :
    main()


if __debug__:
    debug.active += ["SLC"]


