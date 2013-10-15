from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py

from tools import *


#EXPERIMENT_DIR = '/Users/andreirusu/mvpa/3_random_subjects'
#EXPERIMENT_DIR = '/Volumes/backup/mvpa/3_random_subjects'
EXPERIMENT_DIR = '/Volumes/backup/mvpa/functional'
CURRENT_TASK = 'rest' # 'reward' also supported
EXPORT_DIR = '/Users/andreirusu/mvpa/datasets/gray'
#SPACE = 'roi'
#MASK = 'brwROImask.nii'
SPACE = 'full'
MASK = 'rmask.nii'
CLUSTERS = 'srwROIclusters.nii'



def import_session(subject_dir, sess):
    path = os.path.join(EXPERIMENT_DIR, subject_dir, CURRENT_TASK, sess, 'PROC', 'out.nii')
    print('Importing files from: ' + path)
    ds = fmri_dataset(samples = path, mask=os.path.join(EXPERIMENT_DIR, subject_dir, 'one_back', 'struct', 'PROC', MASK))
    print(ds.shape)
    ds.targets = np.ones(ds.shape[0]) * -1
    ds.chunks = np.ones(ds.shape[0]) * 100
    ds = dataset_wizard(samples=ds.samples, targets=ds.targets, chunks=ds.chunks)
    # import clusters 
    clusters_ds = fmri_dataset(samples = os.path.join(EXPERIMENT_DIR, subject_dir, 'one_back', 'struct', 'PROC', CLUSTERS), targets = [-1], chunks = [-1], mask=os.path.join(EXPERIMENT_DIR, subject_dir, 'one_back', 'struct', 'PROC', MASK))
    cluster_ids = np.abs(np.round(clusters_ds.samples[0]))
    print(np.sum(cluster_ids > 0))
    ds.fa['clusters'] = cluster_ids
    print(ds.shape)
    print(ds.nfeatures)
    print(ds.targets)
    print(ds.chunks)
    print(np.mean(ds.fa.clusters))
    ds.save(os.path.join(EXPERIMENT_DIR, EXPORT_DIR, CURRENT_TASK +'.'+sess+ '.'+subject_dir +'.' + SPACE  +'.hdf5'))
    ### PRE-PROCESSING TEST
    #ds = preprocess(ds)




def import_subject(subject_dir):
    print('Subject: ' + subject_dir)
    os.chdir(os.path.join(EXPERIMENT_DIR, subject_dir, CURRENT_TASK))
    print('Looking for sessions in: ' + os.getcwd())
    sessions = glob.glob('sess*')
    print('Found: ' + str(sessions))
    for sess in sessions :
        import_session(subject_dir, sess)
    
def main():
    os.chdir(EXPERIMENT_DIR)
    print('Working in '+os.getcwd())
    # assume current directory contains a directory per subject, begining with the symbol 's' 
    contents=glob.glob('s*')
    print('Found subjects: ' + str(contents))
    for subject_dir in contents :
        import_subject(subject_dir)
        
       
if __name__ == "__main__" :
    main()

