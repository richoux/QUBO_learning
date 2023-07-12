#!/bin/bash

EXE="../bin/learn_q_opt"

CORE=$(grep -c '^processor' /proc/cpuinfo)
if [[ ${CORE%.*} -lt 8 ]] ; then
		echo "Error: this script has been designed to run on a CPU with at least 8 cores."
		echo "Your CPU has $CORE cores. Please modify this script accordingly."
		exit
fi

echo "100 runs for each constraint"

for c in {5..1}
do
		echo ""
		echo "*** $(($c*2)) candidates ***"

		for constraint in alldiff ordered channel
		do
				echo ""
				echo "$constraint"
				for i in {1..12}
				do
						echo "Training"
						$EXE -f "../spaces/incomplete/$constraint-12_12_$c.txt" -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01 >> training01&
						$EXE -f "../spaces/incomplete/$constraint-12_12_$c.txt" -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02 >> training02&
						$EXE -f "../spaces/incomplete/$constraint-12_12_$c.txt" -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03 >> training03&
						$EXE -f "../spaces/incomplete/$constraint-12_12_$c.txt" -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04 >> training04&
						$EXE -f "../spaces/incomplete/$constraint-12_12_$c.txt" -r tmp05 --benchmark 2> /dev/null 1>> training05 ; tail -n 1 tmp05 >> training05&
						$EXE -f "../spaces/incomplete/$constraint-12_12_$c.txt" -r tmp06 --benchmark 2> /dev/null 1>> training06 ; tail -n 1 tmp06 >> training06&
						$EXE -f "../spaces/incomplete/$constraint-12_12_$c.txt" -r tmp07 --benchmark 2> /dev/null 1>> training07 ; tail -n 1 tmp07 >> training07&
						$EXE -f "../spaces/incomplete/$constraint-12_12_$c.txt" -r tmp08 --benchmark 2> /dev/null 1>> training08 ; tail -n 1 tmp08 >> training08&
						wait
						echo "Testing Majority"
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01 --benchmark >> test_error_01 ; tail -n 1 tmp01 >> test_error_01&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02 --benchmark >> test_error_02 ; tail -n 1 tmp02 >> test_error_02&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03 --benchmark >> test_error_03 ; tail -n 1 tmp03 >> test_error_03&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04 --benchmark >> test_error_04 ; tail -n 1 tmp04 >> test_error_04&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp05 --benchmark >> test_error_05 ; tail -n 1 tmp05 >> test_error_05&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp06 --benchmark >> test_error_06 ; tail -n 1 tmp06 >> test_error_06&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp07 --benchmark >> test_error_07 ; tail -n 1 tmp07 >> test_error_07&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp08 --benchmark >> test_error_08 ; tail -n 1 tmp08 >> test_error_08&
						wait
						>&2 echo "$((8*i))% done"
				done
				
				rm -f tmp??*
				
				echo "Training"
				$EXE -f "../spaces/incomplete/$constraint-12_12_$c.txt" -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01 >> training01&
				$EXE -f "../spaces/incomplete/$constraint-12_12_$c.txt" -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02 >> training02&
				$EXE -f "../spaces/incomplete/$constraint-12_12_$c.txt" -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03 >> training03&
				$EXE -f "../spaces/incomplete/$constraint-12_12_$c.txt" -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04 >> training04&
				wait
				echo "Testing Majority"
				$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01 --benchmark >> test_error_01 ; tail -n 1 tmp01 >> test_error_01&
				$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02 --benchmark >> test_error_02 ; tail -n 1 tmp02 >> test_error_02&
				$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03 --benchmark >> test_error_03 ; tail -n 1 tmp03 >> test_error_03&
				$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04 --benchmark >> test_error_04 ; tail -n 1 tmp04 >> test_error_04&
				
				cat training?? > ../results/opt/"$constraint-12_12_$c-training"
				cat test_error_?? > ../results/opt/"$constraint-12_12_$c-test_error"
				rm -f test_error_??* tmp??* training??
		done

		echo ""
		echo "linear_equation"
		for i in {1..12}
		do
				echo "Training"
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_$c.txt" -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01 >> training01&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_$c.txt" -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02 >> training02&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_$c.txt" -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03 >> training03&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_$c.txt" -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04 >> training04&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_$c.txt" -r tmp05 --benchmark 2> /dev/null 1>> training05 ; tail -n 1 tmp05 >> training05&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_$c.txt" -r tmp06 --benchmark 2> /dev/null 1>> training06 ; tail -n 1 tmp06 >> training06&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_$c.txt" -r tmp07 --benchmark 2> /dev/null 1>> training07 ; tail -n 1 tmp07 >> training07&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_$c.txt" -r tmp08 --benchmark 2> /dev/null 1>> training08 ; tail -n 1 tmp08 >> training08&
				wait
				echo "Testing Majority"
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01 --benchmark >> test_error_01 ; tail -n 1 tmp01 >> test_error_01&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02 --benchmark >> test_error_02 ; tail -n 1 tmp02 >> test_error_02&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03 --benchmark >> test_error_03 ; tail -n 1 tmp03 >> test_error_03&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04 --benchmark >> test_error_04 ; tail -n 1 tmp04 >> test_error_04&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp05 --benchmark >> test_error_05 ; tail -n 1 tmp05 >> test_error_05&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp06 --benchmark >> test_error_06 ; tail -n 1 tmp06 >> test_error_06&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp07 --benchmark >> test_error_07 ; tail -n 1 tmp07 >> test_error_07&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp08 --benchmark >> test_error_08 ; tail -n 1 tmp08 >> test_error_08&
				wait
				>&2 echo "$((8*i))% done"
		done

		rm -f tmp??*

		echo "Training"
		$EXE -f "../spaces/incomplete/linear_equation-12_12_72_$c.txt" -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01 >> training01&
		$EXE -f "../spaces/incomplete/linear_equation-12_12_72_$c.txt" -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02 >> training02&
		$EXE -f "../spaces/incomplete/linear_equation-12_12_72_$c.txt" -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03 >> training03&
		$EXE -f "../spaces/incomplete/linear_equation-12_12_72_$c.txt" -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04 >> training04&
		wait
		echo "Testing Majority"
		$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01 --benchmark >> test_error_01 ; tail -n 1 tmp01 >> test_error_01&
		$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02 --benchmark >> test_error_02 ; tail -n 1 tmp02 >> test_error_02&
		$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03 --benchmark >> test_error_03 ; tail -n 1 tmp03 >> test_error_03&
		$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04 --benchmark >> test_error_04 ; tail -n 1 tmp04 >> test_error_04&
		wait

		cat training?? > ../results/opt/"linear_equation-12_12_72_$c-training"
		cat test_error_?? > ../results/opt/"linear_equation-12_12_72_$c-test_error"
		rm -f test_error_??* tmp??* training??

		echo ""
		echo "no_overlap_1D"
		for i in {1..12}
		do
				echo "Training"
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01 >> training01&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02 >> training02&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03 >> training03&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04 >> training04&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" -r tmp05 --benchmark 2> /dev/null 1>> training05 ; tail -n 1 tmp05 >> training05&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" -r tmp06 --benchmark 2> /dev/null 1>> training06 ; tail -n 1 tmp06 >> training06&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" -r tmp07 --benchmark 2> /dev/null 1>> training07 ; tail -n 1 tmp07 >> training07&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" -r tmp08 --benchmark 2> /dev/null 1>> training08 ; tail -n 1 tmp08 >> training08&
				wait
				echo "Testing Majority"
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp01 --benchmark >> test_error_01 ; tail -n 1 tmp01 >> test_error_01&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp02 --benchmark >> test_error_02 ; tail -n 1 tmp02 >> test_error_02&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp03 --benchmark >> test_error_03 ; tail -n 1 tmp03 >> test_error_03&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp04 --benchmark >> test_error_04 ; tail -n 1 tmp04 >> test_error_04&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp05 --benchmark >> test_error_05 ; tail -n 1 tmp05 >> test_error_05&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp06 --benchmark >> test_error_06 ; tail -n 1 tmp06 >> test_error_06&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp07 --benchmark >> test_error_07 ; tail -n 1 tmp07 >> test_error_07&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp08 --benchmark >> test_error_08 ; tail -n 1 tmp08 >> test_error_08&
				wait
				>&2 echo "$((8*i))% done"
		done

		rm -f tmp??*
		
		echo "Training"
		$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01 >> training01&
		$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02 >> training02&
		$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03 >> training03&
		$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_$c.txt" -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04 >> training04&
		wait
		echo "Testing Majority"
		$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp01 --benchmark >> test_error_01 ; tail -n 1 tmp01 >> test_error_01&
		$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp02 --benchmark >> test_error_02 ; tail -n 1 tmp02 >> test_error_02&
		$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp03 --benchmark >> test_error_03 ; tail -n 1 tmp03 >> test_error_03&
		$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp04 --benchmark >> test_error_04 ; tail -n 1 tmp04 >> test_error_04&
		wait

		cat training?? > ../results/opt/"no_overlap_1D-8_35_3_$c-training"
		cat test_error_?? > ../results/opt/"no_overlap_1D-8_35_3_$c-test_error"
		rm -f test_error_??* tmp??* training??
done
