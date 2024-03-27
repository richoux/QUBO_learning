#!/usr/bin/rdmd

import std.stdio;
import std.string;
import std.math;
import std.algorithm;
import std.uni: isWhite;
import std.conv;
import std.process;
import std.file: exists;

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
	
	string caption_errors = "Weak learners success rate and statistics of their training and test errors over 100 runs. ";
	string caption_solutions = "Weak learners solutions and their statistics over 100 runs ";

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
	
	string sampled;
	if( canFind( path, "sampled" ) )
	{
		sampled = "n";
		output_name ~= "_sampled";
		caption_errors ~= "sampled training set, ";
	}
	else
	{
		sampled = "c";
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

	string script_name;
	bool has_mean;
	auto mean_file = path ~ "alldiff-12_12_weak_w3-";
	if( sampled == "n" )
		mean_file ~= "n2";
	else
		mean_file ~= "c1";
	mean_file ~= "-test_error_mean";
	
	if( mean_file.exists )
	{
		script_name = "./analyse_results.d ";
		has_mean = true;
	}
	else
	{
		script_name = "./analyse_results_without_mean.d ";		
		has_mean = false;
	}
	
	foreach( index_c, constraint; ["alldiff-12_12_weak_w","ordered-12_12_weak_w","linear_equation-12_12_72_weak_w","no_overlap_1D-8_35_3_weak_w","channel-12_12_weak_w"] )
	{
		string constraint_name;
		switch( index_c )
		{
		case 0:
			constraint_name = "AllDifferent";
			break;
		case 1:
			constraint_name = "Ordered";
			break;
		case 2:
			constraint_name = "LinearEquation";
			break;
		case 3:
			constraint_name = "NoOverlap1D";
			break;
		default:
			constraint_name = "Channel";
			break;
		}
		
		// majority
		double[5][4] success_training_majority;
		double[5][4] success_test_majority;

		double[5][4] mean_training_majority;
		double[5][4] mean_test_majority;

		double[5][4] median_training_majority;
		double[5][4] median_test_majority;

		double[5][4] min_training_majority;
		double[5][4] min_test_majority;

		double[5][4] max_training_majority;
		double[5][4] max_test_majority;

		double[5][4] std_training_majority;
		double[5][4] std_test_majority;

		// mean
		double[5][4] success_training_mean;
		double[5][4] success_test_mean;

		double[5][4] mean_training_mean;
		double[5][4] mean_test_mean;

		double[5][4] median_training_mean;
		double[5][4] median_test_mean;

		double[5][4] min_training_mean;
		double[5][4] min_test_mean;

		double[5][4] max_training_mean;
		double[5][4] max_test_mean;

		double[5][4] std_training_mean;
		double[5][4] std_test_mean;

		string[][string][4] solutions_majority; // weak learners array (4 groups) of associative arrays (solutions) of arrays of strings (training size) 
		string[][string][4] solutions_mean; // weak learners array (4 groups) of associative arrays (solutions) of arrays of strings (training size) 

		string runtimes_wc_mean = "";
		string runtimes_wc_median = "";
		string runtimes_wc_min = "";
		string runtimes_wc_max = "";
		string runtimes_wc_std = "";

		string runtimes_wl_mean = "";
		string runtimes_wl_median = "";
		string runtimes_wl_min = "";
		string runtimes_wl_max = "";
		string runtimes_wl_std = "";

		string runtimes_swl_mean = "";
		string runtimes_swl_median = "";
		string runtimes_swl_min = "";
		string runtimes_swl_max = "";
		string runtimes_swl_std = "";

		foreach( index_w, w; [3,5,7,9] )
		{
			foreach( index_n, n; [1,2,3,4,5] )
			{
				double samples = n;
				if( sampled == "n" )
					samples *= 2;
				
				auto command = script_name ~ path ~ constraint ~ to!string(w) ~ "-" ~ sampled ~ to!string(samples);
				auto buf = executeShell( command );
				auto lines = buf.output.split("\n");
			
				foreach( line; lines )
				{
					auto words = line.split(": ");

					if( startsWith( line, "Training majority success rate" ) )
						success_training_majority[index_w][index_n] = to!uint(words[1]);

					if( startsWith( line, "Training mean success rate" ) )
						success_training_mean[index_w][index_n] = to!uint(words[1]);

					if( startsWith( line, "Training majority solution" ) )
					{
						string solution = to!string(((words[0].replace("Training majority solution ", "")).replace("  success rate", "")).filter!(c => !c.isWhite));
						if( solution !in solutions_majority[index_w] )					
							solutions_majority[index_w][solution] = new string[10];
						
						solutions_majority[index_w][solution][index_n] = words[1];					
					}

					if( startsWith( line, "Training mean solution" ) )
					{
						string solution = to!string(((words[0].replace("Training mean solution ", "")).replace("  success rate", "")).filter!(c => !c.isWhite));
						if( solution !in solutions_mean[index_w] )					
							solutions_mean[index_w][solution] = new string[10];
						
						solutions_mean[index_w][solution][index_n] = words[1];					
					}

					if( startsWith( line, "Test majority success rate" ) )
						success_test_majority[index_w][index_n] = to!uint(words[1]);

					if( startsWith( line, "Test mean success rate" ) )
						success_test_mean[index_w][index_n] = to!uint(words[1]);

					if( startsWith( line, "Test majority solution" ) )
					{
						string solution = to!string(((words[0].replace("Test majority solution ", "")).replace("  success rate", "")).filter!(c => !c.isWhite));
						if( solution !in solutions_majority[index_w] )					
							solutions_majority[index_w][solution] = new string[10];
						
						solutions_majority[index_w][solution][index_n+5] = words[1];					
					}

					if( startsWith( line, "Test mean solution" ) )
					{
						string solution = to!string(((words[0].replace("Test mean solution ", "")).replace("  success rate", "")).filter!(c => !c.isWhite));
						if( solution !in solutions_mean[index_w] )					
							solutions_mean[index_w][solution] = new string[10];
						
						solutions_mean[index_w][solution][index_n+5] = words[1];					
					}

					if( startsWith( line, "Mean training majority error" ) )
						mean_training_majority[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Mean test majority error" ) )
						mean_test_majority[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Median training majority error" ) )
						median_training_majority[index_w][index_n] = to!double(words[1]);
				
					if( startsWith( line, "Median test majority error" ) )
						median_test_majority[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Min training majority error" ) )
						min_training_majority[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Min test majority error" ) )
						min_test_majority[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Max training majority error" ) )
						max_training_majority[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Max test majority error" ) )
						max_test_majority[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Training majority error std dev" ) )
						std_training_majority[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Test majority error std dev" ) )
						std_test_majority[index_w][index_n] = to!double(words[1]);			

					if( startsWith( line, "Mean training mean error" ) )
						mean_training_mean[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Mean test mean error" ) )
						mean_test_mean[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Median training mean error" ) )
						median_training_mean[index_w][index_n] = to!double(words[1]);
				
					if( startsWith( line, "Median test mean error" ) )
						median_test_mean[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Min training mean error" ) )
						min_training_mean[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Min test mean error" ) )
						min_test_mean[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Max training mean error" ) )
						max_training_mean[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Max test mean error" ) )
						max_test_mean[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Training mean error std dev" ) )
						std_training_mean[index_w][index_n] = to!double(words[1]);

					if( startsWith( line, "Test mean error std dev" ) )
						std_test_mean[index_w][index_n] = to!double(words[1]);			

					if( endsWith( line, "ms" ) )
					{
						auto runtime = words[1].split("ms")[0];

						if( startsWith( line, "Mean wallclock runtime" ) )
							runtimes_wc_mean ~= ( " & " ~ runtime );
						if( startsWith( line, "Median wallclock runtime" ) )
							runtimes_wc_median ~= ( " & \\cellcolor{LightCyan}" ~ runtime );
						if( startsWith( line, "Min wallclock runtime" ) )
							runtimes_wc_min ~= ( " & " ~ runtime );
						if( startsWith( line, "Max wallclock runtime" ) )
							runtimes_wc_max ~= ( " & \\cellcolor{LightCyan}" ~ runtime );
						if( startsWith( line, "Wallclock std dev" ) )
							runtimes_wc_std ~= ( " & " ~ runtime );

						if( startsWith( line, "Mean weak learners runtime" ) )
							runtimes_wl_mean ~= ( " & " ~ runtime );
						if( startsWith( line, "Median weak learners runtime" ) )
							runtimes_wl_median ~= ( " & \\cellcolor{LightCyan}" ~ runtime );
						if( startsWith( line, "Min weak learners runtime" ) )
							runtimes_wl_min ~= ( " & " ~ runtime );
						if( startsWith( line, "Max weak learners runtime" ) )
							runtimes_wl_max ~= ( " & \\cellcolor{LightCyan}" ~ runtime );
						if( startsWith( line, "Weak learners std dev" ) )
							runtimes_wl_std ~= ( " & " ~ runtime );

						if( startsWith( line, "Mean slowest weak learners runtime" ) )
							runtimes_swl_mean ~= ( " & " ~ runtime );
						if( startsWith( line, "Median slowest weak learners runtime" ) )
							runtimes_swl_median ~= ( " & \\cellcolor{LightCyan}" ~ runtime );
						if( startsWith( line, "Min slowest weak learners runtime" ) )
							runtimes_swl_min ~= ( " & " ~ runtime );
						if( startsWith( line, "Max slowest weak learners runtime" ) )
							runtimes_swl_max ~= ( " & \\cellcolor{LightCyan}" ~ runtime );
						if( startsWith( line, "Slowest weak learners std dev" ) )
							runtimes_swl_std ~= ( " & " ~ runtime );
					}
				}
			}
		}

		runtimes_wc_mean ~= "\\\\\n";
		runtimes_wc_median ~= "\\\\\n";
		runtimes_wc_min ~= "\\\\\n";
		runtimes_wc_max ~= "\\\\\n";
		runtimes_wc_std ~= "\\\\\n";
		
		runtimes_wl_mean ~= "\\\\\n";
		runtimes_wl_median ~= "\\\\\n";
		runtimes_wl_min ~= "\\\\\n";
		runtimes_wl_max ~= "\\\\\n";
		runtimes_wl_std ~= "\\\\\n";
		
		runtimes_swl_mean ~= "\\\\\n";
		runtimes_swl_median ~= "\\\\\n";
		runtimes_swl_min ~= "\\\\\n";
		runtimes_swl_max ~= "\\\\\n";
		runtimes_swl_std ~= "\\\\\n";


		output.write("\\begin{table*}[h]
  \\small
  \\caption{", caption_errors, " Constraint ", constraint_name, " with majority.}
  \\begin{center}
    \\begin{tabular}{|c|c||r|r|r|r|r||r|r|r|r|r|}
      \\cline{3-12}
      \\multicolumn{2}{c|}{} & \\multicolumn{5}{c||}{Training} & \\multicolumn{5}{c|}{Test}\\\\
      \\cline{3-12}
      \\multicolumn{2}{c|}{} & \\multicolumn{5}{c||}{Training set size} & \\multicolumn{5}{c|}{Training set size}\\\\
      \\multicolumn{2}{c|}{} & 2 & 4 & 6 & 8 & 10 & 2 & 4 & 6 & 8 & 10\\\\
      \\hline
");

		foreach( index_w, w; [3,5,7,9] )
		{
			output.write("      \\parbox[t]{2mm}{\\multirow{6}{*}{\\rotatebox[origin=c]{90}{", w ," learners}}}");
			
			auto line_rate = " & success ";
			auto line_mean = "       & mean";
			auto line_median = "       & median";
			auto line_min = "       & min";
			auto line_max = "       & max";
			auto line_std = "       & std";
			
			foreach( index_n, n; [1,2,3,4,5] )
			{
				line_rate ~= ( " & \\cellcolor{LightCyan}" ~ to!string( success_training_majority[index_w][index_n] ) );
				line_mean ~= ( " & " ~ to!string( mean_training_majority[index_w][index_n] ) );
				line_median ~= ( " & \\cellcolor{LightCyan}" ~ to!string( median_training_majority[index_w][index_n] ) );
				line_min ~= ( " & " ~ to!string( min_training_majority[index_w][index_n] ) );
				line_max ~= ( " & \\cellcolor{LightCyan}" ~ to!string( max_training_majority[index_w][index_n] ) );
				line_std ~= ( " & " ~ to!string( std_training_majority[index_w][index_n] ) );
			}
			
			foreach( index_n, n; [1,2,3,4,5] )
			{
				line_rate ~= ( " & \\cellcolor{LightCyan}" ~ to!string( success_test_majority[index_w][index_n] ) );
				line_mean ~= ( " & " ~ to!string( mean_test_majority[index_w][index_n] ) );
				line_median ~= ( " & \\cellcolor{LightCyan}" ~ to!string( median_test_majority[index_w][index_n] ) );
				line_min ~= ( " & " ~ to!string( min_test_majority[index_w][index_n] ) );
				line_max ~= ( " & \\cellcolor{LightCyan}" ~ to!string( max_test_majority[index_w][index_n] ) );
				line_std ~= ( " & " ~ to!string( std_test_majority[index_w][index_n] ) );
			}
			
			line_rate ~= "\\\\";
			line_mean ~= "\\\\";
			line_median ~= "\\\\";
			line_min ~= "\\\\";
			line_max ~= "\\\\";
			line_std ~= "\\\\";
		
			output.writeln(line_rate);
			output.writeln(line_mean);
			output.writeln(line_median);
			output.writeln(line_min);
			output.writeln(line_max);
			output.writeln(line_std);

			output.writeln("      \\hline");
		}

		output.writeln("    \\end{tabular}
  \\end{center}
\\end{table*}");

		if( has_mean )
		{
			output.write("\\begin{table*}[h]
  \\small
  \\caption{", caption_errors, " Constraint ", constraint_name, " with mean.}
  \\begin{center}
    \\begin{tabular}{|c|c||r|r|r|r|r||r|r|r|r|r|}
      \\cline{3-12}
      \\multicolumn{2}{c|}{} & \\multicolumn{5}{c||}{Training} & \\multicolumn{5}{c|}{Test}\\\\
      \\cline{3-12}
      \\multicolumn{2}{c|}{} & \\multicolumn{5}{c||}{Training set size} & \\multicolumn{5}{c|}{Training set size}\\\\
      \\multicolumn{2}{c|}{} & 2 & 4 & 6 & 8 & 10 & 2 & 4 & 6 & 8 & 10\\\\
      \\hline
");

			foreach( index_w, w; [3,5,7,9] )
			{
				output.write("      \\parbox[t]{2mm}{\\multirow{6}{*}{\\rotatebox[origin=c]{90}{", w ," learners}}}");
				
				auto line_rate = " & success ";
				auto line_mean = "       & mean";
				auto line_median = "       & median";
				auto line_min = "       & min";
				auto line_max = "       & max";
				auto line_std = "       & std";
				
				foreach( index_n, n; [1,2,3,4,5] )
				{
					line_rate ~= ( " & \\cellcolor{LightCyan}" ~ to!string( success_training_mean[index_w][index_n] ) );
					line_mean ~= ( " & " ~ to!string( mean_training_mean[index_w][index_n] ) );
					line_median ~= ( " & \\cellcolor{LightCyan}" ~ to!string( median_training_mean[index_w][index_n] ) );
					line_min ~= ( " & " ~ to!string( min_training_mean[index_w][index_n] ) );
					line_max ~= ( " & \\cellcolor{LightCyan}" ~ to!string( max_training_mean[index_w][index_n] ) );
					line_std ~= ( " & " ~ to!string( std_training_mean[index_w][index_n] ) );
				}
				
				foreach( index_n, n; [1,2,3,4,5] )
				{
					line_rate ~= ( " & \\cellcolor{LightCyan}" ~ to!string( success_test_mean[index_w][index_n] ) );
					line_mean ~= ( " & " ~ to!string( mean_test_mean[index_w][index_n] ) );
					line_median ~= ( " & \\cellcolor{LightCyan}" ~ to!string( median_test_mean[index_w][index_n] ) );
					line_min ~= ( " & " ~ to!string( min_test_mean[index_w][index_n] ) );
					line_max ~= ( " & \\cellcolor{LightCyan}" ~ to!string( max_test_mean[index_w][index_n] ) );
					line_std ~= ( " & " ~ to!string( std_test_mean[index_w][index_n] ) );
				}
				
				line_rate ~= "\\\\";
				line_mean ~= "\\\\";
				line_median ~= "\\\\";
				line_min ~= "\\\\";
				line_max ~= "\\\\";
				line_std ~= "\\\\";
				
				output.writeln(line_rate);
				output.writeln(line_mean);
				output.writeln(line_median);
				output.writeln(line_min);
				output.writeln(line_max);
				output.writeln(line_std);
				
				output.writeln("      \\hline");
			}
			
			output.writeln("    \\end{tabular}
  \\end{center}
\\end{table*}");
		}
		
		foreach( index_w, w; [3,5,7,9] )
		{		
			output.write("
\\afterpage{%
  \\clearpage%
  \\thispagestyle{empty}%
  \\begin{landscape}
  \\begin{table*}[h]
    \\small
    \\caption{", caption_solutions, "for the constraint ", constraint_name, " considering the majority of ",  w, " weak learners.}
    \\begin{center}
      \\begin{tabular}{|c|c||c|c|c|c|c||c|c|c|c|c|}
        \\cline{3-12}
        \\multicolumn{2}{c|}{} & \\multicolumn{5}{c||}{Training (train size)} & \\multicolumn{5}{c|}{Test (train size)}\\\\
        \\cline{3-12}
        \\multicolumn{2}{c|}{} & 2 & 4 & 6 & 8 & 10 & 2 & 4 & 6 & 8 & 10\\\\
        \\hline
");
			
		output.write("        \\parbox[t]{2mm}{\\multirow{", solutions_majority[index_w].length, "}{*}{\\rotatebox[origin=c]{90}{" , constraint_name, "}}} ");

		foreach( sol, values; solutions_majority[index_w] )
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

		if( has_mean )
		{
			foreach( index_w, w; [3,5,7,9] )
			{		
				output.write("
\\afterpage{%
  \\clearpage%
  \\thispagestyle{empty}%
  \\begin{landscape}
  \\begin{table*}[h]
    \\small
    \\caption{", caption_solutions, "for the constraint ", constraint_name, " considering the mean of ",  w, " weak learners.}
    \\begin{center}
      \\begin{tabular}{|c|c||c|c|c|c|c||c|c|c|c|c|}
        \\cline{3-12}
        \\multicolumn{2}{c|}{} & \\multicolumn{5}{c||}{Training (train size)} & \\multicolumn{5}{c|}{Test (train size)}\\\\
        \\cline{3-12}
        \\multicolumn{2}{c|}{} & 2 & 4 & 6 & 8 & 10 & 2 & 4 & 6 & 8 & 10\\\\
        \\hline
");
				
				output.write("        \\parbox[t]{2mm}{\\multirow{", solutions_mean[index_w].length, "}{*}{\\rotatebox[origin=c]{90}{" , constraint_name, "}}} ");
				
				foreach( sol, values; solutions_mean[index_w] )
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
		}

		output.write("
\\afterpage{%
  \\clearpage%
  \\thispagestyle{empty}%
  \\begin{landscape}
    \\begin{table*}[h]
      \\tiny
      \\caption{Training runtimes over 100 runs for the constraint ", constraint_name, ".}
      \\begin{center}
        \\begin{tabular}{|c|c|r|r|r|r|r|r|r|r|r|r|r|r|r|r|r|r|r|r|r|r|}
          \\cline{3-22}
          \\multicolumn{1}{c}{} & &\\multicolumn{20}{c|}{Number weak learners}\\\\
          \\multicolumn{1}{c}{} & &\\multicolumn{5}{c|}{3} & \\multicolumn{5}{c|}{5} & \\multicolumn{5}{c|}{7} & \\multicolumn{5}{c|}{9}\\\\ 
          \\cline{3-22}
          \\multicolumn{1}{c}{} & &\\multicolumn{5}{c|}{Training set size} & \\multicolumn{5}{c|}{Training set size} & \\multicolumn{5}{c|}{Training set size} & \\multicolumn{5}{c|}{Training set size}\\\\
          \\multicolumn{1}{c}{} & &\\multicolumn{1}{c|}{2} & \\multicolumn{1}{c|}{4} & \\multicolumn{1}{c|}{6} & \\multicolumn{1}{c|}{8} & \\multicolumn{1}{c|}{10} & \\multicolumn{1}{c|}{2} & \\multicolumn{1}{c|}{4} & \\multicolumn{1}{c|}{6} & \\multicolumn{1}{c|}{8} & \\multicolumn{1}{c|}{10} & \\multicolumn{1}{c|}{2} & \\multicolumn{1}{c|}{4} & \\multicolumn{1}{c|}{6} & \\multicolumn{1}{c|}{8} & \\multicolumn{1}{c|}{10} & \\multicolumn{1}{c|}{2} & \\multicolumn{1}{c|}{4} & \\multicolumn{1}{c|}{6} & \\multicolumn{1}{c|}{8} & \\multicolumn{1}{c|}{10}\\\\
          \\hline\n");
		output.write( "         \\parbox[t]{2mm}{\\multirow{4}{*}{\\rotatebox[origin=c]{90}{Wallclock}}} &       Mean", runtimes_wc_mean );
		output.write( "         & \\cellcolor{LightCyan}Median", runtimes_wc_median );
		output.write( "         & Min", runtimes_wc_min );
		output.write( "         & \\cellcolor{LightCyan}Max", runtimes_wc_max );
		output.write( "         & Std dev", runtimes_wc_std );
		output.write( "         \\hline" );
		output.write( "         \\parbox[t]{2mm}{\\multirow{4}{*}{\\rotatebox[origin=c]{90}{Indiv. WL}}} &       Mean", runtimes_wl_mean );
		output.write( "         & \\cellcolor{LightCyan}Median", runtimes_wl_median );
		output.write( "         & Min", runtimes_wl_min );
		output.write( "         & \\cellcolor{LightCyan}Max", runtimes_wl_max );
		output.write( "         & Std dev", runtimes_wl_std );
		output.write( "         \\hline" );
		output.write( "         \\parbox[t]{2mm}{\\multirow{4}{*}{\\rotatebox[origin=c]{90}{Slow. WL}}} &       Mean", runtimes_swl_mean );
		output.write( "         & \\cellcolor{LightCyan}Median", runtimes_swl_median );
		output.write( "         & Min", runtimes_swl_min );
		output.write( "         & \\cellcolor{LightCyan}Max", runtimes_swl_max );
		output.write( "         & Std dev", runtimes_swl_std );

		output.write("          \\hline
        \\end{tabular}
      \\end{center}
    \\end{table*}
  \\end{landscape}
  \\clearpage%
}\n\n\n");

	}

	output.close();	
	return 0;
}
