#!/usr/bin/rdmd

import std.stdio;
import std.string;
import std.math;
import std.algorithm;
import std.conv;
import std.process;

void usage( string prog_name )
{
	auto prog = prog_name.split("/");
	writeln( "Usage: ", prog[$-1], " [sat/opt] Constraint-var_domain" );
	writeln( "Example: ", prog[$-1], " opt alldiff-12_12" );	
}

int main( string[] args )
{
	if( args.length != 3 )
	{
		usage( args[0] );
		return 1;
	}

	auto wl = "weak_learners_" ~ args[1] ~ "/";
	auto input = args[2].split("-");
	
	auto output_name = args[2] ~ ".tex";
	auto output = File( output_name, "w" );

	uint[5][4] success_majority;
	uint[5][4] success_mean;

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
		foreach( index_n, n; [2,4,6,8,10] )
		{
			auto command = "./analyse_results.d " ~ wl ~ args[2] ~ "_weak_w" ~ to!string(w) ~ "-n" ~ to!string(n) ~ " sumup";
			auto buf = executeShell( command );
			auto lines = buf.output.split("\n");
			
			foreach( line; lines )
			{
				auto words = line.split(": ");

				if( startsWith( line, "Majority success rate" ) )
					success_majority[index_w][index_n] = to!uint(words[1]);
				else
				{
					if( startsWith( line, "Mean success rate" ) )
						success_mean[index_w][index_n] = to!uint(words[1]);
					else if( endsWith( line, "ms" ) )
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
		
	auto line_w3 = "";
	auto line_w5 = "";
	auto line_w7 = "";
	auto line_w9 = "";
	foreach( index_n, n; [2,4,6,8,10] )
	{
		line_w3 ~= ( " & \\cellcolor{LightCyan}" ~ to!string( success_mean[0][index_n] ) );
		line_w5 ~= ( " & " ~ to!string( success_mean[1][index_n] ) );
		line_w7 ~= ( " & \\cellcolor{LightCyan}" ~ to!string( success_mean[2][index_n] ) );
		line_w9 ~= ( " & " ~ to!string( success_mean[3][index_n] ) );
	}
	foreach( index_n, n; [2,4,6,8,10] )
	{
		line_w3 ~= ( " & \\cellcolor{LightCyan}" ~ to!string( success_majority[0][index_n] ) );
		line_w5 ~= ( " & " ~ to!string( success_majority[1][index_n] ) );
		line_w7 ~= ( " & \\cellcolor{LightCyan}" ~ to!string( success_majority[2][index_n] ) );
		line_w9 ~= ( " & " ~ to!string( success_majority[3][index_n] ) );
	}

	line_w3 ~= "\\\\\n";
	line_w5 ~= "\\\\\n";
	line_w7 ~= "\\\\\n";
	line_w9 ~= "\\\\\n";
	
	output.write("
\\begin{table*}[h]
  \\small
  \\caption{Success rate over 100 runs on test sets for the constraint ", input[0], ".}
  \\begin{center}
    \\begin{tabular}{|cc|c|c|c|c|c|c|c|c|c|c|}
      \\cmidrule[\\heavyrulewidth]{3-12}
      \\multicolumn{1}{c}{}& & \\multicolumn{5}{c|}{Mean} & \\multicolumn{5}{c|}{Majority}\\\\
      \\cmidrule[\\heavyrulewidth]{3-12}
      \\multicolumn{1}{c}{}& & \\multicolumn{5}{c|}{Training set size} & \\multicolumn{5}{c|}{Training set size}\\\\
      \\multicolumn{1}{c}{}& & 2 & 4 & 6 & 8 & 10 & 2 & 4 & 6 & 8 & 10\\\\
      \\cmidrule[\\heavyrulewidth]{1-12}
      \\parbox[t]{2mm}{\\multirow{4}{*}{\\rotatebox[origin=c]{90}{\\# learners}}} & ");

	output.write("\\cellcolor{LightCyan}3", line_w3);
	output.write("      & 5", line_w5);
	output.write("      & \\cellcolor{LightCyan}7", line_w7);
	output.write("      & 9", line_w9);

	output.write("      \\bottomrule
    \\end{tabular}
  \\end{center}
\\end{table*}\n\n\n");
	
	output.write("
\\afterpage{%
  \\clearpage%
  \\thispagestyle{empty}%
  \\begin{landscape}
    \\begin{table*}[h]
      \\tiny
      \\caption{Training runtimes over 100 runs for the constraint ", input[0], ".}
      \\begin{center}
        \\begin{tabular}{|c|c|r|r|r|r|r|r|r|r|r|r|r|r|r|r|r|r|r|r|r|r|}
          \\cmidrule[\\heavyrulewidth]{3-22}
          \\multicolumn{1}{c}{} & &\\multicolumn{20}{c|}{Number weak learners}\\\\
          \\multicolumn{1}{c}{} & &\\multicolumn{5}{c|}{3} & \\multicolumn{5}{c|}{5} & \\multicolumn{5}{c|}{7} & \\multicolumn{5}{c|}{9}\\\\ 
          \\cmidrule{3-22}
          \\multicolumn{1}{c}{} & &\\multicolumn{5}{c|}{Training set size} & \\multicolumn{5}{c|}{Training set size} & \\multicolumn{5}{c|}{Training set size} & \\multicolumn{5}{c|}{Training set size}\\\\
          \\multicolumn{1}{c}{} & &\\multicolumn{1}{c|}{2} & \\multicolumn{1}{c|}{4} & \\multicolumn{1}{c|}{6} & \\multicolumn{1}{c|}{8} & \\multicolumn{1}{c|}{10} & \\multicolumn{1}{c|}{2} & \\multicolumn{1}{c|}{4} & \\multicolumn{1}{c|}{6} & \\multicolumn{1}{c|}{8} & \\multicolumn{1}{c|}{10} & \\multicolumn{1}{c|}{2} & \\multicolumn{1}{c|}{4} & \\multicolumn{1}{c|}{6} & \\multicolumn{1}{c|}{8} & \\multicolumn{1}{c|}{10} & \\multicolumn{1}{c|}{2} & \\multicolumn{1}{c|}{4} & \\multicolumn{1}{c|}{6} & \\multicolumn{1}{c|}{8} & \\multicolumn{1}{c|}{10}\\\\
          \\midrule\n");
	output.write( "         \\parbox[t]{2mm}{\\multirow{4}{*}{\\rotatebox[origin=c]{90}{Wallclock}}} &       Mean", runtimes_wc_mean );
	output.write( "         & \\cellcolor{LightCyan}Median", runtimes_wc_median );
	output.write( "         & Min", runtimes_wc_min );
	output.write( "         & \\cellcolor{LightCyan}Max", runtimes_wc_max );
	output.write( "         & Std dev", runtimes_wc_std );
	output.write( "         \\midrule" );
	output.write( "         \\parbox[t]{2mm}{\\multirow{4}{*}{\\rotatebox[origin=c]{90}{Indiv. WL}}} &       Mean", runtimes_wl_mean );
	output.write( "         & \\cellcolor{LightCyan}Median", runtimes_wl_median );
	output.write( "         & Min", runtimes_wl_min );
	output.write( "         & \\cellcolor{LightCyan}Max", runtimes_wl_max );
	output.write( "         & Std dev", runtimes_wl_std );
	output.write( "         \\midrule" );
	output.write( "         \\parbox[t]{2mm}{\\multirow{4}{*}{\\rotatebox[origin=c]{90}{Slow. WL}}} &       Mean", runtimes_swl_mean );
	output.write( "         & \\cellcolor{LightCyan}Median", runtimes_swl_median );
	output.write( "         & Min", runtimes_swl_min );
	output.write( "         & \\cellcolor{LightCyan}Max", runtimes_swl_max );
	output.write( "         & Std dev", runtimes_swl_std );

	output.write("          \\bottomrule
        \\end{tabular}
      \\end{center}
    \\end{table*}
  \\end{landscape}
  \\clearpage%
}\n\n\n");

	output.close();	
	return 0;
}
