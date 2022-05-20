#pragma once

#include <sstream>
#include <vector>

#include "ghost/print.hpp"
#include "ghost/variable.hpp"

using namespace std;
using namespace ghost;

class PrintQUBO : public Print
{
	int _matrix_side;
	
public:
	PrintQUBO( int matrix_side );
	
	stringstream print_candidate( const std::vector<Variable>& variables ) const override;
};
