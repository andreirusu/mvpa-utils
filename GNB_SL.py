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

EXPORT_DIR = '../datasets'


def configure_sl(ds):
    sl = sphere_gnbsearchlight(GNB(), NFoldPartitioner(), radius=2)    
    return sl

def main() :
    dsname = sys.argv[1] 
    print('Processing: ' + dsname)
    ds = h5load(dsname)
    ds = preprocess(ds)
    print(DELIM)
    sl = configure_sl(ds)
    res = sl(ds)
    h5save(dsname+'.gnb_sl.hdf5', res)
    cvmeans = 1 - np.mean(res.samples,0)
    #vol = map2nifti(ds, cvmeans, imghdr=ds.a.imghdr)
    print('Mapping seachlight results back into original voxel space!')
    map_voxels(ds.fa.voxel_indices, cvmeans, dsname, dsname+'.gnb_sl.nii')
    print(DELIM1)
    print('Best mean accuracy: '+str(np.max(cvmeans)))
    print(DELIM1)
    print('Done')



if __name__ == "__main__" :
    main()


if __debug__:
    debug.active += ["SLC"]



