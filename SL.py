from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *

import matplotlib, scipy, os, glob, h5py, sys, getopt, nibabel, gc, warnings, tempfile, shutil

import numpy as np

from ROIinfo import * 



def get_dataset(dsname, options) :
    # get training data
    ds_path = options.TEST_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5'
    print(ds_path)
    ds = h5load(ds_path)
    return ds



def main(options):
    print(DELIM1)
    os.chdir(options.EXPERIMENT_DIR)
    contents=glob.glob('s*')

    os.chdir(options.EXPORT_DIR)

    ### GLOBAL STATS
    count = 0
    overall_mean_best_measure = 0


    for dsname in contents :
        try:
            # get training data
            res_name = 'SL.R_'+str(options.SL_RADIUS)  +'.'+ options.CLF + '.' + options.CV + '.'+options.TRAIN_PREFIX + '.' +  options.SPACE + '.' + dsname
            
            ds = get_dataset(dsname, options)
            ds = preprocess_rsa(dsname, ds, options)

            measure = configure_sl(ds, options)
            res = measure(ds)
            h5save(res_name + '.hdf5', res)
            # apply statistics to results
            cvmeans = 0
            if options.STATS == 'mean':
                cvmeans = np.mean(res.samples, axis=0)
            elif options.STATS == 'min':
                cvmeans = np.min(res.samples, axis=0)
            elif options.STATS == 'max':
                cvmeans = np.max(res.samples, axis=0)
            else:
                raise NameError('Wrong STATS!')
                return None 
            print('Stats:')
            print(cvmeans)
            if options.PLOT :
                pl.figure()
                pl.hist(cvmeans, 100)
            print(DELIM)
            count += 1
            overall_mean_best_measure += np.min(cvmeans)
            print('Min: '+str(np.min(cvmeans)))
            print('Mean: '+str(np.mean(cvmeans)))
            print('Max: '+str(np.max(cvmeans)))
            print(DELIM)
            if options.SAVE :
                print('Mapping measure back into original voxel space!')
                map_voxels(ds.fa.voxel_indices, cvmeans, ds, res_name + '.nii')
        except IOError as e:
                print e
                print "I/O error({0}): {1}".format(e.errno, e.strerror)
                pass
        except:
            print "Unexpected error:", sys.exc_info()[0]
            raise
    
    pl.show()
    overall_mean_best_measure /= count
    print(DELIM1)
    print('Overall min  measure: '+str(overall_mean_best_measure))
    print(DELIM1)
    print('Done\n')


if __name__ == "__main__" :
    main(parseOptions())


if __debug__:
    debug.active += ["SLC"]


