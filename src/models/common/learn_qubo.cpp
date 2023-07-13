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
#include "checks.hpp"
#include "print_qubo.hpp"

#if defined BLOCK_SAT
#include "builder_block_sat.hpp"
#else
#include "builder_block_opt.hpp"
#endif

#define BLOCK_MODEL_SIZE 15 // directly linked to the number of patterns

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
	     << "-s, --samestart, to force weak learners to start from the same point in the search space\n"
	     << "-d, --debug, to print additional information\n"
	     << "--complementary, to force one complementary variable\n";
}

int main( int argc, char **argv )
{
	size_t number_variables;
	size_t domain_size;
	int starting_value;
	int parameter = std::numeric_limits<int>::max();
	int time_budget;
	int percent_training_set;
	
	std::string training_data_file_path;
	std::string result_file_path;
	std::string matrix_file_path;
	std::string check_file_path;
	std::string line, string_number;
	std::ifstream training_data_file;
	std::ifstream check_file;

	bool custom_number_samples = false;
	bool custom_starting_point;
	size_t number_samples = 0;
	int number_remains_to_sample = 0;
	size_t total_training_set_size = 0;
	std::vector<int> candidates;
	std::vector<int> samples;
	std::vector<double> labels;
	std::vector<double> sampled_labels;

	bool debug;
	bool complementary_variable;
	bool force_positive;
	bool silent;

	std::vector<int> solution;

	randutils::mt19937_rng rng;
	argh::parser cmdl( { "-f", "--file", "-t", "--timeout", "-n", "--number", "-ps", "--percent", "-c", "--check", "-r", "--result", "-m", "--matrix" } );
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

	if( cmdl( {"n", "number"} ) && cmdl( {"ps", "percent"} ) )
	{
		std::cout << "Invalid arguments: -n/--number and -ps/--percent are mutually exclusive.\n";
		usage( argv );
		return EXIT_FAILURE;
	}

	if( cmdl( {"n", "number"} ) )
	{
		custom_number_samples = true;
	}
	
	cmdl( {"f", "file"} ) >> training_data_file_path;
	cmdl( {"r", "result"}, "" ) >> result_file_path;
	cmdl( {"c", "check"}, "" ) >> check_file_path;
	cmdl( {"m", "matrix"}, "" ) >> matrix_file_path;
	cmdl( {"t", "timeout"}, 1 ) >> time_budget;
	cmdl( {"n", "number"} ) >> number_samples;
	cmdl( {"ps", "percent"}, 100 ) >> percent_training_set;
	time_budget *= 1000000; // GHOST needs microseconds
	cmdl[ {"-s", "--samestart"} ] ? custom_starting_point = true : custom_starting_point = false;
	cmdl[ {"-d", "--debug"} ] ? debug = true : debug = false;
	cmdl[ {"-b", "--benchmark"} ] ? silent = true : silent = false;
	cmdl[ {"--complementary"} ] ? complementary_variable = true : complementary_variable = false;
	cmdl[ {"--force_positive"} ] ? force_positive = true : force_positive = false;
	
	training_data_file.open( training_data_file_path );
	int value;
	double error;

	getline( training_data_file, line );
	std::stringstream line_stream( line );
	line_stream >> number_variables >> domain_size >> starting_value >> parameter;
				
	while( getline( training_data_file, line ) )
	{
		++total_training_set_size;
		auto delimiter = line.find(" : ");
		std::string label = line.substr( 0, delimiter );
		std::stringstream label_stream( label );
		label_stream >> error;
		labels.push_back( error );
		line.erase( 0, delimiter + 3 );
		std::stringstream line_stream( line );
		while( line_stream >> string_number )
		{
			std::stringstream number_stream( string_number );
			number_stream >> value;
			candidates.push_back( value );
		}

		if( complementary_variable )
			candidates.push_back( 1 );
	}

	training_data_file.close();
	if( !custom_number_samples )
		number_samples = static_cast<int>( ( total_training_set_size * percent_training_set ) / 100 );

	if( check_file_path != "" )
	{
		check_file.open( check_file_path );
		
		size_t matrix_side = number_variables * domain_size;
		if( complementary_variable )
			++matrix_side;
		Eigen::MatrixXi Q = Eigen::MatrixXi::Zero( matrix_side, matrix_side );
		std::vector<int> q_matrix;

		getline( check_file, line );
		if( line == "Matrix" )
		{
			int row = 0;
			while( getline( check_file, line ) )
			{
				int count = 0;
				std::stringstream line_stream( line );
				while( line_stream >> string_number )
				{
					++count;
					if( count < row + 1 )
						continue;
					std::stringstream number_stream( string_number );
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
			std::stringstream line_stream( line );

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
				std::cout << "Sampling " << percent_training_set << "% of the training set\n"
				          << "List of sampled candidates:\n";

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
			if( custom_number_samples )
			{
				if( debug )
					std::cout << "Sampling " << number_samples << " candidates for the training set\n"
					          << "List of sampled candidates:\n";
										
				std::vector<int> indexes( total_training_set_size );
				std::iota( indexes.begin(), indexes.end(), 0 );
				int number_positive = static_cast<int>( std::ceil( static_cast<double>( number_samples ) / 2 ) );
				int number_negative = static_cast<int>( std::floor( static_cast<double>( number_samples ) / 2 ) );
				
				rng.shuffle( indexes );
				
				int i = 0;
				int count_positive = 0;
				int count_negative = 0;
				
				while( count_positive < number_positive || count_negative < number_negative )
				{
					if( labels[ indexes[i] ] == 0 && count_positive < number_positive ) // if candidate[i] is positive and we still need some
					{
						std::copy_n( candidates.begin() + ( indexes[i] * ( number_variables + additional_variable ) ), number_variables + additional_variable, std::back_inserter( samples ) );
						sampled_labels.push_back( 0 );
						++count_positive;
					}
					
					if( labels[ indexes[i] ] == 1 && count_negative < number_negative ) // if candidate[i] is negative and we still need some
					{
						std::copy_n( candidates.begin() + ( indexes[i] * ( number_variables + additional_variable ) ), number_variables + additional_variable, std::back_inserter( samples ) );
						sampled_labels.push_back( 1 );
						++count_negative;
					}
					
					++i;
				}

				if( debug )
				{
					for( int i = 0 ; i < number_samples ; ++i )
					{
						std::copy_n( samples.begin() + ( i * ( number_variables + additional_variable ) ), number_variables + additional_variable, std::ostream_iterator<int>( std::cout, " " ) );
						std::cout << ": " << sampled_labels[ i ] << "\n";
					}
					std::cout << "\n";
				}
			}
			else
			{			
				samples.resize( total_training_set_size * ( number_variables + additional_variable ) );
				std::copy( candidates.begin(), candidates.end(), samples.begin() );
				
				sampled_labels.resize( total_training_set_size );
				std::copy( labels.begin(), labels.end(), sampled_labels.begin() );
			}
		}

		if( debug )
		{
			std::cout << "Number vars: " << number_variables + additional_variable
			          << ", Domain: " << domain_size
			          << ", Number samples: " << number_samples
			          << ", Training set size: " << total_training_set_size
			          << ", Starting value: " << starting_value
			          << ", Same starting point: " << std::boolalpha << custom_starting_point << "\n";
		}
			
		BuilderQUBO builder( samples, number_samples, number_variables, domain_size, starting_value, sampled_labels, complementary_variable, parameter );
		ghost::Solver solver( builder );

		double cost;
		bool solved = true;
		ghost::Options options;
#if not defined BLOCK and not defined BLOCK_SAT and not defined BLOCK_OPT
		options.print = make_shared<PrintQUBO>( number_variables * domain_size );
#endif

		options.custom_starting_point = custom_starting_point; 

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
		                matrix_file_path,
		                parameter,
		                check );
#endif
	}

	return EXIT_SUCCESS;
}

