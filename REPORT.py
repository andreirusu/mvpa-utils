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
import scipy.stats as st
    
### GLOBAL STATS
count = 0
overall_mean_err = 0
stats = 0
tasks = 0
summary = ""


from ROIinfo import *


def group_test_mean(preds, task1, task2, roi, hem) :
    print 'task1: ', task1
    print 'task2: ', task2
    t = [ st.ttest_ind((preds[task1][s][roi][hem]['probs']) if  SUBJECT_GROUP[int(re.findall(r'\d+', s)[0])] == 2 else (1 - preds[task1][s][roi][hem]['probs'])  ,
                        (preds[task2][s][roi][hem]['probs']) if  SUBJECT_GROUP[int(re.findall(r'\d+', s)[0])] == 2 else (1 - preds[task2][s][roi][hem]['probs']), equal_var=False)[0].item()  
                for s in preds[task1]['subjects'] 
                    if s in preds[task1] 
                        and roi in preds[task1][s] ]
    tval, pval = st.ttest_1samp(t, 0)
    print 'T: '+ str(t)
    print 'Sample size: ' + str(np.size(t))
    print(DELIM)
    print 't-statistic = %6.3f pvalue = %6.4f' %   (tval, pval)
    if pval < 0.05:
        print "*",
    if pval < 0.01:
        print "*",
    if pval < 0.001:
        print "*",
    if pval < 0.0001:
        print "*",
    print " "
    print " "
    return t, tval, tval




def test_probs(preds, tasks, roi, hem) :
    return [ [group_test_mean(preds, tasks[2], tasks[1], roi, hem)], 
                [group_test_mean(preds, tasks[3], tasks[2], roi, hem)],
                [group_test_mean(preds, tasks[3], tasks[1], roi, hem)] ]


def plot_corr_errors(stats, tasks, xstat, ystat, options, axis) :
    plots = []
    labels =[]
    count = 0 
    roi_count = np.size(ROIids.keys())
    fig = pl.figure(figsize=(5 * len(options.HEM) * roi_count / 3, 5 * 3), dpi=70)
    for i, roi in enumerate(ROIids) :
        for hem in  options.HEM  :
            try:
                count += 1
                pl.subplot(3, len(options.HEM) *  roi_count / 3, count)
                x = [ stats['preds'][options.TEST_PREFIX][s][roi][hem][xstat] 
                                for s in stats['preds'][options.TEST_PREFIX]['subjects'] 
                                    if s in stats['preds'][options.TEST_PREFIX] 
                                        and roi in stats['preds'][options.TEST_PREFIX][s] ]
                y = [ stats['preds'][options.TEST_PREFIX][s][roi][hem][ystat] 
                                for s in stats['preds'][options.TEST_PREFIX]['subjects'] 
                                    if s in stats['preds'][options.TEST_PREFIX] 
                                        and roi in stats['preds'][options.TEST_PREFIX][s] ]
                fit = np.polyfit(x,y,1)
                fit_fn = np.poly1d(fit) # fit_fn is now a function which takes in x and returns an estimate for y
                p = pl.plot(x,y, 'yo', x, fit_fn(x), '--k')
                plots.append(p)
                label = str(hem) + " " + str(roi)
                labels.append(label)
                pl.title(label)
                pl.xlabel(xstat)
                pl.ylabel(ystat)
                pl.axis(axis)
                pl.axhspan(0.5, 1, color='red', alpha=0.25)
                pl.axvspan(0.5, 1 , color='red', alpha=0.25)
            except:
                pass
    fig.suptitle('stats.'+ xstat +'.'+ ystat , fontsize=12)
    fig.savefig('stats.'+ xstat +'.'+ ystat + '.png', dpi=100)


def print_stats(stats, tasks, ystat, options) :
    global summary
    count = 0 
    summary += "%s\tmean\t(SEM)\n" % ystat
    roi_count = np.size(ROIids.keys())
    for i, roi in enumerate(ROIids) :
        for hem in  options.HEM : 
            try:
                count += 1
                label = str(hem) + " " + str(roi)
                y = [ stats['preds'][options.TEST_PREFIX][s][roi][hem][ystat] for s in stats['preds'][options.TEST_PREFIX]['subjects'] if s in stats['preds'][options.TEST_PREFIX] and roi in stats['preds'][options.TEST_PREFIX][s] ]
                s = [ s for s in stats['preds'][options.TEST_PREFIX]['subjects'] if s in stats['preds'][options.TEST_PREFIX] and roi in stats['preds'][options.TEST_PREFIX][s] ]
                summary += "%s\t" % label
                summary += "%.4f\t(%.4f)\n" % (sum(y)/float(len(y)), np.std(np.array(y)) / math.sqrt(len(y)))
            except:
                pass
    summary += '\n' 




