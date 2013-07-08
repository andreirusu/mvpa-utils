from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py
import random


from tools import * 

EXPERIMENT_DIR  = '../3_random_subjects'
EXPORT_DIR      = '../datasets'
TRAIN_PREFIX    = 'one_back'
#TRAIN_PREFIX    = 'reward'
#SPACE           = 'full'
SPACE           = 'roi'


def configure(ds):
    return OneWayAnova()

 

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
        measure = configure(ds)
        res = measure(ds)
        h5save('ANOVA.' + SPACE+'.'+TRAIN_PREFIX + '.' +  dsname+ '.hdf5', res)
        pvals = res.fa.fprob
        print('Min P-value: ' + str(np.nanmin(pvals)))
        res = res.samples[0, :]
        pl.figure()
        pl.hist(res, 100)
        print('Mapping measure back into original voxel space!')
        map_voxels(ds.fa.voxel_indices, res, TRAIN_PREFIX + '.' + dsname + '.' + SPACE + '.hdf5', 'ANOVA.' + TRAIN_PREFIX + '.' +  SPACE+'.'+dsname+ '.nii')
        print(DELIM1)
        print('Done\n')
    pl.show()


if __name__ == "__main__" :
    main()


if __debug__:
    debug.active += ["SLC"]


