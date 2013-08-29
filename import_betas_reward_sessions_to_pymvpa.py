from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py

from tools import *


#EXPERIMENT_DIR = '/Users/andreirusu/mvpa/3_random_subjects'
EXPERIMENT_DIR = '/Volumes/SAMSUNG/mvpa/3_random_subjects'
#EXPERIMENT_DIR = '/Volumes/SAMSUNG/mvpa/functional'
CURRENT_TASK = 'reward' 
EXPORT_DIR = '/Users/andreirusu/mvpa/datasets'
SPACE = 'roi'
MASK = 'brwROImask.nii'
#SPACE = 'full'
#MASK = 'rmask.nii'


def get_chunks():
    chunks = np.arange(1,3).repeat(32)
    chunks = np.concatenate((chunks, chunks), axis=0)
    return chunks


def get_labels():
    labels = np.arange(1,3).repeat(64)
    return labels



def export_session(subject_dir, sess, ds):
    ### PRE-PROCESSING TEST
    print(sess)
    ds.save(os.path.join(EXPERIMENT_DIR, EXPORT_DIR, CURRENT_TASK + '.'+subject_dir+'.'+sess +'.' + SPACE  +'.hdf5'))
    ### PRE-PROCESSING TEST
    ds = preprocess(ds)





def import_subject(subject_dir):
    print('Subject: ' + subject_dir)
    path = os.path.join(EXPERIMENT_DIR, subject_dir, CURRENT_TASK)
    print('Importing files from: ' + path)
    #ds = fmri_dataset(samples = path, mask=os.path.join(EXPERIMENT_DIR, subject_dir, 'one_back', 'struct', 'PROC', MASK))
    #print(ds.shape)
    #ds.targets = np.ones(ds.shape[0]) * -1
    #ds.chunks = np.ones(ds.shape[0]) * 10
    #ds = dataset_wizard(samples=ds.samples, targets=ds.targets, chunks=ds.chunks)
    os.chdir(os.path.join(path, 'analysis', '1'))
    volumes = glob.glob('beta_*img')
    volumes = volumes[0:128] 
    print(volumes)
    print(len(volumes))
    ds = fmri_dataset(samples = volumes, targets = get_labels(), chunks = get_chunks(), mask=os.path.join(EXPERIMENT_DIR, subject_dir, 'one_back', 'struct', 'PROC', MASK))
    print(ds.shape)
    print(ds.nfeatures)
    print(ds.targets)
    print(ds.chunks)
    # export each chunk as a session
    os.chdir('../..')
    for cnk in np.unique(ds.chunks) :
        export_session(subject_dir, 'sess'+str(cnk), ds[ds.chunks == cnk])
    
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

