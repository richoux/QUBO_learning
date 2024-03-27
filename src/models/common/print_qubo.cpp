#include <iostream>
#include <iomanip>
#include <string>
#include <cmath>
#include <algorithm>

#include "print_qubo.hpp"

PrintQUBO::PrintQUBO( int matrix_side )
	: _matrix_side( matrix_side )
{}

std::stringstream PrintQUBO::print_candidate( const std::vector<ghost::Variable>& variables ) const
{
	std::stringstream stream;
		
	stream << "Q matrix:\n";
	
	for( int length = _matrix_side ; length > 0 ; --length )
	{
		int row_number = _matrix_side - length;
		
		for( int i = 0 ; i < row_number ; ++i )
			stream << std::setw( 3 ) << ".";

		int shift = row_number * ( row_number - 1 ) / 2;
		
		for( int i = 0 ; i < length ; ++i )
			stream << std::setw( 3 ) << variables[ ( row_number * _matrix_side ) - shift + i ].get_value();
		stream << "\n";
	}
	
	return stream;
}
