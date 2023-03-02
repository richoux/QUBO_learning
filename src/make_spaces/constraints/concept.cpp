#include <cmath>

#include "concept.hpp"

Concept::Concept( int nb_vars, int max_value )
	: nb_vars( nb_vars ),
	  max_value( max_value )
{ }

bool Concept::constraint_concept( const std::vector<int>& var ) const
{
	// the '!' is to get 0 when the candidate is a solution, and 1 when it is not.
	return !constraint_concept( var, 0, (int)var.size() );
}
