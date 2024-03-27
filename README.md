[![DOI](https://zenodo.org/badge/485604706.svg)](https://zenodo.org/badge/latestdoi/485604706) for one-hot encoding only (ICCS 2023 paper).

# Learning QUBO matrix from data

This program aims to learn pattern composition representing a Q matrix from data. 

## Project tree

* bin: where the project binaries are generated
* include: headers of third-party libraries
* lib: third-party libraries
* obj: where the project object files are generated
* results: contains the results of experiments run for our paper.
* scripts: scripts to run different experiments in the paper.
* spaces: training and test sets. `spaces/complete` and `spaces/incomplete` contain training sets of Experiment 1 and 2, respectively.
* src: source code of the project. `src/make_spaces` contains the source code to generate training and test sets. `src/models` contains the code of our different models. The model presented in the paper is `src/models/block_learning_opt` (and `src/models/block_learning_sat` for the model without the objective function). `src/explored` contains different models and learning schemes that have been tested before `src/models/block_learning_opt` and `src/models/block_learning_sat`.

<br>

## How to:

### Compile programs

```
$> make
```

If you need details of the solving process, then type

```
$> make MYFLAGS=-DGHOST_BENCH
```

<br>

### Run the main program to learn a Q matrix
```
$> ./bin/learn_q_opt (and many options, type -h first to have them)`
```

#### For instance
Learn a q matrix for AllDifferent-4-4:
```
$> ./bin/learn_q_opt -f spaces/complete/alldiff-4_4.txt
```

Learn a q matrix for AllDifferent-4-4 and write q in an output file:
```
$> ./bin/learn_q_opt -f spaces/complete/alldiff-4_4.txt -m matrix_file.txt
```

Learn a q matrix for AllDifferent-4-4 and write the pattern composition vector in an output file:
```
$> ./bin/learn_q_opt -f spaces/complete/alldiff-4_4.txt -r result_file.txt
```

The one-hot encoding is applied by default. To choose the unary encoding, use the option `-e 1`

<br>

### Run the main program to learn a Q matrix with weak learners
```
$> ./bin/weak_learn_q_opt (and many options, type -h first to have them)`
```

#### For instance
Learn a q matrix for AllDifferent-4-4 with 5 weak learners:
```
$> ./bin/weak_learn_q_opt -f spaces/complete/alldiff-4_4.txt -w 5
```

Learn a q matrix for AllDifferent-12-12 with 7 weak learners over the same samples for each weak learners (here, a pre-sampled set of 4 solutions and 4 non-solutions):
```
$> ./bin/weak_learn_q_opt -f spaces/incomplete/alldiff-12_12_4.txt -w 7
```

Learn a q matrix for AllDifferent-12-12 with 9 weak learners over 10 random samples (different samples for each weak learners):
```
$> ./bin/weak_learn_q_opt -f spaces/incomplete/alldiff-12_12_10000.txt -w 9 -n 10
```

<br>

### Run programs to build spaces
Generate complete spaces (scan all possible candidates):
```
$> ./bin/make_complete_spaces (and many options, type -h first to have them)
```

Generate incomplete spaces (draw positive and negative candidates):
```
$> ./bin/make_incomplete_spaces (and many options, type -h first to have them)
```

Generate test spaces (build positive candidates and draw negative ones):
```
$> ./bin/make_test_spaces (and many options, type -h first to have them)
```

#### For instance
Create the file `alldiff.txt` containing the complete space of AllDifferent over 4 variables with domains of size 6:
```
$> ./bin/make_complete_spaces -c ad -n 4 -d 6 -o alldiff.txt
```

Create the file `linear_equation.txt` containing an incomplete space of the LinearSum x+y+z=10 with domains of size 5, by sampling 1,000 positive and 1,000 negative candidates:
```
$> ./bin/make_incomplete_spaces -c le -n 3 -d 5 -p 10 -s 1000 -o linear_equation.txt
```

Create the file `channel.txt` containing a test space of Channel over 20 variables with domains of size 20, with 50 positive and 50 negative candidates:
```
$> ./bin/make_test_spaces -c ch -n 20 -d 20 -s 50 -o channel.txt
```

<br>

#### Warning
Running experiments with scripts in the `scripts` folder will generate new result files in the `results` folder.

