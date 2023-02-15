#include <vector>
#include <string>
#include <map>
#include <algorithm>
#include <set>

#include <iostream>
#include <fstream>
#include <iterator>
#include <chrono>

// Command line option management
#include <argh.h>

#include "utils/random_draw.hpp"

#include "constraints/concept.hpp"
#include "constraints/all_different.hpp"
#include "constraints/linear_equation.hpp"
#include "constraints/ordered.hpp"
#include "constraints/no_overlap_1d.hpp"
#include "constraints/element.hpp"
#include "constraints/channel.hpp"

using namespace std;

void usage( char **argv )
{
	cout << "Usage: " << argv[0] << " -c {ad|le|or|no|el|ch} -n NB_VARIABLES -d MAX_VALUE_DOMAIN -s SAMPLING_PRECISION -o OUTPUT_FILE [-p PARAMETERS]\n"
	     << "Arguments:\n"
	     << "-h, --help\n"
	     << "-c, --constraint {ad|le|or|no|el|ch}\n"
	     << "-n, --nb_vars NB_VARIABLES\n"
	     << "-d, --max_domain MAX_VALUE_DOMAIN\n"
	     << "-s, --sampling NUMBER_SAMPLING\n"
	     << "-o, --output OUTPUT_FILE\n"
	     << "-p, --params PARAMETERS\n";
}

int main( int argc, char** argv )
{
	chrono::duration<double,milli> elapsedTime(0);
	chrono::time_point<chrono::steady_clock> start;
	start = chrono::steady_clock::now();
	
	string constraint;
	int nb_vars, max_value;
	int samplings;
	vector<int> random_solutions;
	vector<int> random_configurations;
	unique_ptr<Concept> constraint_concept;
	map<string, double> cost_map;
	vector<double> params;
	double params_value;
	bool has_param;
	string output_file_path;
	ofstream output_file;
	
	argh::parser cmdl( { "-c", "--constraint", "-n", "--nb_vars", "-d", "--max_domain", "-s", "--sampling", "-p", "--params", "-o", "--output", } );
	cmdl.parse( argc, argv );
	
	if( cmdl[ { "-h", "--help"} ] )
	{
		usage( argv );
		return EXIT_SUCCESS;
	}

	if( !( cmdl( {"n", "nb_vars"} ) && cmdl( {"d", "max_domain"} ) && cmdl( {"o", "output"} ) ) )
	{
		usage( argv );
		return EXIT_FAILURE;
	}

	cmdl( {"n", "nb_vars"}, 9) >> nb_vars;
	cmdl( {"d", "max_domain"}, 9) >> max_value;
	cmdl( {"o", "output"} ) >> output_file_path;	
	cmdl( {"s", "sampling"}, 100) >> samplings;

	if( !( cmdl( {"p", "params"} ) >> params_value ) )
	{
		params_value = 1.0;
		has_param = false;
	}
	else
		has_param = true;

	params = vector<double>( nb_vars, params_value );
	
	if( !( cmdl( {"c", "constraint"} ) >> constraint )
	    ||
	    ( constraint.compare("ad") != 0
	      && constraint.compare("le") != 0
	      && constraint.compare("or") != 0
	      && constraint.compare("no") != 0
	      && constraint.compare("el") != 0
	      && constraint.compare("ch") != 0 ) )
	{
		cerr << "Must provide a valid constraint among ad, le, or, no, el and ch. You provided '" << cmdl( {"c", "constraint"} ).str() << "'\n";
		usage( argv );
		return EXIT_FAILURE;
	}
	else
	{
		if( constraint.compare("ad") == 0 )
		{
			cout << "Constraint: All Different.\n";
			constraint_concept = make_unique<AllDifferent>( nb_vars, max_value );
		}
		
		if( constraint.compare("le") == 0 )
		{
			cout << "Constraint: Linear equation.\n";
			constraint_concept = make_unique<LinearEquation>( nb_vars, max_value, params[0] );
		}

		if( constraint.compare("or") == 0 )
		{
			cout << "Constraint: Ordered.\n";
			constraint_concept = make_unique<Ordered>( nb_vars, max_value );
		}
		
		if( constraint.compare("no") == 0 )
		{
			cout << "Constraint: No Overlap 1D.\n";
			constraint_concept = make_unique<NoOverlap1D>( nb_vars, max_value, params );
		}

		if( constraint.compare("el") == 0 )
		{
			cout << "Constraint: Element.\n";
			constraint_concept = make_unique<Element>( nb_vars, max_value, params[0] );
		}

		if( constraint.compare("ch") == 0 )
		{
			cout << "Constraint: Channel.\n";
			constraint_concept = make_unique<Channel>( nb_vars, max_value );
		}
	}

	cout << nb_vars << "-" << max_value;	
	if( constraint.compare("le") == 0 || constraint.compare("no") == 0 || constraint.compare("el") == 0 )
		cout << "-" << params_value;
	cout << "\n";

	
	int number_draws;
	
	cout << "Perform Latin Hypercube sampling.\n";
	number_draws = cap_draw( constraint_concept, nb_vars, max_value, random_solutions, random_configurations, samplings );

	if( (int)random_solutions.size() == 0 )
	{
		cerr << "No solutions. Abort.\n";
		return EXIT_FAILURE;
	}
	
	unsigned long long int space_size = static_cast<unsigned long long int>( std::pow( max_value, nb_vars ) );
	
	output_file.open( output_file_path );
	output_file << nb_vars << " " << max_value << " " << 1;
	if( has_param )
		output_file << " " << static_cast<int>( params_value );
	output_file << "\n";

	for( int i = 0; i < (int)random_solutions.size(); i += nb_vars )
	{
		output_file << "0 : ";
		std::copy( random_solutions.begin() + i,
		           random_solutions.begin() + i + nb_vars,
		           ostream_iterator<int>( output_file, " " ) );

		output_file << "\n";
	}
	
	for( int i = 0; i < (int)random_configurations.size(); i += nb_vars )
	{
		output_file << "1 : ";
		std::copy( random_configurations.begin() + i,
		           random_configurations.begin() + i + nb_vars,
		           ostream_iterator<int>( output_file, " " ) );

		output_file << "\n";
	}

	output_file.close();

	cout << "Number of solutions: " << samplings << "\n";
	cout << "Space size: " << space_size << "\n";

	cout << "Percent solutions: " << ( static_cast<double>( samplings ) * 100 ) / number_draws << "\n";
	cout << "Percent explored space: " << ( static_cast<double>( samplings ) * 200 ) / space_size << "\n";

	elapsedTime = chrono::steady_clock::now() - start;
	cout << "Elapsed time: " << elapsedTime.count() << "ms\n";
	return EXIT_SUCCESS;
}
