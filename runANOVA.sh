#!/bin/bash -e 
gpmin /Users/andreirusu/mvpa/mvpa-utils/config.pb python /Users/andreirusu/mvpa/mvpa-utils/CV.py -d /Users/andreirusu/mvpa/3_random_subjects -x /Users/andreirusu/mvpa/datasets -t one_back -v kfold -j 1 -f ANOVA 

