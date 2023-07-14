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

	auto filename_test_error_majority = args[1] ~ "-test_error_majority";
	auto filename_training = args[1] ~ "-training";
	
	auto file_test_error_majority = File( filename_test_error_majority );
	auto file_training = File( filename_training );

	auto file_test_error_majority_lines = file_test_error_majority.byLine();
	auto file_training_lines = file_training.byLine();

	bool verbose = ( args.length == 2 || args[2] != "sumup" );
	
	// Training data
	uint number_success_success_majority; // number of times weak learners were all valid, as well as their majority
	uint number_success_fail_majority; // number of times weak learners were all valid, but their majority was not
	uint number_fail_success_majority; // number of times some weak learners were not valid, but their majority was
	uint number_fail_fail_majority; // number of times some weak learners were not valid, as well as their majority

	double[] error_training_majority;
	
	double[] wallclock_time;
	double[] weak_runtimes_all;
	double[] weak_runtimes_slowest;

	uint success_training_majority;
	uint[string] success_training_majority_per_solution;
	uint[string] frequency_training_majority_per_solution;

	// Test data
	uint success_test_majority;
	uint[string] success_test_majority_per_solution;
	uint[string] frequency_test_majority_per_solution;

	double[] error_test_majority;

	int line_number = 1;
	foreach( line; file_test_error_majority_lines )
	{
		if( line_number % 2 == 1 ) // lines with training error
			error_test_majority ~= to!double( line );
		else // lines with a Q-matrix representation
		{
			string linestring = to!string(line);
			++frequency_test_majority_per_solution[linestring];
			if( error_test_majority[$-1] == 0 )
			{
				++success_test_majority;
				++success_test_majority_per_solution[linestring];
			}
		}
		
		++line_number;
	}

	uint count_number_weaks = 0;
	bool all_success = false;
	string linestring;
	foreach( line; file_training_lines )
	{
		auto words = line.split(": ");

		if( startsWith( line, "Weak learner" ) )
		{
			auto runtime = to!double( words[1].split("us")[0]) / 1000;
			weak_runtimes_all ~= runtime;
			++count_number_weaks;
		}

		if( startsWith( line, "Majority solution" ) )
		{
			linestring = to!string( words[1] );
			++frequency_training_majority_per_solution[linestring];
		}

		if( startsWith( line, "Errors by majority" ) )
		{
			auto error = to!double( words[1] );
			error_training_majority ~= error;
			if( error == 0 )
			{
				++success_training_majority;
				++success_training_majority_per_solution[linestring]; // the last value of linestring should correpond to the correct solution
			}
		}

		if( startsWith( line, "All weak learners valid" ) )
		{
			all_success = to!bool( words[1] );
		}

		if( startsWith( line, "Wallclock" ) )
		{
			auto runtime = to!double( words[1].split("us")[0]) / 1000;
			wallclock_time ~= runtime;

			if( all_success )
			{
				if( error_training_majority[$-1] == 0 )
					++number_success_success_majority;
				else
					++number_success_fail_majority;
			}
			else
			{
				if( error_training_majority[$-1] == 0 )
					++number_fail_success_majority;
				else
					++number_fail_fail_majority;
			}
			
			weak_runtimes_slowest ~= weak_runtimes_all[$-count_number_weaks .. $].maxElement;
			count_number_weaks = 0;
		}
	}
	
	if( error_training_majority.length != 100 )
		writefln( "Warning: we do not have 100 majority solutions but ", error_training_majority.length, "." );

	if( verbose )
		writeln("*** Training results ***");
	writeln("Majority training success rate: ", success_training_majority );
	if( verbose )
	{
		writeln();
		foreach( key, value; frequency_training_majority_per_solution )
		{
			uint success = 0;
			if( key in success_training_majority_per_solution )
				success = success_training_majority_per_solution[key];
			writeln("Majority ", key, " training success rate: ", success, "/", value );
		}
	}

	double mean_error_training_majority = error_training_majority.mean.quantize(0.1);
	if( verbose )
		writeln("\n*** Training majority error stats ***");
	writeln( "Mean training majority error: ", mean_error_training_majority );
	writeln( "Median training majority error: ", median(error_training_majority).quantize(0.1) );
	writeln( "Min training majority error: ", error_training_majority.minElement.quantize(0.1) );
	writeln( "Max training majority error: ", error_training_majority.maxElement.quantize(0.1) );
	writeln( "Training majority error std dev: ", pop_standard_deviation(error_training_majority).quantize(0.1) );

	if( verbose )
	{
		writeln("\n*** Training success/failure situations ***");
		writeln( "Number of times weak learners were all valid, as well as their majority: ", number_success_success_majority );
		writeln( "Number of times weak learners were all valid, but their majority was not: ", number_success_fail_majority );
		writeln( "Number of times some weak learners were invalid, but their majority was: ", number_fail_success_majority );
		writeln( "Number of times some weak learners were invalid, as well as their majority: ", number_fail_fail_majority );
	}
	
	double mean = wallclock_time.mean.quantize(0.1);
	if( verbose )
		writeln("\n*** Wallclock runtimes ***");
	writeln( "Mean wallclock runtime: ", mean, "ms" );
	writeln( "Median wallclock runtime: ", median(wallclock_time).quantize(0.1), "ms" );
	writeln( "Min wallclock runtime: ", wallclock_time.minElement.quantize(0.1), "ms" );
	writeln( "Max wallclock runtime: ", wallclock_time.maxElement.quantize(0.1), "ms" );
	writeln( "Wallclock std dev: ", pop_standard_deviation(wallclock_time).quantize(0.1), "ms" );

	double weak_mean = weak_runtimes_all.mean.quantize(0.1);
	if( verbose )
		writeln("\n*** Weak learners runtimes ***");
	writeln( "Mean weak learners runtime: ", weak_mean, "ms" );
	writeln( "Median weak learners runtime: ", median(weak_runtimes_all).quantize(0.1), "ms" );
	writeln( "Min weak learners runtime: ", weak_runtimes_all.minElement.quantize(0.1), "ms" );
	writeln( "Max weak learners runtime: ", weak_runtimes_all.maxElement.quantize(0.1), "ms" );
	writeln( "Weak learners std dev: ", pop_standard_deviation(weak_runtimes_all).quantize(0.1), "ms" );

	double slowest_weak_mean = weak_runtimes_slowest.mean.quantize(0.1);
	if( verbose )
		writeln("\n*** Slowest weak learners runtimes ***");
	writeln( "Mean slowest weak learners runtime: ", slowest_weak_mean, "ms" );
	writeln( "Median slowest weak learners runtime: ", median(weak_runtimes_slowest).quantize(0.1), "ms" );
	writeln( "Min slowest weak learners runtime: ", weak_runtimes_slowest.minElement.quantize(0.1), "ms" );
	writeln( "Max slowest weak learners runtime: ", weak_runtimes_slowest.maxElement.quantize(0.1), "ms" );
	writeln( "Slowest weak learners std dev: ", pop_standard_deviation(weak_runtimes_slowest).quantize(0.1), "ms" );

	if( verbose )
		writeln("\n\n*** Test results ***");
	writeln("Majority test success rate: ", success_test_majority );
	if( verbose )
	{
		writeln();
		foreach( key, value; frequency_test_majority_per_solution )
		{
			uint success = 0;
			if( key in success_test_majority_per_solution )
				success = success_test_majority_per_solution[key];
			writeln("Majority ", key, " test success rate: ", success, "/", value );
		}
	}

	double mean_error_test_majority = error_test_majority.mean.quantize(0.1);
	if( verbose )
		writeln("\n*** Test majority error stats ***");
	writeln( "Mean test majority error: ", mean_error_test_majority );
	writeln( "Median test majority error: ", median(error_test_majority).quantize(0.1) );
	writeln( "Min test majority error: ", error_test_majority.minElement.quantize(0.1) );
	writeln( "Max test majority error: ", error_test_majority.maxElement.quantize(0.1) );
	writeln( "Test majority error std dev: ", pop_standard_deviation(error_test_majority).quantize(0.1) );

	return 0;
}
