#!/bin/bash

EXE="../bin/q_learning_sat"

CORE=$(grep -c '^processor' /proc/cpuinfo)
if ! [[ ${CORE%.*} -eq 16 ]]; then
		echo "Error: this script has been designed to run on a 16-core CPU."
		echo "Your CPU has $CORE cores. Please modify this script accordingly."
		exit
fi

echo "100 runs for each constraint"
echo "Mean runtimes concern the matrix learning. Testing learned matrices may take a while."
echo ""
echo "AllDiff"
>&2 echo ""
>&2 echo "AllDiff"
for i in {1..6}
do
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp01 --benchmark 2> /dev/null 1>> out_time_01 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp01 --benchmark >> out_error_01 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp02 --benchmark 2> /dev/null 1>> out_time_02 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp02 --benchmark >> out_error_02 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp03 --benchmark 2> /dev/null 1>> out_time_03 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp03 --benchmark >> out_error_03 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp04 --benchmark 2> /dev/null 1>> out_time_04 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp04 --benchmark >> out_error_04 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp05 --benchmark 2> /dev/null 1>> out_time_05 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp05 --benchmark >> out_error_05 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp06 --benchmark 2> /dev/null 1>> out_time_06 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp06 --benchmark >> out_error_06 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp07 --benchmark 2> /dev/null 1>> out_time_07 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp07 --benchmark >> out_error_07 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp08 --benchmark 2> /dev/null 1>> out_time_08 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp08 --benchmark >> out_error_08 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp09 --benchmark 2> /dev/null 1>> out_time_09 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp09 --benchmark >> out_error_09 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp10 --benchmark 2> /dev/null 1>> out_time_10 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp10 --benchmark >> out_error_10 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp11 --benchmark 2> /dev/null 1>> out_time_11 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp11 --benchmark >> out_error_11 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp12 --benchmark 2> /dev/null 1>> out_time_12 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp12 --benchmark >> out_error_12 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp13 --benchmark 2> /dev/null 1>> out_time_13 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp13 --benchmark >> out_error_13 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp14 --benchmark 2> /dev/null 1>> out_time_14 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp14 --benchmark >> out_error_14 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp15 --benchmark 2> /dev/null 1>> out_time_15 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp15 --benchmark >> out_error_15 &
		$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp16 --benchmark 2> /dev/null 1>> out_time_16 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp16 --benchmark >> out_error_16 &
		wait
		>&2 echo "$((16*i))% done"
done

$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp01 --benchmark 2> /dev/null 1>> out_time_01 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp01 --benchmark >> out_error_01 &
$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp02 --benchmark 2> /dev/null 1>> out_time_02 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp02 --benchmark >> out_error_02 &
$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp03 --benchmark 2> /dev/null 1>> out_time_03 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp03 --benchmark >> out_error_03 &
$EXE -f "../spaces/complete/alldiff-4_4.txt" -r tmp04 --benchmark 2> /dev/null 1>> out_time_04 ; $EXE -f ../spaces/test/alldiff-30_30.txt -c tmp04 --benchmark >> out_error_04 &
wait

cat out_error_?? > out_error ; cat out_time_?? > out_time ; rm -f out_error_?? out_time_?? tmp?? 
sed -i '/^ *$/d' out_error

