from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *

from mvpa2.mappers.svd import SVDMapper
#from mvpa2.mappers.mdp_adaptor import ICAMapper, PCAMapper

import scipy, os, glob, h5py, sys, getopt, nibabel, gc, warnings, tempfile, shutil, pprint

import numpy as np

import multiprocessing as mp
import scipy.stats as st
    
### GLOBAL STATS
count = 0
overall_mean_err = 0


from ROIinfo import *


def get_preds(task, options):
    try:
        res_name    = 'PRED.'+ options.ROI +'.' + options.HEM+ '.' + options.CLF + '.'+options.TRAIN_PREFIX+ '.'+ task  + '.' +  options.SPACE
        stats = h5load(res_name + '.hdf5') 
        print res_name
        print stats
        print(DELIM)
        return stats
    except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            pass
    except:
        print "Unexpected error:", sys.exc_info()[0]
        raise

def main(options):
    global count
    global overall_mean_err
    os.chdir(options.EXPERIMENT_DIR)
    print('Working in '+os.getcwd())
    print(DELIM)
    print('\nROI INFO')
    print(DELIM)
    print('ROIs:')
    print(DELIM)
    pprint.pprint(ROI, width=40)
    print(DELIM)
    print('ROIids:')
    print(DELIM)
    pprint.pprint(ROIids, width=60)
    print(' ')
    print(DELIM)
    # assume current directory contains a directory per subject, begining with the symbol 's' 
    contents=glob.glob('s*')
    os.chdir(options.EXPORT_DIR)
    # save stats
    tasks = ['reward', 'rest.sess1', 'rest.sess2', 'rest.sess3']
    
    preds = {}
    for task in tasks :
        preds[task] = get_preds(task, options)
    print preds
   
    ### save results
    stats={}
    stats['preds'] = preds
    
    # save stats
    res_name    = 'ALLSTATS.'+ options.ROI +'.' + options.HEM+ '.' + options.CLF + '.'+options.TRAIN_PREFIX+ '.'+options.TEST_PREFIX  + '.' +  options.SPACE
    h5save(res_name + '.hdf5', stats) 
   
    # print results
    print(DELIM1)
    print('Global stats:')
    pprint.pprint(stats, width=80)
    if count > 0 :
        overall_mean_err /= count
        print(DELIM1)
        print('Overall mean measure: '+str(overall_mean_err))
    print(DELIM1)
    pl.show()
    print('Done\n')


if __name__ == "__main__" :
    main(parseOptions())

