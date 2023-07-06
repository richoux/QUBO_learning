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
	cout << "Usage examples:\n" << argv[0] << " -f TRAINING_DATAFILE -w NUMBER_LEARNERS -r RESULT_FILE\n"
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
	     << "-n, --number NUMBER_SAMPLES, to sample NUMBER_SAMPLES random candidates from the training set. Samples here are such that we got NUMBER_SAMPLES/2 positive and NUMBER_SAMPLES/2 negative candidates.\n"
	     << "-p, --parallel, to make parallel search\n"
	     << "-w, --weak_learners NUMBER_LEARNERS, to learn NUMBER_LEARNERS Q matrices and merge them into an average matrix (disabled by default).\n"
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
	int weak_learners;
	
	std::string training_data_file_path;
	std::string result_file_path;
	std::string matrix_file_path;
	std::string check_file_path;
	std::string line, string_number;
	std::ifstream training_data_file;
	std::ifstream check_file;

	size_t number_samples = 0;
	bool custom_number_samples = false;
	int number_remains_to_sample = 0;
	size_t total_training_set_size = 0;
	std::vector<int> candidates;
	std::vector<int> samples;
	std::vector<double> labels;
	std::vector<double> sampled_labels;

	bool parallel;
	bool debug;
	bool complementary_variable;
	bool force_positive;
	bool silent;

	std::vector<int> solution;

	randutils::mt19937_rng rng;
	argh::parser cmdl( { "-f", "--file", "-t", "--timeout", "-n", "--number", "-c", "--check", "-w", "--weak_learners", "-r", "--result", "-m", "--matrix" } );
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

	if( ( cmdl( {"n", "number"} ) ) )
	{
		custom_number_samples = true;
	}
	
	cmdl( {"f", "file"} ) >> training_data_file_path;
	cmdl( {"r", "result"}, "" ) >> result_file_path;
	cmdl( {"c", "check"}, "" ) >> check_file_path;
	cmdl( {"m", "matrix"}, "" ) >> matrix_file_path;
	cmdl( {"t", "timeout"}, 1 ) >> time_budget;
	cmdl( {"n", "number"} ) >> number_samples;
	cmdl( {"w", "weak_learners"}, 1 ) >> weak_learners;
	time_budget *= 1000000; // GHOST needs microseconds
	cmdl[ {"-p", "--parallel"} ] ? parallel = true : parallel = false;
	cmdl[ {"-d", "--debug"} ] ? debug = true : debug = false;
	cmdl[ {"-b", "--benchmark"} ] ? silent = true : silent = false;
	cmdl[ {"--complementary"} ] ? complementary_variable = true : complementary_variable = false;
	cmdl[ {"--force_positive"} ] ? force_positive = true : force_positive = false;

	if( weak_learners <= 1 && !( cmdl( {"c", "check"} ) ))
	{
		std::cout << "You must assign at least 2 weak learners.\n";
		return EXIT_FAILURE;
	}
	
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
		number_samples = total_training_set_size;

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

		samples.resize( total_training_set_size * ( number_variables + additional_variable ) );
		std::copy( candidates.begin(), candidates.end(), samples.begin() );
		
		sampled_labels.resize( total_training_set_size );
		std::copy( labels.begin(), labels.end(), sampled_labels.begin() );
		
		if( debug )
		{
			std::cout << "Number vars: " << number_variables + additional_variable
			          << ", Domain: " << domain_size
			          << ", Number samples: " << number_samples
			          << ", Training set size: " << total_training_set_size
			          << ", Starting value: " << starting_value
			          << "\nParallel run: " << std::boolalpha << parallel << "\n"
			          << "Weak learners: " << weak_learners << "\n";
		}
			
		BuilderQUBO builder( samples, number_samples, number_variables, domain_size, starting_value, sampled_labels, complementary_variable, parameter );
		ghost::Solver solver( builder );

		double cost;
		bool solved = true;
		ghost::Options options;
#if not defined BLOCK and not defined BLOCK_SAT and not defined BLOCK_OPT
		options.print = make_shared<PrintQUBO>( number_variables * domain_size );
