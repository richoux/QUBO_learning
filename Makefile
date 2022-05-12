EXEC=qubo_ghost_scam qubo_ghost_svn qubo_ghost_sparse
EXEC_DEBUG=qubo_ghost_scam_debug qubo_ghost_svn_debug qubo_ghost_sparse_debug

# Compiler flags
CXXFIRSTFLAGS= -O3 -W -Wall -Wextra -pedantic -Wno-sign-compare -Wno-unused-parameter
CXXFIRSTFLAGSDEBUG= -g -O0 -W -Wall -Wextra -pedantic -Wno-sign-compare -Wno-unused-parameter 

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	CXX=g++
	CXXFLAGS= -std=c++17 $(CXXFIRSTFLAGS)
	CXXFLAGSDEBUG= -std=c++17 $(CXXFIRSTFLAGSDEBUG)
	LDFLAGS=-lghost_static -pthread
endif
ifeq ($(UNAME_S),Darwin)
	CXX=clang++
	CXXFLAGS= -std=c++17  -stdlib=libc++ $(CXXFIRSTFLAGS)
	CXXFLAGSDEBUG= -std=c++17  -stdlib=libc++ $(CXXFIRSTFLAGSDEBUG)
	LDFLAGS=-lghost_static -lc++ -lc++abi -pthread
endif

# Directories
OBJDIR=obj
OBJ_scam=$(addprefix $(OBJDIR)/,constraint_unique_value.o objective_supervised_learning.o builder_scam.o print_qubo.o learn_qubo_scam.o)
OBJ_svn=$(addprefix $(OBJDIR)/,constraint_training_set.o constraint_unique_value.o objective_svn.o builder_svn.o print_qubo.o learn_qubo_svn.o)
OBJ_sparse=$(addprefix $(OBJDIR)/,constraint_training_set.o constraint_unique_value.o objective_sparse.o builder_sparse.o print_qubo.o learn_qubo_sparse.o)
BINDIR=bin
INCLUDEDIR=./include
LIBDIR=./lib

VPATH=src:src/model_scam:src/model_svn:src/model_sparse

# Reminder, 'cause it is easy to forget makefile's fucked-up syntax...
# $@ is what triggered the rule, ie the target before :
# $^ is the whole dependencies list, ie everything after :
# $< is the first item in the dependencies list

# Rules
all: $(EXEC)

debug: CXXFLAGS=$(CXXFLAGSDEBUG)
debug: $(EXEC_DEBUG)

qubo_ghost_scam: $(OBJ_scam)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

qubo_ghost_svn: $(OBJ_svn)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

qubo_ghost_sparse: $(OBJ_sparse)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

qubo_ghost_scam_debug: $(OBJ_scam)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

qubo_ghost_svn_debug: $(OBJ_svn)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

qubo_ghost_sparse_debug: $(OBJ_sparse)
	$(CXX) -o $(BINDIR)/$@ $^ -L$(LIBDIR) $(LDFLAGS)

$(OBJDIR)/learn_qubo_scam.o: learn_qubo.cpp builder_scam.cpp print_qubo.cpp
	$(CXX) $(CXXFLAGS) -c -I$(INCLUDEDIR) -I./src/model_scam $< -o $@

$(OBJDIR)/learn_qubo_svn.o: learn_qubo.cpp builder_svn.cpp print_qubo.cpp
	$(CXX) $(CXXFLAGS) -c -DSVN -I$(INCLUDEDIR) -I./src/model_svn $< -o $@

$(OBJDIR)/learn_qubo_sparse.o: learn_qubo.cpp builder_sparse.cpp print_qubo.cpp
	$(CXX) $(CXXFLAGS) -c -DSPARSE -I$(INCLUDEDIR) -I./src/model_sparse $< -o $@

$(OBJDIR)/%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -I$(INCLUDEDIR) $< -o $@

.PHONY: clean 

clean:
	rm -f core $(BINDIR)/* $(OBJDIR)/*.o *~ src/*~ src/model_scam/*~ src/model_svn/*~ src/model_sparse/*~
