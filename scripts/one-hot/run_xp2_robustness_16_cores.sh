#!/bin/bash

EXE="../../bin/learn_q_opt"
RESULTS="../../results/one-hot"

CORE=$(grep -c '^processor' /proc/cpuinfo)
if ! [[ ${CORE%.*} -eq 16 ]]; then
		echo "Error: this script has been designed to run on a 16-core CPU."
		echo "Your CPU has $CORE cores. Please modify this script accordingly."
		exit
fi

echo "100 runs for each constraint"

for c in {6..1}
do
		echo ""
		echo ""
		echo "*** $(($c*2)) candidates ***"
		echo ""
		echo "AllDiff"

		for i in {1..6}
		do
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp01 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp02 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp03 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp04 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp05 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp06 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp07 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp08 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp09 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp10 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp11 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp12 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp13 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp14 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp15 &
				$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp16 &
				wait
				>&2 echo "$((16*i))% done"
				cat tmp?? >> "$RESULTS/alldiff-12_12_${c}_patterns"
		done
		
		$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp01 &
		$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp02 &
		$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp03 &
		$EXE -f "../../spaces/incomplete/alldiff-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp04 &
		wait
		cat tmp01 tmp02 tmp03 tmp04 >> "$RESULTS/alldiff-12_12_${c}_patterns"
		sed -i 's/ //g' "$RESULTS/alldiff-12_12_${c}_patterns"
		rm -f tmp??
		
		echo ""
		echo "Ordered"
		for i in {1..6}
		do
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp01 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp02 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp03 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp04 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp05 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp06 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp07 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp08 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp09 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp10 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp11 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp12 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp13 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp14 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp15 &
				$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp16 &
				wait
				>&2 echo "$((16*i))% done"
				cat tmp?? >> "$RESULTS/ordered-12_12_${c}_patterns"
		done
		
		$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp01 &
		$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp02 &
		$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp03 &
		$EXE -f "../../spaces/incomplete/ordered-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp04 &
		wait
		cat tmp01 tmp02 tmp03 tmp04 >> "$RESULTS/ordered-12_12_${c}_patterns"
		sed -i 's/ //g' "$RESULTS/ordered-12_12_${c}_patterns"
		rm -f tmp??

		echo ""
		echo "LinearSum"
		for i in {1..6}
		do
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp01 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp02 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp03 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp04 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp05 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp06 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp07 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp08 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp09 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp10 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp11 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp12 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp13 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp14 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp15 &
				$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp16 &
				wait
				>&2 echo "$((16*i))% done"
				cat tmp?? >> "$RESULTS/linear_equation-12_12_72_${c}_patterns"
		done

		$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp01 &
		$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp02 &
		$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp03 &
		$EXE -f "../../spaces/incomplete/linear_equation-12_12_72_$c.txt" 2> /dev/null | tail -n 1 1> tmp04 &
		wait
		cat tmp01 tmp02 tmp03 tmp04 >> "$RESULTS/linear_equation-12_12_72_${c}_patterns"
		sed -i 's/ //g' "$RESULTS/linear_equation-12_12_72_${c}_patterns"
		rm -f tmp??

		echo ""
		echo "NoOverlap"
		for i in {1..6}
		do
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp01 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp02 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp03 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp04 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp05 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp06 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp07 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp08 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp09 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp10 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp11 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp12 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp13 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp14 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp15 &
				$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp16 &
				wait
				>&2 echo "$((16*i))% done"
				cat tmp?? >> "$RESULTS/no_overlap_1D-8_35_3_${c}_patterns"
		done

		$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp01 &
		$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp02 &
		$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp03 &
		$EXE -f "../../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" 2> /dev/null | tail -n 1 1> tmp04 &
		wait
		cat tmp01 tmp02 tmp03 tmp04 >> "$RESULTS/no_overlap_1D-8_35_3_${c}_patterns"
		sed -i 's/ //g' "$RESULTS/no_overlap_1D-8_35_3_${c}_patterns"
		rm -f tmp??

		echo ""
		echo "Channel"
		for i in {1..6}
		do
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp01 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp02 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp03 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp04 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp05 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp06 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp07 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp08 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp09 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp10 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp11 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp12 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp13 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp14 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp15 &
				$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp16 &
				wait
				>&2 echo "$((16*i))% done"
				cat tmp?? >> "$RESULTS/channel-12_12_${c}_patterns"
		done

		$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp01 &
		$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp02 &
		$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp03 &
		$EXE -f "../../spaces/incomplete/channel-12_12_$c.txt" 2> /dev/null | tail -n 1 1> tmp04 &
		wait
		cat tmp01 tmp02 tmp03 tmp04 >> "$RESULTS/channel-12_12_${c}_patterns"
		sed -i 's/ //g' "$RESULTS/channel-12_12_${c}_patterns"
		rm -f tmp??
done