SUM=`grep Wall-clock out_time | sed 's/ms,//g' | awk -v sum=0 '{sum += $7} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/100" | bc)

if [[ ${MEAN%.*} -eq 0 ]]; then
		echo "Error: no runtimes available."
		echo "Please recompile the project with the following command: 'make clean && make -j $CORE MYFLAGS=-DGHOST_BENCH'"
		rm out_time out_error
		exit
fi

echo "Mean learning runtime in milliseconds: $MEAN"
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

grep Wall out_time | sed 's/ms,//g' | awk '{print $7}' > ../results/runtime_complete_alldifferent
rm out_error out_time

echo ""
echo "Ordered"
>&2 echo ""
>&2 echo "Ordered"
for i in {1..6}
do
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp01 --benchmark 2> /dev/null 1>> out_time_01 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp01 --benchmark >> out_error_01 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp02 --benchmark 2> /dev/null 1>> out_time_02 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp02 --benchmark >> out_error_02 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp03 --benchmark 2> /dev/null 1>> out_time_03 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp03 --benchmark >> out_error_03 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp04 --benchmark 2> /dev/null 1>> out_time_04 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp04 --benchmark >> out_error_04 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp05 --benchmark 2> /dev/null 1>> out_time_05 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp05 --benchmark >> out_error_05 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp06 --benchmark 2> /dev/null 1>> out_time_06 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp06 --benchmark >> out_error_06 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp07 --benchmark 2> /dev/null 1>> out_time_07 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp07 --benchmark >> out_error_07 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp08 --benchmark 2> /dev/null 1>> out_time_08 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp08 --benchmark >> out_error_08 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp09 --benchmark 2> /dev/null 1>> out_time_09 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp09 --benchmark >> out_error_09 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp10 --benchmark 2> /dev/null 1>> out_time_10 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp10 --benchmark >> out_error_10 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp11 --benchmark 2> /dev/null 1>> out_time_11 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp11 --benchmark >> out_error_11 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp12 --benchmark 2> /dev/null 1>> out_time_12 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp12 --benchmark >> out_error_12 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp13 --benchmark 2> /dev/null 1>> out_time_13 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp13 --benchmark >> out_error_13 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp14 --benchmark 2> /dev/null 1>> out_time_14 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp14 --benchmark >> out_error_14 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp15 --benchmark 2> /dev/null 1>> out_time_15 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp15 --benchmark >> out_error_15 &
		$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp16 --benchmark 2> /dev/null 1>> out_time_16 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp16 --benchmark >> out_error_16 &
		wait
		>&2 echo "$((16*i))% done"
done

$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp01 --benchmark 2> /dev/null 1>> out_time_01 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp01 --benchmark >> out_error_01 &
$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp02 --benchmark 2> /dev/null 1>> out_time_02 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp02 --benchmark >> out_error_02 &
$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp03 --benchmark 2> /dev/null 1>> out_time_03 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp03 --benchmark >> out_error_03 &
$EXE -f "../spaces/complete/ordered-4_4.txt" -r tmp04 --benchmark 2> /dev/null 1>> out_time_04 ; $EXE -f ../spaces/test/ordered-30_30.txt -c tmp04 --benchmark >> out_error_04 &
wait

cat out_error_?? > out_error ; cat out_time_?? > out_time ; rm -f out_error_?? out_time_?? tmp?? 
sed -i '/^ *$/d' out_error

SUM=`grep Wall-clock out_time | sed 's/ms,//g' | awk -v sum=0 '{sum += $7} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/100" | bc)
echo "Mean learning runtime in milliseconds: $MEAN"
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

grep Wall out_time | sed 's/ms,//g' | awk '{print $7}' > ../results/runtime_complete_ordered
rm out_error out_time

echo ""
echo "LinearEquation"
>&2 echo ""
>&2 echo "LinearEquation"
for i in {1..6}
do
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp01 --benchmark 2> /dev/null 1>> out_time_01 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp01 --benchmark >> out_error_01 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp02 --benchmark 2> /dev/null 1>> out_time_02 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp02 --benchmark >> out_error_02 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp03 --benchmark 2> /dev/null 1>> out_time_03 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp03 --benchmark >> out_error_03 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp04 --benchmark 2> /dev/null 1>> out_time_04 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp04 --benchmark >> out_error_04 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp05 --benchmark 2> /dev/null 1>> out_time_05 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp05 --benchmark >> out_error_05 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp06 --benchmark 2> /dev/null 1>> out_time_06 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp06 --benchmark >> out_error_06 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp07 --benchmark 2> /dev/null 1>> out_time_07 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp07 --benchmark >> out_error_07 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp08 --benchmark 2> /dev/null 1>> out_time_08 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp08 --benchmark >> out_error_08 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp09 --benchmark 2> /dev/null 1>> out_time_09 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp09 --benchmark >> out_error_09 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp10 --benchmark 2> /dev/null 1>> out_time_10 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp10 --benchmark >> out_error_10 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp11 --benchmark 2> /dev/null 1>> out_time_11 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp11 --benchmark >> out_error_11 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp12 --benchmark 2> /dev/null 1>> out_time_12 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp12 --benchmark >> out_error_12 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp13 --benchmark 2> /dev/null 1>> out_time_13 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp13 --benchmark >> out_error_13 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp14 --benchmark 2> /dev/null 1>> out_time_14 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp14 --benchmark >> out_error_14 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp15 --benchmark 2> /dev/null 1>> out_time_15 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp15 --benchmark >> out_error_15 &
		$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp16 --benchmark 2> /dev/null 1>> out_time_16 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp16 --benchmark >> out_error_16 &
		wait
		>&2 echo "$((16*i))% done"
