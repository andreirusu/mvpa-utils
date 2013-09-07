from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py
import random


from tools import * 



def main(options) :
    print(DELIM1)
    os.chdir(options.EXPERIMENT_DIR)
    contents=glob.glob('s*')
    count = 0
    overall_mean_error = 0

    os.chdir(options.EXPORT_DIR)

    for dsname in contents :
        # get training data
        train_ds = h5load(options.TRAIN_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5')
        # get test data
        test_ds = h5load(options.TEST_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5')
        # select cluster
        cluster_id = 1
        train_ds.samples = train_ds.samples[:, train_ds.fa.clusters == cluster_id]
        test_ds.samples = test_ds.samples[:, test_ds.fa.clusters == cluster_id]
        print('Processing: ' + dsname)
        train_ds, test_ds = preprocess_train_and_test(train_ds, test_ds)
        #train_ds.chunks[:]  = 1 
        #test_ds.chunks[:]   = 2
        test_ds.chunks = test_ds.chunks + np.max(train_ds.chunks) 
        print(train_ds.chunks)
        print(test_ds.chunks)
        # train clf
        clf = configure_clf(train_ds, options)
        clf.train(train_ds)
        # test clf and display results
        preds = clf(test_ds)
        print(DELIM)
        print(preds.samples.T[0])
        print(test_ds.targets)
        err = np.mean(preds.samples.T[0] == test_ds.targets)
        print(DELIM)
        mean_error = np.asscalar(err)
        overall_mean_error += mean_error
        count += 1
        print('Mean error: '+str(mean_error))
        print(DELIM)
    print(DELIM1)
    overall_mean_error /= count
    print('Overall mean error: '+str(overall_mean_error))
    print(DELIM1)



if __name__ == "__main__" :
    main(parseOptions())


