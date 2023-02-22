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
#include <randutils.hpp>

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

////////////////
// Constraints
////////////////

int main( int argc, char** argv )
{
	chrono::duration<double,milli> elapsedTime(0);
	chrono::time_point<chrono::steady_clock> start;
	start = chrono::steady_clock::now();
	
	string constraint;
	int nb_vars, max_value;
	int samplings;
	vector<int> random_candidates;
	unique_ptr<Concept> constraint_concept;
	vector<double> params;
	double params_value;
	bool has_param;
	string output_file_path;
	ofstream output_file;
	std::map<string, bool> has_been_drawned;

	randutils::mt19937_rng rng;

	argh::parser cmdl( { "-c", "--constraint", "-n", "--nb_vars", "-d", "--max_domain", "-s", "--sampling", "-p", "--params", "-o", "--output", } );
	cmdl.parse( argc, argv );
	
	if( cmdl[ { "-h", "--help"} ] )
	{
		usage( argv );
		return EXIT_SUCCESS;
	}
	
	if( !cmdl( {"o", "output"} ) )
	{
		usage( argv );
		return EXIT_FAILURE;
	}

	cmdl( {"n", "nb_vars"}, 100) >> nb_vars;
	cmdl( {"d", "max_domain"}, 100) >> max_value;
	cmdl( {"s", "sampling"}, 10000) >> samplings;
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
	number_draws = cap_draw_not_solutions( constraint_concept, nb_vars, max_value, random_candidates, samplings );

	cout << "Samplings done.\n";	
	unsigned long long int space_size = static_cast<unsigned long long int>( std::pow( max_value, nb_vars ) );
	
	output_file.open( output_file_path );
	output_file << nb_vars << " " << max_value << " " << 1;
	if( has_param )
		output_file << " " << static_cast<int>( params_value );
	output_file << "\n";

	vector<int> config( nb_vars );
	int count = 0;
	
	if( constraint.compare("ad") == 0 )
	{
		std::iota( config.begin(), config.end(), 1 );
		
		while( count < samplings )
		{
			rng.shuffle( config );
			if( constraint_concept->constraint_concept( config, 0, nb_vars ) )
			{
				if( !has_been_drawned.contains( convert_to_string( config ) ) )
				{
					has_been_drawned[ convert_to_string( config ) ] = true;
					output_file << "0 : ";
					std::copy( config.begin(),
					           config.end(),
					           ostream_iterator<int>( output_file, " " ) );				
					output_file << "\n";
					++count;
				}
			}
		}
	}
	
	if( constraint.compare("le") == 0 )
	{
		rng.generate( config, 1, max_value );
		auto sum = std::accumulate( config.begin(), config.end(), 0 );
		double diff = std::abs( sum - params_value );
		auto mean = std::ceil( diff / nb_vars );
		bool need_to_increase = ( sum < params_value );
		
		while( sum != params_value )
		{
			auto index = rng.uniform( 0, nb_vars - 1 );
			if( need_to_increase )
			{
				if( config[ index ] < max_value - ( mean * 2 ) )
					config[ index ] += ( mean * 2 );
				else
					if( config[ index ] < max_value - mean )
						config[ index ] += mean;
					else
						if( config[ index ] < max_value )
							++config[ index ];
			}
			else
			{
				if( config[ index ] > mean * 2 )
					config[ index ] -= ( mean * 2 );
				else
					if( config[ index ] > mean )
						config[ index ] -= mean;
					else
						if( config[ index ] > 1 )
							--config[ index ];
			}
			sum = std::accumulate( config.begin(), config.end(), 0 );
			need_to_increase = ( sum < params_value );				
		}

		has_been_drawned[ convert_to_string( config ) ] = true;
		output_file << "0 : ";
		std::copy( config.begin(),
		           config.end(),
		           ostream_iterator<int>( output_file, " " ) );				
		output_file << "\n";
		++count;

		while( count < samplings )
		{
			int index = rng.uniform( 0, nb_vars - 2 );
			if( config[ index ] < max_value && config[ index + 1 ] > 1 )
			{
				++config[ index ];
				--config[ index + 1 ];
			}
			if( constraint_concept->constraint_concept( config, 0, nb_vars ) )
			{
				if( !has_been_drawned.contains( convert_to_string( config ) ) )
				{
					has_been_drawned[ convert_to_string( config ) ] = true;
					output_file << "0 : ";
					std::copy( config.begin(),
					           config.end(),
					           ostream_iterator<int>( output_file, " " ) );				
					output_file << "\n";
					++count;
				}
			}
		}
	}
	
	if( constraint.compare("or") == 0 )
	{
		while( count < samplings )
		{
			int start_value = rng.uniform( 1, max_value / 4 );
			int value = start_value;
			for( int i = 0 ; i < nb_vars ; ++i )
			{
				if( value < max_value )
				{
					if( rng.uniform( 0, 100 ) < 5 ) // 5% of chance
					{
						if( rng.uniform( 0, 100 ) < 25 ) // 25% of chance
							value += 2;
						else
							++value;
					}
				}
				
				config[ i ] = value;
			}
					
			if( constraint_concept->constraint_concept( config, 0, nb_vars ) )
			{
				if( !has_been_drawned.contains( convert_to_string( config ) ) )
				{
					has_been_drawned[ convert_to_string( config ) ] = true;
					output_file << "0 : ";
					std::copy( config.begin(),
					           config.end(),
					           ostream_iterator<int>( output_file, " " ) );				
					output_file << "\n";
					++count;
				}
			}
		}
	}
		
	if( constraint.compare("no") == 0 )
	{
		int length = static_cast<int>( params_value );
		while( count < samplings )
		{
			int total_length = nb_vars * length;
			int remain = max_value - total_length;
			int last_value = 0;
			int value = 0;
			
			for( int i = 0 ; i < nb_vars ; ++i )
			{
				value = last_value;
				
				if( remain > 0 )
					value += rng.uniform( 0, remain );
				
				config[i] = value;
				
				last_value = value + length;
				total_length -= length;
				remain = max_value - ( total_length + last_value );
			}
			
			if( constraint_concept->constraint_concept( config, 0, nb_vars ) )
			{
				if( !has_been_drawned.contains( convert_to_string( config ) ) )
				{
					has_been_drawned[ convert_to_string( config ) ] = true;
					output_file << "0 : ";
					std::copy( config.begin(),
					           config.end(),
					           ostream_iterator<int>( output_file, " " ) );				
					output_file << "\n";
					++count;
				}
			}
		}
	}

	if( constraint.compare("ch") == 0 )
	{
		while( count < samplings )
		{
			std::iota( config.begin(), config.end(), 1 );

			int number_swaps = rng.uniform( 1, 10 );
			for( int i = 0 ; i < number_swaps ; ++i )
			{
				int var1 = rng.uniform( 0, nb_vars );
				int var2 = rng.uniform( 0, nb_vars );
				std::swap( config[var1], config[var2] );
			}

			if( constraint_concept->constraint_concept( config, 0, nb_vars ) )
			{
				if( !has_been_drawned.contains( convert_to_string( config ) ) )
				{
					has_been_drawned[ convert_to_string( config ) ] = true;
					output_file << "0 : ";
					std::copy( config.begin(),
					           config.end(),
					           ostream_iterator<int>( output_file, " " ) );				
					output_file << "\n";
					++count;
				}
			}
		}
	}

	for( int i = 0; i < (int)random_candidates.size(); i += nb_vars )
	{
		output_file << "1 : ";
		std::copy( random_candidates.begin() + i,
		           random_candidates.begin() + i + nb_vars,
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
