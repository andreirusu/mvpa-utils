from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py
import sys

EXPORT_DIR = '../datasets'
EPSILON = 1e-10
DELIM = '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'



def configure_dsm_sl(ds):
    # create dissimilarity matrix using the 'confusion' distance
    # metric
    dsm = DSMatrix(ds.targets, 'confusion')
    # setup measure to be computed in each sphere (correlation
    # distance between dissimilarity matrix and the dissimilarities
    # of a particular searchlight sphere across experimental
    # conditions), np.B. in this example between-condition
    # dissimilarity is also pearson's r (i.e., correlation distance)
    dsmetric = DSMMeasure(dsm, 'pearson', 'pearson')
    # setup searchlight with 5 mm radius and measure configured above
    sl = sphere_searchlight(dsmetric, radius=5)
    return sl



def configure_sl(ds):
    cv = configure_cv(ds)
    sl = sphere_searchlight(cv, radius=5)    
    return sl


def configure_cv(ds):
    #clf = SMLR() # Logistic Regression
    #clf = GNB()
    clf = LinearCSVMC(C=1)
    cv = CrossValidation(clf, NFoldPartitioner())
    return cv


def preprocess(ds):
    print('PolyDetrend...')
    poly_detrend(ds, polyord=1, chunks_attr='chunks')
    #zscore(ds)
    print('Z-scoring...')
    zscore(ds, param_est=('targets', [0]))
    print('New dataset shape: ' + str(ds.shape))
    print('Removing extra volumes...')
    ds = ds[ds.targets != 0]
    print('New dataset shape: ' + str(ds.shape))
    # remove constant columns
    print('Removing voxels with std < : '+str(EPSILON)+'...')
    ds = ds[:, np.std(ds.samples,0) > EPSILON ]
    print('New dataset shape: ' + str(ds.shape))
    print('Targets:')
    print(ds.targets)
    print('Chunks:')
    print(ds.chunks)
    return ds


def main() :
    #os.chdir(EXPORT_DIR)
    #contents=glob.glob('s*hdf5')
    dsname = sys.argv[1]
    #for dsname in contents :
    print(DELIM)
    print('Processing: ' + dsname)
    ds = h5load(dsname)
    ds = preprocess(ds)
    sl = configure_sl(ds)
    res = sl(ds)
    h5save(dsname+'.sl_map.hdf5', res)
    map2nifti(ds, 1.0 - res).to_filename(dsname+'.sl_map.nii')



if __name__ == "__main__" :
    main()


if __debug__:
    debug.active += ["SLC"]



