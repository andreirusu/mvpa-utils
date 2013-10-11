#!/bin/bash -e


##<<NOCORRION
python CORR.py --roi="scan" -i both -o reward      "$@"  &
python CORR.py --roi="scan" -i both -o rest.sess1  "$@"  &
python CORR.py --roi="scan" -i both -o rest.sess2  "$@"  &
python CORR.py --roi="scan" -i both -o rest.sess3  "$@"  &
##NOCORRION

#python ALLSTATS.py --roi="scan" -i both  "$@"


