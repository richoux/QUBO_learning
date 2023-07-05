#include <numeric>

#include "constraint_parameter.hpp"

ParameterManagement::ParameterManagement( const vector<int>& variables_index,
                                          int parameter )
	: Constraint( variables_index ),
	  _parameter( parameter )
{ }

double ParameterManagement::required_error( const vector<Variable*>& variables ) const
{
	// Diagonal beam can only be selected if there is a given parameter
	if( _parameter == std::numeric_limits<int>::max() && variables[0]->get_value() == 1 )
		return 1.;
	
	return 0.;
}
