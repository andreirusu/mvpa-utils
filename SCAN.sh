#!/bin/bash -e

python PREDICT.py -o reward      "$@"  &
python PREDICT.py -o rest.sess1  "$@"  &
python PREDICT.py -o rest.sess2  "$@"  &
python PREDICT.py -o rest.sess3  "$@"  &


