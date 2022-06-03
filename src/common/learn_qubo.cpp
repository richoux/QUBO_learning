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
#else
#include "builder_scam.hpp"
#endif

using namespace ghost;
using namespace std::literals::chrono_literals;

void usage( char **argv )
{
	cout << "Usage: " << argv[0] << " -f FILE_TRAINING_DATA [-t TIME_BUDGET] [-s PERCENT] [-p]\n"
	     << "OR : " << argv[0] << " --expected\n"
	     << "Arguments:\n"
	     << "-h, --help, printing this message.\n"
	     << "-f, --file FILE_TRAINING_DATA.\n"
	     << "-t, --timeout TIME_BUDGET, in seconds (1 by default)\n"
	     << "-s, --sample PERCENT, to sample candidates from PERCENT of the training set (100 by default)\n"
	     << "-p, --parallel, to make parallel search\n"
	     << "--expected, to print some expected results\n";
}

void expected()
{
	size_t matrix_side = 9;
	Eigen::MatrixXi Q {
		{-1, 1, 1, 1, 0, 0, 1, 0, 0},
		{0, -1, 1, 0, 1, 0, 0, 1, 0},
		{0, 0, -1, 0, 0, 1, 0, 0, 1},
		{0, 0, 0, -1, 1, 1, 1, 0, 0},
		{0, 0, 0, 0, -1, 1, 0, 1, 0},
		{0, 0, 0, 0, 0, -1, 0, 0, 1},
		{0, 0, 0, 0, 0, 0, -1, 1, 1},
		{0, 0, 0, 0, 0, 0, 0, -1, 1},
		{0, 0, 0, 0, 0, 0, 0, 0, -1}
	};

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
	
	for( auto& candidate : candidates )
	{
		Eigen::VectorXi X = Eigen::VectorXi::Zero( matrix_side );

		string candidate_string = "[";		
		for( size_t index = 0 ; index < 3 ; ++index )
		{
			X( index * 3 + ( candidate[ index ] - 1 ) ) = 1;
			if( index > 0)
				candidate_string += ",";
			candidate_string += std::to_string( candidate[ index ] );
		}

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
                     int starting_value )
{
	size_t matrix_side = number_variables * domain_size;
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

	for( size_t index_sample = 0 ; index_sample < number_samples ; ++index_sample )
	{
		Eigen::VectorXi X = Eigen::VectorXi::Zero( matrix_side );
		
		for( size_t index_var = 0 ; index_var < number_variables ; ++index_var )
			X( index_var * domain_size + ( samples[ index_sample * number_variables + index_var ] - starting_value ) ) = 1;

		scalars[ index_sample ] = ( X.transpose() * Q ) * X;
		if( min_scalar > scalars[ index_sample ]	)
			min_scalar = scalars[ index_sample ];		
	}

	std::cout << "\nQ matrix:\n" << Q
	          << "\n\nMin scalar = " << min_scalar << "\n\n";
	
	for( size_t index_sample = 0 ; index_sample < number_samples ; ++index_sample )
	{
		std::string candidate = "[";
		for( size_t index_var = 0 ; index_var < number_variables ; ++index_var )
		{
			if( index_var > 0 )
				candidate += " ";
			candidate += std::to_string( samples[ index_sample * number_variables + index_var ] );
		}
		candidate += "]";

		// std::cout << "Scalar for candidate " << candidate << ": " << std::setw( 3 ) << scalars[ index_sample ] << "\n";		
		
		if( labels[ index_sample ] == 0 && scalars[ index_sample ] != min_scalar )
			std::cout << "/!\\ Candidate " << candidate << " is a solution but has not a minimal scalar: " << std::setw( 3 ) << scalars[ index_sample ] << "\n";
		
		if( labels[ index_sample ] > 0 && scalars[ index_sample ] == min_scalar )
			std::cout << "/!\\ Candidate " << candidate << " is not a solution but has the minimal scalar " << std::setw( 3 ) << min_scalar << "\n";
	}
}

int main( int argc, char **argv )
{
	size_t number_variables;
	size_t domain_size;
	int starting_value;
	int time_budget;
	int percent_training_set;
	
	string training_data_file_path;
	string line, string_number;
	ifstream training_data_file;

	size_t number_samples = 0;
	size_t total_training_set_size = 0;
	vector<int> candidates;
	vector<int> samples;
	vector<double> labels;
	vector<double> sampled_labels;

	bool parallel;

	randutils::mt19937_rng rng;
	argh::parser cmdl( { "-f", "--file", "-t", "--timeout", "-s", "--sample" } );
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
		time_budget *= 1000000; // GHOST needs microseconds
		//cmdl( {"p", "parallel"} ) ? parallel = true : parallel = false;
		if( cmdl[ {"-p", "--parallel"} ] )
			parallel = true;
		else
			parallel = false;
		
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
			line.erase(0, delimiter + 3 );
			
			stringstream line_stream( line );
			while( line_stream >> string_number )
			{
				stringstream number_stream( string_number );
				number_stream >> value;
				candidates.push_back( value );
			}
		}		

		training_data_file.close();
		number_samples = static_cast<int>( ( total_training_set_size * percent_training_set ) / 100 );

		if( percent_training_set < 100 )
		{
			std::vector<int> indexes( total_training_set_size );
			std::iota( indexes.begin(), indexes.end(), 0 );
			
			rng.shuffle( indexes );
			for( int i = 0 ; i < number_samples ; ++i )
			{
				std::copy_n( candidates.begin() + ( indexes[ i ] * number_variables ), number_variables, std::back_inserter( samples ) );
				sampled_labels.push_back( labels[ indexes[ i ] ] );

				// std::copy_n( candidates.begin() + ( indexes[ i ] * number_variables ), number_variables, std::ostream_iterator<int>( std::cout, " " ) );
				// std::cout << ": " << labels[ indexes[ i ] ] << "\n";
			}
		}
		else
		{
			samples.resize( total_training_set_size * number_variables );
			std::copy( candidates.begin(), candidates.end(), samples.begin() );

			sampled_labels.resize( total_training_set_size );
			std::copy( labels.begin(), labels.end(), sampled_labels.begin() );
		}
		
		std::cout << "Number vars: " << number_variables
		          << ", Domain: " << domain_size
		          << ", Number samples: " << number_samples
		          << ", Training set size: " << total_training_set_size
		          << ", Starting value: " << starting_value
		          << "\nParallel run: " << std::boolalpha << parallel << "\n";		
	
		BuilderQUBO builder( samples, number_samples, number_variables, domain_size, starting_value, sampled_labels );
		Solver solver( builder );

		double cost;
		vector<int> solution;

		Options options;
		options.print = make_shared<PrintQUBO>( number_variables * domain_size );
		if( parallel )
			options.parallel_runs = true;
		
		auto solved = solver.solve( cost, solution, time_budget, options );		

		std::cout << "\nConstraints satisfied: " << std::boolalpha << solved << "\n"
		          << "Objective function cost: " << cost << "\n";
	
		check_solution( solution,
		                candidates,
		                labels,
		                number_variables,
		                domain_size,
		                total_training_set_size,
		                starting_value );

		// check_solution( solution,
		//                 samples,
		//                 labels,
		//                 number_variables,
		//                 domain_size,
		//                 number_samples,
		//                 starting_value );
	}
	
	return EXIT_SUCCESS;
}

