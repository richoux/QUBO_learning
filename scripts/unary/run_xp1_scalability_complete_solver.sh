#!/bin/bash

EXE="../../bin/learn_q_opt"
RESULTS="../../results/unary_complete_search"

echo "AllDiff"
$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null 1> "$RESULTS"/alldiff-complete_patterns

echo ""
echo "Ordered"
$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null 1> "$RESULTS"/ordered-complete_patterns

echo ""
echo "LinearSum"
$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null 1> "$RESULTS"/linear_equation-complete_patterns

echo ""
echo "NoOverlap"
$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null 1> "$RESULTS"/no_overlap_1D-complete_patterns

echo ""
echo "Channel"
$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null 1> "$RESULTS"/channel-complete_patterns
