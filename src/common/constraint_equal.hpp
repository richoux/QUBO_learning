#pragma once

#include <vector>

#include <ghost/variable.hpp>
#include <ghost/constraint.hpp>

using ghost::Variable;
using ghost::Constraint;

class Equal : public Constraint
{
	double required_error( const std::vector<Variable*>& variables ) const override;
	// double optional_delta_error( const std::std::vector<Variable*> &variables, const std::std::vector<int> &indexes, const std::std::vector<int> &candidate_values ) const override;

public:
	Equal( const std::vector<int>& variables );
	Equal( std::vector<int>&& variables );
};
