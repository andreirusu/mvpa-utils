from mvpa2.suite import *
from subprocess import *
from progress_bar import *
from datetime import *
from tools import *
from optparse import OptionParser
from pprint import pprint

import matplotlib, scipy, os, glob, h5py, sys, getopt, nibabel, gc, warnings, tempfile, shutil

from ROIinfo import *

import numpy as inp

SUBJECT_GROUP = [1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 1, 1, 1, 1, 2, 2, 2, 2, 1] 

EPSILON = 1e-3
DELIM   =   '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'
DELIM1  =   '#######################################################################################'

## MAKE EXPERIMENTS FULLY REPEATABLE
random.seed(0)


def selectROI(ds_lst, options):
    # select cluster
    if options.ROI != 'full' : 
        if options.ROI == 'all' :
            cluster_ids = np.arange(1,19,1) 
        else:
            cluster_ids = ROIids[options.ROI]
        print(cluster_ids)
        if options.HEM != 'both':
            cluster_ids = [i for i in cluster_ids if (hem[str(i)] == options.HEM)]
        print(cluster_ids)
        slicer = [ i for i, cluster in enumerate(ds_lst[0].fa.clusters) if (cluster in cluster_ids) ]
        print('Slicer: ' + str(np.size(slicer)))
        for i, ds in enumerate(ds_lst) :
            ds_lst[i]  = ds_lst[i][:, slicer]
            print(ds_lst[i].shape)
    return ds_lst



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





def sphereDataset(ds):
    ds.samples = (ds.samples.T - np.mean(ds.samples, axis = 1)).T
    ds.samples = (ds.samples.T / np.sqrt(np.sum(np.power(ds.samples, 2), axis = 1))).T 
    return ds


def preprocess_train_and_test(train_ds, test_ds, options):
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
    print('Mean train value: ' + str(np.mean(train_ds.samples)) + '\nMean test value: ' + str(np.mean(test_ds.samples)))
    print('Max train value: ' + str(np.max(train_ds.samples)) + '\nMax test value: ' + str(np.max(test_ds.samples)))
    #### Z-SCORE
    #print('Z-scoring...')
    zscore(train_ds, chunks_attr='chunks')
    zscore(test_ds, chunks_attr='chunks')
    #### check for extremes
    print('Min train value: ' + str(np.min(train_ds.samples)) + '\nMin test value: ' + str(np.min(test_ds.samples)))
    print('Mean train value: ' + str(np.mean(train_ds.samples)) + '\nMean test value: ' + str(np.mean(test_ds.samples)))
    print('Max train value: ' + str(np.max(train_ds.samples)) + '\nMax test value: ' + str(np.max(test_ds.samples)))
    ## reject datasets if they contain NaNs
    print('NaN Count train_ds: '+str(np.sum(np.isnan(train_ds.samples))))
    print('NaN Count test_ds: '+str(np.sum(np.isnan(test_ds.samples))))
    assert(not np.isnan(np.sum(train_ds.samples)))
    assert(not np.isnan(np.sum(test_ds.samples)))
    print('Selecting ROI...')
    train_ds, test_ds = selectROI([train_ds, test_ds], options) 
    return train_ds, test_ds 



def preprocess_rsa(dsname, ds, options) :
        print('Processing: ' + dsname)
        print('Dataset shape: ' + str(ds.shape))
        ds=cleanup(zscoreChunks(removeConstantColums(removeNaNColumns(ds))))
        #ds=cleanup(zscoreAll(removeConstantColums(removeNaNColumns(ds))))
        #ds.sa['serial_chunks'] = list(ds.chunks)
        #ds.sa.serial_chunks[ ds.sa.serial_chunks <= 5 ] = 1
        #ds.sa.serial_chunks[ ds.sa.serial_chunks > 5 ] = 2
        #print('SerialChunks:\n' + str(ds.sa.serial_chunks))
        #zscore(ds, chunks_attr='serial_chunks')
        #print('Chunks:\n' + str(ds.chunks))
        #print('SerialChunks:\n' + str(ds.sa.serial_chunks))
        #ds.chunks[ ds.chunks % 2 < 1 ] = 2
        #ds.chunks[ ds.chunks % 2 > 0 ] = 1
        #print('Chunks:\n' + str(ds.chunks))
        #print('SerialChunks:\n' + str(ds.sa.serial_chunks))
        #ds1, ds2 = splitDataset(ds, 0.5)
        #print ds1
        #print ds2
        # # z-scoring both halfs with the parameters of the first half
        # params_ds1 = (np.mean(ds1.samples), np.std(ds1.samples))
        #printDatasetStats(ds1)
        # print('Z-scoring...')
        # zscore(ds1, params = params_ds1)
        # printDatasetStats(ds1)
        #print(DELIM)
        #printDatasetStats(ds2)
        # print('Z-scoring...')
        # zscore(ds2, params = params_ds1)
        # printDatasetStats(ds2)
        print(DELIM)
        #ds = ds[ds.chunks == 1]
        #hlf = np.array(range(1, 9, 1)).repeat(4)
        #ds.chunks = np.concatenate((hlf, hlf), axis=0)
        printDatasetStats(ds)
        print('Chunks:\n' + str(ds.chunks))
        print('Targets:\n' + str(ds.targets))
        print('New dataset shape: ' + str(ds.shape))
        ds = selectROI([ds], options)[0] 
        print(DELIM)
        return ds


