from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py


EXPERIMENT_DIR = '/Users/andreirusu/mvpa/3_random_subjects'
#EXPERIMENT_DIR = '/Volumes/SAMSUNG/mvpa/3_random_subjects'
CURRENT_TASK = 'rest' # 'reward' also supported
EXPORT_DIR = '/Users/andreirusu/mvpa/datasets'


def import_session(subject_dir, sess):
    path = os.path.join(EXPERIMENT_DIR, subject_dir, CURRENT_TASK, sess, 'PROC', 'out.nii')
    print('Importing files from: ' + path)
    ds = fmri_dataset(samples = path, mask=os.path.join(EXPERIMENT_DIR, subject_dir, 'one_back', 'struct', 'PROC', 'rmask.nii'))
    ds.targets = np.zeros(ds.shape[1])
    ds.chunks = np.zeros(ds.shape[1])
    print(ds.shape)
    print(ds.nfeatures)
    print(ds.targets)
    print(ds.chunks)
    ds.save(os.path.join(EXPERIMENT_DIR, EXPORT_DIR, CURRENT_TASK + '.'+subject_dir+'.'+sess+'.full.hdf5'))




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
