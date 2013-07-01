from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py

from tools import *

EXPORT_DIR =  os.getcwd()
EPSILON = 1e-10
DELIM = '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'


def main() :
    os.chdir(EXPORT_DIR)
    contents=glob.glob('one_back.s*.roi.hdf5')
    for dsname in contents :
        print(DELIM)
        print('Processing: ' + dsname)
        ds = h5load(dsname)
        ds = preprocess(ds)
        cv = configure_cv(ds)
        res = cv(ds)
        print('CV fold errors:')
        print(res.samples)
        print('Mean cv accuracy: '+str(1 - np.mean(res)))
        print(DELIM)



if __name__ == "__main__" :
    main()


if __debug__:
    debug.active += ["SLC"]