def parseOptions():
    parser = OptionParser()
    parser.add_option("-d", "--dir", dest="EXPERIMENT_DIR", default='../3_random_subjects',
            help="load datasets from EXPERIMENT_DIR")
    parser.add_option("-s", "--space", dest="SPACE", default = 'full',
            help="read dataset in specified SPACE", metavar="SPACE")
    parser.add_option("-t", "--task", dest="TRAIN_PREFIX", default='one_back',
            help="the specified TASK will be loaded")
    parser.add_option("-o", "--test", dest="TEST_PREFIX", default='reward',
            help="the specified TEST set will be loaded")
    parser.add_option("-x", "--export", dest="EXPORT_DIR", default='../datasets',
            help="write results in EXPORT_DIR")
    parser.add_option("-p", "--plot", action="store_true", dest="PLOT", default=False,
            help="diplay plots")
    parser.add_option("-r", "--radius", dest="SL_RADIUS", default=3, type='int',
            help="user radius SL_RADIUS in searchlight measure")
    parser.add_option("-c", "--classifier", dest="CLF", default='gnb',
            help="the specified classifier will be used: gnb | csvm | smlr | knn")
    parser.add_option("-v", "--cv", dest="CV", default='kfold',
            help="the specified CV will be used: kfold | half | custom")
    parser.add_option("-k", "--rsa", dest="RSA", default='pearson',
            help="the specified metric  will be used for RSA: pearson | spearman | confusion")
    parser.add_option("-f", "--fsel", dest="FSEL", default='NONE',
            help="uses the Feature SELection strategy: GNB_SL | ANOVA | NONE")
    parser.add_option("-n", "--nfeatures", dest="NFEATURES", default=500, type='int',
            help="select NFEATURES top features")
    parser.add_option("-m", "--stats", dest="STATS", default='mean',
            help="the following statistic will be used: max | min | mean")
    parser.add_option("-l", "--lambda", dest="LAMBDA", default=1, type='float',
            help="regularization parameter for classifiers")
    parser.add_option("-j", "--nproc", dest="NPROC", default=1, type='int',
            help="number of threads used")
    parser.add_option("-e", "--write-cost-to-file", dest="OUTFILE", default="cost.txt",
            help="file to write cost to")
    parser.add_option("-a", "--save", action="store_true", dest="SAVE", default=False,
            help="save results to file")
    parser.add_option("-b", "--roi", dest="ROI", default='full',
            help="if specified, analysis runs only on a specific ROI values: full | all | <AN ROI> ")
    parser.add_option("-i", "--hem", dest="HEM", default='both',
            help="if specified, only a certain hemisphere is used; values: both | left | right ")
    parser.add_option("-g", "--nperm", dest="NPERM", type='int', default=0,
            help="if specified, a permutation test is performed; labels are randomized NPERM times and the corresponding quantile error is displayed")
    parser.add_option("-q", "--conf", dest="CONF", type='float', default=0.95,
            help="confidence level for the permutation test")


    
    (options, args) = parser.parse_args()
    
    print('Run parameters:')
    pprint(options)
    print('Args: ')
    pprint(args)
    return options



def partitioner(options):
    if options.CV == 'kfold':
        return NFoldPartitioner(cvtype=1) 
    elif options.CV == 'half':
        return HalfPartitioner() 
    else:
        raise NameError('Wrong Partitioner!')
        return None 


