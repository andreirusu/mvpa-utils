from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py
import sys
import nibabel
from progress_bar import *
import warnings
import tempfile, shutil
from subprocess import *
from datetime import *
import gc as gc	

from tools import *


EPSILON = 1e-5
DELIM   =   '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'
DELIM1  =   '#######################################################################################'
SL_RADIUS   = 3

## MAKE EXPERIMENTS FULLY REPEATABLE
random.seed(0)




def partitioner():
    #return CustomPartitioner([([2], [1]), ([1], [2])]) 
    return NFoldPartitioner(cvtype=1) 


def configure_sl_gnb(ds):
    sl = sphere_gnbsearchlight(GNB(), partitioner(), radius=SL_RADIUS)    
    return sl

def configure_sl_lcsvm(ds):
    clf = LinearCSVMC(C=1)
    cv = CrossValidation(clf, partitioner())
    sl = sphere_searchlight(cv, radius=SL_RADIUS)    
    return sl


def configure_sl_smlr(ds):
    # Sparse (Multinomial) Logistic Regression (lm = lambda, regularization parameter)
    clf = SMLR(lm = 1, seed = 0, ties = False, maxiter = 100) 
    cv = CrossValidation(clf, partitioner())
    sl = sphere_searchlight(cv, radius=SL_RADIUS)    
    return sl



def configure_sl(ds):
    return configure_sl_gnb(ds)
    #return configure_sl_lcsvm(ds)
    #return configure_sl_smlr(ds)

   



def configure_clf(ds): 
    #clf = SMLR(lm = 1, seed = 0, ties = False, maxiter = 10000000) # Sparse (Multinomial) Logistic Regression (lm = lambda, regularization parameter)
    clf = LinearCSVMC(C=1)
    #clf = GNB()
    fsel = SensitivityBasedFeatureSelection(
            OneWayAnova(),
            FixedNElementTailSelector(200, mode='select', tail='upper'))
            #FractionTailSelector(felements=0.01, mode='select', tail='upper'))
            #RangeElementSelector(lower=0.5, mode='select'))
    fclf = FeatureSelectionClassifier(clf, fsel)
    fclf.set_postproc(BinaryFxNode(mean_mismatch_error, 'targets'))
    return fclf



def configure_cv(ds):
    clf = configure_clf(ds)
    #cv = CrossValidation(clf, NFoldPartitioner(cvtype=1))
    cv = CrossValidation(clf, CustomPartitioner(splitrule = [([1, 2, 3, 4, 5], [6, 7])], count=1, selection_strategy='first'))
    return cv


def removeNaNColumns(ds) :
    print('NaN Column Count: '+str(np.sum(np.isnan(np.sum(ds.samples, axis=0)))))
    #### REMOVE ALL COLUMNS WHICH CONTAIN NAN
    ds = ds[:, ~np.isnan(np.sum(ds.samples, axis=0))]
    print('New dataset shape: ' + str(ds.shape))
    return ds


def removeConstantColums(ds):
    #### remove constant columns
    print('Removing voxels with std < '+str(EPSILON)+'...')
    ds = ds[:, np.std(ds.samples,axis=0) > EPSILON ]
    print('New dataset shape: ' + str(ds.shape))
    return ds


def removeLinearTrends(ds):
    #### LINEAR DETRENDING
    print('PolyDetrend...')
    poly_detrend(ds, polyord=1, chunks_attr='chunks')
    return ds


def truncateExtremeValues(ds):
    #### TEMPORARY FIX: 
    #### check for extremes
    print('Min value: ' + str(np.min(ds.samples)))
    print('Mean value: ' + str(np.mean(ds.samples)))
    print('Max value: ' + str(np.max(ds.samples)))
    print('Truncating extreme values...')
    print('Extreme columns: ' + str(np.sum(np.nanmax(ds.samples, axis=0) > 10) + np.sum(np.nanmin(ds.samples, axis=0) < -10)))
    #plotAndWait(ds.samples[:, 34344])
    ds.samples[ds.samples < -10] = -10
    ds.samples[ds.samples > 10] = 10
    #### check for extremes
    print('Min value: ' + str(np.min(ds.samples)))
    print('Mean value: ' + str(np.mean(ds.samples)))
    print('Max value: ' + str(np.max(ds.samples)))
    return ds


def histAndWait(nparray, t=5):
    import matplotlib
    pl.hist(nparray)
    pl.show()
    import time
    time.sleep(t)

def plotAndWait(nparray, t=5):
    import matplotlib
    pl.plot(nparray)
    pl.show()
    import time
    time.sleep(t)



def removeExtremeColumns(ds):
    #### TEMPORARY FIX: 
    #### check for extremes
    print('Min value: ' + str(np.min(ds.samples)))
    print('Mean value: ' + str(np.mean(ds.samples)))
    print('Max value: ' + str(np.max(ds.samples)))
    print('Truncating extreme values...')
    #plotAndWait(ds.samples[:, 34344])
    ds = ds[:, np.nanmax(ds.samples, axis=0) < 5000] 
    print('New dataset shape: ' + str(ds.shape))
    ds = ds[:, np.nanmin(ds.samples, axis=0) > -5000] 
    print('New dataset shape: ' + str(ds.shape))
    #### check for extremes
    print('Min value: ' + str(np.min(ds.samples)))
    print('Mean value: ' + str(np.mean(ds.samples)))
    print('Max value: ' + str(np.max(ds.samples)))
    return ds


