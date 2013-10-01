#!/bin/bash -e

python PREDICT.py -o reward  "$@"   > SCAN.reward.log &
python PREDICT.py -o rest.sess1  "$@"   > SCAN.rest.sess1.log &
python PREDICT.py -o rest.sess2  "$@"   > SCAN.rest.sess2.log &
python PREDICT.py -o rest.sess3  "$@"   > SCAN.rest.sess3.log &

