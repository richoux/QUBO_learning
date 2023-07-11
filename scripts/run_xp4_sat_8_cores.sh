#!/bin/bash
#Weak learners

EXE="../bin/weak_learn_q_sat"

CORE=$(grep -c '^processor' /proc/cpuinfo)
if [[ ${CORE%.*} -lt 8 ]] ; then
		echo "Error: this script has been designed to run on a CPU with at least 8 cores."
		echo "Your CPU has $CORE cores. Please modify this script accordingly."
		exit
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
								echo "Training"
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp05 --benchmark 2> /dev/null 1>> training05&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp06 --benchmark 2> /dev/null 1>> training06&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp07 --benchmark 2> /dev/null 1>> training07&
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp08 --benchmark 2> /dev/null 1>> training08&
								wait
								echo "Testing Majority"
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01_majority --benchmark >> test_error_01_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02_majority --benchmark >> test_error_02_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03_majority --benchmark >> test_error_03_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04_majority --benchmark >> test_error_04_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp05_majority --benchmark >> test_error_05_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp06_majority --benchmark >> test_error_06_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp07_majority --benchmark >> test_error_07_majority&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp08_majority --benchmark >> test_error_08_majority&
								wait
								echo "Testing Mean"
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01_mean --benchmark >> test_error_01_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02_mean --benchmark >> test_error_02_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03_mean --benchmark >> test_error_03_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04_mean --benchmark >> test_error_04_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp05_mean --benchmark >> test_error_05_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp06_mean --benchmark >> test_error_06_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp07_mean --benchmark >> test_error_07_mean&
								$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp08_mean --benchmark >> test_error_08_mean&
								wait
								cat tmp??_majority >> ../results/weak_learners/"$constraint-12_12_weak_w$w-n$n-majority"
								cat tmp??_mean >> ../results/weak_learners/"$constraint-12_12_weak_w$w-n$n-mean"
								>&2 echo "$((8*i))% done"
						done

						rm -f tmp??*

						echo "Training"
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03&
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04&
						wait
						echo "Testing Majority"
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01_majority --benchmark >> test_error_01_majority&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02_majority --benchmark >> test_error_02_majority&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03_majority --benchmark >> test_error_03_majority&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04_majority --benchmark >> test_error_04_majority&
						echo "Testing Mean"
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01_mean --benchmark >> test_error_01_mean&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02_mean --benchmark >> test_error_02_mean&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03_mean --benchmark >> test_error_03_mean&
						$EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04_mean --benchmark >> test_error_04_mean&
						wait

						cat tmp??_majority >> ../results/weak_learners/"$constraint-12_12_weak_w$w-n$n-majority"
						cat tmp??_mean >> ../results/weak_learners/"$constraint-12_12_weak_w$w-n$n-mean"
						cat training?? > ../results/weak_learners/"$constraint-12_12_weak_w$w-n$n-training"
						cat test_error_??_majority > ../results/weak_learners/"$constraint-12_12_weak_w$w-n$n-test_error_majority"
						cat test_error_??_mean > ../results/weak_learners/"$constraint-12_12_weak_w$w-n$n-test_error_mean"
						rm -f test_error_??* tmp??* training??
				done

				echo ""
				echo "linear_equation"
				for i in {1..12}
				do
						echo "Training"
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp05 --benchmark 2> /dev/null 1>> training05&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp06 --benchmark 2> /dev/null 1>> training06&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp07 --benchmark 2> /dev/null 1>> training07&
						$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp08 --benchmark 2> /dev/null 1>> training08&
						wait
						echo "Testing Majority"
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01_majority --benchmark >> test_error_01_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02_majority --benchmark >> test_error_02_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03_majority --benchmark >> test_error_03_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04_majority --benchmark >> test_error_04_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp05_majority --benchmark >> test_error_05_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp06_majority --benchmark >> test_error_06_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp07_majority --benchmark >> test_error_07_majority&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp08_majority --benchmark >> test_error_08_majority&
						wait
						echo "Testing Mean"
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01_mean --benchmark >> test_error_01_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02_mean --benchmark >> test_error_02_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03_mean --benchmark >> test_error_03_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04_mean --benchmark >> test_error_04_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp05_mean --benchmark >> test_error_05_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp06_mean --benchmark >> test_error_06_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp07_mean --benchmark >> test_error_07_mean&
						$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp08_mean --benchmark >> test_error_08_mean&
						wait
						cat tmp??_majority >> ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-majority"
						cat tmp??_mean >> ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-mean"
						>&2 echo "$((8*i))% done"
				done

				rm -f tmp??*

				echo "Training"
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03&
				$EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04&
				wait
				echo "Testing Majority"
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01_majority --benchmark >> test_error_01_majority&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02_majority --benchmark >> test_error_02_majority&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03_majority --benchmark >> test_error_03_majority&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04_majority --benchmark >> test_error_04_majority&
				echo "Testing Mean"
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01_mean --benchmark >> test_error_01_mean&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02_mean --benchmark >> test_error_02_mean&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03_mean --benchmark >> test_error_03_mean&
				$EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04_mean --benchmark >> test_error_04_mean&
				wait

				cat tmp??_majority >> ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-majority"
				cat tmp??_mean >> ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-mean"
				cat training?? > ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-training"
				cat test_error_??_majority > ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-test_error_majority"
				cat test_error_??_mean > ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-test_error_mean"
				rm -f test_error_??* tmp??* training??

				echo ""
				echo "no_overlap_1D"
				for i in {1..12}
				do
						echo "Training"
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp05 --benchmark 2> /dev/null 1>> training05&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp06 --benchmark 2> /dev/null 1>> training06&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp07 --benchmark 2> /dev/null 1>> training07&
						$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp08 --benchmark 2> /dev/null 1>> training08&
						wait
						echo "Testing Majority"
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp01_majority --benchmark >> test_error_01_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp02_majority --benchmark >> test_error_02_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp03_majority --benchmark >> test_error_03_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp04_majority --benchmark >> test_error_04_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp05_majority --benchmark >> test_error_05_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp06_majority --benchmark >> test_error_06_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp07_majority --benchmark >> test_error_07_majority&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp08_majority --benchmark >> test_error_08_majority&
						wait
						echo "Testing Mean"
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp01_mean --benchmark >> test_error_01_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp02_mean --benchmark >> test_error_02_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp03_mean --benchmark >> test_error_03_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp04_mean --benchmark >> test_error_04_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp05_mean --benchmark >> test_error_05_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp06_mean --benchmark >> test_error_06_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp07_mean --benchmark >> test_error_07_mean&
						$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp08_mean --benchmark >> test_error_08_mean&
						wait
						cat tmp??_majority >> ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-majority"
						cat tmp??_mean >> ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-mean"
						>&2 echo "$((8*i))% done"
				done

				rm -f tmp??*
				
				echo "Training"
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03&
				$EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04&
				wait
				echo "Testing Majority"
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp01_majority --benchmark >> test_error_01_majority&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp02_majority --benchmark >> test_error_02_majority&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp03_majority --benchmark >> test_error_03_majority&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp04_majority --benchmark >> test_error_04_majority&
				echo "Testing Mean"
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp01_mean --benchmark >> test_error_01_mean&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp02_mean --benchmark >> test_error_02_mean&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp03_mean --benchmark >> test_error_03_mean&
				$EXE -f "../spaces/test/no_overlap_1D-14_64_3.txt" -c tmp04_mean --benchmark >> test_error_04_mean&
				wait

				cat tmp??_majority >> ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-majority"
				cat tmp??_mean >> ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-mean"
				cat training?? > ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-training"
				cat test_error_??_majority > ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-test_error_majority"
				cat test_error_??_mean > ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-test_error_mean"
				rm -f test_error_??* tmp??* training??
		done
done
