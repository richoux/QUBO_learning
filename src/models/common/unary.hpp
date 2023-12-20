#pragma once

#include "encoding.hpp"

class Unary : public Encoding
{
public:
	std::string name() override;
	int number_triangle_patterns() override;
	int number_square_patterns() override;

	Eigen::VectorXi fill_vector( const std::vector<int>& candidate,
	                             size_t domain_size,
	                             int starting_value,
	                             int additional_variable = 0 )	override;
	
	Eigen::VectorXd fill_vector_reals( const std::vector<int>& candidate,
	                                   size_t domain_size,
	                                   int starting_value,
	                                   int additional_variable = 0 )	override;
	
	Eigen::MatrixXi fill_matrix( const std::vector<int>& variables,
	                             size_t candidate_length,
	                             size_t domain_size,
	                             int starting_value,
	                             int parameter )	override;
	
	Eigen::MatrixXd fill_matrix_reals( const std::vector<double>& variables,
	                                   size_t candidate_length,
	                                   size_t domain_size,
	                                   int starting_value,
	                                   int parameter )	override;
};
