from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *

import matplotlib.pyplot as plt
import scipy, os, glob, h5py, sys, getopt, nibabel, gc, warnings, tempfile, shutil, matplotlib.image

import numpy as inp


def concatDatasets(ds1, ds2):
    ds = dataset_wizard(samples=np.concatenate((ds1.samples, ds2.samples), axis=0), targets=np.concatenate((ds1.targets, ds2.targets), axis=0), chunks=np.concatenate((ds1.chunks, ds2.chunks), axis=0))
    ds.fa['voxel_indices'] = ds1.fa['voxel_indices']
    return ds 


def main(options):
    print(DELIM1)
    os.chdir(options.EXPERIMENT_DIR)
    contents=glob.glob('s*')

    os.chdir(options.EXPORT_DIR)
    
    ### GLOBAL STATS
    count = 0
    overall_mean_accuracy = 0

    #plt.figure(figsize=(30, 10), dpi=80)
    for dsname in contents :
        # get training data
        res_name = 'FullRSA.'+ options.RSA + '.' + options.CLF + '.'+options.TRAIN_PREFIX + '.' +  options.SPACE + '.' + dsname
        one_back = h5load('one_back.' + dsname + '.' + options.SPACE + '.hdf5')
        reward_sess1 = h5load('reward.' + dsname + '.sess1'+ '.' + options.SPACE + '.hdf5')
        reward_sess2 = h5load('reward.' + dsname + '.sess2'+ '.' + options.SPACE + '.hdf5')
        rest_sess1 = h5load('rest.' + dsname + '.sess1'+ '.' + options.SPACE + '.hdf5')
        rest_sess2 = h5load('rest.' + dsname + '.sess2'+ '.' + options.SPACE + '.hdf5')
        rest_sess3 = h5load('rest.' + dsname + '.sess3'+ '.' + options.SPACE + '.hdf5')
        print('Processing: ' + dsname)
        one_back.chunks[:] = 0
        reward_sess1.chunks[:] = 1
        reward_sess2.chunks[:] = 2
        rest_sess1.chunks[:] = 3
        rest_sess2.chunks[:] = 4
        rest_sess3.chunks[:] = 5
        #ds = reward_sess2
        #ds = concatDatasets(one_back, reward_sess1)
        #ds = concatDatasets(ds, rest_sess1)
        #ds = concatDatasets(one_back, rest_sess1)
        #ds = concatDatasets(ds, reward_sess2)
        #ds = concatDatasets(ds, rest_sess1)
        #ds = concatDatasets(ds, rest_sess2)
        #ds = concatDatasets(ds, rest_sess3)
        ds = cleanup(zscoreChunks(removeConstantColums(removeNaNColumns(ds))))
        print(ds.targets)
        #np.random.shuffle(ds.targets)
        print(ds.chunks)
        print('New dataset shape: ' + str(ds.shape))
        print(DELIM)
        if options.PLOT : 
            ### TEMP
            dsm = DSMatrix(ds.samples, options.RSA)
            dsm1 = DSMatrix(ds.targets, 'confusion')
            print(dsm.get_vector_form().shape)
            print(dsm1.get_vector_form().shape)
            test_mat = np.asarray([np.squeeze(dsm.get_vector_form()), np.squeeze(dsm1.get_vector_form())])
            print(test_mat.shape) 
            dsm2 = DSMatrix(test_mat, 'spearman')
            print(dsm2)
            count += 1
            plt.figure()
            plt.subplot(1, 2, 1)
            plt.imshow(dsm1.get_full_matrix())
            plt.colorbar()
            plt.subplot(1, 2, 2)
            plt.imshow(dsm.get_full_matrix())
            plt.colorbar()
            ### END TEMP
        measure = configure_rsa(ds, options)
        res = measure(ds) 
        print(DELIM1)
        print('Measure: '+ str(res))
        print(DELIM1)
        continue
        if options.SAVE :
            h5save(res_name + '.hdf5', res)
    plt.show()
    print('Done\n')


if __name__ == "__main__" :
    main(parseOptions())


if __debug__:
    debug.active += ["SLC"]


