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

    ### GLOBAL STATS
    count = 0
    overall_mean_best_measure = 0


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
        # apply statistics to results
        cvmeans = 0
        if options.STATS == 'mean':
            cvmeans = 1 - np.mean(res.samples, axis=0)
        elif options.STATS == 'min':
            cvmeans = 1 - np.max(res.samples, axis=0)
        elif options.STATS == 'max':
            cvmeans = 1 - np.min(res.samples, axis=0)
        else:
            raise NameError('Wrong STATS!')
            return None 
        cvmeans = cvmeans*100
        print('Fold accuracies:')
        print(cvmeans)
        if options.PLOT :
            pl.figure()
            pl.hist(cvmeans, 100)
        print(DELIM)
        count += 1
        overall_mean_best_measure += np.max(cvmeans)
        print('Best accuracy: '+str(np.max(cvmeans)))
        print(DELIM)
        print('Mapping measure back into original voxel space!')
        map_voxels(ds.fa.voxel_indices, cvmeans, options.TRAIN_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5', res_name + '.nii')
    pl.show()
    overall_mean_best_measure /= count
    print(DELIM1)
    print('Overall mean best measure: '+str(overall_mean_best_measure))
    print(DELIM1)
    print('Done\n')


if __name__ == "__main__" :
    main(parseOptions())


if __debug__:
    debug.active += ["SLC"]


