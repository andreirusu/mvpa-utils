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



def preprocess(ds):
    print('NaN Count: '+str(np.sum(np.isnan(ds.samples))))
    print('Original dataset shape: ' + str(ds.shape))
    #### remove constant columns
    print('Removing voxels with std < '+str(EPSILON)+'...')
    ds = ds[:, np.std(ds.samples,axis=0) > EPSILON ]
    print('New dataset shape: ' + str(ds.shape))
    #### LINEAR DETRENDING
    #print('PolyDetrend...')
    #poly_detrend(ds, polyord=1, chunks_attr='chunks')
    #### truncating extreme values
    #ds.samples[ds.samples < -5] = -5
    #ds.samples[ds.samples > 5] = 5
    #### check for extremes
    print('Min value: ' + str(np.min(ds.samples)))
    print('Mean value: ' + str(np.mean(ds.samples)))
    print('Max value: ' + str(np.max(ds.samples)))
    #### Z-SCORE
    print('Z-scoring...')
    #zscore(ds, param_est=('targets', [0]))
    zscore(ds, chunks_attr='chunks')
    #### CLEAN-UP
    print('Removing extra volumes...')
    ds = ds[ds.targets != 0]
    print('New dataset shape: ' + str(ds.shape))
    #### check for extremes
    print('Min value: ' + str(np.min(ds.samples)))
    print('Mean value: ' + str(np.mean(ds.samples)))
    print('Max value: ' + str(np.max(ds.samples)))
    print('Targets:')
    print(ds.targets)
    print('Chunks:')
    print(ds.chunks)
    # reject dataset if it contains NaNs
    print('NaN Count: '+str(np.sum(np.isnan(ds.samples))))
    assert(not np.isnan(np.sum(ds.samples)))
    return ds
 

def preprocess_train_and_test(train_ds, test_ds):
    print('NaN Count train_ds: '+str(np.sum(np.isnan(train_ds.samples))))
    print('NaN Count test_ds: '+str(np.sum(np.isnan(test_ds.samples))))
    print('Original dataset shapes: ' + str(train_ds.shape) + ' & ' + str(test_ds.shape))
    # remove constant columns
    print('Removing voxels with std < '+str(EPSILON)+'...')
    test_ds = test_ds[:, np.std(train_ds.samples,0) > EPSILON ]
    train_ds = train_ds[:, np.std(train_ds.samples,0) > EPSILON ]
    train_ds = train_ds[:, np.std(test_ds.samples,0) > EPSILON ]
    test_ds = test_ds[:, np.std(test_ds.samples,0) > EPSILON ]
    print('New dataset shapes: ' + str(train_ds.shape) + ' & ' + str(test_ds.shape))
    print('Removing extra volumes...')
    train_ds = train_ds[train_ds.targets != 0]
    test_ds = test_ds[test_ds.targets != 0]
    print('New dataset shapes: ' + str(train_ds.shape) + ' & ' + str(test_ds.shape))
    #### truncating extreme values
    #train_ds.samples[train_ds.samples < -5] = -5
    #train_ds.samples[train_ds.samples > 5] = 5
    #### truncating extreme values
    #test_ds.samples[test_ds.samples < -5] = -5
    #test_ds.samples[test_ds.samples > 5] = 5
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
	prog = ProgressBar(0, len(struct.samples[0]), 77, mode='fixed', char='=')
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



 
