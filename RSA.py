from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *

import matplotlib.pyplot as plt
import scipy, os, glob, h5py, sys, getopt, nibabel, gc, warnings, tempfile, shutil, matplotlib.image

import numpy as inp


def loadSLResults(dsname, options):
    res_name = 'SL.R_'+str(options.SL_RADIUS)  +'.'+ options.CLF + '.' + options.CV + '.'+options.TRAIN_PREFIX + '.' +  options.SPACE + '.' + dsname  
    print('Loading: ' + res_name)
    res = h5load(res_name + '.hdf5')
    cvmeans = 0
    # apply statistics to results
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
    return cvmeans


def fsel(stats,ratio) :
    print(DELIM)
    slicer =  stats > np.max(stats)*ratio
    print(np.sum(slicer))
    print(DELIM)

    return slicer 

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
        res_name = 'RSA.'+ options.RSA + '.' + options.CLF + '.'+options.TRAIN_PREFIX + '.' +  options.SPACE + '.' + dsname
        train_ds = h5load(options.TRAIN_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5')
        print('Processing: ' + dsname)
        
        cvmeans = loadSLResults(dsname, options)

        ds = train_ds
        print('New dataset shape: ' + str(ds.shape))
        ds.samples = ds.samples[:, fsel(cvmeans, 0.8)]
        print('New dataset shape: ' + str(ds.shape))
        ds = preprocess_rsa(dsname, ds)
        print(ds.targets)
        #np.random.shuffle(ds.targets)
        print(ds.targets)
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
            #plt.subplot(1, 3, count)
            plt.figure()
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