def plot_corr(stats, tasks, xstat, ystat, options, axis) :
    global summary
    plots = []
    labels =[]
    count = 0 
    roi_count = np.size(ROIids.keys())
    fig = pl.figure(figsize=(5 * len(options.HEM) * roi_count / 3, 5 * 3), dpi=70)
    for i, roi in enumerate(ROIids) :
        for hem in  options.HEM : 
            try:
                count += 1
                label = str(hem) + " " + str(roi)
                print(DELIM)
                print(label)
                print(DELIM)
                pl.subplot(3, len(options.HEM) * roi_count / 3, count)
                x = [ stats['preds'][options.TEST_PREFIX][s][roi][hem][xstat] for s in stats['preds'][options.TEST_PREFIX]['subjects'] if s in stats['preds'][options.TEST_PREFIX] and roi in stats['preds'][options.TEST_PREFIX][s] ]
                y = [ stats['preds'][options.TEST_PREFIX][s][roi][hem][ystat] for s in stats['preds'][options.TEST_PREFIX]['subjects'] if s in stats['preds'][options.TEST_PREFIX] and roi in stats['preds'][options.TEST_PREFIX][s] ]
                s = [ s for s in stats['preds'][options.TEST_PREFIX]['subjects'] if s in stats['preds'][options.TEST_PREFIX] and roi in stats['preds'][options.TEST_PREFIX][s] ]
                print xstat, x, 'mean: ', sum(x) / float(len(x)), ' SEM: ', np.std(np.array(x)) / math.sqrt(len(x))
                print ystat, y, 'mean: ', sum(y) / float(len(y)), ' SEM: ', np.std(np.array(y)) / math.sqrt(len(y))
                fit = np.polyfit(x,y,1)
                fit_fn = np.poly1d(fit) # fit_fn is now a function which takes in x and returns an estimate for y
                p = pl.plot(x,y, 'yo', x, fit_fn(x), '--k')
                plots.append(p)
                label = str(hem) + " " + str(roi)
                labels.append(label)
                pl.title(label)
                pl.xlabel(xstat)
                pl.ylabel(ystat)
                pl.axis(axis)
                pl.axhspan(0.5, 1, color='red', alpha=0.25)
                print(DELIM1)
            except:
                pass
    fig.suptitle('stats.'+ xstat +'.'+ ystat , fontsize=12)
    fig.savefig('stats.'+ xstat +'.'+ ystat + '.png', dpi=100)



def plot_corr_t(stats, tasks, xstat, ystat, options, axis) :
    plots = []
    labels =[]
    count = 0 
    roi_count = np.size(ROIids.keys())
    fig = pl.figure(figsize=(5 * len(options.HEM) * roi_count / 3, 5 * 3), dpi=70)
    for i, roi in enumerate(ROIids) :
        for hem in options.HEM :
            try:
                count += 1
                label = str(hem) + " " + str(roi)
                print(label)
                print(DELIM)
                labels.append(label)
                pl.subplot(3, len(options.HEM) *  roi_count / 3, count)
                pl.title(label)

                test_data = test_probs(stats['preds'], tasks, roi, hem)
                
                x = np.array(test_data[1][0][0])
                y = [ stats['preds'][options.TEST_PREFIX][s][roi][hem][ystat] for s in stats['preds'][options.TEST_PREFIX]['subjects'] if s in stats['preds'][options.TEST_PREFIX] and roi in stats['preds'][options.TEST_PREFIX][s] ]
                fit = np.polyfit(x,y,1)
                fit_fn = np.poly1d(fit) # fit_fn is now a function which takes in x and returns an estimate for y
                print x, y, np.size(x), np.size(y)
                p = pl.plot(x,y, 'yo', x, fit_fn(x), '--k')
                plots.append(p)
                pl.xlabel(xstat)
                pl.ylabel(ystat)
                pl.axis(axis)
                pl.axhspan(0.5, 1, color='red', alpha=0.25)
                print(DELIM1)
            except:
                pass
    fig.suptitle('stats.'+ xstat +'.'+ ystat , fontsize=12)
    fig.savefig('stats.'+ xstat +'.'+ ystat + '.png', dpi=100)



def tests(stats, tasks, options) :
    count = 0
    for i, roi in enumerate(ROIids) :
        for hem in options.HEM :
            try:
                print(DELIM)
                label = str(hem) + " " + str(roi)
                print(label)
                print(DELIM)
                count += 1
                test_data = test_probs(stats['preds'], tasks, roi, hem)
                print(DELIM1)
            except:
                pass



def main(options):
    global count
    global overall_mean_err
    global stats
    global tasks
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
    os.chdir(options.EXPORT_DIR)
    # save stats
    tasks = ['reward', 'rest.sess1', 'rest.sess2', 'rest.sess3']
    
    print("Loading ALLSTATS...")
    ### save results
    res_name    = 'ALLSTATS.scan.scan.' + options.CLF + '.'+options.TRAIN_PREFIX+ '.'+options.TEST_PREFIX  + '.' +  options.SPACE
    stats = h5load(res_name + '.hdf5') 
    print("Done.")

    if options.HEM == "scan":
        options.HEM = ['left', 'right', 'both']
    else:
        options.HEM = [ options.HEM ]
    
    plot_corr_errors(stats, tasks, 'train_mean_cv_error', 'error', options, [0,1,0,1])
    plot_corr_errors(stats, tasks, 'test_mean_cv_error', 'error', options, [0,1,0,1])
    plot_corr_errors(stats, tasks, 'train_mean_cv_error', 'test_mean_cv_error', options, [0,1,0,1])
    plot_corr(stats, tasks, 'voxel_count', 'train_mean_cv_error', options, [0,5000,0,1])
    plot_corr(stats, tasks, 'voxel_count', 'error', options, [0,5000,0,1])
    #plot_corr_t(stats, tasks, 't', 'error', options, [-5,5,0,1])
    tests(stats, tasks, options)
    print_stats(stats, tasks, 'train_mean_cv_error', options)
    print_stats(stats, tasks, 'test_mean_cv_error', options)
    print_stats(stats, tasks, 'error', options)
    
    
    # print results
    print(DELIM1)
    print('Global stats:')
    #pprint.pprint(stats, width=80)
    if count > 0 :
        overall_mean_err /= count
        print(DELIM1)
        print('Overall mean measure: '+str(overall_mean_err))
    print(DELIM1)
    if options.PLOT:
        pl.show()
    print(summary)
    print('Done\n')
    

if __name__ == "__main__" :
    main(parseOptions())

