#include "ordered.hpp"

Ordered::Ordered( int nb_vars, int max_value )
	: Concept( nb_vars, max_value )
{ }

Ordered::Ordered()
	: Concept( 0, 0 )
{ }

bool Ordered::constraint_concept( const vector<int>& var, int start, int end ) const
{
	for( int i = start ; i < end - 1 ; ++i )
		if( var[i] > var[i+1] )
			return false;
	
	return true;
}

bool Ordered::constraint_concept( const vector<Variable*>& var ) const
{
	for( int i = 0 ; i < var.size() - 1 ; ++i )
		if( var[i]->get_value() > var[i+1]->get_value() )
			return false;
	
	return true;
}
