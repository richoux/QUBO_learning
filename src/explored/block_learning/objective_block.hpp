#pragma once

#include <string>
#include <vector>
#include <memory>

#include <ghost/objective.hpp>
#include <ghost/variable.hpp>
#include <Eigen/Dense>

using namespace std;
using namespace ghost;

class ObjectiveBlock : public Minimize
{
	std::vector<int> _training_data;
	size_t _size_training_set;
	size_t _domain_size;
	size_t _candidate_length;
	int _starting_value; // to know if the domain of true variables starts from 0, 1 or another value.
	                     // Then we consider that other values in the domain are all natural numbers
	                     // from starting_value to starting_value + domain_size.
	std::vector<double> _error_vector;
	int _parameter;

  double required_cost( const vector<Variable*>& vecVariables ) const override;
	Eigen::VectorXi fill_vector( const std::vector<int>& candidate ) const;
	Eigen::MatrixXi fill_matrix( const vector<Variable*>& vecVariables ) const;
	
public:
	ObjectiveBlock( const vector<Variable>& variables,
	                const std::vector<int>& training_data,
	                size_t number_samples,
	                size_t number_variables,
	                size_t domain_size,
	                int starting_value,
	                const std::vector<double>& error_vector,
	                int parameter );
};
