from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *
from optparse import OptionParser

import matplotlib, scipy, os, glob, h5py, sys, getopt, nibabel, gc, warnings, tempfile, shutil

import numpy as inp


def configure(ds):
    return OneWayAnova()

 
def main(options):
    print(DELIM1)
    os.chdir(options.EXPERIMENT_DIR)
    contents=glob.glob('s*')

    os.chdir(options.EXPORT_DIR)

    for dsname in contents :
        # get training data
        train_ds = h5load(options.TRAIN_PREFIX + '.' + dsname + '.' +options.SPACE + '.hdf5')
        print('Processing: ' + dsname)
        ds = preprocess(train_ds)
        print('New dataset shape: ' + str(ds.shape))
        print(DELIM)
        measure = configure(ds)
        res = measure(ds)
        h5save('ANOVA.' + options.SPACE+'.'+options.TRAIN_PREFIX + '.' +  dsname+ '.hdf5', res)
        pvals = res.fa.fprob
        print('Min P-value: ' + str(np.nanmin(pvals)))
        res = res.samples[0, :]
        if options.PLOT :
            pl.figure()
            pl.hist(res, 100)
        print('Mapping measure back into original voxel space!')
        map_voxels(ds.fa.voxel_indices, res, options.TRAIN_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5', 'ANOVA.' + options.TRAIN_PREFIX + '.' +  options.SPACE+'.'+dsname+ '.nii')
        print(DELIM1)
        print('Done\n')
    pl.show()


if __name__ == "__main__" :
    main(parseOptions())


if __debug__:
    debug.active += ["SLC"]


