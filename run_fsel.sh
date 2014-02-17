#!/bin/bash -e 
gpmin config_fsel.pb python CV.py -d /Users/andreirusu/mvpa/functional -x /Users/andreirusu/mvpa/datasets -t one_back -v kfold -j 1 --fsel ANOVA 
#gpmin config_fsel.pb python CV.py -d /Users/andreirusu/mvpa/functional -x /Users/andreirusu/mvpa/datasets -t one_back -v kfold -j 1 --fsel GNB_SL 

