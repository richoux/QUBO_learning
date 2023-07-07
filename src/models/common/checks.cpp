#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>

#include "checks.hpp"
#include "matrix.hpp"

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
                           bool full_check )
{
	Eigen::MatrixXi Q = fill_matrix( solution, number_variables, domain_size, starting_value, parameter );
		
	check_solution( Q,
	                samples,
	                labels,
	                number_variables,
	                domain_size,
	                number_samples,
	                starting_value,
	                complementary_variable,
	                silent,
	                matrix_file_path,
	                parameter,
	                full_check );
	
	if( result_file_path != "" )
	{
		if( !silent )
			std::cout << "Result file: " << result_file_path << "\n";
		std::ofstream result_file;
		result_file.open( result_file_path );
		result_file << "Solution\n";
		for( int value : solution )
			result_file << value << " ";
		result_file << "\n";
		result_file.close();
	}
}

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
                     bool full_check )
{
	if( silent )
		full_check = false;
		
	size_t matrix_side = number_variables * domain_size;
	if( complementary_variable )
		++matrix_side;
	
	int errors = 0;
	int min_scalar = std::numeric_limits<int>::max();
	std::vector<int> scalars( number_samples );

	int additional_variable = 0;
	if( complementary_variable )
		additional_variable = 1;

	for( size_t index_sample = 0 ; index_sample < number_samples ; ++index_sample )
	{
		Eigen::VectorXi X = Eigen::VectorXi::Zero( matrix_side );
		
		for( size_t index_var = 0 ; index_var < number_variables ; ++index_var )
			X( index_var * domain_size + ( samples[ index_sample * ( number_variables + additional_variable ) + index_var ] - starting_value ) ) = 1;

		if( complementary_variable )
			X( matrix_side - 1 ) = 1;
		
		scalars[ index_sample ] = ( X.transpose() * Q ) * X;
		if( min_scalar > scalars[ index_sample ]	)
			min_scalar = scalars[ index_sample ];		
	}

	for( size_t index_sample = 0 ; index_sample < number_samples ; ++index_sample )
	{
		std::string candidate = "[";
		for( size_t index_var = 0 ; index_var < number_variables + additional_variable ; ++index_var )
		{
			if( index_var > 0 )
				candidate += " ";
			candidate += std::to_string( samples[ index_sample * ( number_variables + additional_variable ) + index_var ] );
		}

		candidate += "]";
		
		if( labels[ index_sample ] == 0 )
		{
			if( scalars[ index_sample ] != min_scalar )
			{
				++errors;
				if( !silent )
					std::cout << "/!\\ Candidate " << candidate << " is a solution but has not a minimal scalar: " << std::setw( 3 ) << scalars[ index_sample ] << "\n";
			}
			else
				if( full_check )
					std::cout << "Candidate " << candidate << " (solution): " << std::setw( 3 ) << scalars[ index_sample ] << "\n";
		}
		else
			if( scalars[ index_sample ] == min_scalar )
			{
				++errors;
				if( !silent )
					std::cout << "/!\\ Candidate " << candidate << " is not a solution but has the minimal scalar " << std::setw( 3 ) << min_scalar << "\n";
			}
			else
				if( full_check )
					std::cout << "Candidate " << candidate << ": " << std::setw( 3 ) << scalars[ index_sample ] << "\n";
	}

	if( !silent )
		std::cout << "\nQ matrix:\n" << Q
		          << "\n\nMin scalar = " << min_scalar << "\n";
	std::cout << "Number of errors: " << errors << "\n\n";

	if( matrix_file_path != "" )
	{
		if( !silent )
			std::cout << "Matrix file: " << matrix_file_path << "\n";
		std::ofstream matrix_file;
		matrix_file.open( matrix_file_path );
		std::streambuf *coutbuf = std::cout.rdbuf();
		std::cout.rdbuf( matrix_file.rdbuf() );
		std::cout << "Matrix\n";
		std::cout << Q << "\n";
		std::cout.rdbuf( coutbuf );
		matrix_file.close();
	}
}

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
                                 bool full_check )
{
	Eigen::MatrixXd Q = fill_matrix_reals( solution, number_variables, domain_size, starting_value, parameter );
		
	check_solution_reals( Q,
	                      samples,
	                      labels,
	                      number_variables,
	                      domain_size,
	                      number_samples,
	                      starting_value,
	                      complementary_variable,
	                      silent,
	                      matrix_file_path,
	                      parameter,
	                      full_check );
	
	if( result_file_path != "" )
	{
		if( !silent )
			std::cout << "Result file: " << result_file_path << "\n";
		std::ofstream result_file;
		result_file.open( result_file_path );
		result_file << "Solution\n";
		for( double value : solution )
			result_file << value << " ";
		result_file << "\n";
		result_file.close();
	}
}

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
                           bool full_check )
{
	if( silent )
		full_check = false;
		
	size_t matrix_side = number_variables * domain_size;
	if( complementary_variable )
		++matrix_side;
	
	int errors = 0;
	double min_scalar = std::numeric_limits<double>::max();
	std::vector<double> scalars( number_samples );

	int additional_variable = 0;
	if( complementary_variable )
		additional_variable = 1;

	for( size_t index_sample = 0 ; index_sample < number_samples ; ++index_sample )
	{
		Eigen::VectorXi X = Eigen::VectorXi::Zero( matrix_side );
		
		for( size_t index_var = 0 ; index_var < number_variables ; ++index_var )
			X( index_var * domain_size + ( samples[ index_sample * ( number_variables + additional_variable ) + index_var ] - starting_value ) ) = 1;

		if( complementary_variable )
			X( matrix_side - 1 ) = 1;
		
		scalars[ index_sample ] = ( X.transpose() * Q ) * X;
		if( min_scalar > scalars[ index_sample ]	)
			min_scalar = scalars[ index_sample ];		
	}

	for( size_t index_sample = 0 ; index_sample < number_samples ; ++index_sample )
	{
		std::string candidate = "[";
		for( size_t index_var = 0 ; index_var < number_variables + additional_variable ; ++index_var )
		{
			if( index_var > 0 )
				candidate += " ";
			candidate += std::to_string( samples[ index_sample * ( number_variables + additional_variable ) + index_var ] );
		}

		candidate += "]";
		
		if( labels[ index_sample ] == 0 )
		{
			if( scalars[ index_sample ] != min_scalar )
			{
				++errors;
				if( !silent )
					std::cout << "/!\\ Candidate " << candidate << " is a solution but has not a minimal scalar: " << std::setw( 3 ) << scalars[ index_sample ] << "\n";
			}
			else
				if( full_check )
					std::cout << "Candidate " << candidate << " (solution): " << std::setw( 3 ) << scalars[ index_sample ] << "\n";
		}
		else
			if( scalars[ index_sample ] == min_scalar )
			{
				++errors;
				if( !silent )
					std::cout << "/!\\ Candidate " << candidate << " is not a solution but has the minimal scalar " << std::setw( 3 ) << min_scalar << "\n";
			}
			else
				if( full_check )
					std::cout << "Candidate " << candidate << ": " << std::setw( 3 ) << scalars[ index_sample ] << "\n";
	}

	if( !silent )
		std::cout << "\nQ matrix:\n" << Q
		          << "\n\nMin scalar = " << min_scalar << "\n";
	std::cout << "Number of errors: " << errors << "\n\n";

	if( matrix_file_path != "" )
	{
		if( !silent )
			std::cout << "Matrix file: " << matrix_file_path << "\n";
		std::ofstream matrix_file;
		matrix_file.open( matrix_file_path );
		std::streambuf *coutbuf = std::cout.rdbuf();
		std::cout.rdbuf( matrix_file.rdbuf() );
		std::cout << "Matrix\n";
		std::cout << Q << "\n";
		std::cout.rdbuf( coutbuf );
		matrix_file.close();
	}
}
