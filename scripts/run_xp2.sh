#!/bin/bash

EXE="../bin/learn_q_opt"
echo "100 runs for each constraint"

echo ""
echo "AllDiff"
for i in {1..100}
do
		$EXE -f ../spaces/incomplete/alldiff-12_12_5.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f ../spaces/test/alldiff-30_30.txt -c tmp --benchmark >> out_error
done
sed -i '/^ *$/d' out_error
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

rm tmp out_error

echo ""
echo "Ordered"
for i in {1..100}
do
		$EXE -f ../spaces/incomplete/ordered-12_12_5.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f ../spaces/test/ordered-30_30.txt -c tmp --benchmark >> out_error
done
sed -i '/^ *$/d' out_error
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

rm tmp out_error

echo ""
echo "LinearSum"
for i in {1..100}
do
		$EXE -f ../spaces/incomplete/linear_equation-12_12_72_5.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp --benchmark >> out_error
done
sed -i '/^ *$/d' out_error
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

rm tmp out_error

echo ""
echo "NoOverlap"
for i in {1..100}
do
		$EXE -f ../spaces/incomplete/no_overlap_1D-8_35_3_5.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp --benchmark >> out_error
done
sed -i '/^ *$/d' out_error
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

rm tmp out_error

echo ""
echo "Channel"
for i in {1..100}
do
		$EXE -f ../spaces/incomplete/channel-12_12_5.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f ../spaces/test/channel-30_30.txt -c tmp --benchmark >> out_error
done
sed -i '/^ *$/d' out_error
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
echo "Imperfect representations (bad learning): $BAD_LEARN"

rm tmp out_error