done

$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp01 --benchmark 2> /dev/null 1>> out_time_01 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp01 --benchmark >> out_error_01 &
$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp02 --benchmark 2> /dev/null 1>> out_time_02 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp02 --benchmark >> out_error_02 &
$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp03 --benchmark 2> /dev/null 1>> out_time_03 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp03 --benchmark >> out_error_03 &
$EXE -f "../spaces/complete/linear_equation-4_4_10.txt" -r tmp04 --benchmark 2> /dev/null 1>> out_time_04 ; $EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp04 --benchmark >> out_error_04 &
wait

cat out_error_?? > out_error ; cat out_time_?? > out_time ; rm -f out_error_?? out_time_?? tmp?? 
sed -i '/^ *$/d' out_error

SUM=`grep Wall-clock out_time | sed 's/ms,//g' | awk -v sum=0 '{sum += $7} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/100" | bc)
echo "Mean learning runtime in milliseconds: $MEAN"
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

grep Wall out_time | sed 's/ms,//g' | awk '{print $7}' > ../results/runtime_complete_linear_equation
rm out_error out_time

echo ""
echo "NoOverlap"
>&2 echo ""
>&2 echo "NoOverlap"
for i in {1..6}
do
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp01 --benchmark 2> /dev/null 1>> out_time_01 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp01 --benchmark >> out_error_01 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp02 --benchmark 2> /dev/null 1>> out_time_02 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp02 --benchmark >> out_error_02 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp03 --benchmark 2> /dev/null 1>> out_time_03 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp03 --benchmark >> out_error_03 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp04 --benchmark 2> /dev/null 1>> out_time_04 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp04 --benchmark >> out_error_04 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp05 --benchmark 2> /dev/null 1>> out_time_05 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp05 --benchmark >> out_error_05 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp06 --benchmark 2> /dev/null 1>> out_time_06 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp06 --benchmark >> out_error_06 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp07 --benchmark 2> /dev/null 1>> out_time_07 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp07 --benchmark >> out_error_07 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp08 --benchmark 2> /dev/null 1>> out_time_08 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp08 --benchmark >> out_error_08 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp09 --benchmark 2> /dev/null 1>> out_time_09 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp09 --benchmark >> out_error_09 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp10 --benchmark 2> /dev/null 1>> out_time_10 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp10 --benchmark >> out_error_10 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp11 --benchmark 2> /dev/null 1>> out_time_11 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp11 --benchmark >> out_error_11 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp12 --benchmark 2> /dev/null 1>> out_time_12 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp12 --benchmark >> out_error_12 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp13 --benchmark 2> /dev/null 1>> out_time_13 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp13 --benchmark >> out_error_13 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp14 --benchmark 2> /dev/null 1>> out_time_14 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp14 --benchmark >> out_error_14 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp15 --benchmark 2> /dev/null 1>> out_time_15 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp15 --benchmark >> out_error_15 &
		$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp16 --benchmark 2> /dev/null 1>> out_time_16 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp16 --benchmark >> out_error_16 &
		wait
		>&2 echo "$((16*i))% done"
done

$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp01 --benchmark 2> /dev/null 1>> out_time_01 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp01 --benchmark >> out_error_01 &
$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp02 --benchmark 2> /dev/null 1>> out_time_02 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp02 --benchmark >> out_error_02 &
$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp03 --benchmark 2> /dev/null 1>> out_time_03 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp03 --benchmark >> out_error_03 &
$EXE -f "../spaces/complete/no_overlap_1D-3_7_2.txt" -r tmp04 --benchmark 2> /dev/null 1>> out_time_04 ; $EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp04 --benchmark >> out_error_04 &
wait

cat out_error_?? > out_error ; cat out_time_?? > out_time ; rm -f out_error_?? out_time_?? tmp?? 
sed -i '/^ *$/d' out_error

SUM=`grep Wall-clock out_time | sed 's/ms,//g' | awk -v sum=0 '{sum += $7} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/100" | bc)
echo "Mean learning runtime in milliseconds: $MEAN"
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

