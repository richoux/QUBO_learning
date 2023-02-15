#pragma once

#include "concept.hpp"

class Ordered : public Concept
{
public:
	Ordered( int nb_vars, int max_value );
	Ordered();
	
	bool constraint_concept( const vector<int>& var, int start, int end ) const override;
};
