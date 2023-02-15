#pragma once

#include "concept.hpp"

class LinearEquation : public Concept
{
	int _rhs;
	
public:
	LinearEquation( int nb_vars, int max_value, int rhs );
	LinearEquation( int rhs );
	
	bool constraint_concept( const vector<int>& var, int start, int end ) const override;
};
