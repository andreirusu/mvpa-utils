#!/bin/bash -e


<<NOPREDICTION
python PREDICT.py --roi="scan" -i both -o reward      "$@"  &
python PREDICT.py --roi="scan" -i both -o rest.sess1  "$@"  &
python PREDICT.py --roi="scan" -i both -o rest.sess2  "$@"  &
python PREDICT.py --roi="scan" -i both -o rest.sess3  "$@"  &
python PREDICT.py --roi="scan" -i both -o rest.band.sess1  "$@"  &
python PREDICT.py --roi="scan" -i both -o rest.band.sess2  "$@"  &
python PREDICT.py --roi="scan" -i both -o rest.band.sess3  "$@"  &
NOPREDICTION

#python ALLSTATS.py --roi="scan" -i both  "$@"

python REPORT.py --roi="scan" -i both  "$@" > report.txt