def zscoreChunks(ds):
    #### Z-SCORE
    #### check for extremes
    print('Min value: ' + str(np.min(ds.samples)))
    print('Mean value: ' + str(np.mean(ds.samples)))
    print('Max value: ' + str(np.max(ds.samples)))
    print('Z-scoring...')
    #zscore(ds, param_est=('targets', [0]))
    zscore(ds, chunks_attr='chunks')
    #### check for extremes
    print('Min value: ' + str(np.min(ds.samples)))
    print('Mean value: ' + str(np.mean(ds.samples)))
    print('Max value: ' + str(np.max(ds.samples)))
    return ds


def cleanup(ds):
    #### CLEAN-UP
    print('Removing extra volumes...')
    ds = ds[ds.targets != 0]
    print('New dataset shape: ' + str(ds.shape))
    print('Targets:')
    print(ds.targets)
    print('Chunks:')
    print(ds.chunks)
    # reject dataset if it contains NaNs
    print('NaN Count: '+str(np.sum(np.isnan(ds.samples))))
    assert(not np.isnan(np.sum(ds.samples)))
    return ds


def preprocess(ds):
    print('Original dataset shape: ' + str(ds.shape))
    #return cleanup(zscoreChunks(truncateExtremeValues(removeNaNColumns(removeConstantColums(ds)))))
    return cleanup(zscoreChunks(removeConstantColums(removeExtremeColumns(removeNaNColumns(ds)))))
 

def preprocess_train_and_test(train_ds, test_ds):
    print('Original dataset shapes: ' + str(train_ds.shape) + ' & ' + str(test_ds.shape))
    # remove constant columns
    print('Removing voxels with std < '+str(EPSILON)+'...')
    test_ds = test_ds[:, np.std(train_ds.samples,0) > EPSILON ]
    train_ds = train_ds[:, np.std(train_ds.samples,0) > EPSILON ]
    train_ds = train_ds[:, np.std(test_ds.samples,0) > EPSILON ]
    test_ds = test_ds[:, np.std(test_ds.samples,0) > EPSILON ]
    print('New dataset shapes: ' + str(train_ds.shape) + ' & ' + str(test_ds.shape))
    ### REMOVING colums with NaNs
    print('NaN Count train_ds: '+str(np.sum(np.isnan(train_ds.samples))))
    print('NaN Count test_ds: '+str(np.sum(np.isnan(test_ds.samples))))
    train_ds = train_ds[:, ~np.isnan(np.sum(train_ds.samples, axis=0))]
    test_ds = test_ds[:, ~np.isnan(np.sum(test_ds.samples, axis=0))]
    print('New dataset shapes: ' + str(train_ds.shape) + ' & ' + str(test_ds.shape))
    print('Removing extra volumes...')
    train_ds = train_ds[train_ds.targets != 0]
    test_ds = test_ds[test_ds.targets != 0]
    print('New dataset shapes: ' + str(train_ds.shape) + ' & ' + str(test_ds.shape))
    #### TEMPORARY FIX: 
   # print('Truncating extreme values...')
   # train_ds.samples[train_ds.samples < -5] = -5
   # train_ds.samples[train_ds.samples > 5] = 5
   # #### truncating extreme values
   # test_ds.samples[test_ds.samples < -5] = -5
   # test_ds.samples[test_ds.samples > 5] = 5
    #### check for extremes
    print('Min train value: ' + str(np.min(train_ds.samples)) + '\nMin test value: ' + str(np.min(test_ds.samples)))
    print('Mean train value: ' + str(np.mean(train_ds.samples)) + '\nMax test value: ' + str(np.mean(test_ds.samples)))
    print('Max train value: ' + str(np.max(train_ds.samples)) + '\nMax test value: ' + str(np.max(test_ds.samples)))
    #### Z-SCORE
    print('Z-scoring...')
    zscore(train_ds, chunks_attr='chunks')
    zscore(test_ds, chunks_attr='chunks')
    #### check for extremes
    print('Min train value: ' + str(np.min(train_ds.samples)) + '\nMin test value: ' + str(np.min(test_ds.samples)))
    print('Mean train value: ' + str(np.mean(train_ds.samples)) + '\nMax test value: ' + str(np.mean(test_ds.samples)))
    print('Max train value: ' + str(np.max(train_ds.samples)) + '\nMax test value: ' + str(np.max(test_ds.samples)))
    ## reject datasets if they contain NaNs
    print('NaN Count train_ds: '+str(np.sum(np.isnan(train_ds.samples))))
    print('NaN Count test_ds: '+str(np.sum(np.isnan(test_ds.samples))))
    assert(not np.isnan(np.sum(train_ds.samples)))
    assert(not np.isnan(np.sum(test_ds.samples)))
    return train_ds, test_ds 



def map_voxels(voxels, values, struct_filename, filename):
	struct = h5load(struct_filename)
	prog = ProgressBar(0, len(voxels))
	st = np.zeros(struct.shape[1])
	# find voxels in struct
	struct_dict = {}
	for index, voxel in enumerate(struct.fa.voxel_indices):
		struct_dict[tuple(voxel)] = index
	for index, voxel in enumerate(voxels):
		if struct_dict.has_key(tuple(voxel)) :
			st[struct_dict[tuple(voxel)]] = values[index]
		prog.increment_amount()
    		print prog, '\r',
    		sys.stdout.flush()
	npair = map2nifti(struct, st)
	nimg = nibabel.nifti1.Nifti1Image(data=npair.get_data(), affine=None, header=npair.get_header())
	nimg.to_filename(filename)



 
