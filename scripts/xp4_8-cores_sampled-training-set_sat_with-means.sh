#!/bin/bash
#Weak learners

EXE="../bin/weak_learn_q_sat"

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

for w in 3 5 7 9
do
		echo ""
		echo "*** $w weak learners ***"

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
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01_majority >> training01&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02_majority >> training02&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03_majority >> training03&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04_majority >> training04&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -w $w -n $n -r tmp05 --benchmark 2> /dev/null 1>> training05 ; tail -n 1 tmp05_majority >> training05&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -w $w -n $n -r tmp06 --benchmark 2> /dev/null 1>> training06 ; tail -n 1 tmp06_majority >> training06&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -w $w -n $n -r tmp07 --benchmark 2> /dev/null 1>> training07 ; tail -n 1 tmp07_majority >> training07&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -w $w -n $n -r tmp08 --benchmark 2> /dev/null 1>> training08 ; tail -n 1 tmp08_majority >> training08&
								wait
								echo -n "Testing Majority... "
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01_majority --benchmark >> test_error_01_majority  ; tail -n 1 tmp01_majority >> test_error_01_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02_majority --benchmark >> test_error_02_majority  ; tail -n 1 tmp02_majority >> test_error_02_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03_majority --benchmark >> test_error_03_majority  ; tail -n 1 tmp03_majority >> test_error_03_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04_majority --benchmark >> test_error_04_majority  ; tail -n 1 tmp04_majority >> test_error_04_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp05_majority --benchmark >> test_error_05_majority  ; tail -n 1 tmp05_majority >> test_error_05_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp06_majority --benchmark >> test_error_06_majority  ; tail -n 1 tmp06_majority >> test_error_06_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp07_majority --benchmark >> test_error_07_majority  ; tail -n 1 tmp07_majority >> test_error_07_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp08_majority --benchmark >> test_error_08_majority  ; tail -n 1 tmp08_majority >> test_error_08_majority&
								wait
								echo -n "Testing Mean... "
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01_mean --benchmark >> test_error_01_mean ; tail -n 1 tmp01_mean >> test_error_01_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02_mean --benchmark >> test_error_02_mean ; tail -n 1 tmp02_mean >> test_error_02_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03_mean --benchmark >> test_error_03_mean ; tail -n 1 tmp03_mean >> test_error_03_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04_mean --benchmark >> test_error_04_mean ; tail -n 1 tmp04_mean >> test_error_04_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp05_mean --benchmark >> test_error_05_mean ; tail -n 1 tmp05_mean >> test_error_05_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp06_mean --benchmark >> test_error_06_mean ; tail -n 1 tmp06_mean >> test_error_06_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp07_mean --benchmark >> test_error_07_mean ; tail -n 1 tmp07_mean >> test_error_07_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp08_mean --benchmark >> test_error_08_mean ; tail -n 1 tmp08_mean >> test_error_08_mean&
								wait
								>&2 echo "$((8*i))% done"
						done

						rm -f tmp??*

						echo -n "Training... "
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01_majority >> training01&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02_majority >> training02&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03_majority >> training03&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" $SOLVER_ARG -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04_majority >> training04&
						wait
						echo -n "Testing Majority... "
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01_majority --benchmark >> test_error_01_majority  ; tail -n 1 tmp01_majority >> test_error_01_majority&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02_majority --benchmark >> test_error_02_majority  ; tail -n 1 tmp02_majority >> test_error_02_majority&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03_majority --benchmark >> test_error_03_majority  ; tail -n 1 tmp03_majority >> test_error_03_majority&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04_majority --benchmark >> test_error_04_majority  ; tail -n 1 tmp04_majority >> test_error_04_majority&
						echo -n "Testing Mean... "
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01_mean --benchmark >> test_error_01_mean ; tail -n 1 tmp01_mean >> test_error_01_mean&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02_mean --benchmark >> test_error_02_mean ; tail -n 1 tmp02_mean >> test_error_02_mean&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03_mean --benchmark >> test_error_03_mean ; tail -n 1 tmp03_mean >> test_error_03_mean&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04_mean --benchmark >> test_error_04_mean ; tail -n 1 tmp04_mean >> test_error_04_mean&
						wait

						cat training?? > ../results/weak_learners/"$START_DIR"/sampled_training_set/sat/"$constraint-12_12_weak_w$w-n$n-training"
						cat test_error_??_majority > ../results/weak_learners/"$START_DIR"/sampled_training_set/sat/"$constraint-12_12_weak_w$w-n$n-test_error_majority"
						cat test_error_??_mean > ../results/weak_learners/"$START_DIR"/sampled_training_set/sat/"$constraint-12_12_weak_w$w-n$n-test_error_mean"
						rm -f test_error_??* tmp??* training??
				done

				echo ""
				echo "linear_equation"
				for i in {1..12}
				do
						echo -n "Training... "
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01_majority >> training01&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02_majority >> training02&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03_majority >> training03&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04_majority >> training04&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -w $w -n $n -r tmp05 --benchmark 2> /dev/null 1>> training05 ; tail -n 1 tmp05_majority >> training05&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -w $w -n $n -r tmp06 --benchmark 2> /dev/null 1>> training06 ; tail -n 1 tmp06_majority >> training06&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -w $w -n $n -r tmp07 --benchmark 2> /dev/null 1>> training07 ; tail -n 1 tmp07_majority >> training07&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -w $w -n $n -r tmp08 --benchmark 2> /dev/null 1>> training08 ; tail -n 1 tmp08_majority >> training08&
						wait
						echo -n "Testing Majority... "
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01_majority --benchmark >> test_error_01_majority  ; tail -n 1 tmp01_majority >> test_error_01_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02_majority --benchmark >> test_error_02_majority  ; tail -n 1 tmp02_majority >> test_error_02_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03_majority --benchmark >> test_error_03_majority  ; tail -n 1 tmp03_majority >> test_error_03_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04_majority --benchmark >> test_error_04_majority  ; tail -n 1 tmp04_majority >> test_error_04_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp05_majority --benchmark >> test_error_05_majority  ; tail -n 1 tmp05_majority >> test_error_05_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp06_majority --benchmark >> test_error_06_majority  ; tail -n 1 tmp06_majority >> test_error_06_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp07_majority --benchmark >> test_error_07_majority  ; tail -n 1 tmp07_majority >> test_error_07_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp08_majority --benchmark >> test_error_08_majority  ; tail -n 1 tmp08_majority >> test_error_08_majority&
						wait
						echo -n "Testing Mean... "
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01_mean --benchmark >> test_error_01_mean ; tail -n 1 tmp01_mean >> test_error_01_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02_mean --benchmark >> test_error_02_mean ; tail -n 1 tmp02_mean >> test_error_02_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03_mean --benchmark >> test_error_03_mean ; tail -n 1 tmp03_mean >> test_error_03_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04_mean --benchmark >> test_error_04_mean ; tail -n 1 tmp04_mean >> test_error_04_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp05_mean --benchmark >> test_error_05_mean ; tail -n 1 tmp05_mean >> test_error_05_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp06_mean --benchmark >> test_error_06_mean ; tail -n 1 tmp06_mean >> test_error_06_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp07_mean --benchmark >> test_error_07_mean ; tail -n 1 tmp07_mean >> test_error_07_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp08_mean --benchmark >> test_error_08_mean ; tail -n 1 tmp08_mean >> test_error_08_mean&
						wait
						>&2 echo "$((8*i))% done"
				done

				rm -f tmp??*

				echo -n "Training... "
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01_majority >> training01&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02_majority >> training02&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03_majority >> training03&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" $SOLVER_ARG -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04_majority >> training04&
				wait
				echo -n "Testing Majority... "
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01_majority --benchmark >> test_error_01_majority  ; tail -n 1 tmp01_majority >> test_error_01_majority&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02_majority --benchmark >> test_error_02_majority  ; tail -n 1 tmp02_majority >> test_error_02_majority&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03_majority --benchmark >> test_error_03_majority  ; tail -n 1 tmp03_majority >> test_error_03_majority&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04_majority --benchmark >> test_error_04_majority  ; tail -n 1 tmp04_majority >> test_error_04_majority&
				echo -n "Testing Mean... "
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01_mean --benchmark >> test_error_01_mean ; tail -n 1 tmp01_mean >> test_error_01_mean&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02_mean --benchmark >> test_error_02_mean ; tail -n 1 tmp02_mean >> test_error_02_mean&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03_mean --benchmark >> test_error_03_mean ; tail -n 1 tmp03_mean >> test_error_03_mean&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04_mean --benchmark >> test_error_04_mean ; tail -n 1 tmp04_mean >> test_error_04_mean&
				wait

				cat training?? > ../results/weak_learners/"$START_DIR"/sampled_training_set/sat/"linear_equation-12_12_72_weak_w$w-n$n-training"
				cat test_error_??_majority > ../results/weak_learners/"$START_DIR"/sampled_training_set/sat/"linear_equation-12_12_72_weak_w$w-n$n-test_error_majority"
				cat test_error_??_mean > ../results/weak_learners/"$START_DIR"/sampled_training_set/sat/"linear_equation-12_12_72_weak_w$w-n$n-test_error_mean"
				rm -f test_error_??* tmp??* training??

				echo ""
				echo "no_overlap_1D"
				for i in {1..12}
				do
						echo -n "Training... "
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01_majority >> training01&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02_majority >> training02&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03_majority >> training03&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04_majority >> training04&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -w $w -n $n -r tmp05 --benchmark 2> /dev/null 1>> training05 ; tail -n 1 tmp05_majority >> training05&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -w $w -n $n -r tmp06 --benchmark 2> /dev/null 1>> training06 ; tail -n 1 tmp06_majority >> training06&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -w $w -n $n -r tmp07 --benchmark 2> /dev/null 1>> training07 ; tail -n 1 tmp07_majority >> training07&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -w $w -n $n -r tmp08 --benchmark 2> /dev/null 1>> training08 ; tail -n 1 tmp08_majority >> training08&
						wait
						echo -n "Testing Majority... "
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp01_majority --benchmark >> test_error_01_majority  ; tail -n 1 tmp01_majority >> test_error_01_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp02_majority --benchmark >> test_error_02_majority  ; tail -n 1 tmp02_majority >> test_error_02_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp03_majority --benchmark >> test_error_03_majority  ; tail -n 1 tmp03_majority >> test_error_03_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp04_majority --benchmark >> test_error_04_majority  ; tail -n 1 tmp04_majority >> test_error_04_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp05_majority --benchmark >> test_error_05_majority  ; tail -n 1 tmp05_majority >> test_error_05_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp06_majority --benchmark >> test_error_06_majority  ; tail -n 1 tmp06_majority >> test_error_06_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp07_majority --benchmark >> test_error_07_majority  ; tail -n 1 tmp07_majority >> test_error_07_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp08_majority --benchmark >> test_error_08_majority  ; tail -n 1 tmp08_majority >> test_error_08_majority&
						wait
						echo -n "Testing Mean... "
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp01_mean --benchmark >> test_error_01_mean ; tail -n 1 tmp01_mean >> test_error_01_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp02_mean --benchmark >> test_error_02_mean ; tail -n 1 tmp02_mean >> test_error_02_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp03_mean --benchmark >> test_error_03_mean ; tail -n 1 tmp03_mean >> test_error_03_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp04_mean --benchmark >> test_error_04_mean ; tail -n 1 tmp04_mean >> test_error_04_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp05_mean --benchmark >> test_error_05_mean ; tail -n 1 tmp05_mean >> test_error_05_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp06_mean --benchmark >> test_error_06_mean ; tail -n 1 tmp06_mean >> test_error_06_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp07_mean --benchmark >> test_error_07_mean ; tail -n 1 tmp07_mean >> test_error_07_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp08_mean --benchmark >> test_error_08_mean ; tail -n 1 tmp08_mean >> test_error_08_mean&
						wait
						>&2 echo "$((8*i))% done"
				done

				rm -f tmp??*
				
				echo -n "Training... "
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; tail -n 1 tmp01_majority >> training01&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; tail -n 1 tmp02_majority >> training02&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; tail -n 1 tmp03_majority >> training03&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" $SOLVER_ARG -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; tail -n 1 tmp04_majority >> training04&
				wait
				echo -n "Testing Majority... "
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp01_majority --benchmark >> test_error_01_majority  ; tail -n 1 tmp01_majority >> test_error_01_majority&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp02_majority --benchmark >> test_error_02_majority  ; tail -n 1 tmp02_majority >> test_error_02_majority&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp03_majority --benchmark >> test_error_03_majority  ; tail -n 1 tmp03_majority >> test_error_03_majority&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp04_majority --benchmark >> test_error_04_majority  ; tail -n 1 tmp04_majority >> test_error_04_majority&
				echo -n "Testing Mean... "
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp01_mean --benchmark >> test_error_01_mean ; tail -n 1 tmp01_mean >> test_error_01_mean&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp02_mean --benchmark >> test_error_02_mean ; tail -n 1 tmp02_mean >> test_error_02_mean&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp03_mean --benchmark >> test_error_03_mean ; tail -n 1 tmp03_mean >> test_error_03_mean&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp04_mean --benchmark >> test_error_04_mean ; tail -n 1 tmp04_mean >> test_error_04_mean&
				wait

				cat training?? > ../results/weak_learners/"$START_DIR"/sampled_training_set/sat/"no_overlap_1D-8_35_3_weak_w$w-n$n-training"
				cat test_error_??_majority > ../results/weak_learners/"$START_DIR"/sampled_training_set/sat/"no_overlap_1D-8_35_3_weak_w$w-n$n-test_error_majority"
				cat test_error_??_mean > ../results/weak_learners/"$START_DIR"/sampled_training_set/sat/"no_overlap_1D-8_35_3_weak_w$w-n$n-test_error_mean"
				rm -f test_error_??* tmp??* training??
		done
done
