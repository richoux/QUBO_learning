#pragma once

#include <memory>
#include <ghost/model_builder.hpp>

using namespace ghost;
using namespace std;

class BuilderQUBO : public ModelBuilder
{
	std::vector<int> _training_data;
	size_t _size_training_set;
	size_t _domain_size;
	size_t _candidate_length;
	int _matrix_side;
	int _starting_value;
	std::vector<double> _error_vector;
	int _parameter;
	
public:
	BuilderQUBO( const std::vector<int>& training_data,
	             size_t number_samples,
	             size_t number_variables,
	             size_t domain_size,
	             int starting_value,
	             const std::vector<double>& error_vector,
	             bool complementary_variable,
	             int parameter );
	
	void declare_variables() override;
	void declare_constraints() override;
};
