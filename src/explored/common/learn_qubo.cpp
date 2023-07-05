#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>
#include <string>

#include <vector>
#include <algorithm>
#include <cmath>
#include <chrono>
#include <limits>

#include <ghost/solver.hpp>
#include <argh.h>
#include <randutils.hpp>
#include <Eigen/Dense>

#include "matrix.hpp"
#include "print_qubo.hpp"
#if defined SVN
#include "builder_svn.hpp"
#elif defined SPARSE
#include "builder_sparse.hpp"
#elif defined SCAM
#include "builder_scam.hpp"
#elif defined PREF
#include "builder_force_preference.hpp"
#elif defined BLOCK
#include "builder_block.hpp"
#else
#include "builder_force_pattern.hpp"
#endif

#define BLOCK_MODEL_SIZE 15 // directly linked to the number of patterns

using namespace ghost;
using namespace std::literals::chrono_literals;

void usage( char **argv )
{
	cout << "Usage examples:\n" << argv[0] << " -f TRAINING_DATAFILE [-t TIME_BUDGET] [-s PERCENT] [-p]\n"
	     << argv[0] << " -f TRAINING_DATAFILE -w NUMBER_LEARNERS -n NUMBER_SAMPLES -r RESULT_FILE\n"
	     << argv[0] << " -f TEST_DATAFILE -c [RESULT_FILE]\n"
	     << "\nArguments:\n"
	     << "-h, --help, printing this message.\n"
	     << "-f, --file DATAFILE.\n"
	     << "-c, --check [RESULT_FILE], to compute xt.Q.x results if a file is provided containing either Q or the solution produced by GHOST, or to display all xt.Q.x results after the learning of Q if no files are given.\n"
	     << "-r, --result RESULT_FILE, to write the solution in RESULT_FILE\n"
	     << "-m, --matrix RESULT_FILE, to write the learned Q matrix in RESULT_FILE\n"
	     << "-t, --timeout TIME_BUDGET, in seconds (1 by default)\n"
	     << "-b, --benchmark, to limit prints.\n"
	     << "-ps, --percent PERCENT [--force_positive], to sample candidates from PERCENT of the training set (100 by default). --force_positive forces considering all positive candidates.\n"
	     << "-n, --number NUMBER_SAMPLES, to sample NUMBER_SAMPLES candidates from the training set (the full set by default). Samples here are such that we got NUMBER_SAMPLES/2 positive and NUMBER_SAMPLES/2 negative candidates.\n"
	     << "-p, --parallel, to make parallel search\n"
	     << "-d, --debug, to print additional information\n"
	     << "--complementary, to force one complementary variable\n";
}

void check_solution_block( const std::vector<int>& solution,
                           const std::vector<int>& samples,
                           const std::vector<double>& labels,
                           size_t number_variables,
                           size_t domain_size,
                           size_t number_samples,
                           int starting_value,
                           bool complementary_variable,
                           bool silent,
                           string result_file_path,
                           string matrix_file_path,
                           int parameter,
                           bool full_check = false )
{
	if( silent )
		full_check = false;

	size_t matrix_side = number_variables * domain_size;
	if( complementary_variable )
		++matrix_side;
	
	Eigen::MatrixXi Q = fill_matrix( solution, number_variables, domain_size, starting_value, parameter );
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
		          << "\n\nMin scalar = " << min_scalar << "\n"
		          << "Number of errors: " << errors << "\n\n";

	if( matrix_file_path != "" )
	{
		if( !silent )
			std::cout << "Matrix file: " << matrix_file_path << "\n";
		ofstream matrix_file;
		matrix_file.open( matrix_file_path );
		std::streambuf *coutbuf = std::cout.rdbuf();
		std::cout.rdbuf( matrix_file.rdbuf() );
		std::cout << "Matrix\n";
		std::cout << Q << "\n";
		std::cout.rdbuf( coutbuf );
		matrix_file.close();
	}

	if( result_file_path != "" )
	{
		if( !silent )
			std::cout << "Result file: " << result_file_path << "\n";
		ofstream result_file;
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
                     string result_file_path,
                     string matrix_file_path,
                     int parameter,
                     bool full_check = false )
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
		ofstream matrix_file;
		matrix_file.open( matrix_file_path );
		std::streambuf *coutbuf = std::cout.rdbuf();
		std::cout.rdbuf( matrix_file.rdbuf() );
		std::cout << "Matrix\n";
		std::cout << Q << "\n";
		std::cout.rdbuf( coutbuf );
		matrix_file.close();
	}
}

