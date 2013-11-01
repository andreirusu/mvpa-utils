from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *

from mvpa2.mappers.svd import SVDMapper
#from mvpa2.mappers.mdp_adaptor import ICAMapper, PCAMapper

import scipy, os, glob, h5py, sys, getopt, nibabel, gc, warnings, tempfile, shutil, pprint

import numpy as np

import multiprocessing as mp
    
### GLOBAL STATS
count = 0
overall_mean_err = 0


from ROIinfo import *


def predict_features(test_ds, options) :
    ### compute first PC and return
    features = False
    ds = preprocess_rsa("sXX", test_ds, options)
    
    ds = removeNaNColumns(ds)
    ds = removeInfColumns(ds)
    ## PERFORM PCA
    print(DELIM1)
    import sklearn.decomposition as deco
    x = np.copy(ds.samples)
    x = (x - np.mean(x, 0)) # You need to normalize your data first
    n_components = 1
    pca = deco.PCA(n_components) # n_components is the components number after reduction
    features = pca.fit(x).transform(x)
    
    print ('Explained variance (first %d components): %.2f'%(n_components, sum(pca.explained_variance_ratio_)))
    print(DELIM1)
    
    return features



def process_hem(subject_dir, options, test_ds, stats):
    global count
    global overall_mean_err
    ## get test data
    test_path =  options.TEST_PREFIX + '.'+subject_dir+'.' + options.SPACE  +'.hdf5'
    print('Loading: ' + test_path)
    test_ds = selectROI([test_ds], options)[0] 
    
    #### CORRICT WITH TRUE LABELS 
    features = predict_features(test_ds, options)
    stats['features'] = features
    print np.transpose(stats['features']) 
    # compute error if labels are available
    print(DELIM)



def process_roi(subject_dir, options, test_ds, stats):
    if options.HEM == "scan" :
        for hem in ['left', 'right', 'both'] : 
            try:
                new_options = copy.deepcopy(options)
                new_options.HEM = hem
                stats[new_options.HEM] = {}
                process_hem(subject_dir, new_options, test_ds, stats[new_options.HEM]) 
            except:
                pass
    else:
        stats[options.HEM] = {}
        process_hem(subject_dir, options, test_ds, stats[options.HEM])


def process_sessions(subject_dir, options, stats):
    global count
    global overall_mean_err
    ## get test data
    test_path =  options.TEST_PREFIX + '.'+subject_dir+'.' + options.SPACE  +'.hdf5'
    print('Loading: ' + test_path)
    test_ds = h5load(test_path)
    ### PRE-PROCESSING
    print('Processing: ' + subject_dir)
    
    if options.ROI == "scan":
        for roi in ROIids : 
            new_options = copy.deepcopy(options)
            new_options.ROI = roi
            stats[new_options.ROI] = {}
            process_roi(subject_dir, new_options, test_ds, stats[new_options.ROI]) 

    else:
        stats[options.ROI] = {}
        process_roi(subject_dir, options, test_ds, stats[options.ROI]) 
    

   
   
def process_subject(subject_dir, options, stats):
    try:
        print('Subject: ' + subject_dir)
        import re
        subject_nr = int(re.findall(r'\d+', subject_dir)[0])
        if SUBJECT_GROUP[subject_nr] == 1 :
            print('Rewarderd category: chair')
        elif SUBJECT_GROUP[subject_nr] == 2 :
            print('Rewarderd category: house')
        else:
            raise NameError('Wrong subject group!')
            return None 
        # process test data
        process_sessions(subject_dir, options, stats)
    except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            pass
    except:
        print "Unexpected error:", sys.exc_info()[0]
        raise


def main(options):
    global count
    global overall_mean_err
    os.chdir(options.EXPERIMENT_DIR)
    print('Working in '+os.getcwd())
    print(DELIM)
    print('\nROI INFO')
    print(DELIM)
    print('ROIs:')
    print(DELIM)
    pprint.pprint(ROI, width=40)
    print(DELIM)
    print('ROIids:')
    print(DELIM)
    pprint.pprint(ROIids, width=60)
    print(' ')
    print(DELIM)
    # assume current directory contains a directory per subject, begining with the symbol 's' 
    contents=glob.glob('s*')
    stats={}
    os.chdir(options.EXPORT_DIR)
    stats['subjects'] = []
    stats['options'] = vars(options)
    print('Found subjects: ' + str(contents))
    for subject_dir in contents :
        stats['subjects'].append(subject_dir)
        stats[subject_dir] = {}
        process_subject(subject_dir, options, stats[subject_dir])
    # save stats
    res_name    = 'CORR.'+ options.ROI +'.' + options.HEM+ '.' + options.CLF + '.'+options.TRAIN_PREFIX+ '.'+options.TEST_PREFIX  + '.' +  options.SPACE
    h5save(res_name + '.hdf5', stats) 
    # print results
    print('Global stats:')
    pprint.pprint(stats, width=80)
    if count > 0 :
        overall_mean_err /= count
        print(DELIM1)
        print('Overall mean measure: '+str(overall_mean_err))
    print(DELIM1)
    pl.show()
    print('Done\n')


if __name__ == "__main__" :
    main(parseOptions())

