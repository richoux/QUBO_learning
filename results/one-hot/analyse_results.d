#!/usr/bin/rdmd

import std.stdio;
import std.string;
import std.math;
import std.algorithm;
import std.conv;
import std.file;
import std.process;

void usage( string prog_name )
{
	auto prog = prog_name.split("/");
	writeln( "Usage: ", prog[$-1], " RESULT_FILE" );
	writeln( "Example: ", prog[$-1], " alldiff_complete_patterns" );	
}

int dictionary_value( string filename_dictionary, string pattern_vector )
{
	if( !filename_dictionary.exists )
		return -1;

	File file_dictionary = File( filename_dictionary, "r" );
	
	foreach( line; file_dictionary.byLine() )
	{
		auto vector = to!string(line);
		if( vector.startsWith( pattern_vector ) )
		{
			file_dictionary.close();
			return to!int( vector.split(" ")[1] );
		}
	}
	
	file_dictionary.close();
	return -1;
}

int main( string[] args )
{
	if( args.length != 2 )
	{
		usage( args[0] );
		return 1;
	}

	string filename_pattern_vectors = args[1];
	string constraint = filename_pattern_vectors.split("-")[0];
	string filename_dictionary = constraint ~ "_dictionary";
	
	File file_pattern_vectors = File( filename_pattern_vectors, "r" );
	File file_dictionary;

	string filename_test;
	
	int[string] errors_per_patter_vector;
	int[string] number_vectors;

	foreach( line; file_pattern_vectors.byLine() )
	{
		auto vector = to!string(line);
		++number_vectors[vector];
		
		int error = dictionary_value( filename_dictionary, vector );
		
		if( error > -1 )
		{
			errors_per_patter_vector[ vector ] += error;
		}
		else
		{
			switch( constraint )
			{
			case "alldiff":
				filename_test = "../../spaces/test/alldiff-30_30.txt";
				break;
			case "ordered":
				filename_test = "../../spaces/test/ordered-30_30.txt";
				break;
			case "linear_equation":
				filename_test = "../../spaces/test/linear_equation-30_30_600.txt";
				break;
			case "no_overlap_1D":
				filename_test = "../../spaces/test/no_overlap_1D-20_160_6.txt";
				break;
			case "channel":
				filename_test = "../../spaces/test/channel-30_30.txt";
				break;
			default:
			}

			auto solution_tmp = "solution_tmp";
			File file_solution = File( solution_tmp, "w" );
			file_solution.writeln( "Solution" );
			string solution;
			foreach( ch; vector )
			{
				solution ~= ch ~ " ";
			}
			file_solution.writeln( solution );
			file_solution.close();

			string command = "../../bin/learn_q_opt -f " ~ filename_test ~ " -c solution_tmp --benchmark 2> /dev/null";
			writeln( "Executing ../../bin/learn_q_opt -f " ~ filename_test ~ " -c " ~ vector ~ " --benchmark 2> /dev/null" );
			auto exe = executeShell( command );
			if( exe.status != 0 )
				writeln("Failed to retrieve file listing");
			else
			{
				string output = "0"; // 0 by default, replaced by 1 if we realize it is not a solution
				errors_per_patter_vector[ vector ] = 0;
				if( !exe.output.startsWith("0") )
				{
					output = "1";
					errors_per_patter_vector[ vector ] = 1;
				}
				
				file_dictionary = File( filename_dictionary, "a+" );
				file_dictionary.writeln( vector ~ " " ~ output );
				file_dictionary.close();
			}
			solution_tmp.remove;
		}
	}

	int total_vectors = 0;
	int total_errors = 0;
	foreach( k, v; errors_per_patter_vector)
	{
		writeln("Number of " ~ k ~ ": " ~ to!string( number_vectors[k] ) ~ ". Errors: " ~ to!string(v) );
		total_vectors += number_vectors[k];
		total_errors += v;
	}
	writeln( "Total errors: " ~ to!string( total_errors ) ~ "/" ~ to!string( total_vectors ) );
	
	return 0;
}