#endif
		if( parallel )
			options.parallel_runs = true;
			
		std::vector<std::vector<int>> solutions( weak_learners );
		double sum_cost = 0.;
		std::vector<int> indexes( total_training_set_size );
		std::iota( indexes.begin(), indexes.end(), 0 );
		int number_positive = std::ceil( number_samples / 2 );
		int number_negative = std::floor( number_samples / 2 );
		options.custom_starting_point = true; 
		
		for( int i = 0 ; i < weak_learners ; ++i )
		{
			if( custom_number_samples ) // sample a random, different sub-training set for each weak learner
			{
				std::vector<int> sub_samples;
				std::vector<double> sub_sampled_labels;
				
				rng.shuffle( indexes );
				
				int i = 0;
				int count_positive = 0;
				int count_negative = 0;
				
				while( count_positive < number_positive || count_negative < number_negative )
				{
					if( labels[ indexes[i] ] == 0 && count_positive < number_positive ) // if candidate[i] is positive and we still need some
					{
						std::copy_n( candidates.begin() + ( indexes[i] * ( number_variables + additional_variable ) ), number_variables + additional_variable, std::back_inserter( sub_samples ) );
						sub_sampled_labels.push_back( 0 );
						++count_positive;
					}
					
					if( labels[ indexes[i] ] == 1 && count_negative < number_negative ) // if candidate[i] is negative and we still need some
					{
						std::copy_n( candidates.begin() + ( indexes[i] * ( number_variables + additional_variable ) ), number_variables + additional_variable, std::back_inserter( sub_samples ) );
						sub_sampled_labels.push_back( 1 );
						++count_negative;
					}
					
					++i;
				}
				
				BuilderQUBO builder( sub_samples, number_samples, number_variables, domain_size, starting_value, sub_sampled_labels, complementary_variable, parameter );
				solver = Solver( builder );
			}
			
			solved = solved && solver.solve( cost, solutions[i], time_budget, options );
			sum_cost += cost;
		}

		for( int i = 0 ; i < weak_learners ; ++i )
		{
			std::cout << "Solution of weak learner " << i << ": ";
			std::copy( solutions[i].begin(), solutions[i].end(), std::ostream_iterator<int>( std::cout, " " ) );
			std::cout << "\n";
		}
		
		// mean solution
		std::vector<int> mean_solution( solutions[0].size(), 0 );
		for( auto& sol : solutions )
			std::transform( sol.cbegin(), sol.cend(), mean_solution.cbegin(), mean_solution.begin(), std::plus<>{} );

		std::transform( mean_solution.cbegin(), mean_solution.cend(), mean_solution.begin(), [&](auto s){ return static_cast<int>( std::round( s / weak_learners ) ); } );

		// majority solution
		std::vector<int> majority_solution( solutions[0].size(), 0 );
		int triangle_1 = 0;
		int triangle_2 = 0;
		int triangle_3 = 0;
		int sum_element;
			
		for( int i = 0 ; i < solutions[0].size() ; ++i )
		{
			sum_element = 0;
			for( int s = 0 ; s < weak_learners ; ++s )
			{
				if( i == 0 )
				{
					if( solutions[s][0] == 1 )
						++triangle_1;
					else
						if( solutions[s][0] == 2 )
							++triangle_2;
						else
							++triangle_3;
				}
				else
				{
					if( solutions[s][i] == 1 )
						++sum_element;
				}
			}

			if( i == 0 )
			{
				if( static_cast<double>( triangle_1 ) == ( static_cast<double>( weak_learners ) / 3 ) && static_cast<double>( triangle_2 ) == ( static_cast<double>( weak_learners ) / 3 ) ) // if we have a draw among triangle patterns, select one randomly
				{
					majority_solution[0] = rng.uniform(1,3);
				}
				else
				{
					if( triangle_1 == triangle_2 && triangle_1 > triangle_3 )
						majority_solution[0] = rng.uniform(1,2);
					else
					{
						if( triangle_3 == triangle_2 && triangle_3 > triangle_1 )
							majority_solution[0] = rng.uniform(2,3);
						else
						{
							if( triangle_1 == triangle_3 && triangle_1 > triangle_2 )
							{
								int flip_coin = rng.uniform(0,1);
								if( flip_coin == 0 )
									majority_solution[0] = 1;
								else
									majority_solution[0] = 3;
							}
							else
							{						
								if( triangle_1 > triangle_2 )
								{
										
									if( triangle_1 > triangle_3 )
										majority_solution[0] = 1;
									else
										majority_solution[0] = 3;
								}
								else
								{
									if( triangle_2 > triangle_3 )
										majority_solution[0] = 2;
									else
										majority_solution[0] = 3;
								}
							}
						}
					}
				}
			}
			else
			{
				if( static_cast<double>( sum_element ) == static_cast<double>( weak_learners ) / 2 )
					majority_solution[i] = rng.uniform(0,1);
				else
				{
					if( static_cast<double>( sum_element ) > static_cast<double>( weak_learners ) / 2 )
						majority_solution[i] = 1;
					else
						majority_solution[i] = 0;
				}
			}
		}

		// min solution
		std::vector<int> min_solution( solutions[0].size(), 0 );
		std::copy( solutions[0].begin(), solutions[0].end(), min_solution.begin() );
		for( auto& sol : solutions )
			std::transform( sol.cbegin(), sol.cend(), min_solution.cbegin(), min_solution.begin(), [](auto a, auto b){ return std::min(a,b); } );

		// max solution
		std::vector<int> max_solution( solutions[0].size(), 0 );
		for( auto& sol : solutions )
			std::transform( sol.cbegin(), sol.cend(), max_solution.cbegin(), max_solution.begin(), [](auto a, auto b){ return std::max(a,b); } );
		
		cost = sum_cost / weak_learners;
		
		
		bool check = false;
		if( cmdl[ {"c", "check"} ] && check_file_path == "" )
			check = true;

