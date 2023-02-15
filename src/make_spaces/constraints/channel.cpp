#include <algorithm>
#include "channel.hpp"

Channel::Channel( int nb_vars, int max_value )
	: Concept( nb_vars, max_value )
{ }

Channel::Channel()
	: Concept( 0, 0 )
{ }

bool Channel::constraint_concept( const vector<int>& var, int start, int end ) const
{
	// we consider that domains star from 1, explaining the 'var[ var[i]-1 ] != i+1'
	for( int i = start ; i < end ; ++i )
		if( var[i]-1 < 0 || var[i]-1 >= static_cast<int>( var.size() ) || var[ var[i]-1 ] != i+1 )
			return false;

	return true;
}