int main( int argc, char **argv )
{
	size_t number_variables;
	size_t domain_size;
	int starting_value;
	int parameter = std::numeric_limits<int>::max();
	int time_budget;
	int percent_training_set;
	
	string training_data_file_path;
	string result_file_path;
	string matrix_file_path;
	string check_file_path;
	string line, string_number;
	ifstream training_data_file;
	ifstream check_file;

	size_t number_samples = 0;
	int number_remains_to_sample = 0;
	size_t total_training_set_size = 0;
	vector<int> candidates;
	vector<int> samples;
	vector<double> labels;
	vector<double> sampled_labels;

	bool parallel;
	bool debug;
	bool complementary_variable;
	bool force_positive;
	bool silent;

	vector<int> solution;

	randutils::mt19937_rng rng;
	argh::parser cmdl( { "-f", "--file", "-t", "--timeout", "-ps", "--percent", "-c", "--check", "-r", "--result", "-m", "--matrix" } );
	cmdl.parse( argc, argv );
	
	if( cmdl[ {"-h", "--help"} ] )
	{
		usage( argv );
		return EXIT_SUCCESS;
	}

	if( !( cmdl( {"f", "file"} ) ) )
	{
		usage( argv );
		return EXIT_FAILURE;
	}

	cmdl( {"f", "file"} ) >> training_data_file_path;
	cmdl( {"r", "result"}, "" ) >> result_file_path;
	cmdl( {"c", "check"}, "" ) >> check_file_path;
	cmdl( {"m", "matrix"}, "" ) >> matrix_file_path;
	cmdl( {"t", "timeout"}, 1 ) >> time_budget;
	cmdl( {"ps", "percent"}, 100 ) >> percent_training_set;
	time_budget *= 1000000; // GHOST needs microseconds
	cmdl[ {"-p", "--parallel"} ] ? parallel = true : parallel = false;
	cmdl[ {"-d", "--debug"} ] ? debug = true : debug = false;
	cmdl[ {"-b", "--benchmark"} ] ? silent = true : silent = false;
	cmdl[ {"--complementary"} ] ? complementary_variable = true : complementary_variable = false;
	cmdl[ {"--force_positive"} ] ? force_positive = true : force_positive = false;
	
	training_data_file.open( training_data_file_path );
	int value;
	double error;

	getline( training_data_file, line );
	stringstream line_stream( line );
	line_stream >> number_variables >> domain_size >> starting_value >> parameter;
				
	while( getline( training_data_file, line ) )
	{
		++total_training_set_size;
		auto delimiter = line.find(" : ");
		std::string label = line.substr( 0, delimiter );
		stringstream label_stream( label );
		label_stream >> error;
		labels.push_back( error );
		line.erase( 0, delimiter + 3 );
		stringstream line_stream( line );
		while( line_stream >> string_number )
		{
			stringstream number_stream( string_number );
			number_stream >> value;
			candidates.push_back( value );
		}

		if( complementary_variable )
			candidates.push_back( 1 );
	}

	training_data_file.close();
	number_samples = static_cast<int>( ( total_training_set_size * percent_training_set ) / 100 );

	if( check_file_path != "" )
	{
		check_file.open( check_file_path );
		
		size_t matrix_side = number_variables * domain_size;
		if( complementary_variable )
			++matrix_side;
		Eigen::MatrixXi Q = Eigen::MatrixXi::Zero( matrix_side, matrix_side );
		vector<int> q_matrix;

		getline( check_file, line );
		if( line == "Matrix" )
		{
			int row = 0;
			while( getline( check_file, line ) )
			{
				int count = 0;
				stringstream line_stream( line );
				while( line_stream >> string_number )
				{
					++count;
					if( count < row + 1 )
						continue;
					stringstream number_stream( string_number );
					number_stream >> value;
					q_matrix.push_back( value );
				}
				++row;
			}
				
			for( size_t length = matrix_side ; length > 0 ; --length )
			{
				int row_number = matrix_side - length;
				
				int shift = row_number * ( row_number - 1 ) / 2;
				
				for( int i = 0 ; i < length ; ++i )
					Q( row_number, row_number + i ) = q_matrix[ ( row_number * matrix_side ) - shift + i ];
			}
		}
		else
		{
			getline( check_file, line );
			stringstream line_stream( line );

			solution.reserve( BLOCK_MODEL_SIZE );
			for( int i = 0 ; i < BLOCK_MODEL_SIZE; ++i )
				line_stream >> solution[i];
			
			Q = fill_matrix( solution, number_variables, domain_size, starting_value, parameter );
		}
		
		check_file.close();

		check_solution( Q,
		                candidates,
		                labels,
		                number_variables,
		                domain_size,
		                total_training_set_size,
		                starting_value,
		                complementary_variable,
		                silent,
		                "",
		                "",
		                parameter,
		                false );
	}
	else
	{
		int additional_variable = 0;
		if( complementary_variable )
			additional_variable = 1;

		if( percent_training_set < 100 )
		{
			std::vector<int> indexes( total_training_set_size );
			std::iota( indexes.begin(), indexes.end(), 0 );
				
			if( debug )
				std::cout << "List of sampled candidates:\n";

			int number_positive_candidates = 0;

			if( force_positive )
				for( int i = total_training_set_size - 1 ; i >= 0 ; --i )
					if( labels[ i ] == 0 )
					{
						std::copy_n( candidates.begin() + ( i * ( number_variables + additional_variable ) ), number_variables + additional_variable, std::back_inserter( samples ) );
						sampled_labels.push_back( 0 );
						++number_positive_candidates;
						indexes.erase( indexes.begin() + i );
						if( debug )
						{
							std::copy_n( candidates.begin() + ( i * ( number_variables + additional_variable ) ), number_variables + additional_variable, std::ostream_iterator<int>( std::cout, " " ) );
							std::cout << ": " << labels[ i ] << "\n";
						}
					}

			number_remains_to_sample = number_samples - number_positive_candidates;
				
			if( number_remains_to_sample < 0 )
				std::cerr << "Warning: the sample rate is too low regarding the number of positive candidates for this constraint.\n";
				
			rng.shuffle( indexes );

			for( int i = 0 ; i < number_remains_to_sample ; ++i )
			{
				std::copy_n( candidates.begin() + ( indexes[ i ] * ( number_variables + additional_variable ) ), number_variables + additional_variable, std::back_inserter( samples ) );
				sampled_labels.push_back( labels[ indexes[ i ] ] );
				if( debug )
				{
					std::copy_n( candidates.begin() + ( indexes[ i ] * ( number_variables + additional_variable ) ), number_variables + additional_variable, std::ostream_iterator<int>( std::cout, " " ) );
					std::cout << ": " << labels[ indexes[ i ] ] << "\n";
				}						
			}

			if( debug )
			{
				std::cout << "List of NON-SAMPLED candidates:\n";
				for( int i = number_samples - number_positive_candidates; i < total_training_set_size - number_positive_candidates ; ++i )
				{
					std::copy_n( candidates.begin() + ( indexes[ i ] * ( number_variables + additional_variable ) ), number_variables + additional_variable, std::ostream_iterator<int>( std::cout, " " ) );
					std::cout << ": " << labels[ indexes[ i ] ] << "\n";
				}
			}
		}
		else
		{
			samples.resize( total_training_set_size * ( number_variables + additional_variable ) );
			std::copy( candidates.begin(), candidates.end(), samples.begin() );

			sampled_labels.resize( total_training_set_size );
			std::copy( labels.begin(), labels.end(), sampled_labels.begin() );
		}

		if( debug )
		{
			std::cout << "Number vars: " << number_variables + additional_variable
			          << ", Domain: " << domain_size
			          << ", Number samples: " << number_samples
			          << ", Training set size: " << total_training_set_size
			          << ", Starting value: " << starting_value
			          << "\nParallel run: " << std::boolalpha << parallel << "\n";
		}
			
		BuilderQUBO builder( samples, number_samples, number_variables, domain_size, starting_value, sampled_labels, complementary_variable, parameter );
		Solver solver( builder );

		double cost;
		bool solved = true;
		Options options;
#if not defined BLOCK and not defined BLOCK_SAT and not defined BLOCK_OPT
		options.print = make_shared<PrintQUBO>( number_variables * domain_size );
#endif
		if( parallel )
			options.parallel_runs = true;
			
		solved = solver.solve( cost, solution, time_budget, options );		

		if( !silent )
		{
			std::cout << "\nConstraints satisfied: " << std::boolalpha << solved << "\n"
			          << "Objective function cost: " << cost << "\n";
		}
		
		bool check = false;
		if( cmdl[ {"c", "check"} ] && check_file_path == "" )
			check = true;

#if defined BLOCK or defined BLOCK_SAT or defined BLOCK_OPT
		check_solution_block( solution,
		                      candidates,
		                      labels,
		                      number_variables,
		                      domain_size,
		                      total_training_set_size,
		                      starting_value,
		                      complementary_variable,
		                      silent,
		                      result_file_path,
		                      matrix_file_path,
		                      parameter,
		                      check );
#else
		size_t matrix_side = number_variables * domain_size;
		if( complementary_variable )
			++matrix_side;
		
		Eigen::MatrixXi Q = Eigen::MatrixXi::Zero( matrix_side, matrix_side );
		
		for( size_t length = matrix_side ; length > 0 ; --length )
		{
			int row_number = matrix_side - length;
			
			int shift = row_number * ( row_number - 1 ) / 2;
			
			for( int i = 0 ; i < length ; ++i )
				Q( row_number, row_number + i ) = solution[ ( row_number * matrix_side ) - shift + i ];
		}
		
		check_solution( Q,
		                candidates,
		                labels,
		                number_variables,
		                domain_size,
		                total_training_set_size,
		                starting_value,
		                complementary_variable,
		                silent,
		                result_file_path,
		                matrix_file_path,
		                parameter,
		                check );
#endif
	}

	return EXIT_SUCCESS;
}

