#include <algorithm>

#include "linear_equation.hpp"

LinearEquation::LinearEquation( int nb_vars, int max_value, int rhs )
	: Concept( nb_vars, max_value ),
	  _rhs( rhs )
{ }

LinearEquation::LinearEquation( int rhs )
	: Concept( 0, 0 ),
	  _rhs( rhs )	  
{ }

bool LinearEquation::constraint_concept( const vector<int>& var, int start, int end ) const
{
	return accumulate( var.begin() + start, var.begin() + end, 0 ) == _rhs;
}
