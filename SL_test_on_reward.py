from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py
import random


from tools import * 


random.seed(0)

EXPERIMENT_DIR  = '../3_random_subjects'
EXPORT_DIR      = '../datasets'
TRAIN_PREFIX    = 'one_back'
TEST_PREFIX     = 'reward'
SPACE           = 'full'


def main() :
    print(DELIM1)
    os.chdir(EXPERIMENT_DIR)
    contents=glob.glob('s*')

    os.chdir(EXPORT_DIR)

    for dsname in contents :
        # get training data
        train_ds = h5load(TRAIN_PREFIX + '.' + dsname + '.' + SPACE + '.hdf5')
        # get test data
        test_ds = h5load(TEST_PREFIX + '.' + dsname + '.' + SPACE + '.hdf5')
        print('Processing: ' + dsname)
        train_ds, test_ds = preprocess_train_and_test(train_ds, test_ds)
        train_ds.chunks[:]  = 1 
        test_ds.chunks[:]   = 2
        ds = dataset_wizard(samples=np.concatenate((train_ds.samples, test_ds.samples), axis=0), targets=np.concatenate((train_ds.targets, test_ds.targets), axis=0), chunks=np.concatenate((train_ds.chunks, test_ds.chunks), axis=0))
        ds.fa['voxel_indices'] = train_ds.fa.voxel_indices
        print(ds.chunks)
        print('New dataset shape: ' + str(ds.shape))
        print(DELIM)
        sl = configure_sl(ds)
        res = sl(ds)
        h5save('CROSS_SL.R_'+str(SL_RADIUS)+'.'+ SPACE + '.' + dsname+ '.hdf5', res)
        print(res.samples)
        cvmeans = 1 - np.mean(res.samples, axis=0)
        #pl.figure()
        #pl.hist(cvmeans, 100)
        print('Mapping seachlight results back into original voxel space!')
        cvmeans = cvmeans*100
        cvmeans[cvmeans < 55] = 0

        map_voxels(ds.fa.voxel_indices, cvmeans, TRAIN_PREFIX + '.' + dsname + '.' + SPACE + '.hdf5', 'CROSS_SL.R_'+str(SL_RADIUS)+'.'+ SPACE + '.' + dsname+ '.nii')

        print(DELIM1)
        print('Best accuracy: '+str(np.max(cvmeans)))
        print(DELIM1)
        print('Done')
    pl.show()


if __name__ == "__main__" :
    main()


if __debug__:
    debug.active += ["SLC"]


