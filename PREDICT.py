from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *

import matplotlib, scipy, os, glob, h5py, sys, getopt, nibabel, gc, warnings, tempfile, shutil

import numpy as inp

def process_session(subject_dir, sess, options):
    # get training data
    train_path = options.TRAIN_PREFIX + '.' + subject_dir + '.' + options.SPACE + '.hdf5'
    print('Loading: ' + train_path)
    train_ds = h5load(train_path)
    ## get test data
    test_path =  options.TEST_PREFIX + '.'+subject_dir+'.'+sess +'.' + options.SPACE  +'.hdf5'
    print('Loading: ' + test_path)
    test_ds = h5load(test_path)
    ### PRE-PROCESSING
    print('Processing: ' + subject_dir)
    train_ds, test_ds = preprocess_train_and_test(train_ds, test_ds)
    clf = configure_clf(train_ds, options)
    clf.train(train_ds)
    preds = clf(test_ds)
    #print(preds.samples)
    #print(test_ds.targets)
    print(DELIM1)
    for cls in np.unique(train_ds.targets) :
        print(cls, np.sum(preds.samples == cls))
    # compute accuracy if labels are available
    if not -1 in test_ds.targets :
        print('Accuracy: ' + str(np.sum(preds.samples.T == test_ds.targets)*100.0/test_ds.targets.size))
    print(DELIM1)



def process_subject(subject_dir, options):
    print('Subject: ' + subject_dir)
    os.chdir(os.path.join(options.EXPERIMENT_DIR, subject_dir, options.TEST_PREFIX))
    print('Looking for sessions in: ' + os.getcwd())
    sessions = glob.glob('sess*')
    os.chdir(os.path.join('..', '..', options.EXPORT_DIR))
    print('Found: ' + str(sessions))
    for sess in sessions :
        process_session(subject_dir, sess, options)
    
def main(options):
    os.chdir(options.EXPERIMENT_DIR)
    print('Working in '+os.getcwd())
    # assume current directory contains a directory per subject, begining with the symbol 's' 
    contents=glob.glob('s*')

    print('Found subjects: ' + str(contents))
    for subject_dir in contents :
        process_subject(subject_dir, options)
        
       
if __name__ == "__main__" :
    main(parseOptions())

