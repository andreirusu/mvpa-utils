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
        res_name = 'CV.'+ options.CV + '.' + options.CLF + '.'+options.TRAIN_PREFIX + '.' +  options.SPACE + '.' + dsname
        train_ds = h5load(options.TRAIN_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5')
        print('Processing: ' + dsname)
        ds = preprocess(train_ds)
        print('New dataset shape: ' + str(ds.shape))
        print(DELIM)
        measure = configure_cv(ds, options)
        res = measure(ds)
        h5save(res_name + '.hdf5', res)
        print('Fold ERRORS:')
        print(res.samples)
        cvmeans = 1 - np.mean(res.samples, axis=0)
        cvmeans = cvmeans*100
        print(DELIM)
        print('Best mean accuracy: '+str(np.max(cvmeans)))
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


