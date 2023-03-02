#include <numeric>
#include <iostream>
#include <limits>
#include <cmath>

#include <Eigen/Dense>

#include "objective_short_expression.hpp"

using namespace std;

ObjectiveShortExpression::ObjectiveShortExpression( const vector<Variable>& variables )
	: Minimize( variables, "Minimize the number of patterns in the composition" )
{ }

double ObjectiveShortExpression::required_cost( const vector<Variable*>& vecVariables ) const 
{
	return accumulate( vecVariables.begin() + 1, vecVariables.end(), 0, [](double total, const auto &var){ return total + var->get_value(); } );
}
