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

def predict_probs(train_ds, test_ds, options, shuffle=False) :
    #train_ds  = train_ds[train_ds.targets == 1]
    #train_ds.targets[train_ds.targets == 2] = 1 
    #test_ds  = test_ds[test_ds.targets == 1]
    #test_ds.targets[test_ds.targets == 2] = 1 
    #test_ds.targets[test_ds.targets == -1] = 1 
    #test_ds = test_ds[0]
    #print train_ds.targets
    #print test_ds.targets

    if shuffle :
        train_ds = train_ds.copy(deep=True)
        #print('Targets:\n' + str(train_ds.targets))
        np.random.shuffle(train_ds.targets)
        #print('Targets:\n' + str(train_ds.targets))
    # configure classifier
    clf = configure_clf_prob(train_ds, options)
    print clf
    clf.train(train_ds)
    preds = clf(test_ds)
    print 'TRGTS: ', test_ds.targets.tolist()
    print 'PREDS: ', preds.samples.T[0].astype(int).tolist()
    if options.PLOT:
        pl.figure()
        if 1 in test_ds.targets :
            pl.subplot(1,2,1)
        probs =  np.array([ [pd[1] for (c, pd) in clf.ca.probabilities],
                            [pd[2] for (c, pd) in clf.ca.probabilities],
                            [pd[c] for (c, pd) in clf.ca.probabilities] ])
        pl.boxplot(probs.T)
        if 1 in test_ds.targets :
            pl.subplot(1,2,2)
            import random
            probs = np.array([random.sample([pd[1] for i, (c, pd) in enumerate(clf.ca.probabilities) if test_ds.targets[i] == 1] * 100, 100) ,
                              random.sample([pd[1] for i, (c, pd) in enumerate(clf.ca.probabilities) if test_ds.targets[i] == 2] * 100, 100)])
            pl.boxplot(probs.T)
    
    err = -1
    if 1 in test_ds.targets :
        err = np.sum(preds.samples.T != test_ds.targets)*1.0/test_ds.targets.size
    
    
    
    #print clf.ca.probabilities
    
    probs =  np.array([pd[1] for (c, pd) in clf.ca.probabilities])
                       # [pd[2] for (c, pd) in clf.ca.probabilities],
                       # [pd[c] for (c, pd) in clf.ca.probabilities] 
    print probs
    #pl.figure()
    #pl.hist(probs)
    
    return preds, err, probs



def predict(train_ds, test_ds, options, shuffle=False) :
    if shuffle :
        train_ds = train_ds.copy(deep=True)
        #print('Targets:\n' + str(train_ds.targets))
        np.random.shuffle(train_ds.targets)
        #print('Targets:\n' + str(train_ds.targets))
    # configure classifier
    clf = configure_clf(train_ds, options)
    
    clf.train(train_ds)
    preds = clf(test_ds)
    #print(preds.samples)
    #print(test_ds.targets)
    err = -1
    if 1 in test_ds.targets :
        err = np.sum(preds.samples.T != test_ds.targets)*1.0/test_ds.targets.size
    return preds, err

 
def worker(lst):
    import random
    n, train_ds, test_ds, options, state =  lst
    random.setstate(state)
    random.jumpahead(n)
    preds, err = predict(train_ds, test_ds, options, True)
    return err



def process_hem(subject_dir, options, train_ds, test_ds, stats):
    global count
    global overall_mean_err
    ## get test data
    test_path =  options.TEST_PREFIX + '.'+subject_dir+'.' + options.SPACE  +'.hdf5'
    print('Loading: ' + test_path)
    train_ds, test_ds = selectROI([train_ds, test_ds], options) 
    stats['voxel_count'] = test_ds.shape[1] 
    #### PREDICT WITH TRUE LABELS 
    preds, err, probs = predict_probs(train_ds, test_ds, options, False)
    print(DELIM)
    if 1 in test_ds.targets :
        count += 1
        overall_mean_err += err
        print('Error: ' + str(err))
        stats['error'] = err
    print(DELIM)
    stats['counts'] = {}
    stats['probs'] = probs
    for cls in np.unique(train_ds.targets) :
        counts = np.sum(preds.samples == cls)
        stats['counts'][cls] = counts
        print(cls, counts)
    # compute error if labels are available
    print(DELIM)
    
    if options.NPERM == 0 :
        return 

    if options.NPERM >= (10.0/(1 - options.CONF)):
        ## PERMUTATION TESTING
        pool = mp.Pool(options.NPROC)
        nperm = options.NPERM
        import random
        random.seed(random.random())
        state = random.getstate()
        
        err_perm = pool.map(worker, [(i, train_ds, test_ds, options, state) for i in np.arange(0,nperm,1)], 100)
       # 
        pool.close()
        pool.join()
        err_perm = np.array(sorted(err_perm))
       
        # read result
        ind = int(np.floor(nperm * (1 - options.CONF) - 1))
        print('Error at ' +  str(1 - options.CONF)  + ' : ' + str(err_perm[ind]))
        print(DELIM)
        if options.PLOT :
            pl.figure()
            pl.hist(err_perm, nperm/100)
            pl.hist([err], nperm/100)
    else:
        raise NameError('Wrong number of permutations for given confidence level!')
        return None 


def process_roi(subject_dir, options, train_ds, test_ds, stats):
    if options.HEM == "scan" :
        for hem in ['left', 'right', 'both'] : 
            try:
                new_options = copy.deepcopy(options)
                new_options.HEM = hem
                stats[new_options.HEM] = {}
                process_hem(subject_dir, new_options, train_ds, test_ds, stats[new_options.HEM]) 
            except:
                pass
    else:
        stats[options.HEM] = {}
        process_hem(subject_dir, options, train_ds, test_ds, stats[options.HEM])


def process_sessions(subject_dir, options, train_ds, stats):
    global count
    global overall_mean_err
    ## get test data
    test_path =  options.TEST_PREFIX + '.'+subject_dir+'.' + options.SPACE  +'.hdf5'
    print('Loading: ' + test_path)
    test_ds = h5load(test_path)
    ### PRE-PROCESSING
    print('Processing: ' + subject_dir)
    train_ds, test_ds = preprocess_train_and_test(train_ds, test_ds, options)
    
    if options.ROI == "scan" :
        for roi in ROIids : 
            new_options = copy.deepcopy(options)
            new_options.ROI = roi
            stats[new_options.ROI] = {}
            process_roi(subject_dir, new_options, train_ds, test_ds, stats[new_options.ROI]) 

    else:
        stats[options.ROI] = {}
        process_roi(subject_dir, options, train_ds, test_ds, stats[options.ROI]) 
    

   
   
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

        # get training data
        train_path = options.TRAIN_PREFIX + '.' + subject_dir + '.' + options.SPACE + '.hdf5'
        print('Loading: ' + train_path)
        train_ds = h5load(train_path)
        # process test data
        process_sessions(subject_dir, options, train_ds, stats)
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
    res_name    = 'PRED.'+ options.ROI +'.' + options.HEM+ '.' + options.CLF + '.'+options.TRAIN_PREFIX+ '.'+options.TEST_PREFIX  + '.' +  options.SPACE
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

