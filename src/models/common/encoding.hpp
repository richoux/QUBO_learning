#pragma once

#include <Eigen/Dense>

class Encoding
{
public:
	virtual std::string name();
	virtual int number_triangle_patterns() = 0;
	virtual int number_square_patterns() = 0;

	virtual Eigen::VectorXi fill_vector( const std::vector<int>& candidate,
	                                     size_t domain_size,
	                                     int starting_value,
	                                     int additional_variable = 0 ) = 0;
	
	virtual Eigen::VectorXd fill_vector_reals( const std::vector<int>& candidate,
	                                           size_t domain_size,
	                                           int starting_value,
	                                           int additional_variable = 0 ) = 0;
	
	virtual Eigen::MatrixXi fill_matrix( const std::vector<int>& variables,
	                                     size_t candidate_length,
	                                     size_t domain_size,
	                                     int starting_value,
	                                     int parameter ) = 0;
	
	virtual Eigen::MatrixXd fill_matrix_reals( const std::vector<double>& variables,
	                                           size_t candidate_length,
	                                           size_t domain_size,
	                                           int starting_value,
	                                           int parameter ) = 0;

	
	Eigen::VectorXi fill_vector_from_samples( const std::vector<int>& samples,
	                                          size_t index_sample,
	                                          size_t number_variables,
	                                          size_t domain_size,
	                                          int starting_value,
	                                          int additional_variable	);

	Eigen::VectorXd fill_vector_reals_from_samples( const std::vector<int>& samples,
	                                                size_t index_sample,
	                                                size_t number_variables,
	                                                size_t domain_size,
	                                                int starting_value,
	                                                int additional_variable	);
};
