#pragma once

#include <vector>

#include <ghost/variable.hpp>
#include <ghost/constraint.hpp>

using namespace std;
using namespace ghost;

class UniqueValue : public Constraint
{
	double required_error( const vector<Variable*>& variables ) const override;

public:
	UniqueValue( const vector<int>& variables );
	UniqueValue( vector<int>&& variables );
};
