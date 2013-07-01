from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py
import random


from tools import * 


random.seed(0)

EXPERIMENT_DIR = '../3_random_subjects'
EXPORT_DIR = os.getcwd()
TRAIN_PREFIX = 'one_back'
TEST_PREFIX = 'reward'
SPACE           = 'full'




def main() :
    print(DELIM1)
    os.chdir(EXPERIMENT_DIR)
    contents=glob.glob('s*')
    count = 0
    overall_mean_accuracy = 0

    os.chdir(EXPORT_DIR)

    for dsname in contents :
        # get training data
        train_ds = h5load(TRAIN_PREFIX + '.' + dsname + '.' + SPACE + '.hdf5')
        # get test data
        test_ds = h5load(TEST_PREFIX + '.' + dsname + '.' + SPACE + '.hdf5')
        print('Processing: ' + dsname)
        train_ds, test_ds = preprocess_train_and_test(train_ds, test_ds)
        #train_ds.chunks[:]  = 1 
        #test_ds.chunks[:]   = 2
        test_ds.chunks = test_ds.chunks + np.max(train_ds.chunks) 
        print(train_ds.chunks)
        print(test_ds.chunks)
        # train clf
        clf = configure_clf(train_ds)
        clf.train(train_ds)
        # test clf and display results
        err = clf(test_ds)
        print(DELIM)
        mean_accuracy = 1 - np.asscalar(err.samples)
        overall_mean_accuracy += mean_accuracy
        count += 1
        print('Mean accuracy: '+str(mean_accuracy))
        print(DELIM)
    print(DELIM1)
    overall_mean_accuracy /= count
    print('Overall mean accuracy: '+str(overall_mean_accuracy))
    print(DELIM1)



if __name__ == "__main__" :
    main()


if __debug__:
    debug.active += ["SLC"]


