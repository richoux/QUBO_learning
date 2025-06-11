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

#include "encoding.hpp"
#include "onehot.hpp"
#include "unary.hpp"

#include "checks.hpp"
#include "print_qubo.hpp"

#if defined BLOCK_SAT
#include "builder_block_sat.hpp"
#else
#include "builder_block_opt.hpp"
#endif

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
	     << "-e, --encoding ENCODING_CODE, 0 for one-hot, 1 for unary (one-hot by default)\n"
	     << "-n, --number NUMBER_SAMPLES, to sample NUMBER_SAMPLES random candidates from the training set. Samples here are such that we got NUMBER_SAMPLES/2 positive and NUMBER_SAMPLES/2 negative candidates.\n"
	     << "-s, --samestart, to force weak learners to start from the same point in the search space\n"
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
	bool custom_starting_point;
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

	int encoding_type;
	Encoding *encoding;
	
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
	cmdl( {"e", "encoding"}, 0 ) >> encoding_type;
	cmdl( {"w", "weak_learners"}, 1 ) >> weak_learners;
	time_budget *= 1000000; // GHOST needs microseconds
	cmdl[ {"-s", "--samestart"} ] ? custom_starting_point = true : custom_starting_point = false;
	cmdl[ {"-d", "--debug"} ] ? debug = true : debug = false;
	cmdl[ {"-b", "--benchmark"} ] ? silent = true : silent = false;
	cmdl[ {"--complementary"} ] ? complementary_variable = true : complementary_variable = false;
	cmdl[ {"--force_positive"} ] ? force_positive = true : force_positive = false;

	if( weak_learners <= 1 && !( cmdl( {"c", "check"} ) ))
	{
		std::cout << "You must assign at least 2 weak learners.\n";
		return EXIT_FAILURE;
	}

	switch( encoding_type )
	{
	case 1:
		encoding = new Unary();
		break;
	default:
		encoding = new Onehot();
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

		std::vector<int> q_matrix;

		if( check_file_path.ends_with( "_mean" ) )
		{
			Eigen::MatrixXd Q = Eigen::MatrixXd::Zero( matrix_side, matrix_side );
			getline( check_file, line );
			getline( check_file, line );
			std::stringstream line_stream( line );

			int number_patterns = encoding->number_square_patterns() + encoding->number_triangle_patterns();
			
			std::vector<double> solution_real( number_patterns, 0. );
			for( int i = 0 ; i < number_patterns; ++i )
				line_stream >> solution_real[i];
			
			Q = encoding->fill_matrix_reals( solution_real, number_variables, domain_size, starting_value, parameter );
			
			check_solution_reals( Q,
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
			                      encoding,
			                      false );
		}
		else
		{		
			Eigen::MatrixXi Q = Eigen::MatrixXi::Zero( matrix_side, matrix_side );
			
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

				int number_patterns = encoding->number_square_patterns() + 1; // since triangle patterns are encoded on a unique variable

				solution.reserve( number_patterns );
				for( int i = 0 ; i < number_patterns; ++i )
					line_stream >> solution[i];
				
				Q = encoding->fill_matrix( solution, number_variables, domain_size, starting_value, parameter );
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
			                "",
			                parameter,
			                encoding,
			                false );		
		}
		
		check_file.close();
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
			          << ", Same starting point: " << std::boolalpha << custom_starting_point
			          << "\nWeak learners: " << weak_learners << "\n";
		}

		std::chrono::time_point<std::chrono::steady_clock> start_program( std::chrono::steady_clock::now() );
		std::chrono::duration<double,std::micro> elapsed_time_program( 0 );

		// So far with GHOST v2.8, there is no default Solver constructor.
		// The unique constructor requires a Builder as parameter, so the two next lines are necessary.
		BuilderQUBO builder( samples, number_samples, number_variables, domain_size, starting_value, sampled_labels, complementary_variable, parameter, encoding );
		ghost::Solver solver( builder );

		double cost;
		bool solved = true;
		std::vector<bool> weak_solved( weak_learners, true );
		ghost::Options options;
			
		std::vector<std::vector<int>> solutions( weak_learners );
		double sum_cost = 0.;
		std::vector<int> indexes( total_training_set_size );
		std::iota( indexes.begin(), indexes.end(), 0 );
		int number_positive = static_cast<int>( std::ceil( static_cast<double>( number_samples ) / 2 ) );
		int number_negative = static_cast<int>( std::floor( static_cast<double>( number_samples ) / 2 ) );
		
		options.custom_starting_point = custom_starting_point; 
		
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
				
				BuilderQUBO builder( sub_samples, number_samples, number_variables, domain_size, starting_value, sub_sampled_labels, complementary_variable, parameter, encoding );
				solver = Solver( builder );
			}

			std::chrono::duration<double,std::micro> elapsed_time_solver( 0 );
			std::chrono::time_point<std::chrono::steady_clock> start_solver( std::chrono::steady_clock::now() );
			weak_solved[i] = solver.fast_search( cost, solutions[i], time_budget, options );
			solved = solved && weak_solved[i];
			elapsed_time_solver = std::chrono::steady_clock::now() - start_solver;
			std::cout << "Solution of weak learner " << i << ": ";
			std::copy( solutions[i].begin(), solutions[i].end(), std::ostream_iterator<int>( std::cout, " " ) );
			std::cout << "\nValid solution: " << std::boolalpha << weak_solved[i];
			std::cout << "\nWeak learner " << i << " runtime: " << elapsed_time_solver.count() << "us\n";
			
			sum_cost += cost;
		}

		// mean solution
		int number_patterns = encoding->number_square_patterns() + encoding->number_triangle_patterns();
		std::vector<double> mean_solution( number_patterns, 0 );
		// for( auto& sol : solutions )
		// 	std::transform( sol.cbegin(), sol.cend(), mean_solution.cbegin(), mean_solution.begin(), std::plus<>{} );
		for( int i = 0 ; i < weak_learners ; ++i )
		{
			if( encoding->number_triangle_patterns() == 3 )
				switch( solutions[i][0] )
				{
				case 1:
					mean_solution[0] += 1;
					break;
				case 2:
					mean_solution[1] += 1;
					break;
				default:
					mean_solution[2] += 1;
				}
			else // we assume there is just 2 patterns, like for unary encoding
				switch( solutions[i][0] )
				{
				case 0:
					mean_solution[0] += 1;
					break;
				case 1:
					mean_solution[1] += 1;
				}
			
			std::transform( solutions[i].cbegin()+1, solutions[i].cend(), mean_solution.cbegin()+encoding->number_triangle_patterns(), mean_solution.begin()+encoding->number_triangle_patterns(), std::plus<>{} );
		}

		std::transform( mean_solution.cbegin(), mean_solution.cend(), mean_solution.begin(), [&](auto s){ return s / weak_learners; } );

		// majority solution
		number_patterns = encoding->number_square_patterns() + 1; // since triangle patterns are encoded on a unique variable
		std::vector<int> majority_solution( number_patterns, 0 );
		int triangle_1 = 0;
		int triangle_2 = 0;
		int triangle_3 = 0;
		int sum_element;

		bool has_3_triangle_patterns = encoding->number_triangle_patterns() == 3;
		
		for( int i = 0 ; i < number_patterns ; ++i )
		{
			sum_element = 0;
			for( int s = 0 ; s < weak_learners ; ++s )
			{
				if( i == 0 && has_3_triangle_patterns )
				{
					if( solutions[s][0] == 1 )
						++triangle_1;
					else
					{
						if( solutions[s][0] == 2 )
							++triangle_2;
						else
							++triangle_3;
					}				
				}
				else
				{
					if( solutions[s][i] == 1 )
						++sum_element;
				}
			}

			if( i == 0 && has_3_triangle_patterns )
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
		std::vector<int> min_solution( number_patterns, 0 );
		std::copy( solutions[0].begin(), solutions[0].end(), min_solution.begin() );
		for( auto& sol : solutions )
			std::transform( sol.cbegin(), sol.cend(), min_solution.cbegin(), min_solution.begin(), [](auto a, auto b){ return std::min(a,b); } );

		// max solution
		std::vector<int> max_solution( number_patterns, 0 );
		for( auto& sol : solutions )
			std::transform( sol.cbegin(), sol.cend(), max_solution.cbegin(), max_solution.begin(), [](auto a, auto b){ return std::max(a,b); } );
		
		cost = sum_cost / weak_learners;
		
		elapsed_time_program = std::chrono::steady_clock::now() - start_program;
		
		bool check = false;
		if( cmdl[ {"c", "check"} ] && check_file_path == "" )
			check = true;

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
		
		std::cout << "Mean solution: ";
		std::copy( mean_solution.begin(), mean_solution.end(), std::ostream_iterator<double>( std::cout, " " ) );
		std::cout << "\nErrors by mean: ";
		check_solution_block_reals( mean_solution,
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
		                            encoding,
		                            check,
		                            "_mean" );

		std::cout << "Majority solution: ";
		std::copy( majority_solution.begin(), majority_solution.end(), std::ostream_iterator<int>( std::cout, " " ) );
		std::cout << "\nErrors by majority: ";
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
		                      encoding,
		                      check,
		                      "_majority" );
