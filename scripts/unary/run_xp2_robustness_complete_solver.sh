#!/bin/bash

EXE="../../bin/learn_q_opt"
RESULTS="../../results/unary_complete_search"

for c in {6..1}
do
		echo ""
		echo ""
		echo "*** $(($c*2)) candidates ***"
		echo ""
		echo "AllDiff"
		$EXE -e 1 -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null 1> "$RESULTS/alldiff-12_12_$c"

		echo ""
		echo "Ordered"
		$EXE -e 1 -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null 1> "$RESULTS/ordered-12_12_$c"

		echo ""
		echo "LinearSum"
		$EXE -e 1 -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null 1> "$RESULTS/linear_equation-12_12_72_$c"

		echo ""
		echo "NoOverlap"
		$EXE -e 1 -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null 1> "$RESULTS/no_overlap_1D-8_35_3_$c"

		echo ""
		echo "Channel"
		$EXE -e 1 -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null 1> "$RESULTS/channel-12_12_$c"
done
