#include <cmath>
#include <algorithm>

#include "constraint_unique_value.hpp"

UniqueValue::UniqueValue( const vector<int>& variables )
	: Constraint( variables ),
	  _number_1( 0 ),
	  _number_2( 0 )
{ }

UniqueValue::UniqueValue( vector<int>&& variables )
	: Constraint( std::move( variables ) ),
	  _number_1( 0 ),
	  _number_2( 0 )
{ }

double UniqueValue::required_error( const vector<Variable*>& variables ) const
{
	double error = 0.;

	_number_1 = 0;
	_number_2 = 0;
	
	for( auto& v : variables )
		if( v->get_value() == 1 )
			++_number_1;
		else
			if( v->get_value() == 2 )
				++_number_2;

	if( _number_1 != static_cast<int>( variables.size() ) && _number_2 != static_cast<int>( variables.size() ) )
		error = static_cast<double>( std::min( _number_1, _number_2 ) );

	return error;
}

double UniqueValue::optional_delta_error( const std::vector<Variable*> &variables, const std::vector<int> &indexes, const std::vector<int> &candidate_values ) const
{
	double error = 0.;

	int number_1 = _number_1;
	int number_2 = _number_2;

	for( size_t i = 0 ; i < indexes.size() ; ++i )
	{
		if( variables[ indexes[i] ]->get_value() == 1 )
			--number_1;
		else
			if( variables[ indexes[i] ]->get_value() == 2 )
				--number_2;

		if( candidate_values[i] == 1 )
			++number_1;
		else
			if( candidate_values[i] == 2 )
				++number_2;
	}

	if( number_1 != static_cast<int>( variables.size() ) && number_2 != static_cast<int>( variables.size() ) )
		error = static_cast<double>( std::min( number_1, number_2 ) );
	
	return error - get_current_error();
}
