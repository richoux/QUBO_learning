#pragma once

#include <vector>

#include <ghost/variable.hpp>
#include <ghost/constraint.hpp>

using namespace std;
using namespace ghost;

class UniqueValue : public Constraint
{
	mutable int _number_1;
	mutable int _number_2;
	
	double required_error( const vector<Variable*>& variables ) const override;
	double optional_delta_error( const std::vector<Variable*> &variables, const std::vector<int> &indexes, const std::vector<int> &candidate_values ) const override;

public:
	UniqueValue( const vector<int>& variables );
	UniqueValue( vector<int>&& variables );
};
