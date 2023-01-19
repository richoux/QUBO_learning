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

#include "print_qubo.hpp"
#if defined SVN
#include "builder_svn.hpp"
#elif defined SPARSE
#include "builder_sparse.hpp"
#elif defined SCAM
#include "builder_scam.hpp"
#else
#include "builder_force_pattern.hpp"
#endif

using namespace ghost;
using namespace std::literals::chrono_literals;

void usage( char **argv )
{
	cout << "Usage: " << argv[0] << " -f FILE_TRAINING_DATA [-t TIME_BUDGET] [-s PERCENT] [-p]\n"
	     << "OR : " << argv[0] << " -f FILE_TRAINING_DATA --check [FILE_Q_MATRIX]\n"
	     << "OR : " << argv[0] << " --expected\n"
	     << "Arguments:\n"
	     << "-h, --help, printing this message.\n"
	     << "-f, --file FILE_TRAINING_DATA.\n"
	     << "-t, --timeout TIME_BUDGET, in seconds (1 by default)\n"
	     << "-s, --sample PERCENT [--force_positive], to sample candidates from PERCENT of the training set (100 by default). --force_positive forces considering all positive candidates.\n"
	     << "-p, --parallel, to make parallel search\n"
	     << "-d, --debug, to print additional information\n"
	     << "-c, --complementary, to force one complementary variable\n"
	     << "-w, --weak_learners NUMBER_LEARNERS, to learn NUMBER_LEARNERS Q matrices and merge them into an average matrix (disabled by default).\n"
	     << "--check [FILE_Q_MATRIX] to compute xt.Q.x results if a file is provided containing Q, or to display all xt.Q.x results after the learning of Q otherwise.\n"
	     << "--expected, to print some expected results\n";
}

