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

	int number_1 = 0;
	int number_2 = 0;
	
	for( auto& v : variables )
		if( v->get_value() == 1 )
			++number_1;
		else
			if( v->get_value() == 2 )
				++number_2;

	if( number_1 != static_cast<int>( variables.size() ) && number_2 != static_cast<int>( variables.size() ) )
		error = static_cast<double>( std::min( number_1, number_2 ) );

	return error;
}
