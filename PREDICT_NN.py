from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *

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
    print('Target:')
    print train_ds.targets
    print test_ds.targets
    
    if shuffle :
        train_ds = train_ds.copy(deep=True)
        #print('Targets:\n' + str(train_ds.targets))
        np.random.shuffle(train_ds.targets)
        #print('Targets:\n' + str(train_ds.targets))
    # configure classifier
    clf = configure_clf_dists(train_ds, options)
    print clf
    clf.train(train_ds)
    print clf
    preds = clf(test_ds)
    print 'TRGTS: ', test_ds.targets.tolist()
    preds_ds = preds
    preds = preds.samples.T[0].astype(int).tolist()
    print 'PREDS: ', preds 
        
    if options.PLOT:
        distances_rc = np.squeeze( np.min(clf.ca.distances.samples[:, train_ds.targets == 1], axis=1))
        distances_uc = np.squeeze( np.min(clf.ca.distances.samples[:, train_ds.targets == 2], axis=1))
        
        print distances_rc
        print distances_uc
        lmts = [0, 1500, 0, 1500]
        
        #sclr = np.max([distances_rc, distances_uc]) / lmts[1]
        sclr = 1
        distances_rc /= sclr 
        distances_uc /= sclr

        pl.figure()
        offset = 1
        if 1 in test_ds.targets :
            offset = 2
        pl.subplot(offset,2,1)
        import random
        probs =  np.array([ random.sample([d for i,d  in enumerate(distances_rc) if True] * 300, 1000),
                            random.sample([d for i,d  in enumerate(distances_uc) if True] * 300, 1000)])
        print probs
        pl.boxplot(probs.T)
        pl.subplot(offset,2,2)
        pl.plot(np.arange(lmts[0], lmts[1]), np.arange(lmts[0], lmts[1]))
        pl.plot(distances_rc, distances_uc, 'o') 
        pl.axis(lmts)
        
        if 1 in test_ds.targets :
            pl.subplot(offset,2, offset + 1)
            import random
            probs =  np.array([ random.sample([d for i,d  in enumerate(distances_rc) if test_ds.targets[i] == 1] * 300, 1000),
                                random.sample([d for i,d  in enumerate(distances_uc) if test_ds.targets[i] == 2] * 300, 1000)])
            print probs
            pl.boxplot(probs.T)
            pl.subplot(offset, 2, offset + 2)
            pl.plot(np.arange(lmts[0], lmts[1]), np.arange(lmts[0], lmts[1]))
            pl.plot(distances_rc[test_ds.targets == 1], distances_uc[test_ds.targets == 1], 'o') 
            pl.plot(distances_rc[test_ds.targets == 2], distances_uc[test_ds.targets == 2], 'o') 
            pl.axis(lmts)
    err = -1
    if 1 in test_ds.targets :
        err = np.sum(preds != test_ds.targets)*1.0/test_ds.targets.size
    return preds_ds, err



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



def process_session(subject_dir, options, train_ds, stats):
    global count
    global overall_mean_err
    ## get test data
    test_path =  options.TEST_PREFIX + '.'+subject_dir+'.' + options.SPACE  +'.hdf5'
    print('Loading: ' + test_path)
    test_ds = h5load(test_path)
    ### PRE-PROCESSING
    print('Processing: ' + subject_dir)
    #train_ds = preprocess_rsa(subject_dir, train_ds)
    #test_ds = preprocess_rsa(subject_dir, test_ds)
    train_ds, test_ds = preprocess_train_and_test(train_ds, test_ds, options)
    #### PREDICT WITH TRUE LABELS 
    preds, err = predict_probs(train_ds, test_ds, options, False)
    print(DELIM)
    if 1 in test_ds.targets :
        count += 1
        overall_mean_err += err
        print('Error: ' + str(err))
        stats['error'] = err
    print(DELIM)
    stats['counts'] = {}
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


def process_subject(subject_dir, options, stats):
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
    process_session(subject_dir, options, train_ds, stats)


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
    print('Found subjects: ' + str(contents))
    for subject_dir in contents :
        stats['subjects'].append(subject_dir)
        stats[subject_dir] = {}
        process_subject(subject_dir, options, stats[subject_dir])
    # save stats
    res_name    = 'PRED.'+ options.CLF + '.'+options.TRAIN_PREFIX+ '.'+options.TEST_PREFIX  + '.' +  options.SPACE
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

