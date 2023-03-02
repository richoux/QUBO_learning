#pragma once

#include "concept.hpp"

class NoOverlap1D : public Concept
{
	vector<double> _params;
	
public:
	NoOverlap1D( int nb_vars, int max_value, vector<double> params );
	NoOverlap1D( vector<double> params );
	
	bool constraint_concept( const vector<int>& var, int start, int end ) const override;
};