def configure_sl_gnb(ds, options):
    return sphere_gnbsearchlight(GNB(), partitioner(options), radius=options.SL_RADIUS, nproc=options.NPROC)    

def configure_sl_knn(ds, options):
    clf = kNN(k=options.LAMBDA)
    cv = CrossValidation(clf, partitioner(options))
    sl = sphere_searchlight(cv, radius=options.SL_RADIUS, nproc=options.NPROC)    
    return sl


def configure_sl_lcsvm(ds, options):
    clf = LinearCSVMC(C=options.LAMBDA)
    cv = CrossValidation(clf, partitioner(options))
    sl = sphere_searchlight(cv, radius=options.SL_RADIUS, nproc=options.NPROC)    
    return sl


def configure_sl_rsa(ds, options):
    dsm = configure_rsa(ds, options)
    sl = sphere_searchlight(dsm, radius=options.SL_RADIUS, nproc=options.NPROC)    
    return sl


def configure_sl_smlr(ds, options):
    # Sparse (Multinomial) Logistic Regression (lm = lambda, regularization parameter)
    clf = SMLR(lm = options.LAMBDA, seed = 0, ties = False, maxiter = 100) 
    cv = CrossValidation(clf, partitioner(options))
    sl = sphere_searchlight(cv, radius=options.SL_RADIUS, nproc=options.NPROC)    
    return sl



def configure_sl(ds, options):
    if options.CLF == 'gnb':
        return configure_sl_gnb(ds, options)
    elif options.CLF == 'csvm': 
        return configure_sl_lcsvm(ds, options)
    elif options.CLF == 'smlr':
        return configure_sl_smlr(ds, options)
    elif options.CLF == 'knn':
        return configure_sl_knn(ds, options)
    elif options.CLF == 'rsa':
        return configure_sl_rsa(ds, options)
    else:
        raise NameError('Wrong SL!')
        return None 



def fsel_sl_gnb(ds, options):
    proc = None
    if options.STATS == 'mean':
       proc = FxMapper('samples', np.mean, attrfx='merge') 
    elif options.STATS == 'min':
        proc = FxMapper('samples', np.max, attrfx='merge') 
    elif options.STATS == 'max':
        proc = FxMapper('samples', np.min, attrfx='merge') 
    else:
        raise NameError('Wrong STATS!')
        return None 
    return sphere_gnbsearchlight(GNB(), HalfPartitioner(), radius=options.SL_RADIUS, postproc=proc, nproc=options.NPROC)
    

def fsel_sl_csvm(ds, options):
    proc = None
    if options.STATS == 'mean':
       proc = FxMapper('samples', np.mean, attrfx='merge') 
    elif options.STATS == 'min':
        proc = FxMapper('samples', np.min, attrfx='merge') 
    elif options.STATS == 'max':
        proc = FxMapper('samples', np.max, attrfx='merge') 
    else:
        raise NameError('Wrong STATS!')
        return None 
    return sphere_searchlight(CrossValidation(LinearCSVMC(C=options.LAMBDA), HalfPartitioner()), radius=options.SL_RADIUS, postproc=proc, nproc=options.NPROC)
    


def configure_clf(ds, options): 
    clf = None
    if options.CLF == 'gnb':
        clf = GNB()
    elif options.CLF == 'csvm': 
        clf = LinearCSVMC(C=options.LAMBDA)
    elif options.CLF == 'nsvm': 
        clf = LinearNuSVMC(nu=options.LAMBDA)
    elif options.CLF == 'smlr':
        clf = SMLR(lm = options.LAMBDA, seed = 0) 
    elif options.CLF == 'knn':
        clf = kNN(k = options.LAMBDA, dfx=mvpa2.clfs.distance.squared_euclidean_distance) 
    else:
        raise NameError('Wrong CLF!')
        return None 
    fsel = None
    if options.FSEL.upper() == 'NONE' :
        return clf
    elif options.FSEL.upper() == 'ANOVA' :
        fsel = SensitivityBasedFeatureSelection(
                OneWayAnova(),
                FixedNElementTailSelector(options.NFEATURES, mode='select', tail='upper'))
                #FractionTailSelector(felements=0.01, mode='select', tail='upper'))
                #RangeElementSelector(lower=0.5, mode='select'))
    elif options.FSEL.upper() == 'GNB_SL' :
        fsel = SensitivityBasedFeatureSelection(
                fsel_sl_gnb(ds, options),
                FixedNElementTailSelector(options.NFEATURES, mode='select', tail='lower'))
    elif options.FSEL.upper() == 'CSVM_SL' :
        fsel = SensitivityBasedFeatureSelection(
                fsel_sl_csvm(ds, options),
                FixedNElementTailSelector(options.NFEATURES, mode='select', tail='lower'))
    else:
        raise NameError('Wrong FSEL!')
        return None 
    fclf = FeatureSelectionClassifier(clf, fsel)
    return fclf
    

