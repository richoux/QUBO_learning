#pragma once

#include <sstream>
#include <vector>

#include "ghost/print.hpp"
#include "ghost/variable.hpp"

class PrintQUBO : public ghost::Print
{
	int _matrix_side;
	
public:
	PrintQUBO( int matrix_side );
	
	std::stringstream print_candidate( const std::vector<ghost::Variable>& variables ) const override;
};
