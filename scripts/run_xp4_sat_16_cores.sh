#!/bin/bash
#Weak learners

EXE="../bin/weak_learn_q_sat"

CORE=$(grep -c '^processor' /proc/cpuinfo)
if ! [[ ${CORE%.*} -eq 16 ]]; then
		echo "Error: this script has been designed to run on a 16-core CPU."
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
						for i in {1..6}
						do
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01_majority --benchmark >> test_error_01_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01_mean --benchmark >> test_error_01_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02_majority --benchmark >> test_error_02_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02_mean --benchmark >> test_error_02_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03_majority --benchmark >> test_error_03_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03_mean --benchmark >> test_error_03_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04_majority --benchmark >> test_error_04_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04_mean --benchmark >> test_error_04_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp05 --benchmark 2> /dev/null 1>> training05 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp05_majority --benchmark >> test_error_05_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp05_mean --benchmark >> test_error_05_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp06 --benchmark 2> /dev/null 1>> training06 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp06_majority --benchmark >> test_error_06_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp06_mean --benchmark >> test_error_06_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp07 --benchmark 2> /dev/null 1>> training07 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp07_majority --benchmark >> test_error_07_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp07_mean --benchmark >> test_error_07_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp08 --benchmark 2> /dev/null 1>> training08 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp08_majority --benchmark >> test_error_08_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp08_mean --benchmark >> test_error_08_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp09 --benchmark 2> /dev/null 1>> training09 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp09_majority --benchmark >> test_error_09_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp09_mean --benchmark >> test_error_09_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp10 --benchmark 2> /dev/null 1>> training10 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp10_majority --benchmark >> test_error_10_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp10_mean --benchmark >> test_error_10_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp11 --benchmark 2> /dev/null 1>> training11 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp11_majority --benchmark >> test_error_11_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp11_mean --benchmark >> test_error_11_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp12 --benchmark 2> /dev/null 1>> training12 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp12_majority --benchmark >> test_error_12_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp12_mean --benchmark >> test_error_12_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp13 --benchmark 2> /dev/null 1>> training13 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp13_majority --benchmark >> test_error_13_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp13_mean --benchmark >> test_error_13_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp14 --benchmark 2> /dev/null 1>> training14 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp14_majority --benchmark >> test_error_14_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp14_mean --benchmark >> test_error_14_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp15 --benchmark 2> /dev/null 1>> training15 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp15_majority --benchmark >> test_error_15_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp15_mean --benchmark >> test_error_15_mean &
								$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp16 --benchmark 2> /dev/null 1>> training16 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp16_majority --benchmark >> test_error_16_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp16_mean --benchmark >> test_error_16_mean &
								wait
								cat tmp??_majority >> ../results/weak_learners/"$constraint-12_12_weak_w$w-n$n-majority"
								cat tmp??_mean >> ../results/weak_learners/"$constraint-12_12_weak_w$w-n$n-mean"
								>&2 echo "$((16*i))% done"
						done

						rm -f tmp??*

						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01_majority --benchmark >> test_error_01_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp01_mean --benchmark >> test_error_01_mean &
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02_majority --benchmark >> test_error_02_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp02_mean --benchmark >> test_error_02_mean &
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03_majority --benchmark >> test_error_03_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp03_mean --benchmark >> test_error_03_mean &
						$EXE -f "../spaces/incomplete/$constraint-12_12_100.txt" -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04_majority --benchmark >> test_error_04_majority ; $EXE -f "../spaces/test/$constraint-30_30.txt" -c tmp04_mean --benchmark >> test_error_04_mean &
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
				for i in {1..6}
				do
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01_majority --benchmark >> test_error_01_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01_mean --benchmark >> test_error_01_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02_majority --benchmark >> test_error_02_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02_mean --benchmark >> test_error_02_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03_majority --benchmark >> test_error_03_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03_mean --benchmark >> test_error_03_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04_majority --benchmark >> test_error_04_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04_mean --benchmark >> test_error_04_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp05 --benchmark 2> /dev/null 1>> training05 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp05_majority --benchmark >> test_error_05_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp05_mean --benchmark >> test_error_05_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp06 --benchmark 2> /dev/null 1>> training06 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp06_majority --benchmark >> test_error_06_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp06_mean --benchmark >> test_error_06_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp07 --benchmark 2> /dev/null 1>> training07 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp07_majority --benchmark >> test_error_07_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp07_mean --benchmark >> test_error_07_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp08 --benchmark 2> /dev/null 1>> training08 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp08_majority --benchmark >> test_error_08_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp08_mean --benchmark >> test_error_08_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp09 --benchmark 2> /dev/null 1>> training09 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp09_majority --benchmark >> test_error_09_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp09_mean --benchmark >> test_error_09_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp10 --benchmark 2> /dev/null 1>> training10 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp10_majority --benchmark >> test_error_10_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp10_mean --benchmark >> test_error_10_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp11 --benchmark 2> /dev/null 1>> training11 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp11_majority --benchmark >> test_error_11_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp11_mean --benchmark >> test_error_11_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp12 --benchmark 2> /dev/null 1>> training12 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp12_majority --benchmark >> test_error_12_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp12_mean --benchmark >> test_error_12_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp13 --benchmark 2> /dev/null 1>> training13 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp13_majority --benchmark >> test_error_13_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp13_mean --benchmark >> test_error_13_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp14 --benchmark 2> /dev/null 1>> training14 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp14_majority --benchmark >> test_error_14_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp14_mean --benchmark >> test_error_14_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp15 --benchmark 2> /dev/null 1>> training15 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp15_majority --benchmark >> test_error_15_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp15_mean --benchmark >> test_error_15_mean )&
						($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp16 --benchmark 2> /dev/null 1>> training16 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp16_majority --benchmark >> test_error_16_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp16_mean --benchmark >> test_error_16_mean )&
						wait
						cat tmp??_majority >> ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-majority"
						cat tmp??_mean >> ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-mean"
						>&2 echo "$((16*i))% done"
				done

				rm -f tmp??*

				($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01_majority --benchmark >> test_error_01_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp01_mean --benchmark >> test_error_01_mean )&
				($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02_majority --benchmark >> test_error_02_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp02_mean --benchmark >> test_error_02_mean )&
				($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03_majority --benchmark >> test_error_03_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp03_mean --benchmark >> test_error_03_mean )&
				($EXE -f "../spaces/incomplete/linear_equation-12_12_72_100.txt" -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04_majority --benchmark >> test_error_04_majority ; $EXE -f "../spaces/test/linear_equation-30_30_600.txt" -c tmp04_mean --benchmark >> test_error_04_mean )&
				wait

				cat tmp??_majority >> ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-majority"
				cat tmp??_mean >> ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-mean"
				cat training?? > ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-training"
				cat test_error_??_majority > ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-test_error_majority"
				cat test_error_??_mean > ../results/weak_learners/"linear_equation-12_12_72_weak_w$w-n$n-test_error_mean"
				rm -f test_error_??* tmp??* training??

				echo ""
				echo "no_overlap_1D"
				for i in {1..6}
				do
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp01_majority --benchmark >> test_error_01_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp01_mean --benchmark >> test_error_01_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp02_majority --benchmark >> test_error_02_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp02_mean --benchmark >> test_error_02_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp03_majority --benchmark >> test_error_03_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp03_mean --benchmark >> test_error_03_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp04_majority --benchmark >> test_error_04_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp04_mean --benchmark >> test_error_04_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp05 --benchmark 2> /dev/null 1>> training05 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp05_majority --benchmark >> test_error_05_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp05_mean --benchmark >> test_error_05_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp06 --benchmark 2> /dev/null 1>> training06 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp06_majority --benchmark >> test_error_06_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp06_mean --benchmark >> test_error_06_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp07 --benchmark 2> /dev/null 1>> training07 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp07_majority --benchmark >> test_error_07_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp07_mean --benchmark >> test_error_07_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp08 --benchmark 2> /dev/null 1>> training08 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp08_majority --benchmark >> test_error_08_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp08_mean --benchmark >> test_error_08_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp09 --benchmark 2> /dev/null 1>> training09 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp09_majority --benchmark >> test_error_09_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp09_mean --benchmark >> test_error_09_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp10 --benchmark 2> /dev/null 1>> training10 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp10_majority --benchmark >> test_error_10_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp10_mean --benchmark >> test_error_10_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp11 --benchmark 2> /dev/null 1>> training11 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp11_majority --benchmark >> test_error_11_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp11_mean --benchmark >> test_error_11_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp12 --benchmark 2> /dev/null 1>> training12 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp12_majority --benchmark >> test_error_12_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp12_mean --benchmark >> test_error_12_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp13 --benchmark 2> /dev/null 1>> training13 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp13_majority --benchmark >> test_error_13_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp13_mean --benchmark >> test_error_13_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp14 --benchmark 2> /dev/null 1>> training14 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp14_majority --benchmark >> test_error_14_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp14_mean --benchmark >> test_error_14_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp15 --benchmark 2> /dev/null 1>> training15 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp15_majority --benchmark >> test_error_15_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp15_mean --benchmark >> test_error_15_mean )&
						($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp16 --benchmark 2> /dev/null 1>> training16 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp16_majority --benchmark >> test_error_16_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp16_mean --benchmark >> test_error_16_mean )&
						wait
						cat tmp??_majority >> ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-majority"
						cat tmp??_mean >> ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-mean"
						>&2 echo "$((16*i))% done"
				done

				rm -f tmp??*
				
				($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp01 --benchmark 2> /dev/null 1>> training01 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp01_majority --benchmark >> test_error_01_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp01_mean --benchmark >> test_error_01_mean )&
				($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp02 --benchmark 2> /dev/null 1>> training02 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp02_majority --benchmark >> test_error_02_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp02_mean --benchmark >> test_error_02_mean )&
				($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp03 --benchmark 2> /dev/null 1>> training03 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp03_majority --benchmark >> test_error_03_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp03_mean --benchmark >> test_error_03_mean )&
				($EXE -f "../spaces/incomplete/no_overlap_1D-8_35_3_100.txt" -w $w -n $n -r tmp04 --benchmark 2> /dev/null 1>> training04 ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp04_majority --benchmark >> test_error_04_majority ; $EXE -f "../spaces/test/no_overlap_1D-20_160_6.txt" -c tmp04_mean --benchmark >> test_error_04_mean )&
				wait

				cat tmp??_majority >> ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-majority"
				cat tmp??_mean >> ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-mean"
				cat training?? > ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-training"
				cat test_error_??_majority > ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-test_error_majority"
				cat test_error_??_mean > ../results/weak_learners/"no_overlap_1D-8_35_3_weak_w$w-n$n-test_error_mean"
				rm -f test_error_??* tmp??* training??
		done
done
