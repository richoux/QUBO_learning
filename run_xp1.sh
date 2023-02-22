#!/bin/bash

EXE="./bin/q_learning_opt"
LOOP=100

echo "$LOOP runs for each constraint"
echo ""
echo "AllDiff"
for i in {1..$LOOP}
do
		$EXE -f spaces/alldiff-4_4.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f spaces/incomplete/alldiff-15_15_10000.txt -c tmp --benchmark >> out_error
done
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean errors: $MEAN"

rm tmp out_error

echo ""
echo "Ordered"
for i in {1..$LOOP}
do
		$EXE -f spaces/ordered-4_4.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f spaces/incomplete/ordered-12_18_10000.txt -c tmp --benchmark >> out_error
done
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean errors: $MEAN"

rm tmp out_error

echo ""
echo "LinearSum"
for i in {1..$LOOP}
do
		$EXE -f spaces/linear_equation-4_4_10.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f spaces/incomplete/linear_equation-12_12_72_10000.txt -c tmp --benchmark >> out_error
done
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean errors: $MEAN"

rm tmp out_error

echo ""
echo "NoOverlap"
for i in {1..$LOOP}
do
		$EXE -f spaces/no_overlap_1D-3_7_2.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f spaces/incomplete/no_overlap_1D-12_48_3_10000.txt -c tmp --benchmark >> out_error
done
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean errors: $MEAN"

rm tmp out_error

# echo ""
# echo "Channel"
# for i in {1..$LOOP}
# do
# 		$EXE -f spaces/channel-4_4.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
# 		$EXE -f spaces/incomplete/channel-12_12_10000.txt -c tmp --benchmark >> out_error
# done
# SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
# MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
# echo "Mean errors: $MEAN"

# rm tmp out_error
