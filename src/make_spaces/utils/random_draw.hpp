#pragma once

#include <vector>
#include <string>

#include "../constraints/concept.hpp"

using namespace std;

std::string convert_to_string( const vector<int>& config, int start, int end );
std::string convert_to_string( const vector<int>& config );

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

int cap_draw_not_solutions( unique_ptr<Concept>& constraint_concept,
                            int nb_vars,
                            int max_value,
                            vector<int>& not_solutions,
                            int number_sol = 100 );