void expected()
{
	size_t matrix_side = 9;
	Eigen::MatrixXi Q {
		{-1, 0, 0, 1, 0, 0, 1, 0, 0},
		{0, -1, 0, 0, 1, 0, 0, 1, 0},
		{0, 0, -1, 0, 0, 1, 0, 0, 1},
		{0, 0, 0, -1, 0, 0, 1, 0, 0},
		{0, 0, 0, 0, -1, 0, 0, 1, 0},
		{0, 0, 0, 0, 0, -1, 0, 0, 1},
		{0, 0, 0, 0, 0, 0, -1, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, -1, 0},
		{0, 0, 0, 0, 0, 0, 0, 0, -1}
	};
	// Eigen::MatrixXi Q {
	// 	{-1, 1, 1, 1, 0, 0, 1, 0, 0},
	// 	{0, -1, 1, 0, 1, 0, 0, 1, 0},
	// 	{0, 0, -1, 0, 0, 1, 0, 0, 1},
	// 	{0, 0, 0, -1, 1, 1, 1, 0, 0},
	// 	{0, 0, 0, 0, -1, 1, 0, 1, 0},
	// 	{0, 0, 0, 0, 0, -1, 0, 0, 1},
	// 	{0, 0, 0, 0, 0, 0, -1, 1, 1},
	// 	{0, 0, 0, 0, 0, 0, 0, -1, 1},
	// 	{0, 0, 0, 0, 0, 0, 0, 0, -1}
	// };

	std::vector< std::array<int, 3> > candidates {
		{1, 1, 1},
		{1, 1, 2},
		{1, 1, 3},
		{1, 2, 1},
		{1, 2, 2},
		{1, 2, 3},
		{1, 3, 1},
		{1, 3, 2},
		{1, 3, 3},
		{2, 1, 1},
		{2, 1, 2},
		{2, 1, 3},
		{2, 2, 1},
		{2, 2, 2},
		{2, 2, 3},
		{2, 3, 1},
		{2, 3, 2},
		{2, 3, 3},
		{3, 1, 1},
		{3, 1, 2},
		{3, 1, 3},
		{3, 2, 1},
		{3, 2, 2},
		{3, 2, 3},
		{3, 3, 1},
		{3, 3, 2},
		{3, 3, 3}
	};

	/*
	  size_t matrix_side = 10;
	  Eigen::MatrixXi Q {
	  {0, 0, 0, 0, 0, 0, 0, 0, 0,   0},
	  {0, 1, 0, 0, 2, 4, 0, 2, 4,  -6},
	  {0, 0, 4, 0, 4, 8, 0, 4, 8, -12},
	  {0, 0, 0, 0, 0, 0, 0, 0, 0,   0},
	  {0, 0, 0, 0, 1, 0, 0, 2, 4,  -6},
	  {0, 0, 0, 0, 0, 4, 0, 4, 8, -12},
	  {0, 0, 0, 0, 0, 0, 0, 0, 0,   0},
	  {0, 0, 0, 0, 0, 0, 0, 1, 0,  -6},
	  {0, 0, 0, 0, 0, 0, 0, 0, 4, -12},
	  {0, 0, 0, 0, 0, 0, 0, 0, 0,   0}
	  };

	  std::vector< std::array<int, 4> > candidates {
	  {0, 0, 0, 1},
	  {0, 0, 1, 1},
	  {0, 0, 2, 1},
	  {0, 1, 0, 1},
	  {0, 1, 1, 1},
	  {0, 1, 2, 1},
	  {0, 2, 0, 1},
	  {0, 2, 1, 1},
	  {0, 2, 2, 1},
	  {1, 0, 0, 1},
	  {1, 0, 1, 1},
	  {1, 0, 2, 1},
	  {1, 1, 0, 1},
	  {1, 1, 1, 1},
	  {1, 1, 2, 1},
	  {1, 2, 0, 1},
	  {1, 2, 1, 1},
	  {1, 2, 2, 1},
	  {2, 0, 0, 1},
	  {2, 0, 1, 1},
	  {2, 0, 2, 1},
	  {2, 1, 0, 1},
	  {2, 1, 1, 1},
	  {2, 1, 2, 1},
	  {2, 2, 0, 1},
	  {2, 2, 1, 1},
	  {2, 2, 2, 1}
	  };
	*/
	
	for( auto& candidate : candidates )
	{
		Eigen::VectorXi X = Eigen::VectorXi::Zero( matrix_side );

		string candidate_string = "[";		
		for( size_t index = 0 ; index < 3 ; ++index )
		{
			X( index * 3 + candidate[ index ] - 1 ) = 1;
			if( index > 0)
				candidate_string += ",";
			candidate_string += std::to_string( candidate[ index ] );
		}
		//X( 9 ) = 1;

		candidate_string += "]";		
		std::cout << candidate_string << " = " << ( X.transpose() * Q ) * X << "\n";
	}
}

void check_solution( const std::vector<int>& solution,
                     const std::vector<int>& samples,
                     const std::vector<double>& labels,
                     size_t number_variables,
                     size_t domain_size,
                     size_t number_samples,
                     int starting_value,
                     bool complementary_variable,
                     bool full_check = false )
{
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

	std::cout << "\nQ matrix:\n" << Q
	          << "\n\nMin scalar = " << min_scalar << "\n\n";
	
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
				std::cout << "/!\\ Candidate " << candidate << " is a solution but has not a minimal scalar: " << std::setw( 3 ) << scalars[ index_sample ] << "\n";
			else
				if( full_check )
					std::cout << "Candidate " << candidate << " (solution): " << std::setw( 3 ) << scalars[ index_sample ] << "\n";
		}
		else
			if( scalars[ index_sample ] == min_scalar )
				std::cout << "/!\\ Candidate " << candidate << " is not a solution but has the minimal scalar " << std::setw( 3 ) << min_scalar << "\n";
			else
				if( full_check )
					std::cout << "Candidate " << candidate << ": " << std::setw( 3 ) << scalars[ index_sample ] << "\n";
	}
}

