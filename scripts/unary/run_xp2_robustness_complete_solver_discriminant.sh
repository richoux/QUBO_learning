#!/bin/bash

EXE="../../bin/learn_q_opt"
RESULTS="../../results/unary_complete_search"

for c in {6..1}
do
		echo ""
		echo ""
		echo "*** $(($c*2)) candidates ***"
		echo ""
		echo "Channel"
		$EXE -e 1 -f "../../spaces/incomplete/channel-12_12_${c}_discriminant.txt" 2> /dev/null 1> "$RESULTS/channel-12_12_${c}_discriminant"
done
