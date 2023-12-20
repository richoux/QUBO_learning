EXEC=learn_q_opt learn_q_sat weak_learn_q_opt weak_learn_q_sat make_incomplete_spaces make_complete_spaces make_test_spaces
EXEC_DEBUG=learn_q_opt_debug weak_learn_q_opt_debug

# Compiler flags
MYFLAGS=
CXXFIRSTFLAGS= -O3 -W -Wall -Wextra -pedantic -Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -Wno-unused-but-set-variable
CXXFIRSTFLAGSDEBUG= -g -O0 -W -Wall -Wextra -pedantic -Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -Wno-unused-but-set-variable

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	CXX=g++
	CXXFLAGS= -std=c++20 $(CXXFIRSTFLAGS) $(MYFLAGS)
	CXXFLAGSDEBUG= -std=c++20 $(CXXFIRSTFLAGSDEBUG) $(MYFLAGS)
	LDFLAGS=-lghost_static -pthread
	LDFLAGSDEBUG=-lghost_staticd -pthread
endif
ifeq ($(UNAME_S),Darwin)
	CXX=clang++
	CXXFLAGS= -std=c++20 -stdlib=libc++ $(CXXFIRSTFLAGS) $(MYFLAGS)
	CXXFLAGSDEBUG= -std=c++20 -stdlib=libc++ $(CXXFIRSTFLAGSDEBUG) $(MYFLAGS)
	LDFLAGS=-lghost_static -lc++ -lc++abi -pthread
endif

# Directories
OBJDIR=obj
OBJ_block_sat=$(addprefix $(OBJDIR)/,constraint_training_set_block.o builder_block_sat.o learn_qubo_block_sat.o matrix.o print_qubo.o checks.o encoding.o onehot.o unary.o)
OBJ_block_opt=$(addprefix $(OBJDIR)/,constraint_training_set_block.o builder_block_opt.o learn_qubo_block_opt.o objective_short_expression.o matrix.o print_qubo.o checks.o encoding.o onehot.o unary.o)
OBJ_weak_block_sat=$(addprefix $(OBJDIR)/,constraint_training_set_block.o builder_block_sat.o weak_learn_qubo_block_sat.o matrix.o print_qubo.o checks.o encoding.o onehot.o unary.o)
OBJ_weak_block_opt=$(addprefix $(OBJDIR)/,constraint_training_set_block.o builder_block_opt.o weak_learn_qubo_block_opt.o objective_short_expression.o matrix.o print_qubo.o checks.o encoding.o onehot.o unary.o)
OBJ_make_incomplete_spaces=$(addprefix $(OBJDIR)/,make_incomplete_spaces.o increment.o latin.o random_draw.o all_different.o concept.o linear_equation.o no_overlap_1d.o ordered.o element.o channel.o)
OBJ_make_complete_spaces=$(addprefix $(OBJDIR)/,make_complete_spaces.o increment.o latin.o random_draw.o all_different.o concept.o linear_equation.o no_overlap_1d.o ordered.o element.o channel.o)
OBJ_make_test_spaces=$(addprefix $(OBJDIR)/,make_test_spaces.o increment.o latin.o random_draw.o all_different.o concept.o linear_equation.o no_overlap_1d.o ordered.o element.o channel.o)
BINDIR=bin
INCLUDEDIR=./include
LIBDIR=./lib

VPATH=src/models/common:src/models/model_scam:src/models/model_svn:src/models/model_sparse:src/models/model_force_pattern:src/models/model_force_preference:src/models/block_learning:src/models/block_learning_sat:src/models/block_learning_opt:src/make_spaces:src/make_spaces/constraints:src/make_spaces/utils

# Reminder, 'cause it is easy to forget makefile's fucked-up syntax...
# $@ is what triggered the rule, ie the target before :
# $^ is the whole dependencies list, ie everything after :
# $< is the first item in the dependencies list

# Rules
all: $(EXEC)

debug: CXXFLAGS=$(CXXFLAGSDEBUG)
debug: LDFLAGS=$(LDFLAGSDEBUG)
debug: $(EXEC_DEBUG)

make_incomplete_spaces: $(OBJ_make_incomplete_spaces)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

make_complete_spaces: $(OBJ_make_complete_spaces)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

make_test_spaces: $(OBJ_make_test_spaces)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

learn_q_opt: $(OBJ_block_opt)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

learn_q_opt_debug: $(OBJ_block_opt)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

learn_q_sat: $(OBJ_block_sat)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

weak_learn_q_opt: $(OBJ_weak_block_opt)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

weak_learn_q_sat: $(OBJ_weak_block_sat)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

weak_learn_q_opt_debug: $(OBJ_weak_block_opt)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

$(OBJDIR)/learn_qubo_block_opt.o: learn_qubo.cpp builder_block_opt.cpp 
	$(CXX) $(CXXFLAGS) -c -DBLOCK_OPT -I$(INCLUDEDIR) -I./src/models/block_learning_opt -I./src/models/common $< -o $@

$(OBJDIR)/learn_qubo_block_sat.o: learn_qubo.cpp builder_block_sat.cpp 
	$(CXX) $(CXXFLAGS) -c -DBLOCK_SAT -I$(INCLUDEDIR) -I./src/models/block_learning_sat -I./src/models/common $< -o $@

$(OBJDIR)/weak_learn_qubo_block_opt.o: weak_learn_qubo.cpp builder_block_opt.cpp 
	$(CXX) $(CXXFLAGS) -c -DBLOCK_OPT -I$(INCLUDEDIR) -I./src/models/block_learning_opt -I./src/models/common $< -o $@

$(OBJDIR)/weak_learn_qubo_block_sat.o: weak_learn_qubo.cpp builder_block_sat.cpp 
	$(CXX) $(CXXFLAGS) -c -DBLOCK_SAT -I$(INCLUDEDIR) -I./src/models/block_learning_sat -I./src/models/common $< -o $@

$(OBJDIR)/%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -I$(INCLUDEDIR) -I./src/models/common -I./src/make_spaces/utils -I./src/make_spaces/constraints $< -o $@

.PHONY: clean 

clean:
	rm -f core $(BINDIR)/* $(OBJDIR)/*.o
