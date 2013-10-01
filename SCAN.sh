#!/bin/bash -e


<<NOPREDICTION
python PREDICT.py --roi="scan" -i scan -o reward      "$@"  &
python PREDICT.py --roi="scan" -i scan -o rest.sess1  "$@"  &
python PREDICT.py --roi="scan" -i scan -o rest.sess2  "$@"  &
python PREDICT.py --roi="scan" -i scan -o rest.sess3  "$@"  &
NOPREDICTION

python ALLSTATS.py --roi="scan" -i scan  "$@"


