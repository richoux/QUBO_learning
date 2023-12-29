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

#include "checks.hpp"

void usage( char **argv )
{
	std::cout << "Usage examples:\n" << argv[0] << " -n 10 -d 10 [-s 1] [-p 15] -c RESULT_FILE\n"
	          << "\nArguments:\n"
	          << "-h, --help, printing this message.\n"
	          << "-n, --variables N, the number of variables.\n"
	          << "-d, --domain D, the domain size.\n"
	          << "-c, --check RESULT_FILE, to build Q given the solution produced by GHOST in RESULT_FILE.\n"
	          << "-s, --start S, the first value in the domain (1 by default).\n"
	          << "-p, --parameter P, a parameter value (MAX_INT by default).\n"
	          << "-e, --encoding ENCODING_CODE, 0 for one-hot, 1 for unary (one-hot by default)\n";
}

int main( int argc, char **argv )
{
	size_t number_variables;
	size_t domain_size;
	int starting_value;
	int parameter = std::numeric_limits<int>::max();
	
	std::string check_file_path;
	std::string line;
	std::ifstream check_file;

	int encoding_type;
	Encoding *encoding;
	
	std::vector<int> solution;

	argh::parser cmdl( { "-n", "--variables", "-d", "--domain", "-c", "--check", "-e", "--encoding" } );
	cmdl.parse( argc, argv );
	
	if( cmdl[ {"-h", "--help"} ] )
	{
		usage( argv );
		return EXIT_SUCCESS;
	}

	if( !( cmdl( {"n", "variables"} ) && cmdl( {"d", "domain"} ) && cmdl( {"c", "check"} ) ) )
	{
		usage( argv );
		return EXIT_FAILURE;
	}

	cmdl( {"n", "variables"} ) >> number_variables;
	cmdl( {"d", "domain"} ) >> domain_size;
	cmdl( {"c", "check"} ) >> check_file_path;
	cmdl( {"e", "encoding"}, 0 ) >> encoding_type;
	cmdl( {"s", "start"}, 1 ) >> starting_value;
	cmdl( {"p", "parameter"} ) >> parameter;

	switch( encoding_type )
	{
	case 1:
		encoding = new Unary();
		break;
	default:
		encoding = new Onehot();
	}
	
	check_file.open( check_file_path );
	
	size_t matrix_side = number_variables * domain_size;
	Eigen::MatrixXi Q = Eigen::MatrixXi::Zero( matrix_side, matrix_side );
	std::vector<int> q_matrix;

	getline( check_file, line );
	getline( check_file, line );
	std::stringstream line_stream( line );
	
	int number_patterns = encoding->number_square_patterns() + 1; // since triangle patterns are encoded on a unique variable
	solution.reserve( number_patterns );
	for( int i = 0 ; i < number_patterns; ++i )
		line_stream >> solution[i];
	
	Q = encoding->fill_matrix( solution, number_variables, domain_size, starting_value, parameter );
	check_file.close();

	std::cout << Q << "\n";

	return EXIT_SUCCESS;
}

