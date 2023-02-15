#include <vector>
#include <string>
#include <algorithm>

#include <iostream>
#include <fstream>
#include <iterator>

// Command line option management
#include <argh.h>

#include "utils/increment.hpp"

#include "constraints/concept.hpp"
#include "constraints/all_different.hpp"
#include "constraints/linear_equation.hpp"
#include "constraints/ordered.hpp"
#include "constraints/no_overlap_1d.hpp"

using namespace std;

void usage( char **argv )
{
	cout << "Usage: " << argv[0] << " -c {ad|le|or|no} -n NB_VARIABLES -d MAX_VALUE_DOMAIN -o OUTPUT_FILE [-p PARAMETERS]\n"
	     << "Arguments:\n"
	     << "-h, --help\n"
	     << "-c, --constraint {ad|le|or|no}\n"
	     << "-n, --nb_vars NB_VARIABLES\n"
	     << "-d, --max_domain MAX_VALUE_DOMAIN\n"
	     << "-o, --output OUTPUT_FILE\n"
	     << "-p, --params PARAMETERS\n";
}

int main( int argc, char** argv )
{
	string constraint;
	int nb_vars, max_value;
	unique_ptr<Concept> constraint_concept;
	bool has_param;
	vector<double> params;
	double params_value;
	string output_file_path;
	ofstream output_file;
	
	argh::parser cmdl( { "-c", "--constraint", "-n", "--nb_vars", "-d", "--max_domain", "-p", "--params", "-o", "--output", } );
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
	      && constraint.compare("no") != 0 ) )
	{
		cerr << "Must provide a valid constraint among ad, le, or and no. You provided '" << cmdl( {"c", "constraint"} ).str() << "'\n";
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
	}

	output_file.open( output_file_path );
	output_file << nb_vars << " " << max_value << " " << 1;
	if( has_param )
		output_file << " " << static_cast<int>( params_value );
	output_file << "\n";
	
	vector<int> configurations( nb_vars, 1 );
	do
	{
		output_file << constraint_concept->constraint_concept( configurations ) << " : ";
		
		std::copy( configurations.begin(),
		           configurations.end(),
		           ostream_iterator<int>( output_file, " " ) );
		
		output_file << "\n";
		increment( configurations, max_value );
	} while( std::any_of( configurations.begin(), configurations.end(), [&max_value](auto& c){ return c != max_value; } ) );

	// last round
	output_file << constraint_concept->constraint_concept( configurations ) << " : ";
	
	std::copy( configurations.begin(),
	           configurations.end(),
	           ostream_iterator<int>( output_file, " " ) );
	
	output_file << "\n";
	output_file.close();

	return EXIT_SUCCESS;
}