// #else
// 		size_t matrix_side = number_variables * domain_size;
// 		if( complementary_variable )
// 			++matrix_side;
		
// 		Eigen::MatrixXi Q = Eigen::MatrixXi::Zero( matrix_side, matrix_side );
		
// 		for( size_t length = matrix_side ; length > 0 ; --length )
// 		{
// 			int row_number = matrix_side - length;
			
// 			int shift = row_number * ( row_number - 1 ) / 2;
			
// 			for( int i = 0 ; i < length ; ++i )
// 				Q( row_number, row_number + i ) = majority_solution[ ( row_number * matrix_side ) - shift + i ];
// 		}
		
// 		check_solution( Q,
// 		                candidates,
// 		                labels,
// 		                number_variables,
// 		                domain_size,
// 		                total_training_set_size,
// 		                starting_value,
// 		                complementary_variable,
// 		                silent,
// 		                matrix_file_path,
// 		                parameter,
// 		                check );
// #endif

		std::cout << "All weak learners valid: " << std::boolalpha << solved;
		          // << "Objective function cost: " << cost << "\n";
		
		// std::cout << "Majority solution: ";
		// std::copy( majority_solution.begin(), majority_solution.end(), std::ostream_iterator<int>( std::cout, " " ) );
		
		// std::cout << "\nMean solution: ";
		// std::copy( mean_solution.begin(), mean_solution.end(), std::ostream_iterator<double>( std::cout, " " ) );
		
		// std::cout << "\nMin solution: ";
		// std::copy( min_solution.begin(), min_solution.end(), std::ostream_iterator<int>( std::cout, " " ) );
		
		// std::cout << "\nMax solution: ";
		// std::copy( max_solution.begin(), max_solution.end(), std::ostream_iterator<int>( std::cout, " " ) );
		
		std::cout << "\nWallclock runtime: " << elapsed_time_program.count() << "us\n\n";
	}
	
	return EXIT_SUCCESS;
}