#if defined BLOCK or defined BLOCK_SAT or defined BLOCK_OPT
		// std::cout << "Check solution by mean\n";
		// check_solution_block( mean_solution,
		//                       candidates,
		//                       labels,
		//                       number_variables,
		//                       domain_size,
		//                       total_training_set_size,
		//                       starting_value,
		//                       complementary_variable,
		//                       silent,
		//                       result_file_path,
		//                       matrix_file_path,
		//                       parameter,
		//                       check );

		// std::cout << "Check solution by minimum\n";
		// check_solution_block( min_solution,
		//                       candidates,
		//                       labels,
		//                       number_variables,
		//                       domain_size,
		//                       total_training_set_size,
		//                       starting_value,
		//                       complementary_variable,
		//                       silent,
		//                       result_file_path,
		//                       matrix_file_path,
		//                       parameter,
		//                       check );

		// std::cout << "Check solution by maximum\n";
		// check_solution_block( max_solution,
		//                       candidates,
		//                       labels,
		//                       number_variables,
		//                       domain_size,
		//                       total_training_set_size,
		//                       starting_value,
		//                       complementary_variable,
		//                       silent,
		//                       result_file_path,
		//                       matrix_file_path,
		//                       parameter,
		//                       check );
		
		std::cout << "Check solution by majority\n";
		check_solution_block( majority_solution,
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
				Q( row_number, row_number + i ) = majority_solution[ ( row_number * matrix_side ) - shift + i ];
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

		// print solutions
		for( int i = 0 ; i < weak_learners ; ++i )
		{
			std::cout << "Solution of weak learner " << i << ": ";
			std::copy( solutions[i].begin(), solutions[i].end(), std::ostream_iterator<int>( std::cout, " " ) );
			std::cout << "\n";
		}

		if( !silent )
		{
			std::cout << "\nConstraints satisfied: " << std::boolalpha << solved << "\n"
			          << "Objective function cost: " << cost << "\n";
			
			std::cout << "Majority solution: ";
			std::copy( majority_solution.begin(), majority_solution.end(), std::ostream_iterator<int>( std::cout, " " ) );

			std::cout << "\nMean solution: ";
			std::copy( mean_solution.begin(), mean_solution.end(), std::ostream_iterator<int>( std::cout, " " ) );

			std::cout << "\nMin solution: ";
			std::copy( min_solution.begin(), min_solution.end(), std::ostream_iterator<int>( std::cout, " " ) );

			std::cout << "\nMax solution: ";
			std::copy( max_solution.begin(), max_solution.end(), std::ostream_iterator<int>( std::cout, " " ) );

			std::cout << "\n";
		}

	}
	
	return EXIT_SUCCESS;
}