def configure_rsa(ds, options):
    dsm = DSMatrix(ds.targets, 'confusion')
    #return CrossValidation(DSMMeasure(dsm, options.RSA, 'spearman'), partitioner(options))
    return DSMMeasure(dsm, options.RSA, 'spearman')




def configure_cv(ds, options):
    return CrossValidation(configure_clf(ds, options), partitioner(options))



def removeNaNColumns(ds) :
    print('NaN Column Count: '+str(np.sum(np.isnan(np.sum(ds.samples, axis=0)))))
    #### REMOVE ALL COLUMNS WHICH CONTAIN NAN
    ds = ds[:, ~np.isnan(np.sum(ds.samples, axis=0))]
    print('New dataset shape: ' + str(ds.shape))
    return ds

def setNaNtoMean(ds) :
    print('NaN Count: '+str(np.sum(np.isnan(ds.samples))))
    #### REMOVE ALL COLUMNS WHICH CONTAIN NAN
    ds.samples[np.isnan(ds.samples)] = np.nansum(ds.samples)/ds.shape[0]/ds.shape[1]
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
    ds = ds[:, np.nanmax(ds.samples, axis=0) < 500] 
    print('New dataset shape: ' + str(ds.shape))
    ds = ds[:, np.nanmin(ds.samples, axis=0) > -500] 
    print('New dataset shape: ' + str(ds.shape))
    #### check for extremes
    print('Min value: ' + str(np.min(ds.samples)))
    print('Mean value: ' + str(np.mean(ds.samples)))
    print('Max value: ' + str(np.max(ds.samples)))
    return ds


def zscoreAll(ds):
    #### Z-SCORE
    #### check for extremes
    print('Min value: ' + str(np.min(ds.samples)))
    print('Mean value: ' + str(np.mean(ds.samples)))
    print('Max value: ' + str(np.max(ds.samples)))
    print('Z-scoring...')
    zscore(ds, auto_train=False,  params=(np.mean(ds.samples), np.std(ds.samples)))
    #### check for extremes
    print('Min value: ' + str(np.min(ds.samples)))
    print('Mean value: ' + str(np.mean(ds.samples)))
    print('Max value: ' + str(np.max(ds.samples)))
    return ds


def printDatasetStats(ds):
    #### check for extremes
    print('Min value: ' + str(np.min(ds.samples)))
    print('Mean value: ' + str(np.mean(ds.samples)))
    print('Max value: ' + str(np.max(ds.samples)))


def zscoreChunks(ds):
    #### Z-SCORE
    printDatasetStats(ds)
    print('Z-scoring...')
    #zscore(ds, param_est=('targets', [0]))
    zscore(ds, chunks_attr='chunks')
    printDatasetStats(ds)
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
    #return cleanup(zscoreChunks(removeConstantColums(removeExtremeColumns(setNaNtoMean(ds)))))
 


def splitDataset(ds, frac):
    splitPoint = np.sort(np.unique(np.array(ds.chunks)))
    print splitPoint
    splitPoint = splitPoint[np.floor(np.size(splitPoint) * frac)]
    print splitPoint
    return ds[ds.chunks < splitPoint], ds[ds.chunks >= splitPoint]


def map_voxels(voxels, values, strct, filename):
    prog = ProgressBar(0, len(voxels))
    st = np.zeros(strct.shape[1])
    # find voxels in strct
    struct_dict = {}
    for index, voxel in enumerate(strct.fa.voxel_indices):
        struct_dict[tuple(voxel)] = index
    for index, voxel in enumerate(voxels):
        if struct_dict.has_key(tuple(voxel)) :
            st[struct_dict[tuple(voxel)]] = values[index]
            prog.increment_amount()
            print prog, '\r',
            sys.stdout.flush()
    print strct
    print st.shape
    print values.shape
    npair = map2nifti(strct, st)
    nimg = nibabel.nifti1.Nifti1Image(data=npair.get_data(), affine=None, header=npair.get_header())
    nimg.to_filename(filename)



 
