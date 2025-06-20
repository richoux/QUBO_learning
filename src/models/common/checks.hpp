#pragma once

#include <Eigen/Dense>
#include <vector>
#include <string>

#include "encoding.hpp"

void check_solution_block( const std::vector<int>& solution,
                           const std::vector<int>& samples,
                           const std::vector<double>& labels,
                           size_t number_variables,
                           size_t domain_size,
                           size_t number_samples,
                           int starting_value,
                           bool complementary_variable,
                           bool silent,
                           std::string result_file_path,
                           std::string matrix_file_path,
                           int parameter,
                           Encoding *encoding,
                           bool full_check = false,
                           std::string suffix = "" );

void check_solution( const Eigen::MatrixXi& Q,
                     const std::vector<int>& samples,
                     const std::vector<double>& labels,
                     size_t number_variables,
                     size_t domain_size,
                     size_t number_samples,
                     int starting_value,
                     bool complementary_variable,
                     bool silent,
                     std::string matrix_file_path,
                     int parameter,
                     Encoding *encoding,
                      bool full_check = false );

void check_solution_block_reals( const std::vector<double>& solution,
                                 const std::vector<int>& samples,
                                 const std::vector<double>& labels,
                                 size_t number_variables,
                                 size_t domain_size,
                                 size_t number_samples,
                                 int starting_value,
                                 bool complementary_variable,
                                 bool silent,
                                 std::string result_file_path,
                                 std::string matrix_file_path,
                                 int parameter,
                                 Encoding *encoding,
                                 bool full_check = false,
                                 std::string suffix = "" );

void check_solution_reals( const Eigen::MatrixXd& Q,
                           const std::vector<int>& samples,
                           const std::vector<double>& labels,
                           size_t number_variables,
                           size_t domain_size,
                           size_t number_samples,
                           int starting_value,
                           bool complementary_variable,
                           bool silent,
                           std::string matrix_file_path,
                           int parameter,
                           Encoding *encoding,
                           bool full_check = false );

