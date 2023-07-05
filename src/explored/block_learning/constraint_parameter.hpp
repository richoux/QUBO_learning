#pragma once

#include <vector>

#include <ghost/variable.hpp>
#include <ghost/constraint.hpp>

using namespace std;
using namespace ghost;

class ParameterManagement : public Constraint
{
	int _parameter;
	
	double required_error( const vector<Variable*>& variables ) const override;

public:
	ParameterManagement( const vector<int>& variables_index,
	                     int parameter );
};
