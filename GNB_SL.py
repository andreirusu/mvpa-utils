from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *

import matplotlib, scipy, os, glob, h5py, sys, getopt, nibabel, gc, warnings, tempfile, shutil

import numpy as inp

def main(options):
    print(DELIM1)
    os.chdir(options.EXPERIMENT_DIR)
    contents=glob.glob('s*')

    os.chdir(options.EXPORT_DIR)

    for dsname in contents :
        # get training data
        res_name = 'SL.R_'+str(options.SL_RADIUS)  +'.'+ options.CLF + '.' + options.CV + '.'+options.TRAIN_PREFIX + '.' +  options.SPACE + '.' + dsname
        train_ds = h5load(options.TRAIN_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5')
        print('Processing: ' + dsname)
        ds = preprocess(train_ds)
        print('New dataset shape: ' + str(ds.shape))
        print(DELIM)
        measure = configure_sl(ds, options)
        res = measure(ds)
        h5save(res_name + '.hdf5', res)
        print(res.samples)
        cvmeans = 1 - np.mean(res.samples, axis=0)
        cvmeans = cvmeans*100
        if options.PLOT :
            pl.figure()
            pl.hist(cvmeans, 100)
        cvmeans[cvmeans<60] = 0
        print(DELIM1)
        print('Best mean accuracy: '+str(np.max(cvmeans)))
        print(DELIM1)
        print('Mapping measure back into original voxel space!')
        map_voxels(ds.fa.voxel_indices, cvmeans, options.TRAIN_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5', res_name + '.nii')
        print('Done\n')
    pl.show()


if __name__ == "__main__" :
    main(parseOptions())


if __debug__:
    debug.active += ["SLC"]


