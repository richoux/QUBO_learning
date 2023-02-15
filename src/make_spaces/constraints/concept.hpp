#pragma once

#include <vector>

#include <ghost/variable.hpp>

using namespace std;
using namespace ghost;

class Concept
{
public:
	int nb_vars;
	int max_value;

	Concept( int nb_vars, int max_value );
	
	bool constraint_concept( const std::vector<int>& var ) const;
	virtual bool constraint_concept( const std::vector<int>& var, int start, int end ) const = 0;
};
