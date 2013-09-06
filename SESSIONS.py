from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *

import matplotlib, scipy, os, glob, h5py, sys, getopt, nibabel, gc, warnings, tempfile, shutil, pprint
import matplotlib.pyplot as plt

import numpy as inp


def process_session(subject_dir, sess, options, train_ds, stats):
    print(DELIM)
        ## get test data
    test_path =  options.TEST_PREFIX + '.'+subject_dir+'.'+sess +'.' + options.SPACE  +'.hdf5'
    print('Loading: ' + test_path)
    test_ds = h5load(test_path)
    ### PRE-PROCESSING
    print('Processing: ' + subject_dir)
    #train_ds, test_ds = preprocess_train_and_test(train_ds, test_ds)
    train_ds = preprocess_rsa(subject_dir, train_ds)
    test_ds = preprocess_rsa(subject_dir, test_ds)
    #clf = configure_clf(train_ds, options)
    #clf.train(train_ds)
    #preds = clf(test_ds)
    #print(preds.samples)
    #print(test_ds.targets)
    #print(DELIM1)
    #stats['counts'] = {}
    # for cls in np.unique(train_ds.targets) :
    #     count = np.sum(preds.samples == cls)
    #     stats['counts'][cls] = count
    #     print(cls, count)
    # # compute accuracy if labels are available
    # if not -1 in test_ds.targets :
    #     acc = np.sum(preds.samples.T == test_ds.targets)*100.0/test_ds.targets.size
    #     print('Accuracy: ' + str(acc))
    #     stats['accuracy'] = acc
    #print(DELIM1)
    k = 10000
    plt.subplot(2,2,1)
    plt.hist(np.mean(train_ds.samples, axis=0), 100, alpha=0.5)
    plt.subplot(2,2,2)
    plt.hist(np.std(train_ds.samples, axis=0), 100, alpha=0.5)
    plt.subplot(2,2,3)
    plt.hist(np.mean(test_ds.samples, axis=0), 100, alpha=0.5)
    plt.subplot(2,2,4)
    plt.hist(np.std(test_ds.samples, axis=0), 100, alpha=0.5)
    

def process_subject(subject_dir, options, stats):
    print('Subject: ' + subject_dir)
    # get sessions
    os.chdir(os.path.join(options.EXPERIMENT_DIR, subject_dir, options.TEST_PREFIX))
    print('Looking for sessions in: ' + os.getcwd())
    sessions = glob.glob('sess*')    
    print('Found: ' + str(sessions))
    os.chdir(os.path.join('..', '..', options.EXPORT_DIR))
    print os.getcwd()
    # get training data
    train_path = options.TRAIN_PREFIX + '.' + subject_dir + '.' + options.SPACE + '.hdf5'
    print('Loading: ' + train_path)
    train_ds = h5load(train_path)
    stats['sessions'] = []
    # process test data
    plt.figure()
    for sess in sessions :
        stats['sessions'].append(sess)
        stats[sess] = {}
        process_session(subject_dir, sess, options, train_ds, stats[sess])
    print(DELIM1)

def main(options):
    os.chdir(options.EXPERIMENT_DIR)
    print('Working in '+os.getcwd())
    # assume current directory contains a directory per subject, begining with the symbol 's' 
    contents=glob.glob('s*')
    stats={}
    stats['subjects'] = []
    print('Found subjects: ' + str(contents))
    print(DELIM1)
    for subject_dir in contents :
        stats['subjects'].append(subject_dir)
        stats[subject_dir] = {}
        process_subject(subject_dir, options, stats[subject_dir])
    # save stats
    res_name    = 'PRED.'+ options.CLF + '.'+options.TRAIN_PREFIX+ '.'+options.TEST_PREFIX  + '.' +  options.SPACE
    h5save(res_name + '.hdf5', stats) 
    # print results
    pprint.pprint(stats, width=80)
    plt.show()
       
if __name__ == "__main__" :
    main(parseOptions())

