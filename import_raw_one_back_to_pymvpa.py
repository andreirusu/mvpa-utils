from mvpa2.suite import *
import matplotlib
import scipy
import numpy as inp
import os
import glob
import h5py


EXPERIMENT_DIR = '/Users/andreirusu/mvpa/3_random_subjects'
CURRENT_TASK = 'one_back' # 'reward' also supported
EXPORT_DIR = '../datasets'
VOLUME_THRESHOLD = 0.7

def clean_up_filename(s):
    return s.split(',')[0]


def get_file_list(mat):
    flst = mat['SPM']['xY'][0][0]['P'][0][0].tolist()
    for i, fstr in enumerate(flst):
        flst[i] = clean_up_filename(fstr)
    return flst

def get_chunks(mat):
    #chunks = abs(np.array(mat['SPM']['xX'][0][0]['X'][0][0][:, 0]) * 0) 
    #chunks[1:np.floor(np.size(chunks)/2) ] = 1
    #chunks[np.floor(np.size(chunks)/2):np.size(chunks)] = 2
    chunks = np.arange(1,6).repeat(79)
    return chunks

def get_labels(mat):
    labels = abs(np.array(mat['SPM']['xX'][0][0]['X'][0][0][:, 0]) * 0)
    labels[mat['SPM']['xX'][0][0]['X'][0][0][:, 0] > VOLUME_THRESHOLD] = 1
    labels[mat['SPM']['xX'][0][0]['X'][0][0][:, 2] > VOLUME_THRESHOLD] = 2
    return labels

def main():
    os.chdir(EXPERIMENT_DIR)
    print('Working in '+os.getcwd())
    # assume current directory contains a directory per subject, begining with the symbol 's' 
    contents=glob.glob('s*')
    print('Found subjects: ' + str(contents))
    for subject_dir in contents :
        print('Subject: ' + subject_dir)
        os.chdir(os.path.join(EXPERIMENT_DIR, subject_dir))
        mat = scipy.io.loadmat(os.path.join(EXPERIMENT_DIR, subject_dir, CURRENT_TASK, 'analysis', '1', 'SPM.mat'))
        # print( > 0.5)
        volumes = get_file_list(mat)
        print(len(volumes))
        ds = fmri_dataset(samples = volumes, targets = get_labels(mat), chunks = get_chunks(mat), mask=os.path.join(EXPERIMENT_DIR, subject_dir, 'one_back', 'struct', 'PROC', 'rmask.nii'))
        print(ds.shape)
        print(ds.nfeatures)
        print(ds.targets)
        print(ds.chunks)
        ds.save(os.path.join(EXPERIMENT_DIR, EXPORT_DIR, 'RAW.'+CURRENT_TASK + '.'+subject_dir+'.full.hdf5'))


def import_subject_dataset(path):
    print(path)


if __name__ == "__main__" :
    main()

