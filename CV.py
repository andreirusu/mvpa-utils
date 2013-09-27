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
    overall_mean_error = 0

    for dsname in contents :
        try:
            # get training data
            res_name = 'CV.'+ options.CV + '.' + options.CLF + '.'+options.TRAIN_PREFIX + '.' +  options.SPACE + '.' + dsname
            train_ds = h5load(options.TRAIN_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5')
            print('Processing: ' + dsname)
            ds = preprocess(train_ds, options)
            print('New dataset shape: ' + str(ds.shape))
            print(DELIM)
            measure = configure_cv(ds, options)
            res = measure(ds) # returns errors
            cvmeans = res.samples # rescales and returns error
            print('Fold error:')
            print(cvmeans)
            if options.SAVE :
                h5save(res_name + '.hdf5', res)
            print(DELIM)
            mean_error = np.mean(cvmeans)
            print('Mean error: '+str(mean_error))
            print(DELIM)
            overall_mean_error += mean_error
            count += 1
        except IOError as e:
                print "I/O error({0}): {1}".format(e.errno, e.strerror)
                pass
        except:
            print "Unexpected error:", sys.exc_info()[0]
            raise
    print(DELIM1)
    overall_mean_error /= count
    print('Overall mean error: '+str(overall_mean_error))
    if options.OUTFILE:
        f = open(options.OUTFILE, "w")
        f.write(str(overall_mean_error) + "\n")
        f.close()
    print(DELIM1)
    print('Done\n')


if __name__ == "__main__" :
    main(parseOptions())


if __debug__:
    debug.active += ["SLC"]


