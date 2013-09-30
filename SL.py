from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *

import matplotlib, scipy, os, glob, h5py, sys, getopt, nibabel, gc, warnings, tempfile, shutil

import numpy as np

from ROIinfo import * 


def concatDatasets(ds1, ds2):
    ds = dataset_wizard(samples=np.concatenate((ds1.samples, ds2.samples), axis=0), targets=np.concatenate((ds1.targets, ds2.targets), axis=0), chunks=np.concatenate((ds1.chunks, ds2.chunks), axis=0))
    ds.fa['voxel_indices'] = ds1.fa['voxel_indices']
    return ds 



def get_dataset(dsname, options) :
    one_back = h5load('one_back.' + dsname + '.' + options.SPACE + '.hdf5')
    reward = h5load('reward.' + dsname + '.' + options.SPACE + '.hdf5')
    #rest_sess1 = h5load('rest.sess1.' + dsname + '.' + options.SPACE + '.hdf5')
    #rest_sess2 = h5load('rest.sess2.' + dsname + '.' + options.SPACE + '.hdf5')
    #rest_sess3 = h5load('rest.sess3.' + dsname + '.' + options.SPACE + '.hdf5')
    print('Processing: ' + dsname)
    reward.chunks += np.max(one_back.chunks)
    #rest_sess1.chunks[:] += np.max(reward.chunks)
    #rest_sess2.chunks[:] += np.max(rest_sess1.chunks)
    #rest_sess3.chunks[:] += np.max(rest_sess2.chunks)
    ds = concatDatasets(one_back, reward)
    ds = concatDatasets(ds, reward)
    #ds = concatDatasets(ds, rest_sess1)
    #ds = concatDatasets(ds, rest_sess2)
    #ds = concatDatasets(ds, rest_sess3)
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
            overall_mean_best_measure += np.mean(cvmeans)
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
    print('Overall mean  measure: '+str(overall_mean_best_measure))
    print(DELIM1)
    print('Done\n')


if __name__ == "__main__" :
    main(parseOptions())


if __debug__:
    debug.active += ["SLC"]


