#pragma once

#include <vector>

#include "../constraints/concept.hpp"

using namespace std;

void random_draw( unique_ptr<Concept>& constraint_concept,
                  int nb_vars,
                  int max_value,
                  vector<int>& solutions,
                  vector<int>& not_solutions,
                  double percent = 0.1 );

int cap_draw( unique_ptr<Concept>& constraint_concept,
              int nb_vars,
              int max_value,
              vector<int>& solutions,
              vector<int>& not_solutions,
              int number_sol = 100 );
