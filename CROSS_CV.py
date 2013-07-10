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
    overall_mean_accuracy = 0

    for dsname in contents :
        # get training data
        res_name    = 'CROSS_CV.'+ options.CV + '.' + options.CLF + '.'+options.TRAIN_PREFIX+ '.'+options.TEST_PREFIX  + '.' +  options.SPACE + '.' + dsname
        train_ds    = h5load(options.TRAIN_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5')
        test_ds     = h5load(options.TEST_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5')
        print('Processing: ' + dsname)
        train_ds, test_ds = preprocess_train_and_test(train_ds, test_ds)
        train_ds.chunks[:]  = 1 
        test_ds.chunks[:]   = 2
        #test_ds.chunks = test_ds.chunks + np.max(train_ds.chunks) 
        ds = dataset_wizard(samples=np.concatenate((train_ds.samples, test_ds.samples), axis=0), targets=np.concatenate((train_ds.targets, test_ds.targets), axis=0), chunks=np.concatenate((train_ds.chunks, test_ds.chunks), axis=0))
        ds.fa['voxel_indices'] = train_ds.fa.voxel_indices
        print(ds.targets)
        print(ds.chunks)
        print('New dataset shape: ' + str(ds.shape))
        print(DELIM)
        measure = configure_cv(ds, options)
        res = measure(ds)
        h5save(res_name + '.hdf5', res)
        cvmeans = 100 - res.samples*100
        print('Fold accuracies:')
        print(cvmeans)
        cvmeans = np.mean(cvmeans, axis=0)
        print(DELIM)
        print('Mean accuracy: '+str(np.max(cvmeans)))
        print(DELIM)
        overall_mean_accuracy += np.max(cvmeans)
        count += 1
    print(DELIM1)
    overall_mean_accuracy /= count
    print('Overall mean accuracy: '+str(overall_mean_accuracy))
    print(DELIM1)
    print('Done\n')


if __name__ == "__main__" :
    main(parseOptions())


if __debug__:
    debug.active += ["SLC"]


