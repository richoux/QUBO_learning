#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 SIZE_EXTRACTION"
		exit
fi

SIZE_TAIL=$1
SIZE_HEAD=$(($SIZE_TAIL+1))

head -n $SIZE_HEAD alldiff-12_12_100.txt > "alldiff-12_12_$SIZE_TAIL.txt"
tail -n $SIZE_TAIL alldiff-12_12_100.txt >> "alldiff-12_12_$SIZE_TAIL.txt"

head -n $SIZE_HEAD ordered-12_12_100.txt > "ordered-12_12_$SIZE_TAIL.txt"
tail -n $SIZE_TAIL ordered-12_12_100.txt >> "ordered-12_12_$SIZE_TAIL.txt"

head -n $SIZE_HEAD linear_equation-12_12_72_100.txt > "linear_equation-12_12_72_$SIZE_TAIL.txt"
tail -n $SIZE_TAIL linear_equation-12_12_72_100.txt >> "linear_equation-12_12_72_$SIZE_TAIL.txt"

head -n $SIZE_HEAD no_overlap_1D-8_35_3_100.txt > "no_overlap_1D-8_35_3_$SIZE_TAIL.txt"
tail -n $SIZE_TAIL no_overlap_1D-8_35_3_100.txt >> "no_overlap_1D-8_35_3_$SIZE_TAIL.txt"

head -n $SIZE_HEAD channel-12_12_100.txt > "channel-12_12_$SIZE_TAIL.txt"
tail -n $SIZE_TAIL channel-12_12_100.txt >> "channel-12_12_$SIZE_TAIL.txt"
