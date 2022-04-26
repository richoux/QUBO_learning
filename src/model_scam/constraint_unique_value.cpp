#include <cmath>
#include <algorithm>

#include "constraint_unique_value.hpp"

UniqueValue::UniqueValue( const vector<int>& variables )
	: Constraint( variables )
{ }

UniqueValue::UniqueValue( vector<int>&& variables )
	: Constraint( std::move( variables ) )
{ }

double UniqueValue::required_error( const vector<Variable*>& variables ) const
{
	double error = 0.;
	
	for( auto& v : variables )
		if( v->get_value() < 1 ) // < 1 to accept values like 2, 3, ...
			++error;

	return error;
}
