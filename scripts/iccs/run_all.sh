#!/bin/bash

echo "Compiling with the GHOST_BENCH flag"
(cd .. ; make clean && make -j 16 MYFLAGS=-DGHOST_BENCH)
echo "Runtime estimation with complete spaces"
./run_tests_sat_complete_16_cores.sh > ../results/tests_sat_complete.txt
echo "Runtime estimation with incomplete spaces"
./run_tests_sat_incomplete_16_cores.sh > ../results/tests_sat_incomplete.txt
echo "Recompiling"
(cd .. ; make clean && make -j 16)
echo "Experiment 1"
./run_xp1_16_cores.sh > ../results/xp1.txt
echo "Experiment 2"
./run_xp2_16_cores.sh > ../results/xp2.txt
echo "Experiment 3"
./run_xp3_16_cores.sh > ../results/xp3.txt
