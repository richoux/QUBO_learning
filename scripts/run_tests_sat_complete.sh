#!/bin/bash

# if [ "$#" -ne 1 ]; then
#     echo "Usage: $0 path/to/executable"
# 		exit
# fi

EXE="../bin/learn_q_sat"

echo "100 runs for each constraint"
echo "Mean runtimes concern the matrix learning. Testing learned matrices may take a while."
echo ""
echo "AllDiff"
for i in {1..100}
do
		$EXE -f ../spaces/complete/alldiff-4_4.txt -r tmp --benchmark 2> /dev/null 1>> out_time
		$EXE -f ../spaces/test/alldiff-30_30.txt -c tmp --benchmark >> out_error
done
SUM=`grep Wall-clock out_time | sed 's/ms,//g' | awk -v sum=0 '{sum += $7} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/100" | bc)

if [[ ${MEAN%.*} -eq 0 ]]; then
		CORE=$(grep -c '^processor' /proc/cpuinfo)
		echo "Error: no runtimes available."
		echo "Please recompile the project with the following command: 'make clean && make -j $CORE MYFLAGS=-DGHOST_BENCH'"
		rm tmp out_time out_error
		exit
fi

echo "Mean learning runtime in milliseconds: $MEAN"
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

mv out_time ../results/runtime_complete_alldifferent
rm tmp out_error

echo ""
echo "Ordered"
for i in {1..100}
do
 		$EXE -f ../spaces/complete/ordered-4_4.txt -r tmp --benchmark 2> /dev/null 1>> out_time
 		$EXE -f ../spaces/test/ordered-30_30.txt -c tmp --benchmark >> out_error
done
SUM=`grep Wall-clock out_time | sed 's/ms,//g' | awk -v sum=0 '{sum += $7} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/100" | bc)
echo "Mean learning runtime in milliseconds: $MEAN"
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

mv out_time ../results/runtime_complete_ordered
rm tmp out_error

echo ""
echo "LinearEquation"
for i in {1..100}
do
		$EXE -f ../spaces/complete/linear_equation-4_4_10.txt -r tmp --benchmark 2> /dev/null 1>> out_time
		$EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp --benchmark >> out_error
done
SUM=`grep Wall-clock out_time | sed 's/ms,//g' | awk -v sum=0 '{sum += $7} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/100" | bc)
echo "Mean learning runtime in milliseconds: $MEAN"
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

mv out_time ../results/runtime_complete_linear_equation
rm tmp out_error

echo ""
echo "NoOverlap"
for i in {1..100}
do
		$EXE -f ../spaces/complete/no_overlap_1D-3_7_2.txt -r tmp --benchmark 2> /dev/null 1>> out_time
		$EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp --benchmark >> out_error
done
SUM=`grep Wall-clock out_time | sed 's/ms,//g' | awk -v sum=0 '{sum += $7} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/100" | bc)
echo "Mean learning runtime in milliseconds: $MEAN"
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

mv out_time ../results/runtime_complete_no_overlap_1D
rm tmp out_error

echo ""
echo "Channel"
for i in {1..100}
do
		$EXE -f ../spaces/complete/channel-4_4.txt -r tmp --benchmark 2> /dev/null 1>> out_time
		$EXE -f ../spaces/test/channel-30_30.txt -c tmp --benchmark >> out_error
done
SUM=`grep Wall-clock out_time | sed 's/ms,//g' | awk -v sum=0 '{sum += $7} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/100" | bc)
echo "Mean learning runtime in milliseconds: $MEAN"
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

mv out_time ../results/runtime_complete_channel
rm tmp out_error
