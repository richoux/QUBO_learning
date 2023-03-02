#pragma once

#include "concept.hpp"

class AllDifferent : public Concept
{
public:
	AllDifferent( int nb_vars, int max_value );
	AllDifferent();
	
	bool constraint_concept( const std::vector<int>& var, int start, int end ) const override;
};
