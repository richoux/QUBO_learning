#!/bin/bash

EXE="../bin/q_learning_opt"

echo "100 runs for each constraint"
echo ""
echo "AllDiff"
for i in {1..100}
do
		$EXE -f ../spaces/complete/alldiff-4_4.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f ../spaces/test/alldiff-30_30.txt -c tmp --benchmark >> out_error
		# sed "2q;d" tmp >> model_log
done
sed -i '/^ *$/d' out_error
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
# awk '$4>0 {print NR}' out_error >> tmp2
# for t in $(cat tmp2)
# do
# 		sed "${t}q;d" model_log >> ../results/bad_models-complete_alldiff
# done
echo "Imperfect representations (bad learning): $BAD_LEARN"

rm tmp out_error

echo ""
echo "Ordered"
for i in {1..100}
do
		$EXE -f ../spaces/complete/ordered-4_4.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f ../spaces/test/ordered-30_30.txt -c tmp --benchmark >> out_error
		# sed "2q;d" tmp >> model_log
done
sed -i '/^ *$/d' out_error
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
# awk '$4>0 {print NR}' out_error >> tmp2
# for t in $(cat tmp2)
# do
# 		sed "${t}q;d" model_log >> ../results/bad_models-complete_ordered
# done
echo "Imperfect representations (bad learning): $BAD_LEARN"

rm tmp out_error

echo ""
echo "LinearSum"
for i in {1..100}
do
		$EXE -f ../spaces/complete/linear_equation-4_4_10.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f ../spaces/test/linear_equation-30_30_600.txt -c tmp --benchmark >> out_error
		# sed "2q;d" tmp >> model_log
done
sed -i '/^ *$/d' out_error
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
# awk '$4>0 {print NR}' out_error >> tmp2
# for t in $(cat tmp2)
# do
# 		sed "${t}q;d" model_log >> ../results/bad_models-complete_linear_equation
# done
echo "Imperfect representations (bad learning): $BAD_LEARN"

rm tmp out_error

echo ""
echo "NoOverlap"
for i in {1..100}
do
		$EXE -f ../spaces/complete/no_overlap_1D-3_7_2.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f ../spaces/test/no_overlap_1D-20_160_6.txt -c tmp --benchmark >> out_error
		# sed "2q;d" tmp >> model_log
done
sed -i '/^ *$/d' out_error
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
# awk '$4>0 {print NR}' out_error >> tmp2
# for t in $(cat tmp2)
# do
# 		sed "${t}q;d" model_log >> ../results/bad_models-complete_no_overlap_1D
# done
echo "Imperfect representations (bad learning): $BAD_LEARN"

rm tmp out_error

echo ""
echo "Channel"
for i in {1..100}
do
		$EXE -f ../spaces/complete/channel-4_4.txt -r tmp --benchmark 2> /dev/null 1> /dev/null
		$EXE -f ../spaces/test/channel-30_30.txt -c tmp --benchmark >> out_error
		# sed "2q;d" tmp >> model_log
done
sed -i '/^ *$/d' out_error
BAD_LEARN=`awk -v count=0 '$4>0 {++count} END {print count}' out_error`
# awk '$4>0 {print NR}' out_error >> tmp2
# for t in $(cat tmp2)
# do
# 		sed "${t}q;d" model_log >> ../results/bad_models-complete_channel
# done
echo "Imperfect representations (bad learning): $BAD_LEARN"

rm tmp out_error
