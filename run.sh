#!/bin/bash -e 
gpmin config.pb python CV.py -d /Users/andreirusu/mvpa/3_random_subjects -x /Users/andreirusu/mvpa/datasets -t one_back -v kfold -j 1 

