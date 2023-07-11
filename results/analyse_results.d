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

	auto filename_majority = args[1] ~ "-majority";
	auto filename_mean = args[1] ~ "-mean";
	auto filename_test_error_majority = args[1] ~ "-test_error_majority";
	auto filename_test_error_mean = args[1] ~ "-test_error_mean";
	auto filename_training = args[1] ~ "-training";
	
	auto file_majority = File( filename_majority );
	auto file_mean = File( filename_mean );
	auto file_test_error_majority = File( filename_test_error_majority );
	auto file_test_error_mean = File( filename_test_error_mean );
	auto file_training = File( filename_training );

	// auto output_name = args[1] ~ ".tex";
	// auto output = File( output_name, "w" );
	
	auto file_majority_lines = file_majority.byLine();
	auto file_mean_lines = file_mean.byLine();
	auto file_test_error_majority_lines = file_test_error_majority.byLine();
	auto file_test_error_mean_lines = file_test_error_mean.byLine();
	auto file_training_lines = file_training.byLine();

	bool verbose = ( args.length == 2 || args[2] != "sumup" );
	
	string[] majority_solutions;
	string[] mean_solutions;
	
	// Training data
	uint number_success_success_majority; // number of times weak learners were all valid, as well as their majority
	uint number_success_fail_majority; // number of times weak learners were all valid, but their majority was not
	uint number_fail_success_majority; // number of times some weak learners were not valid, but their majority was
	uint number_fail_fail_majority; // number of times some weak learners were not valid, as well as their majority
	
	uint number_success_success_mean;
	uint number_success_fail_mean;
	uint number_fail_success_mean;
	uint number_fail_fail_mean;

	uint[] error_training_majority;
	uint[] error_training_mean;
	
	double[] wallclock_time;
	double[] weak_runtimes_all;
	double[] weak_runtimes_slowest;

	// Test data
	uint success_majority;
	uint success_mean;
	uint[string] success_majority_per_solution;
	uint[string] success_mean_per_solution;	
	uint[string] frequency_majority_per_solution;
	uint[string] frequency_mean_per_solution;	

	foreach( line; file_majority_lines )
		if( !startsWith( line, "Solution" ) )
			majority_solutions ~= to!string( line );

	foreach( line; file_mean_lines )
		if( !startsWith( line, "Solution" ) )
			mean_solutions ~= to!string( line );

	int index = 0;
	foreach( line; file_test_error_majority_lines )
	{
		++frequency_majority_per_solution[ majority_solutions[ index ] ];

		if( line == "0" )
		{
			++success_majority;
			++success_majority_per_solution[ majority_solutions[ index ] ];
		}
		
		++index;
	}

	index = 0;
	foreach( line; file_test_error_mean_lines )
	{
		++frequency_mean_per_solution[ mean_solutions[ index ] ];

		if( line == "0" )
		{
			++success_mean;
			++success_mean_per_solution[ mean_solutions[ index ] ];
		}
		
		++index;
	}

	if( verbose )
		writeln("*** Test results ***");
	writeln("Majority success rate: ", success_majority );
	writeln("Mean success rate: ", success_mean );

	if( verbose )
	{
		writeln();
		foreach( key, value; success_majority_per_solution )
			writeln("Majority ", key, " success rate: ", value, "/", frequency_majority_per_solution[key] );
		
		writeln();
		foreach( key, value; success_mean_per_solution )
			writeln("Mean ", key, " success rate: ", value, "/", frequency_mean_per_solution[key] );
	}
	
	uint count_number_weaks = 0;
	bool all_success = false;
	foreach( line; file_training_lines )
	{
		auto words = line.split(": ");

		if( startsWith( line, "Weak learner" ) )
		{
			auto runtime = to!double( words[1].split("us")[0]) / 1000;
			weak_runtimes_all ~= runtime;
			++count_number_weaks;
		}

		if( startsWith( line, "Errors by mean" ) )
		{
			error_training_mean ~= to!uint( words[1] );
		}
		
		if( startsWith( line, "Errors by majority" ) )
		{
			error_training_majority ~= to!uint( words[1] );
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
				if( error_training_mean[$-1] == 0 )
					++number_success_success_mean;
				else
					++number_success_fail_mean;
				
				if( error_training_majority[$-1] == 0 )
					++number_success_success_majority;
				else
					++number_success_fail_majority;
			}
			else
			{
				if( error_training_mean[$-1] == 0 )
					++number_fail_success_mean;
				else
					++number_fail_fail_mean;
				
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
	if( error_training_mean.length != 100 )
		writefln( "Warning: we do not have 100 mean solutions but ", error_training_mean.length, "." );

	if( verbose )
	{
		writeln("\n*** Success/failure situations ***");
		writeln( "Number of times weak learners were all valid, as well as their majority: ", number_success_success_majority );
		writeln( "Number of times weak learners were all valid, but their majority was not: ", number_success_fail_majority );
		writeln( "Number of times some weak learners were invalid, but their majority was: ", number_fail_success_majority );
		writeln( "Number of times some weak learners were invalid, as well as their majority: ", number_fail_fail_majority );
		writeln("------");
		writeln( "Number of times weak learners were all valid, as well as their mean: ", number_success_success_mean );
		writeln( "Number of times weak learners were all valid, but their mean was not: ", number_success_fail_mean );
		writeln( "Number of times some weak learners were invalid, but their mean was: ", number_fail_success_mean );
		writeln( "Number of times some weak learners were invalid, as well as their mean: ", number_fail_fail_mean );
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

// 	output.write("
// \\begin{table*}[h]\n
//   \\small\n
//   \\caption{Success rate over 100 runs on test sets. Timeout is fixed at 1s for each run.}\n
//   \\begin{center}\n
//      %\\rowcolors{1}{}{LightCyan}
//     \\begin{tabular}{@{}|c|c|c|c|c|c|@{}}
// ");
	
	return 0;
}