grep Wall out_time | sed 's/ms,//g' | awk '{print $7}' > ../results/runtime_complete_no_overlap_1D
rm out_error out_time

echo ""
echo "Channel"
>&2 echo ""
>&2 echo "Channel"
for i in {1..6}
do
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp01 --benchmark 2> /dev/null 1>> out_time_01 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp01 --benchmark >> out_error_01 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp02 --benchmark 2> /dev/null 1>> out_time_02 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp02 --benchmark >> out_error_02 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp03 --benchmark 2> /dev/null 1>> out_time_03 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp03 --benchmark >> out_error_03 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp04 --benchmark 2> /dev/null 1>> out_time_04 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp04 --benchmark >> out_error_04 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp05 --benchmark 2> /dev/null 1>> out_time_05 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp05 --benchmark >> out_error_05 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp06 --benchmark 2> /dev/null 1>> out_time_06 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp06 --benchmark >> out_error_06 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp07 --benchmark 2> /dev/null 1>> out_time_07 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp07 --benchmark >> out_error_07 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp08 --benchmark 2> /dev/null 1>> out_time_08 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp08 --benchmark >> out_error_08 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp09 --benchmark 2> /dev/null 1>> out_time_09 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp09 --benchmark >> out_error_09 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp10 --benchmark 2> /dev/null 1>> out_time_10 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp10 --benchmark >> out_error_10 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp11 --benchmark 2> /dev/null 1>> out_time_11 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp11 --benchmark >> out_error_11 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp12 --benchmark 2> /dev/null 1>> out_time_12 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp12 --benchmark >> out_error_12 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp13 --benchmark 2> /dev/null 1>> out_time_13 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp13 --benchmark >> out_error_13 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp14 --benchmark 2> /dev/null 1>> out_time_14 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp14 --benchmark >> out_error_14 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp15 --benchmark 2> /dev/null 1>> out_time_15 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp15 --benchmark >> out_error_15 &
		$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp16 --benchmark 2> /dev/null 1>> out_time_16 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp16 --benchmark >> out_error_16 &
		wait
		>&2 echo "$((16*i))% done"
done

$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp01 --benchmark 2> /dev/null 1>> out_time_01 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp01 --benchmark >> out_error_01 &
$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp02 --benchmark 2> /dev/null 1>> out_time_02 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp02 --benchmark >> out_error_02 &
$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp03 --benchmark 2> /dev/null 1>> out_time_03 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp03 --benchmark >> out_error_03 &
$EXE -f "../spaces/complete/channel-4_4.txt" -r tmp04 --benchmark 2> /dev/null 1>> out_time_04 ; $EXE -f ../spaces/test/channel-30_30.txt -c tmp04 --benchmark >> out_error_04 &
wait

cat out_error_?? > out_error ; cat out_time_?? > out_time ; rm -f out_error_?? out_time_?? tmp?? 
sed -i '/^ *$/d' out_error

SUM=`grep Wall-clock out_time | sed 's/ms,//g' | awk -v sum=0 '{sum += $7} END {print sum}'`
MEAN=$(echo "scale=2; $SUM/100" | bc)
echo "Mean learning runtime in milliseconds: $MEAN"
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

grep Wall out_time | sed 's/ms,//g' | awk '{print $7}' > ../results/runtime_complete_channel
rm out_error out_time
