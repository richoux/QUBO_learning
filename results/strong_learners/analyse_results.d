#!/usr/bin/rdmd

import std.stdio;
import std.string;
import std.math;
import std.algorithm;
import std.conv;

void usage( string prog_name )
{
	auto prog = prog_name.split("/");
	writeln( "Usage: ", prog[$-1], " FILE_without_suffix [sumup]" );
	writeln( "Example: ", prog[$-1], " alldiff-12_12_weak_w3-n2" );	
}

double median( double[] array )
{
	array.sort();
	if( array.length % 2 == 0 )
		return array[ $ / 2 ];
	else
		return ( array[ ($ - 1) / 2 ] + array[ $ / 2 ] ) / 2;
}

double pop_standard_deviation( double[] array )
{
	auto mean = array.mean;
	array[] -= mean;
	array[] ^^= 2;
	return sqrt( sum( array ) / array.length );
}

int main( string[] args )
{
	if( args.length < 2 || args.length > 3 || ( args.length == 3 && args[2] != "sumup" ) )
	{
		usage( args[0] );
		return 1;
	}

	auto filename_test_error = args[1] ~ "-test_error";
	auto filename_training = args[1] ~ "-training";
	
	auto file_test_error = File( filename_test_error );
	auto file_training = File( filename_training );

	auto file_test_error_lines = file_test_error.byLine();
	auto file_training_lines = file_training.byLine();

	bool verbose = ( args.length == 2 || args[2] != "sumup" );
		
	double[] error_training;
	double[] error_test;

	// Training data
	uint success_training = 0;
	uint[string] success_training_per_solution;
	uint[string] frequency_training_per_solution;

	// Test data
	uint success_test = 0;
	uint[string] success_test_per_solution;
	uint[string] frequency_test_per_solution;

	int line_number = 1;
	foreach( line; file_training_lines )
	{
		if( line_number % 2 == 1 ) // lines with training error
			error_training ~= to!double( line );
		else // lines with a Q-matrix representation
		{
			string linestring = to!string(line);
			++frequency_training_per_solution[linestring];
			if( error_training[$-1] == 0 )
			{
				++success_training;
				++success_training_per_solution[linestring];
			}
		}
		
		++line_number;
	}

	line_number = 1;
	foreach( line; file_test_error_lines )
	{
		if( line_number % 2 == 1 ) // lines with test error
			error_test ~= to!double( line );
		else // lines with a Q-matrix representation
		{
			string linestring = to!string(line);
			++frequency_test_per_solution[linestring];
			if( error_test[$-1] == 0 )
			{
				++success_test;
				++success_test_per_solution[linestring];
			}
		}
		
		++line_number;
	}

	if( verbose )
		writeln("*** Training results ***");
	writeln("Training success rate: ", success_training );

	if( verbose )
	{
		foreach( key, value; frequency_training_per_solution )
		{
			uint success_rate = 0;
			if( key in success_training_per_solution )
				success_rate = success_training_per_solution[key];
			writeln("Training solution ", key, " success rate: ", success_rate, "/", value );
		}
	}

	if( verbose )
		writeln("\n*** Test results ***");
	writeln("Test success rate: ", success_test );

	if( verbose )
	{
		foreach( key, value; frequency_test_per_solution )
		{
			uint success_rate = 0;
			if( key in success_test_per_solution )
				success_rate = success_test_per_solution[key];
			writeln("Test solution ", key, " success rate: ", success_rate, "/", value );
		}
	}
	
	if( error_training.length != 100 )
		writefln( "Warning: we do not have 100 solutions after training but ", error_training.length, "." );

	if( error_test.length != 100 )
		writefln( "Warning: we do not have 100 solutions after tests but ", error_test.length, "." );
	
	double mean_error_training = error_training.mean.quantize(0.1);
	if( verbose )
		writeln("\n*** Training error stats ***");
	writeln( "Mean training error: ", mean_error_training );
	writeln( "Median training error: ", median(error_training).quantize(0.1) );
	writeln( "Min training error: ", error_training.minElement.quantize(0.1) );
	writeln( "Max training error: ", error_training.maxElement.quantize(0.1) );
	writeln( "Training error std dev: ", pop_standard_deviation(error_training).quantize(0.1) );

	double mean_error_test = error_test.mean.quantize(0.1);
	if( verbose )
		writeln("\n*** Test error stats ***");
	writeln( "Mean test error: ", mean_error_test );
	writeln( "Median test error: ", median(error_test).quantize(0.1) );
	writeln( "Min test error: ", error_test.minElement.quantize(0.1) );
	writeln( "Max test error: ", error_test.maxElement.quantize(0.1) );
	writeln( "Test error std dev: ", pop_standard_deviation(error_test).quantize(0.1) );
	
	return 0;
}
