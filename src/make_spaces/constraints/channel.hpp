#pragma once

#include "concept.hpp"

class Channel : public Concept
{
public:
	Channel( int nb_vars, int max_value );
	Channel();
	
	bool constraint_concept( const vector<int>& var, int start, int end ) const override;
};
