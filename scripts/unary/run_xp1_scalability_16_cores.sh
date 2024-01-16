#!/bin/bash

EXE="../../bin/learn_q_opt"
RESULTS="../../results/unary"

CORE=$(grep -c '^processor' /proc/cpuinfo)
if ! [[ ${CORE%.*} -eq 16 ]]; then
		echo "Error: this script has been designed to run on a 16-core CPU."
		echo "Your CPU has $CORE cores. Please modify this script accordingly."
		exit
fi

echo "100 runs for each constraint"
echo ""
echo "AllDiff"
for i in {1..6}
do
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp01 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp02 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp03 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp04 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp05 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp06 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp07 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp08 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp09 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp10 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp11 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp12 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp13 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp14 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp15 &
		$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp16 &
		wait
		>&2 echo "$((16*i))% done"
		cat tmp?? >> "$RESULTS"/alldiff-complete_patterns
done

$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp01 &
$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp02 &
$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp03 &
$EXE -e 1 -f "../../spaces/complete/alldiff-4_4.txt" 2> /dev/null | tail -n 1 1> tmp04 &
wait
cat tmp01 tmp02 tmp03 tmp04 >> "$RESULTS"/alldiff-complete_patterns
sed -i 's/ //g' "$RESULTS"/alldiff-complete_patterns
rm -f tmp??

echo ""
echo "Ordered"
for i in {1..6}
do
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp01 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp02 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp03 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp04 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp05 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp06 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp07 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp08 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp09 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp10 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp11 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp12 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp13 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp14 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp15 &
		$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp16 &
		wait
		>&2 echo "$((16*i))% done"
		cat tmp?? >> "$RESULTS"/ordered-complete_patterns
done

$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp01 &
$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp02 &
$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp03 &
$EXE -e 1 -f "../../spaces/complete/ordered-4_4.txt" 2> /dev/null | tail -n 1 1> tmp04 &
wait
cat tmp01 tmp02 tmp03 tmp04 >> "$RESULTS"/ordered-complete_patterns
sed -i 's/ //g' "$RESULTS"/ordered-complete_patterns
rm -f tmp??

echo ""
echo "LinearSum"
for i in {1..6}
do
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp01 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp02 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp03 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp04 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp05 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp06 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp07 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp08 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp09 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp10 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp11 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp12 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp13 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp14 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp15 &
		$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp16 &
		wait
		>&2 echo "$((16*i))% done"
		cat tmp?? >> "$RESULTS"/linear_equation-complete_patterns
done

$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp01 &
$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp02 &
$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp03 &
$EXE -e 1 -f "../../spaces/complete/linear_equation-4_4_10.txt" 2> /dev/null | tail -n 1 1> tmp04 &
wait
cat tmp01 tmp02 tmp03 tmp04 >> "$RESULTS"/linear_equation-complete_patterns
sed -i 's/ //g' "$RESULTS"/linear_equation-complete_patterns
rm -f tmp??

echo ""
echo "NoOverlap"
for i in {1..6}
do
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp01 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp02 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp03 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp04 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp05 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp06 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp07 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp08 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp09 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp10 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp11 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp12 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp13 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp14 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp15 &
		$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp16 &
		wait
		>&2 echo "$((16*i))% done"
		cat tmp?? >> "$RESULTS"/no_overlap_1D-complete_patterns
done

$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp01 &
$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp02 &
$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp03 &
$EXE -e 1 -f "../../spaces/complete/no_overlap_1D-3_7_2.txt" 2> /dev/null | tail -n 1 1> tmp04 &
wait
cat tmp01 tmp02 tmp03 tmp04 >> "$RESULTS"/no_overlap_1D-complete_patterns
sed -i 's/ //g' "$RESULTS"/no_overlap_1D-complete_patterns
rm -f tmp??

echo ""
echo "Channel"
for i in {1..6}
do
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp01 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp02 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp03 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp04 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp05 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp06 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp07 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp08 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp09 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp10 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp11 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp12 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp13 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp14 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp15 &
		$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp16 &
		wait
		>&2 echo "$((16*i))% done"
		cat tmp?? >> "$RESULTS"/channel-complete_patterns
done

$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp01 &
$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp02 &
$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp03 &
$EXE -e 1 -f "../../spaces/complete/channel-4_4.txt" 2> /dev/null | tail -n 1 1> tmp04 &
wait
cat tmp01 tmp02 tmp03 tmp04 >> "$RESULTS"/channel-complete_patterns
sed -i 's/ //g' "$RESULTS"/channel-complete_patterns
rm -f tmp??
