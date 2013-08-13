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
        res = measure(ds) # returns errors
        cvmeans = (1 - res.samples) * 100 # rescales and returns accuracies
        print('Fold accuracies:')
        print(cvmeans)
        if options.SAVE :
            h5save(res_name + '.hdf5', res)
        print(DELIM)
        mean_accuracy = np.mean(cvmeans)
        print('Mean accuracy: '+str(mean_accuracy))
        print(DELIM)
        overall_mean_accuracy += mean_accuracy
        count += 1
    print(DELIM1)
    overall_mean_accuracy /= count
    print('Overall mean accuracy: '+str(overall_mean_accuracy))
    if options.OUTFILE:
        f = open(options.OUTFILE, "w")
        f.write(str((100 - overall_mean_accuracy) / 100) + "\n")
        f.close()
    print(DELIM1)
    print('Done\n')


if __name__ == "__main__" :
    main(parseOptions())


if __debug__:
    debug.active += ["SLC"]


