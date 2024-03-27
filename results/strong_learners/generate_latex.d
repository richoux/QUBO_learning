#!/usr/bin/rdmd

import std.stdio;
import std.string;
import std.math;
import std.algorithm;
import std.uni: isWhite;
import std.conv;
import std.process;

void usage( string prog_name )
{
	auto prog = prog_name.split("/");
	writeln( "Usage: ", prog[$-1], "  data_path" );
	writeln( "Example: ", prog[$-1], " random_start/sampled_training_set/opt/" );	
}

int main( string[] args )
{
	if( args.length != 2 )
	{
		usage( args[0] );
		return 1;
	}

	string path = args[1];
	if( !endsWith( path, "/" ) )
		path ~= "/";

	string caption_errors = "Strong learners success rate and statistics of their training and test errors over 100 runs. ";
	string caption_solutions = "Strong learners solutions and their statistics over 100 runs ";

	string output_name = "";
	if( canFind( path, "random" ) )
	{
		output_name ~= "random";
		caption_errors ~= "Random starting point, ";
	}
	else
	{
		output_name ~= "same";
		caption_errors ~= "Fixed starting point, ";
	}
	
	string sampled = "";
	if( canFind( path, "sampled" ) )
	{
		sampled = "n";
		output_name ~= "_sampled";
		caption_errors ~= "sampled training set, ";
	}
	else
	{
		output_name ~= "_fixed";
		caption_errors ~= "fixed training set, ";
	}
	
	if( canFind( path, "sat" ) )
	{
		output_name ~= "_sat.tex";
		caption_errors ~= "satisfaction runs.";
	}
	else
	{
		output_name ~= "_opt.tex";
		caption_errors ~= "optimization runs.";
	}
		
	auto output = File( output_name, "w" );

	double[5][5] success_training;
	double[5][5] success_test;

	double[5][5] mean_training;
	double[5][5] mean_test;

	double[5][5] median_training;
	double[5][5] median_test;

	double[5][5] min_training;
	double[5][5] min_test;

	double[5][5] max_training;
	double[5][5] max_test;

	double[5][5] std_training;
	double[5][5] std_test;

	string[][string][5] solutions; // array of 5 constraints (index) of associative arrays (solutions) of arrays of strings (training size)

	foreach( index_c, constraint; ["alldiff-12_12_","ordered-12_12_","linear_equation-12_12_72_","no_overlap_1D-8_35_3_","channel-12_12_"] )
	{		
		foreach( index_n, n; [1,2,3,4,5] )
		{
			double samples = n;
			if( sampled == "n" )
				samples *= 2;
				
			auto command = "./analyse_results.d " ~ path ~ constraint ~ sampled ~ to!string(samples);
			auto buf = executeShell( command );
			auto lines = buf.output.split("\n");

			foreach( line; lines )
			{
				auto words = line.split(": ");

				if( startsWith( line, "Training success rate" ) )
					success_training[index_c][index_n] = to!double(words[1]);

				if( startsWith( line, "Training solution" ) )
				{
					string solution = to!string(((words[0].replace("Training solution ", "")).replace("  success rate", "")).filter!(c => !c.isWhite));
					if( solution !in solutions[index_c] )					
						solutions[index_c][solution] = new string[10];

					solutions[index_c][solution][index_n] = words[1];					
				}
				
				if( startsWith( line, "Test success rate" ) )
					success_test[index_c][index_n] = to!double(words[1]);

				if( startsWith( line, "Test solution" ) )
				{
					string solution = to!string(((words[0].replace("Test solution ", "")).replace("  success rate", "")).filter!(c => !c.isWhite));
					if( solution !in solutions[index_c] )					
						solutions[index_c][solution] = new string[10];

					solutions[index_c][solution][index_n+5] = words[1];					
				}

				if( startsWith( line, "Mean training error" ) )
					mean_training[index_c][index_n] = to!double(words[1]);

				if( startsWith( line, "Mean test error" ) )
					mean_test[index_c][index_n] = to!double(words[1]);

				if( startsWith( line, "Median training error" ) )
					median_training[index_c][index_n] = to!double(words[1]);
				
				if( startsWith( line, "Median test error" ) )
					median_test[index_c][index_n] = to!double(words[1]);

				if( startsWith( line, "Min training error" ) )
					min_training[index_c][index_n] = to!double(words[1]);

				if( startsWith( line, "Min test error" ) )
					min_test[index_c][index_n] = to!double(words[1]);

				if( startsWith( line, "Max training error" ) )
					max_training[index_c][index_n] = to!double(words[1]);

				if( startsWith( line, "Max test error" ) )
					max_test[index_c][index_n] = to!double(words[1]);

				if( startsWith( line, "Training error std dev" ) )
					std_training[index_c][index_n] = to!double(words[1]);

				if( startsWith( line, "Test error std dev" ) )
					std_test[index_c][index_n] = to!double(words[1]);			
			}
		}
	}	
	
	output.write("\\begin{table*}[h]
  \\small
  \\caption{", caption_errors, "}
  \\begin{center}
    \\begin{tabular}{|c|c||r|r|r|r|r||r|r|r|r|r|}
      \\cline{3-12}
      \\multicolumn{2}{c|}{} & \\multicolumn{5}{c||}{Training success (train size)} & \\multicolumn{5}{c|}{Test success (train size)}\\\\
      \\cline{3-12}
      \\multicolumn{2}{c|}{} & 2 & 4 & 6 & 8 & 10 & 2 & 4 & 6 & 8 & 10\\\\
      \\hline
");

	foreach( index_c, constraint; ["AllDifferent","Ordered","Linear Equation","NoOverlap1D","Channel"] )
	{
		auto line_rate = "Success rate ";
		auto line_mean = "      & \\cellcolor{LightCyan}Mean ";
		auto line_median = "      & Median ";
		auto line_min = "      & \\cellcolor{LightCyan}Min ";
		auto line_max = "      & Max ";
		auto line_std = "      & \\cellcolor{LightCyan}Std dev ";

		output.write("      \\parbox[t]{2mm}{\\multirow{6}{*}{\\rotatebox[origin=c]{90}{" , constraint, "}}} & ");
		
		foreach( index; [0,1,2,3,4] )
		{
			line_rate ~= ( " & " ~ to!string( success_training[index_c][index] ) );
			line_mean ~= ( " & \\cellcolor{LightCyan}" ~ to!string( mean_training[index_c][index] ) );
			line_median ~= ( " & " ~ to!string( median_training[index_c][index] ) );
			line_min ~= ( " & \\cellcolor{LightCyan}" ~ to!string( min_training[index_c][index] ) );
			line_max ~= ( " & " ~ to!string( max_training[index_c][index] ) );
			line_std ~= ( " & \\cellcolor{LightCyan}" ~ to!string( std_training[index_c][index] ) );
		}

		foreach( index; [0,1,2,3,4] )
		{
			line_rate ~= ( " & " ~ to!string( success_test[index_c][index] ) );
			line_mean ~= ( " & \\cellcolor{LightCyan}" ~ to!string( mean_test[index_c][index] ) );
			line_median ~= ( " & " ~ to!string( median_test[index_c][index] ) );
			line_min ~= ( " & \\cellcolor{LightCyan}" ~ to!string( min_test[index_c][index] ) );
			line_max ~= ( " & " ~ to!string( max_test[index_c][index] ) );
			line_std ~= ( " & \\cellcolor{LightCyan}" ~ to!string( std_test[index_c][index] ) );
		}

		line_rate ~= "\\\\";
		line_mean ~= "\\\\";
		line_median ~= "\\\\";
		line_min ~= "\\\\";
		line_max ~= "\\\\";
		line_std ~= "\\\\";

		output.writeln( line_rate );
		output.writeln( line_mean );
		output.writeln( line_median );
		output.writeln( line_min );
		output.writeln( line_max );
		output.writeln( line_std );
		output.writeln("      \\hline");
	}

	output.writeln("      \\end{tabular}
  \\end{center}
\\end{table*}");

	foreach( index_c, constraint; ["AllDifferent","Ordered","Linear Equation","NoOverlap1D","Channel"] )
	{
			output.write("
\\afterpage{%
  \\clearpage%
  \\thispagestyle{empty}%
  \\begin{landscape}
  \\begin{table*}[h]
    \\small
    \\caption{", caption_solutions, "for the constraint ", constraint, ".}
    \\begin{center}
      \\begin{tabular}{|c|c||c|c|c|c|c||c|c|c|c|c|}
        \\cline{3-12}
        \\multicolumn{2}{c|}{} & \\multicolumn{5}{c||}{Training (train size)} & \\multicolumn{5}{c|}{Test (train size)}\\\\
        \\cline{3-12}
        \\multicolumn{2}{c|}{} & 2 & 4 & 6 & 8 & 10 & 2 & 4 & 6 & 8 & 10\\\\
        \\hline
");

		output.write("        \\parbox[t]{2mm}{\\multirow{", solutions[index_c].length, "}{*}{\\rotatebox[origin=c]{90}{" , constraint, "}}} ");

		foreach( sol, values; solutions[index_c] )
		{
			auto line = "        & " ~ sol;
	
			foreach( index; [0,1,2,3,4,5,6,7,8,9] )
			{
				line ~= ( " & " ~ to!string( values[index] ) );
			}
						
			line ~= "\\\\";

			output.writeln( line );
		}
		
		output.writeln("        \\hline");

		output.writeln("        \\end{tabular}
    \\end{center}
  \\end{table*}
  \\end{landscape}
  \\clearpage%
}");
	}
	
	output.close();	
	return 0;
}