int main( int argc, char **argv )
{
	size_t number_variables;
	size_t domain_size;
	int starting_value;
	int time_budget;
	int percent_training_set;
	int weak_learners;
	
	string training_data_file_path;
	string q_matrix_file_path;
	string line, string_number;
	ifstream training_data_file;
	ifstream q_matrix_file;

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
	
	randutils::mt19937_rng rng;
	argh::parser cmdl( { "-f", "--file", "-t", "--timeout", "-s", "--sample", "--check", "-w", "--weak_learners" } );
	cmdl.parse( argc, argv );
	
	if( cmdl[ {"-h", "--help"} ] )
	{
		usage( argv );
		return EXIT_SUCCESS;
	}

	if( cmdl[ {"--expected"} ] )
	{
		expected();
	}
	else
	{	
		if( !( cmdl( {"f", "file"} ) ) )
		{
			usage( argv );
			return EXIT_FAILURE;
		}

		cmdl( {"f", "file"} ) >> training_data_file_path;
		cmdl( {"t", "timeout"}, 1 ) >> time_budget;
		cmdl( {"s", "sample"}, 100 ) >> percent_training_set;
		cmdl( {"w", "weak_learners"}, 1 ) >> weak_learners;
		time_budget *= 1000000; // GHOST needs microseconds
		cmdl[ {"-p", "--parallel"} ] ? parallel = true : parallel = false;
		cmdl[ {"-d", "--debug"} ] ? debug = true : debug = false;
		cmdl[ {"-c", "--complementary"} ] ? complementary_variable = true : complementary_variable = false;-
		cmdl[ {"--force_positive"} ] ? force_positive = true : force_positive = false;
		
		training_data_file.open( training_data_file_path );
		int value;
		double error;

		getline( training_data_file, line );
		stringstream line_stream( line );
		line_stream >> number_variables >> domain_size >> starting_value;
	
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

		if( cmdl( {"check"} ) >> q_matrix_file_path )
		{
			q_matrix_file.open( q_matrix_file_path );
			vector<int> q_matrix;

			int row = 0;
			while( getline( q_matrix_file, line ) )
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

			q_matrix_file.close();

			check_solution( q_matrix,
			                candidates,
			                labels,
			                number_variables,
			                domain_size,
			                total_training_set_size,
			                starting_value,
			                complementary_variable,
			                true );
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
				if( weak_learners > 1 )
					std::cout  << "Weak learners: " << weak_learners << "\n";		
			}
			
			BuilderQUBO builder( samples, number_samples, number_variables, domain_size, starting_value, sampled_labels, complementary_variable );
			Solver solver( builder );

			vector<int> solution;
			double cost;
			bool solved = true;
			Options options;
			options.print = make_shared<PrintQUBO>( number_variables * domain_size );
			if( parallel )
				options.parallel_runs = true;
			
			if( weak_learners == 1 )
			{			
				solved = solver.solve( cost, solution, time_budget, options );		
			}
			else
			{
				vector<vector<int>> solutions( weak_learners );
				double sum_cost = 0.;
				
				for( int i = 0 ; i < weak_learners ; ++i )
				{
					solved = solved && solver.solve( cost, solutions[i], time_budget, options );
					sum_cost += cost;
				}

				solution = std::vector<int>( solutions[0].size(), 0 );
				
				for( auto& sol : solutions )
					std::transform( sol.cbegin(), sol.cend(), solution.cbegin(), solution.begin(), std::plus<>{} );

				std::transform( solution.cbegin(), solution.cend(), solution.begin(), [&](auto s){ return static_cast<int>( std::round( s / weak_learners ) ); } );
				
				cost = sum_cost / weak_learners;
			}
				
			std::cout << "\nConstraints satisfied: " << std::boolalpha << solved << "\n"
			          << "Objective function cost: " << cost << "\n";
			
			bool check = false;
			if( cmdl[ {"check"} ] )
				check = true;
			
			check_solution( solution,
			                candidates,
			                labels,
			                number_variables,
			                domain_size,
			                total_training_set_size,
			                starting_value,
			                complementary_variable,
			                check );
		}
		
		return EXIT_SUCCESS;
	}
}

