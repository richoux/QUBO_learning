#include <iostream>

#include <random>
#include <cmath>

#include <randutils.hpp>

#include "latin.hpp"
#include "random_draw.hpp"

void random_draw( unique_ptr<Concept>& constraint_concept,
                  int nb_vars,
                  int max_value,
                  vector<int>& solutions,
                  vector<int>& not_solutions,
                  double percent )
{
	LHS latin;
  vector<int> configuration( nb_vars );
  unsigned long long int sampling_size = static_cast<unsigned long long int>( percent * std::pow( max_value, nb_vars ) / 100 );
  vector<int> latin_draws = latin.sample( nb_vars, max_value );

  for( unsigned long long int i = 0; i < sampling_size; i += max_value )
  {
	  for( int j = 0; j < max_value; ++j )
		  if( constraint_concept->constraint_concept( latin_draws, j * nb_vars, (j + 1) * nb_vars ) )
		  {
			  //++counter;
			  solutions.insert( solutions.end(),
			                    latin_draws.begin() + ( j * nb_vars ),
			                    latin_draws.begin() + ( ( j + 1 ) * nb_vars ) );
		  }
		  else
			  not_solutions.insert( not_solutions.end(),
			                        latin_draws.begin() + ( j * nb_vars ),
			                        latin_draws.begin() + ( ( j + 1 ) * nb_vars ) );
	  
	  latin_draws = latin.sample( nb_vars, max_value );
  }
}

int cap_draw( unique_ptr<Concept>& constraint_concept,
              int nb_vars,
              int max_value,
              vector<int>& solutions,
              vector<int>& not_solutions,
              int number_sol )
{
	LHS latin;
	vector<int> configuration( nb_vars );
  vector<int> sample( nb_vars );
  int count_sol = 0;
  int count_no_sol = 0;
  vector<int> latin_draws = latin.sample( nb_vars, max_value );
  int count_draw = 0;
  
  do
  {
	  for( int j = 0; j < max_value; ++j )
	  {
		  ++count_draw;
		  if( constraint_concept->constraint_concept( latin_draws, j * nb_vars, (j + 1) * nb_vars ) )
		  {
			  if( count_sol < number_sol )
			  {
				  solutions.insert( solutions.end(),
				                    latin_draws.begin() + ( j * nb_vars ),
				                    latin_draws.begin() + ( ( j + 1 ) * nb_vars ) );
				  ++count_sol;
			  }
		  }
		  else
			  if( count_no_sol < count_sol )
			  {
				  not_solutions.insert( not_solutions.end(),
				                        latin_draws.begin() + ( j * nb_vars ),
				                        latin_draws.begin() + ( ( j + 1 ) * nb_vars ) );
				  ++count_no_sol;			  
			  }
	  }
	  
	  latin_draws = latin.sample( nb_vars, max_value );
  } while( count_sol < number_sol || count_no_sol < number_sol );

  return count_draw;
}
