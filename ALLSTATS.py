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


def group_test_mean(preds, task1, task2) :
    print(DELIM1)
    print 'task1: ', task1, 'task2: ', task2
    s21 = [ st.ttest_ind(preds[task2][s]['probs'], preds[task1][s]['probs'], equal_var=False)[0].item() for s in preds[task1]['subjects'] ]
    print s21
    print np.mean(s21)
    print 't-statistic = %6.3f pvalue = %6.4f' %  st.ttest_1samp(s21, 0)
    print(DELIM)


def group_test(preds, task1, task2) :
    print(DELIM1)
    print 'task1: ', task1, 'task2: ', task2
    s21 = [ st.levene(preds[task2][s]['probs'], preds[task1][s]['probs'], center='median')[0].item() for s in preds[task1]['subjects'] ]
    print s21
    print np.mean(s21)
    print 't-statistic = %6.3f pvalue = %6.4f' %  st.ttest_1samp(s21, 0)
    print(DELIM)





def test_probs(preds, tasks,  options) :
    group_test_mean(preds, tasks[2], tasks[1])
    group_test_mean(preds, tasks[3], tasks[2])
    group_test_mean(preds, tasks[3], tasks[1])


def test_counts(preds, tasks,  options) :
    print(DELIM1)
    print 's21'
    s21 = [ ( preds[tasks[2]][s]['counts'][1] - preds[tasks[1]][s]['counts'][1] ) for s in preds[tasks[1]]['subjects'] ]
    print s21
    print np.mean(s21)
    print 't-statistic = %6.3f pvalue = %6.4f' %  st.ttest_1samp(s21, 0)
    print(DELIM)

    print 's32'
    s32 = [ ( preds[tasks[3]][s]['counts'][1] - preds[tasks[2]][s]['counts'][1] ) for s in preds[tasks[1]]['subjects'] ]
    print s32
    print np.mean(s32)
    print 't-statistic = %6.3f pvalue = %6.4f' %  st.ttest_1samp(s32, 0)
    print(DELIM)

    
    print 's31'
    s31 = [ ( preds[tasks[3]][s]['counts'][1] - preds[tasks[1]][s]['counts'][1] )  for s in preds[tasks[1]]['subjects'] ]
    print s31
    print np.mean(s31)
    print 't-statistic = %6.3f pvalue = %6.4f' %  st.ttest_1samp(s31, 0)
    print(DELIM)
    


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
   
    #test_counts(preds, tasks,  options)
    
    test_probs(preds, tasks,  options)

    ### save results
    stats={}
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

