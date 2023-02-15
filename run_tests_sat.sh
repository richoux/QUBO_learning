#!/bin/bash

# if [ "$#" -ne 1 ]; then
#     echo "Usage: $0 path/to/executable"
# 		exit
# fi

EXE="./bin/q_learning_sat"
LOOP=100

echo "$LOOP runs for each constraint"
echo ""
echo "AllDiff"
for i in {1..$LOOP}
do
#		$EXE -f spaces/incomplete/alldiff-15_15_2.txt -p -r tmp --benchmark 2> /dev/null 1>> out_time
		$EXE -f spaces/incomplete/alldiff-15_15_100.txt -p -r tmp --benchmark 2> /dev/null 1>> out_time
		$EXE -f spaces/incomplete/alldiff-15_15_100000.txt -c tmp --benchmark >> out_error
done
SUM=`grep Wall-clock out_time | sed 's/us//g' | awk -v sum=0 '{sum += $5} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)

if [[ ${MEAN%.*} -eq 0 ]]; then
		CORE=$(grep -c '^processor' /proc/cpuinfo)
		echo "Error: no runtimes available."
		echo "Please recompile the project with the following command: 'make clean && make -j $CORE MYFLAGS=-DGHOST_BENCH'"
		rm tmp out_time out_error
		exit
fi

echo "Mean runtime in microseconds: $MEAN"
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean errors: $MEAN"

rm tmp out_time out_error

echo ""
echo "LinearEquation"
for i in {1..$LOOP}
do
#		$EXE -f spaces/incomplete/linear_equation-12_12_72_2.txt -p -r tmp --benchmark 2> /dev/null 1> out_time
		$EXE -f spaces/incomplete/linear_equation-12_12_72_100.txt -p -r tmp --benchmark 2> /dev/null 1> out_time
		$EXE -f spaces/incomplete/linear_equation-12_12_72_10000.txt -c tmp --benchmark >> out_error
done
SUM=`grep Wall-clock out_time | sed 's/us//g' | awk -v sum=0 '{sum += $5} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean runtime in microseconds: $MEAN"
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean errors: $MEAN"

rm tmp out_time out_error

# echo "Connection Minimum"
# for i in {1..$LOOP}
# do
# 		$EXE -f spaces/incomplete/connection_minimum_geq-12_12_3_2.txt -p -r tmp --benchmark 2> /dev/null 1> out_time
# 		$EXE -f spaces/incomplete/connection_minimum_geq-12_12_3_10000.txt -c tmp --benchmark >> out_error
# done
# SUM=`grep Wall-clock out_time | sed 's/us//g' | awk -v sum=0 '{sum += $5} END {print sum}'`
# MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
# echo "Mean runtime in microseconds: $MEAN"
# SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
# MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
# echo "Mean errors: $MEAN"

# rm tmp out_time out_error

echo ""
echo "NoOverlap"
for i in {1..$LOOP}
do
#		$EXE -f spaces/incomplete/no_overlap_1D-12_48_3_3.txt -p -r tmp --benchmark 2> /dev/null 1> out_time
		$EXE -f spaces/incomplete/no_overlap_1D-12_48_3_100.txt -p -r tmp --benchmark 2> /dev/null 1> out_time
		$EXE -f spaces/incomplete/no_overlap_1D-12_48_3_10000.txt -c tmp --benchmark >> out_error
done
SUM=`grep Wall-clock out_time | sed 's/us//g' | awk -v sum=0 '{sum += $5} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean runtime in microseconds: $MEAN"
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean errors: $MEAN"

rm tmp out_time out_error

echo ""
echo "Ordered"
for i in {1..$LOOP}
do
#		$EXE -f spaces/incomplete/ordered-12_18_2.txt -p -r tmp --benchmark 2> /dev/null 1> out_time
		$EXE -f spaces/incomplete/ordered-12_18_100.txt -p -r tmp --benchmark 2> /dev/null 1> out_time
		$EXE -f spaces/incomplete/ordered-12_18_10000.txt -c tmp --benchmark >> out_error
done
SUM=`grep Wall-clock out_time | sed 's/us//g' | awk -v sum=0 '{sum += $5} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean runtime in microseconds: $MEAN"
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean errors: $MEAN"

rm tmp out_time out_error
