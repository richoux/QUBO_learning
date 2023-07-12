#!/bin/bash

EXE="../bin/learn_q_sat"

CORE=$(grep -c '^processor' /proc/cpuinfo)
if [[ ${CORE%.*} -lt 8 ]] ; then
		echo "Error: this script has been designed to run on a CPU with at least 8 cores."
		echo "Your CPU has $CORE cores. Please modify this script accordingly."
		exit
fi

if [[ $# -ne 1 ]]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 [same/random], with 'same' to make learners starting from the same point in the search space, and 'random' otherwise."
    exit 2
fi

SOLVER_ARG=""
START_DIR="random_start"
if [[ $1 == "same" ]]; then
		SOLVER_ARG="-s"
		START_DIR="same_start"
elif [[ $1 != "random" ]]; then
    echo "Illegal parameter"
    echo "Usage: $0 [same/random], with 'same' to make learners starting from the same point in the search space, and 'random' otherwise."
    exit 2
fi

echo "100 runs for each constraint"

for n in 2 4 6 8 10
do
		echo ""
		echo "*** $n candidates ***"
		for constraint in alldiff ordered channel
		do
				echo ""
				echo "$constraint"
				for i in {1..12}
				do
						echo -n "Training... "
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01 >> training01&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02 >> training02&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03 >> training03&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04 >> training04&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -n $n -r tmp05 --benchmark 2> /dev/null 1>> training05 ; tail -n 1 tmp05 >> training05&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -n $n -r tmp06 --benchmark 2> /dev/null 1>> training06 ; tail -n 1 tmp06 >> training06&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -n $n -r tmp07 --benchmark 2> /dev/null 1>> training07 ; tail -n 1 tmp07 >> training07&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -n $n -r tmp08 --benchmark 2> /dev/null 1>> training08 ; tail -n 1 tmp08 >> training08&
						wait
						echo -n "Testing... "
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
				
				echo -n "Training... "
				$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01 >> training01&
				$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02 >> training02&
				$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03 >> training03&
				$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04 >> training04&
				wait
				echo -n "Testing... "
				$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01 --benchmark >> test_error_01 ; tail -n 1 tmp01 >> test_error_01&
				$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02 --benchmark >> test_error_02 ; tail -n 1 tmp02 >> test_error_02&
				$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03 --benchmark >> test_error_03 ; tail -n 1 tmp03 >> test_error_03&
				$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04 --benchmark >> test_error_04 ; tail -n 1 tmp04 >> test_error_04&
				
				cat training?? > ../results/strong_learners/"$START_DIR"/sampled_training_set/sat/"$constraint-12_12_n$n-training"
				cat test_error_?? > ../results/strong_learners/"$START_DIR"/sampled_training_set/sat/"$constraint-12_12_n$n-test_error"
				rm -f test_error_??* tmp??* training??
		done

		echo ""
		echo "linear_equation"
		for i in {1..12}
		do
				echo -n "Training... "
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01 >> training01&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02 >> training02&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03 >> training03&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04 >> training04&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -n $n -r tmp05 --benchmark 2> /dev/null 1>> training05 ; tail -n 1 tmp05 >> training05&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -n $n -r tmp06 --benchmark 2> /dev/null 1>> training06 ; tail -n 1 tmp06 >> training06&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -n $n -r tmp07 --benchmark 2> /dev/null 1>> training07 ; tail -n 1 tmp07 >> training07&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -n $n -r tmp08 --benchmark 2> /dev/null 1>> training08 ; tail -n 1 tmp08 >> training08&
				wait
				echo -n "Testing... "
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

		echo -n "Training... "
		$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01 >> training01&
		$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02 >> training02&
		$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03 >> training03&
		$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04 >> training04&
		wait
		echo -n "Testing... "
		$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01 --benchmark >> test_error_01 ; tail -n 1 tmp01 >> test_error_01&
		$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02 --benchmark >> test_error_02 ; tail -n 1 tmp02 >> test_error_02&
		$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03 --benchmark >> test_error_03 ; tail -n 1 tmp03 >> test_error_03&
		$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04 --benchmark >> test_error_04 ; tail -n 1 tmp04 >> test_error_04&
		wait

		cat training?? > ../results/strong_learners/"$START_DIR"/sampled_training_set/sat/"linear_equation-12_12_72_n$n-training"
		cat test_error_?? > ../results/strong_learners/"$START_DIR"/sampled_training_set/sat/"linear_equation-12_12_72_n$n-test_error"
		rm -f test_error_??* tmp??* training??

		echo ""
		echo "no_overlap_1D"
		for i in {1..12}
		do
				echo -n "Training... "
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01 >> training01&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02 >> training02&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03 >> training03&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04 >> training04&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -n $n -r tmp05 --benchmark 2> /dev/null 1>> training05 ; tail -n 1 tmp05 >> training05&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -n $n -r tmp06 --benchmark 2> /dev/null 1>> training06 ; tail -n 1 tmp06 >> training06&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -n $n -r tmp07 --benchmark 2> /dev/null 1>> training07 ; tail -n 1 tmp07 >> training07&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -n $n -r tmp08 --benchmark 2> /dev/null 1>> training08 ; tail -n 1 tmp08 >> training08&
				wait
				echo -n "Testing... "
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
		
		echo -n "Training... "
		$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01 >> training01&
		$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02 >> training02&
		$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03 >> training03&
		$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04 >> training04&
		wait
		echo -n "Testing... "
		$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp01 --benchmark >> test_error_01 ; tail -n 1 tmp01 >> test_error_01&
		$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp02 --benchmark >> test_error_02 ; tail -n 1 tmp02 >> test_error_02&
		$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp03 --benchmark >> test_error_03 ; tail -n 1 tmp03 >> test_error_03&
		$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp04 --benchmark >> test_error_04 ; tail -n 1 tmp04 >> test_error_04&
		wait

		cat training?? > ../results/strong_learners/"$START_DIR"/sampled_training_set/sat/"no_overlap_1D-8_35_3_n$n-training"
		cat test_error_?? > ../results/strong_learners/"$START_DIR"/sampled_training_set/sat/"no_overlap_1D-8_35_3_n$n-test_error"
		rm -f test_error_??* tmp??* training??
done
