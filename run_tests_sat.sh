#!/bin/bash

# if [ "$#" -ne 1 ]; then
#     echo "Usage: $0 path/to/executable"
# 		exit
# fi

EXE="./bin/q_learning_sat"
LOOP=100

echo "$LOOP runs for each constraint"
echo "Mean runtimes concern the matrix learning. Testing learned matrices may take a while."
echo ""
echo "AllDiff"
for i in {1..$LOOP}
do
		$EXE -f spaces/incomplete/alldiff-12_12_100.txt -p -r tmp --benchmark 2> /dev/null 1> out_time
		$EXE -f spaces/test/alldiff-30_30.txt -c tmp --benchmark >> out_error
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

echo "Mean learning runtime in microseconds: $MEAN"
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean error: $MEAN"

rm tmp out_time out_error

# echo ""
# echo "Ordered"
# for i in {1..$LOOP}
# do
#  		$EXE -f spaces/incomplete/ordered-12_12_100.txt -p -r tmp --benchmark 2> /dev/null 1> out_time
#  		$EXE -f spaces/test/ordered-30_30.txt -c tmp --benchmark >> out_error
# done
# SUM=`grep Wall-clock out_time | sed 's/us//g' | awk -v sum=0 '{sum += $5} END {print sum}'`
# MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
# echo "Mean learning runtime in microseconds: $MEAN"
# SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
# MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
# echo "Mean error: $MEAN"

# rm tmp out_time out_error

echo ""
echo "LinearEquation"
for i in {1..$LOOP}
do
		$EXE -f spaces/incomplete/linear_equation-12_12_72_100.txt -p -r tmp --benchmark 2> /dev/null 1> out_time
		$EXE -f spaces/test/linear_equation-30_30_600.txt -c tmp --benchmark >> out_error
done
SUM=`grep Wall-clock out_time | sed 's/us//g' | awk -v sum=0 '{sum += $5} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean learning runtime in microseconds: $MEAN"
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean error: $MEAN"

rm tmp out_time out_error

echo ""
echo "NoOverlap"
for i in {1..$LOOP}
do
		$EXE -f spaces/incomplete/no_overlap_1D-8_35_3_100.txt -p -r tmp --benchmark 2> /dev/null 1> out_time
		$EXE -f spaces/test/no_overlap_1D-20_160_6.txt -c tmp --benchmark >> out_error
done
SUM=`grep Wall-clock out_time | sed 's/us//g' | awk -v sum=0 '{sum += $5} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean learning runtime in microseconds: $MEAN"
SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
echo "Mean error: $MEAN"

rm tmp out_time out_error

# echo ""
# echo "Channel"
# for i in {1..$LOOP}
# do
# 		$EXE -f spaces/incomplete/channel-12_12_100.txt -p -r tmp --benchmark 2> /dev/null 1> out_time
# 		$EXE -f spaces/test/channel-30_30.txt -c tmp --benchmark >> out_error
# done
# SUM=`grep Wall-clock out_time | sed 's/us//g' | awk -v sum=0 '{sum += $5} END {print sum}'`
# MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
# echo "Mean learning runtime in microseconds: $MEAN"
# SUM=`awk -v sum=0 '{sum += $4} END {print sum}' out_error`
# MEAN=$(echo "scale=2; $SUM/$LOOP" | bc)
# echo "Mean error: $MEAN"

# rm tmp out_error
