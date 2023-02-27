#!/bin/bash

EXE="./bin/q_learning_opt"
LOOP=100

echo "$LOOP runs for each constraint"
echo ""
echo "AllDiff"
for i in {1..$LOOP}
do
		$EXE -f spaces/complete/alldiff-4_4.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f spaces/test/alldiff-30_30.txt -c tmp --benchmark >> out_error
done
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
echo "Total sum of errors: $SUM"
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean error: $MEAN"

rm tmp out_error

echo ""
echo "Ordered"
for i in {1..$LOOP}
do
		$EXE -f spaces/complete/ordered-4_4.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f spaces/test/ordered-30_30.txt -c tmp --benchmark >> out_error
done
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
echo "Total sum of errors: $SUM"
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean error: $MEAN"

rm tmp out_error

echo ""
echo "LinearSum"
for i in {1..$LOOP}
do
		$EXE -f spaces/complete/linear_equation-4_4_10.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f spaces/test/linear_equation-30_30_600.txt -c tmp --benchmark >> out_error
done
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
echo "Total sum of errors: $SUM"
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean error: $MEAN"

rm tmp out_error

echo ""
echo "NoOverlap"
for i in {1..$LOOP}
do
		$EXE -f spaces/complete/no_overlap_1D-3_7_2.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f spaces/test/no_overlap_1D-20_160_6.txt -c tmp --benchmark >> out_error
done
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
echo "Total sum of errors: $SUM"
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean error: $MEAN"

rm tmp out_error

echo ""
echo "Channel"
for i in {1..$LOOP}
do
		$EXE -f spaces/complete/channel-4_4.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f spaces/test/channel-30_30.txt -c tmp --benchmark >> out_error
done
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
echo "Total sum of errors: $SUM"
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean error: $MEAN"

rm tmp out_error
