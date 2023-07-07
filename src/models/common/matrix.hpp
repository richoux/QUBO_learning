#pragma once

#include <Eigen/Dense>

Eigen::VectorXi fill_vector( const std::vector<int>& candidate, size_t domain_size, int starting_value );
Eigen::MatrixXi fill_matrix( const std::vector<int>& variables, size_t candidate_length, size_t domain_size, int starting_value, int parameter );
Eigen::MatrixXd fill_matrix_reals( const std::vector<double>& variables, size_t candidate_length, size_t domain_size, int starting_value, int parameter );
