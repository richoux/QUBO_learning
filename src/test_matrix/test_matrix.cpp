#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>
#include <string>

#include <vector>
#include <algorithm>
#include <cmath>

#include <argh.h>
#include <Eigen/Dense>

#include "encoding.hpp"
#include "onehot.hpp"
#include "unary.hpp"

void usage( char **argv )
{
	std::cout << "Usage examples:\n" << argv[0] << " -m MATRIX_FILE -v CANDIDATE_VECTOR_FILE\n"
	          << "\nArguments:\n"
	          << "-h, --help, printing this message.\n"
	          << "-m, --matrix MATRIX_FILE.\n"
	          << "-v, --vector CANDIDATE_VECTOR_FILE.\n";
}

int main( int argc, char **argv )
{
	size_t number_variables;
	size_t domain_size;
	int starting_value;
	
	std::string matrix_file_path;
	std::string vector_file_path;
	std::string line, string_number;
	std::ifstream matrix_file;
	std::ifstream vector_file;

	int encoding_type = 0;
	Encoding *encoding;

	int number_vectors = 0;
	std::vector<std::vector<int>> candidates;
	int value;
	std::vector<double> labels;
	double error;
	
	argh::parser cmdl( { "-m", "--matrix", "-v", "--vector" } );
	cmdl.parse( argc, argv );
	
	if( cmdl[ {"-h", "--help"} ] )
	{
		usage( argv );
		return EXIT_SUCCESS;
	}

	if( !( cmdl( {"m", "matrix"} ) && cmdl( {"v", "vector"} ) ) )
	{
		usage( argv );
		return EXIT_FAILURE;
	}

	cmdl( {"m", "matrix"} ) >> matrix_file_path;
	cmdl( {"v", "vector"} ) >> vector_file_path;

	vector_file.open( vector_file_path );
	getline( vector_file, line );
	std::stringstream line_stream( line );
	line_stream >> number_variables >> domain_size;

	size_t matrix_side = number_variables * domain_size;

	Eigen::MatrixXi Q = Eigen::MatrixXi::Zero( matrix_side, matrix_side );
	std::vector<int> q_matrix;

	while( getline( vector_file, line ) )
	{
		auto delimiter = line.find(" : ");
		std::string label = line.substr( 0, delimiter );
		std::stringstream label_stream( label );
		label_stream >> error;
		labels.push_back( error );
		line.erase( 0, delimiter + 3 );
		std::stringstream line_stream( line );
		candidates.push_back( std::vector<int>() );
		while( line_stream >> string_number )
		{
			std::stringstream number_stream( string_number );
			number_stream >> value;
			candidates[number_vectors].push_back( value );
		}
		++number_vectors;
	}

	vector_file.close();
	
	matrix_file.open( matrix_file_path );
	int row = 0;
	while( getline( matrix_file, line ) )
	{
		if( line == "Matrix" )
			getline( matrix_file, line );

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

	std::cout << Q << "\n";

	matrix_file.close();

	for( int i = 0 ; i < number_vectors ; ++i )
	{
		if( labels[i] == 0 )
			std::cout << "Should be a solution: ";
		else
			std::cout << "Should NOT be a solution: ";

		Eigen::VectorXi X = Eigen::VectorXi::Zero( matrix_side );
		for(int j = 0 ; j < matrix_side ; ++j )
			X(j) = candidates[i][j];
		
		std::cout << ( X.transpose() * Q ) * X << "\n";
	}

	return EXIT_SUCCESS;
}

