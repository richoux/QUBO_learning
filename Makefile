#EXEC=qubo_ghost_scam qubo_ghost_svn qubo_ghost_sparse qubo_ghost_force_pattern qubo_ghost_force_preference qubo_block qubo_block_sat
EXEC=q_learning_opt q_learning_sat make_spaces make_complete_spaces make_test_spaces
#EXEC_DEBUG=qubo_ghost_scam_debug qubo_ghost_svn_debug qubo_ghost_sparse_debug qubo_ghost_force_pattern_debug qubo_ghost_force_preference_debug qubo_block_debug qubo_block_sat_debug

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
# OBJ_scam=$(addprefix $(OBJDIR)/,objective_supervised_learning.o builder_scam.o print_qubo.o learn_qubo_scam.o)
# OBJ_svn=$(addprefix $(OBJDIR)/,constraint_training_set.o objective_svn.o builder_svn.o print_qubo.o learn_qubo_svn.o)
# OBJ_sparse=$(addprefix $(OBJDIR)/,constraint_training_set.o objective_sparse.o builder_sparse.o print_qubo.o learn_qubo_sparse.o)
# OBJ_force_pattern=$(addprefix $(OBJDIR)/,objective_supervised_learning.o builder_force_pattern.o print_qubo.o learn_qubo_force_pattern.o)
# OBJ_force_preference=$(addprefix $(OBJDIR)/,objective_supervised_learning.o builder_force_preference.o print_qubo.o learn_qubo_force_preference.o)
# OBJ_block=$(addprefix $(OBJDIR)/,objective_block.o builder_block.o learn_qubo_block.o constraint_parameter.o)
OBJ_block_sat=$(addprefix $(OBJDIR)/,constraint_training_set_block.o builder_block_sat.o learn_qubo_block_sat.o matrix.o)
OBJ_block_opt=$(addprefix $(OBJDIR)/,constraint_training_set_block.o builder_block_opt.o learn_qubo_block_opt.o objective_short_expression.o matrix.o)
OBJ_make_spaces=$(addprefix $(OBJDIR)/,make_spaces.o increment.o latin.o random_draw.o all_different.o concept.o linear_equation.o no_overlap_1d.o ordered.o element.o channel.o)
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

# debug: CXXFLAGS=$(CXXFLAGSDEBUG)
# debug: LDFLAGS=$(LDFLAGSDEBUG)
# debug: $(EXEC_DEBUG)

# qubo_ghost_scam: $(OBJ_scam)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_ghost_svn: $(OBJ_svn)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_ghost_sparse: $(OBJ_sparse)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_ghost_force_pattern: $(OBJ_force_pattern)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_ghost_force_preference: $(OBJ_force_preference)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_block: $(OBJ_block)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_block_sat: $(OBJ_block_sat)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_ghost_scam_debug: $(OBJ_scam)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_ghost_svn_debug: $(OBJ_svn)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_ghost_sparse_debug: $(OBJ_sparse)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_ghost_force_pattern_debug: $(OBJ_force_pattern)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_ghost_force_preference_debug: $(OBJ_force_preference)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_block_debug: $(OBJ_block)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# qubo_block_sat_debug: $(OBJ_block_sat)
# 	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

# $(OBJDIR)/learn_qubo_scam.o: learn_qubo.cpp builder_scam.cpp print_qubo.cpp
# 	$(CXX) $(CXXFLAGS) -c -DSCAM -I$(INCLUDEDIR) -I./src/models/model_scam -I./src/models/common $< -o $@

# $(OBJDIR)/learn_qubo_svn.o: learn_qubo.cpp builder_svn.cpp print_qubo.cpp
# 	$(CXX) $(CXXFLAGS) -c -DSVN -I$(INCLUDEDIR) -I./src/models/model_svn -I./src/models/common $< -o $@

# $(OBJDIR)/learn_qubo_sparse.o: learn_qubo.cpp builder_sparse.cpp print_qubo.cpp
# 	$(CXX) $(CXXFLAGS) -c -DSPARSE -I$(INCLUDEDIR) -I./src/models/model_sparse -I./src/models/common $< -o $@

# $(OBJDIR)/learn_qubo_force_pattern.o: learn_qubo.cpp builder_force_pattern.cpp print_qubo.cpp
# 	$(CXX) $(CXXFLAGS) -c -I$(INCLUDEDIR) -I./src/models/model_force_pattern -I./src/models/common $< -o $@

# $(OBJDIR)/learn_qubo_force_preference.o: learn_qubo.cpp builder_force_preference.cpp print_qubo.cpp
# 	$(CXX) $(CXXFLAGS) -c -DPREF -I$(INCLUDEDIR) -I./src/models/model_force_preference -I./src/models/common $< -o $@

# $(OBJDIR)/learn_qubo_block.o: learn_qubo.cpp builder_block.cpp 
# 	$(CXX) $(CXXFLAGS) -c -DBLOCK -I$(INCLUDEDIR) -I./src/models/block_learning -I./src/models/common $< -o $@

make_spaces: $(OBJ_make_spaces)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

make_complete_spaces: $(OBJ_make_complete_spaces)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

make_test_spaces: $(OBJ_make_test_spaces)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

q_learning_opt: $(OBJ_block_opt)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

q_learning_sat: $(OBJ_block_sat)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

$(OBJDIR)/learn_qubo_block_opt.o: learn_qubo.cpp builder_block_opt.cpp 
	$(CXX) $(CXXFLAGS) -c -DBLOCK_OPT -I$(INCLUDEDIR) -I./src/models/block_learning_opt -I./src/models/common $< -o $@

$(OBJDIR)/learn_qubo_block_sat.o: learn_qubo.cpp builder_block_sat.cpp 
	$(CXX) $(CXXFLAGS) -c -DBLOCK_SAT -I$(INCLUDEDIR) -I./src/models/block_learning_sat -I./src/models/common $< -o $@

$(OBJDIR)/%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -I$(INCLUDEDIR) -I./src/models/common -I./src/make_spaces/utils -I./src/make_spaces/constraints $< -o $@

.PHONY: clean 

clean:
	rm -f core $(BINDIR)/* $(OBJDIR)/*.o
