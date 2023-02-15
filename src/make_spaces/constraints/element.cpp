#include <algorithm>
#include "element.hpp"

Element::Element( int nb_vars, int max_value, int element )
	: Concept( nb_vars, max_value ),
	  _element( element )
{ }

Element::Element( int element )
	: Concept( 0, 0 ),
	  _element( element )
{ }

bool Element::constraint_concept( const vector<int>& var, int start, int end ) const
{
	return std::any_of( var.begin() + start, var.begin() + start + end, [&](auto v){ return v == _element; } );
}
