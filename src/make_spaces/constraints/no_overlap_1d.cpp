#include <algorithm>
#include <iostream>
#include <iterator>

#include "no_overlap_1d.hpp"

NoOverlap1D::NoOverlap1D( int nb_vars, int max_value, vector<double> params )
	: Concept( nb_vars, max_value ),
	  _params( params )
{ }

NoOverlap1D::NoOverlap1D( vector<double> params )
	: Concept( 0, 0 ),
	  _params( params )	  
{ }

bool NoOverlap1D::constraint_concept( const vector<int>& var, int start, int end ) const
{
	for( int i = start; i < end; ++i )
		for( int j = start; j < end; ++j )
			if( j != i && var[j] + _params[j-start] > var[i] && var[i] + _params[i-start] > var[j] )
				return false;

	return true;
}

bool NoOverlap1D::constraint_concept( const vector<Variable*>& var ) const
{
	for( int i = 0; i < (int)var.size(); ++i )
		for( int j = 0; i < (int)var.size(); ++j )
			if( j != i
			    &&
			    var[j]->get_value() + _params[j] > var[i]->get_value()
			    &&
			    var[i]->get_value() + _params[i] > var[j]->get_value() )
				return false;

	return true;
}
