#include <numeric>
#include <iostream>
#include <limits>

#include <Eigen/Dense>

#include "objective_sparse.hpp"

using namespace std;

ObjectiveSparse::ObjectiveSparse( const vector<Variable>& variables )
	: Maximize( variables, "Maximize sparsity" )
{ }

double ObjectiveSparse::required_cost( const vector<Variable*>& vecVariables ) const 
{
	return std::count_if( vecVariables.begin(), vecVariables.end(), [](auto &v){ return v->get_value() == 0; } );
}

int ObjectiveSparse::expert_heuristic_value( const std::vector< Variable * > &variables, int variable_index, const std::vector< int > &possible_values ) const
{
	return rng.pick( possible_values );

}
