#pragma once

#include "concept.hpp"

class Element : public Concept
{
	int _element;
	
public:
	Element( int nb_vars, int max_value, int element );
	Element( int element );
	
	bool constraint_concept( const vector<int>& var, int start, int end ) const override;
	bool constraint_concept( const vector<Variable*>& var ) const override;
};
