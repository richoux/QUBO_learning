#pragma once

#include <vector>

#include <ghost/variable.hpp>
#include <ghost/constraint.hpp>

using namespace std;
using namespace ghost;

class TrainingSet : public Constraint
{
	std::vector<int> _training_data;
	mutable std::vector<int> _variable_values;
	// mutable std::vector<int> _variable_values_for_delta;
	size_t _size_training_set;
	size_t _domain_size;
	size_t _candidate_length;
	int _starting_value; // to know if the domain of true variables starts from 0, 1 or another value.
	                     // Then we consider that other values in the domain are all natural numbers
	                     // from starting_value to starting_value + domain_size.
	std::vector<double> _error_vector;
	int _parameter;
	
	double compute_error( const std::vector<int>& variable_values ) const;
	double required_error( const vector<Variable*>& variables ) const override;
	// double optional_delta_error( const std::vector<Variable*> &variables, const std::vector<int> &indexes, const std::vector<int> &candidate_values ) const override;

public:
	TrainingSet( const vector<Variable>& variables,
	             const std::vector<int>& training_data,
	             size_t number_samples,
	             size_t number_variables,
	             size_t domain_size,
	             int starting_value,
	             const std::vector<double>& error_vector,
	             int parameter );
};
