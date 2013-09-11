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
    print res
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


def fsel(stats, ds, original_ds, options) :
    stats_copy = np.array(stats)
    print(DELIM)
    print(original_ds.fa.voxel_indices)
    original_dict = {}
    for index, voxel in enumerate(original_ds.fa.voxel_indices):
        original_dict[tuple(voxel)] = index
    print('Selecting SL sphere...')
    sz_max = np.power(2*options.SL_RADIUS - 1, 3) - 2  
    while True :
        # get the center with lowest statistic
        center = np.argmin(stats_copy)
        # get sphere
        space="voxel_indices"
        kwa = {space: Sphere(options.SL_RADIUS)}
        qe=IndexQueryEngine(**kwa)
        qe.train(ds)
        best_sphere_ids = qe.query_byid(center)
        sz = np.size(best_sphere_ids)
        print(center, sz, sz_max, original_dict.has_key(tuple(ds.fa.voxel_indices[center])), stats_copy[center]) 
        print(DELIM)
        # reject sphere if smaller than 
        if sz < sz_max or not original_dict.has_key(tuple(ds.fa.voxel_indices[center])):
            stats_copy[center] = np.max(stats_copy)
        else :
            # commit to this center; compute slicer
            slicer = stats_copy > 10^6
            slicer[center] = True
            for i in best_sphere_ids :
                slicer[i] = True
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
        test_ds = h5load(options.TEST_PREFIX + '.' + dsname + '.' + options.SPACE + '.hdf5')
        print('Processing: ' + dsname)
        
        #cvmeans = loadSLResults(dsname, options)
        ds = test_ds
        print('New dataset shape: ' + str(ds.shape))
        ds = preprocess_rsa(dsname, ds, options)
        print('New dataset shape: ' + str(ds.shape))
        #ds.samples = ds.samples[:, fsel(cvmeans, ds, test_ds, options)]
        print(ds.targets)
        #np.random.shuffle(ds.targets)
        print(ds.targets)
        print('New dataset shape: ' + str(ds.shape))
        print(DELIM)
        # average DSMs from different sessions
        for cnk in np.unique(ds.chunks):
            chunk_ds = ds[ds.chunks == cnk]
            if options.PLOT : 
                ### TEMP
                dsm = DSMatrix(chunk_ds.samples, options.RSA)
                try:
                    average_dsm 
                except NameError:
                    average_dsm_vector = dsm.get_vector_form()
                    average_dsm = dsm.get_full_matrix()
                else : 
                    average_dsm_vector += dsm.get_vector_form()
                    average_dsm += dsm.get_full_matrix()
            """
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
                plt.imshow(dsm.get_full_matrix(), interpolation="nearest")
                plt.colorbar()
                plt.subplot(1, 2, 2)
                plt.imshow(dsm1.get_full_matrix(), interpolation="nearest")
                plt.colorbar()
                ### END TEMP
            """
            measure = configure_rsa(chunk_ds, options)
            res = measure(chunk_ds) 
            print(DELIM1)
            print('Measure: '+ str(res))
            print(DELIM1)
        """
        if options.SAVE :
            h5save(res_name + '.hdf5', res)
        """
        # PLOT AVERAGE DSM
        if options.PLOT : 
            ### TEMP
            dsm1 = DSMatrix(chunk_ds.targets, 'confusion')
            average_dsm_vector /= np.size(np.unique(ds.chunks))
            average_dsm /= np.size(np.unique(ds.chunks))
            test_mat = np.asarray([np.squeeze(average_dsm_vector), np.squeeze(dsm1.get_vector_form())])
            print(test_mat.shape) 
            dsm2 = DSMatrix(test_mat, 'spearman')
            print(dsm2)
            plt.figure()
            plt.subplot(1, 2, 1)
            plt.imshow(average_dsm, interpolation="nearest")
            plt.colorbar()
            plt.subplot(1, 2, 2)
            plt.imshow(dsm1.get_full_matrix(), interpolation="nearest")
            plt.colorbar()
            ### END TEMP
        """
        # compute overall average
        if options.PLOT : 
                ### TEMP
                try:
                    subject_average_dsm 
                except NameError:
                    subject_average_dsm_vector = average_dsm_vector 
                    subject_average_dsm = average_dsm
                else : 
                    subject_average_dsm_vector += average_dsm_vector
                    subject_average_dsm += average_dsm
        """
        del average_dsm_vector
        del average_dsm
    """
    # PLOT SUBJECT AVERAGE DSM
    if options.PLOT : 
        ### TEMP
        dsm1 = DSMatrix(chunk_ds.targets, 'confusion')
        subject_average_dsm_vector /= np.size(contents)
        subject_average_dsm /= np.size(contents)
        test_mat = np.asarray([np.squeeze(subject_average_dsm_vector), np.squeeze(dsm1.get_vector_form())])
        print(test_mat.shape) 
        dsm2 = DSMatrix(test_mat, 'spearman')
        print(dsm2)
        plt.figure()
        plt.subplot(1, 2, 1)
        plt.imshow(subject_average_dsm, interpolation="nearest")
        plt.colorbar()
        plt.subplot(1, 2, 2)
        plt.imshow(dsm1.get_full_matrix(), interpolation="nearest")
        plt.colorbar()
    """
    plt.show()
    print('Done\n')


if __name__ == "__main__" :
    main(parseOptions())


if __debug__:
    debug.active += ["SLC"]


