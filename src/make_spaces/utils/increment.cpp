#include <algorithm>

#include "increment.hpp"

bool increment( vector<int>& variables, const int max_value, const int index )
{
	if( index < 0 )
		return false;

	if( variables[ index ] < max_value )
		++variables[ index ];
	else
	{
		// Domain starts at 1
		variables[ index ] = 1;
		increment( variables, max_value, index - 1 );
	}

	return true;
}

bool increment( vector<int>& variables, const int max_value )
{
	return increment( variables, max_value, variables.size() - 1 );
}

