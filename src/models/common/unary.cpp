#include "unary.hpp"

std::string Unary::name() {	return "Unary encoding"; }
int Unary::number_triangle_patterns() { return 2; }
int Unary::number_square_patterns() { return 14; }

Eigen::VectorXi Unary::fill_vector( const std::vector<int>& candidate,
                                     size_t domain_size,
                                     int starting_value,
                                     int additional_variable )
{
	size_t candidate_length = candidate.size() ;

	Eigen::VectorXi X = Eigen::VectorXi::Zero( ( candidate_length + additional_variable ) * domain_size );

	for( size_t index = 0 ; index < candidate_length ; ++index )
		for( int domain_index = 0 ; domain_index <= candidate[ index ] - starting_value ; ++domain_index )
			X( index * domain_size + domain_index ) = 1;

	if( additional_variable > 0 )
		X( candidate_length ) = 1;

	return X;
}

Eigen::VectorXd Unary::fill_vector_reals( const std::vector<int>& candidate,
                                          size_t domain_size,
                                          int starting_value,
                                          int additional_variable )
{
	size_t candidate_length = candidate.size() ;

	Eigen::VectorXd X = Eigen::VectorXd::Zero( ( candidate_length + additional_variable ) * domain_size );

	for( size_t index = 0 ; index < candidate_length ; ++index )
		for( int domain_index = 0 ; domain_index < candidate[ index ] - starting_value ; ++domain_index )
			X( index * domain_size + domain_index ) = 1;

	if( additional_variable > 0 )
		X( candidate_length ) = 1;

	return X;
}

Eigen::MatrixXi Unary::fill_matrix( const std::vector<int>& variables,
                                     size_t candidate_length,
                                     size_t domain_size,
                                     int starting_value,
                                     int parameter )
{
	size_t matrix_side;
	matrix_side	= candidate_length * domain_size;
		
	Eigen::MatrixXi Q = Eigen::MatrixXi::Zero( matrix_side, matrix_side );

	int row_variable;
	int col_variable;
	int row_domain;
	int col_domain;

	bool triangle_element;
	int param_triangle = 1;
	int param_square = 0;

	if( variables[0] == 1 ) // linear combinatorics pattern
	{
		if( parameter == std::numeric_limits<int>::max() )
			param_triangle = 1;
		else
			param_triangle = parameter;
	}
	
	if( variables[12] == 1 || variables[13] == 1 ) // repel or attract patterns
	{
		if( parameter == std::numeric_limits<int>::max() )
			param_square = 0;
		else
			param_square = parameter;
	}

	for( size_t row = 0 ; row < matrix_side ; ++row )
	{
		row_variable = row / domain_size;
		row_domain = row % domain_size;
		for( size_t col = row ; col < matrix_side ; ++col )
		{
			col_variable = col / domain_size;
			col_domain = col % domain_size;
			
			if( col == row ) //diagonal
			{
				// Modified Philippe's encoding
				if( row_domain == 0 )
					Q( row, col ) += -1; // unary encoding constraint, diagonal part
				else
					Q( row, col ) += 1; // unary encoding constraint, diagonal part
				
				// JF's encoding
				// Q( row, col ) += row_domain; // unary encoding constraint, diagonal part

				// Flo's encoding
				// int sum = 0;
				// for( int i = row_domain ; i < domain_size ; ++i )
				// 	sum += 2*(i+1) - 1;
				// Q( row, col ) += -sum + row_domain; // unary encoding constraint, diagonal part

				// Philippe's encoding
				// if( col > 0 ) // if this is not the first element on the diagonal
				// 	Q( row, col ) += 1; // unary encoding constraint, diagonal part
				
				if( variables[0] == 1 ) // linear combinatorics pattern
				{
					// first try
					// if( col == 0 ) // if this is the first element on the diagonal
					// 	Q( row, col ) += -param_triangle; // this is equivalent to place param_triangle/n at every first element of triangle pattern positions x_i.x_i,
					// // but this way, it avoids eventual rounding errors due to the division.
					// else
					// 	Q( row, col ) += 1; // if future implementations would consider coefficients in the Linear Equation constraint,
					// // this 1 should be replaced bu the corresponding coefficient, as well as the 1 in column 0.

					// Q( row, col ) += ( row_domain + starting_value ) * ( row_domain + starting_value - 2*param_triangle );
					Q( row, col ) += 1 - 2*param_triangle;
				}
			}
			else // non-diagonal
			{
				// Philippe's encoding
				if( col == row  + 1 && col_domain > 0 )
					Q( row, col ) += -1; // unary encoding constraint, non-diagonal part
				
				triangle_element = ( col < row + domain_size - row_domain ? true : false );
				if( triangle_element )
				{
					// JF's encoding
					// Q( row, col ) += -1; // unary encoding constraint, triangle part
					
					// Flo's encoding
					// Q( row, col ) += 2; // unary encoding constraint, triangle part

					if( variables[0] == 1 ) // linear combinatorics pattern
						Q( row, col ) += 2;
				}
				else
				{
					Q( row, col ) += 2 * variables[14]; // full-2 pattern

					if( row_domain == col_domain ) // diagonal in each square patterns
					{
						Q( row, col ) += variables[4]; // less-than pattern
						Q( row, col ) += variables[6]; // greater-than pattern

						if( variables[13] == 1 ) // attract pattern
						{
							if( param_square >= domain_size )
								Q( row, col ) += 1; 
							else
								if( param_square == domain_size - 1 )
									Q( row, col ) += -2;
						}
					
						if( row_domain == 0 )
						{					
							Q( row, col ) += variables[1]; // different pattern
							Q( row, col ) += variables[7]; // favor assigning the current position
							Q( row, col ) += variables[10]; // avoid assigning a different position
							Q( row, col ) += param_square * variables[12]; // repel pattern
						}
						else // row_domain > 0
						{
							Q( row, col ) += 2 * variables[1]; // different pattern
							Q( row, col ) += -2 * variables[2]; // equality pattern
							Q( row, col ) += -variables[3]; // less-than-or-equals-to pattern;
							Q( row, col ) += -variables[5]; // greater-than-or-equals-to pattern
							Q( row, col ) += 2 * variables[12]; // repel pattern
						}
					}

					if( row_domain < col_domain ) // upper-right part of each square patterns
					{
						if( col_domain == row_domain + 1 )
						{
							Q( row, col ) += -variables[1]; // different pattern
							Q( row, col ) += variables[2]; // equality pattern
							Q( row, col ) += -variables[4]; // less-than pattern
							Q( row, col ) += variables[5]; // greater-than-or-equals-to pattern
						}
					}

					if( row_domain > col_domain ) // lower-left part of each square patterns
					{
						if( col_domain == row_domain - 1 )
						{
							Q( row, col ) += -variables[1]; // different pattern
							Q( row, col ) += variables[2]; // equality pattern
							Q( row, col ) += variables[3]; // less-than-or-equals-to pattern
							Q( row, col ) += -variables[6]; // greater-than pattern
						}
					}

					if( row_domain == row_variable && col_domain == col_variable ) // x_i = i and x_j = j
					{
						Q( row, col ) += -variables[7]; // favor assigning the current position
						Q( row, col ) += variables[8]; // avoid assigning the current position
						Q( row, col ) += variables[9]; // favor assigning a different position
						Q( row, col ) += -variables[10]; // avoid assigning a different position
						if( col + 1 < matrix_side && col_domain + 1 < domain_size )
						{
							Q( row, col+1 ) += variables[7]; // favor assigning the current position
							Q( row, col+1 ) += -variables[8]; // avoid assigning the current position
							Q( row, col+1 ) += -variables[9]; // favor assigning a different position
							Q( row, col+1 ) += variables[10]; // avoid assigning a different position
							if( row + 1 < matrix_side && row_domain + 1 < domain_size )
							{
								Q( row+1, col+1 ) += -variables[7]; // favor assigning the current position
								Q( row+1, col+1 ) += variables[8]; // avoid assigning the current position
								Q( row+1, col+1 ) += variables[9]; // favor assigning a different position
								Q( row+1, col+1 ) += -variables[10]; // avoid assigning a different position
							}
						}
						if( row + 1 < matrix_side && row_domain + 1 < domain_size )
						{
							Q( row+1, col ) += variables[7]; // favor assigning the current position
							Q( row+1, col ) += -variables[8]; // avoid assigning the current position
							Q( row+1, col ) += -variables[9]; // favor assigning a different position
							Q( row+1, col ) += variables[10]; // avoid assigning a different position
						}
					}

					if( col_domain == row_variable && row_domain == col_variable ) // x_i = j and x_j = i
					{
						Q( row, col ) += variables[9]; // favor assigning a different position
						Q( row, col ) += -variables[10]; // avoid assigning a different position
						Q( row, col ) += -2 * variables[11]; // swap values pattern
						if( col + 1 < matrix_side && col_domain + 1 < domain_size )
						{
							Q( row, col+1 ) += -variables[9]; // favor assigning a different position
							Q( row, col+1 ) += variables[10]; // avoid assigning a different position
							Q( row, col+1 ) += 2 * variables[11]; // swap values pattern
							if( row + 1 < matrix_side && row_domain + 1 < domain_size )
							{
								Q( row+1, col+1 ) += variables[9]; // favor assigning a different position
								Q( row+1, col+1 ) += -variables[10]; // avoid assigning a different position
								Q( row+1, col+1 ) += -2 * variables[11]; // swap values pattern
							}
						}
						if( row + 1 < matrix_side && row_domain + 1 < domain_size )
						{
							Q( row+1, col ) += -variables[9]; // favor assigning a different position
							Q( row+1, col ) += variables[10]; // avoid assigning a different position
							Q( row+1, col ) += 2 * variables[11]; // swap values pattern
						}
					}

					if( col_domain == 0 )
					{
						if( variables[11] == 1 ) // swap values pattern
						{
							if( row_domain == col_variable )
							{
								Q( row, col ) += 1;
								if( row + 1 < matrix_side && row_domain + 1 < domain_size )
									Q( row+1, col ) += -1;
							}
						}
						if( variables[12] == 1 ) // repel pattern
						{
							if( 0 < row_domain && row_domain <= param_square )
								Q( row, col ) += -1;
						}
						if( variables[13] == 1 ) // attract pattern
						{
							if( row_domain >= param_square )
								Q( row, col ) += 1;
						}
					}

					if( row_domain == 0 )
					{
						if( variables[11] == 1 ) // swap values pattern
						{
							if( col_domain == row_variable )
							{
								Q( row, col ) += 1;
								if( col + 1 < matrix_side && col_domain + 1 < domain_size )
									Q( row, col+1 ) += -1;
							}
						}
						if( variables[12] == 1 ) // repel pattern
						{
							if( 0 < col_domain && col_domain <= param_square )
								Q( row, col ) += -1;
						}
						if( variables[13] == 1 ) // attract pattern
						{
							if( col_domain >= param_square )
								Q( row, col ) += 1;
						}
					}
				
					if( variables[12] == 1 ) // repel pattern
					{
						if( ( col_domain > param_square && col_domain - row_domain == param_square )
						    ||
						    ( row_domain > param_square && row_domain - col_domain == param_square ) )
							Q( row, col ) += -1;
					}
					
					if( variables[13] == 1 ) // attract pattern
					{
						if( ( col_domain >= param_square && col_domain - row_domain == param_square - 1 )
						    ||
						    ( row_domain >= param_square && row_domain - col_domain == param_square - 1) )
							Q( row, col ) += -1;
					}
				}
			}
		}
	}
	
	return Q;
}

Eigen::MatrixXd Unary::fill_matrix_reals( const std::vector<double>& variables,
                                          size_t candidate_length,
                                          size_t domain_size,
                                          int starting_value,
                                          int parameter )
{
	size_t matrix_side;
	matrix_side	= candidate_length * domain_size;
		
	Eigen::MatrixXd Q = Eigen::MatrixXd::Zero( matrix_side, matrix_side );

	int row_variable;
	int col_variable;
	int row_domain;
	int col_domain;
	
	int param_triangle;
	int param_square;

	if( variables[0] == 1 ) // linear combinatorics pattern
	{
		if( parameter == std::numeric_limits<int>::max() )
			param_triangle = 1;
		else
			param_triangle = parameter;
	}
	
	if( variables[12] == 1 || variables[13] == 1 ) // repel or attract patterns
	{
		if( parameter == std::numeric_limits<int>::max() )
			param_square = 0;
		else
			param_square = parameter;
	}

	for( size_t row = 0 ; row < matrix_side ; ++row )
	{
		row_variable = row / domain_size;
		row_domain = row % domain_size;
		for( size_t col = row ; col < matrix_side ; ++col )
		{
			col_variable = col / domain_size;
			col_domain = col % domain_size;
			
			if( col == row ) //diagonal
			{
				if( col > 0 ) // if this is not the first element on the diagonal
					Q( row, col ) += 1; // unary encoding constraint, diagonal part
				
				if( variables[0] == 1 ) // linear combinatorics pattern
				{
					if( col == 0 ) // if this is the first element on the diagonal
						Q( row, col ) += 1 - param_triangle; // this is equivalent to place param_triangle/n at every first element of triangle pattern positions x_i.x_i,
					// but this way, it avoids eventual rounding errors due to the division.
					else
						Q( row, col ) += 1; // if future implementations would consider coefficients in the Linear Equation constraint,
					// this 1 should be replaced bu the corresponding coefficient, as well as the 1 in column 0.
				}
			}
			else // non-diagonal
			{
				if( col == row  + 1 )
					Q( row, col ) += -1; // unary encoding constraint, non-diagonal part

				if( row_domain == col_domain ) // diagonal in each square patterns
				{
					Q( row, col ) += variables[4]; // less-than pattern
					Q( row, col ) += variables[6]; // greater-than pattern

					if( param_square >= domain_size )
						Q( row, col ) += variables[13]; // attract pattern
					else
						if( param_square == domain_size - 1 )
							Q( row, col ) += -2 * variables[13]; // attract pattern
				}

				if( row_domain == 0 )
				{					
					Q( row, col ) += variables[1]; // different pattern
					Q( row, col ) += variables[7]; // favor assigning the current position
					Q( row, col ) += variables[10]; // avoid assigning a different position
					Q( row, col ) += param_square * variables[12]; // repel pattern
				}
				else // row_domain > 0
				{
					Q( row, col ) += 2 * variables[1]; // different pattern
					Q( row, col ) += -2 * variables[2]; // equality pattern
					Q( row, col ) += -variables[3]; // less-than-or-equals-to pattern;
					Q( row, col ) += -variables[5]; // greater-than-or-equals-to pattern
					Q( row, col ) += 2 * variables[12]; // repel pattern
				}
			}
			if( row_domain < col_domain ) // upper-right part of each square patterns
			{
				if( col_domain == row_domain + 1 )
				{
					Q( row, col ) += -variables[1]; // different pattern
					Q( row, col ) += variables[2]; // equality pattern
					Q( row, col ) += -variables[4]; // less-than pattern
					Q( row, col ) += variables[5]; // greater-than-or-equals-to pattern
				}
			}
			if( row_domain > col_domain ) // lower-left part of each square patterns
			{
				if( col_domain == row_domain - 1 )
				{
					Q( row, col ) += -variables[1]; // different pattern
					Q( row, col ) += variables[2]; // equality pattern
					Q( row, col ) += variables[3]; // less-than-or-equals-to pattern
					Q( row, col ) += -variables[6]; // greater-than pattern
				}
			}

			if( row_domain == row_variable && col_domain == col_variable ) // x_i = i and x_j = j
			{
				Q( row, col ) += -variables[7]; // favor assigning the current position
				Q( row, col ) += variables[8]; // avoid assigning the current position
				Q( row, col ) += variables[9]; // favor assigning a different position
				Q( row, col ) += -variables[10]; // avoid assigning a different position
				if( col + 1 < matrix_side )
				{
					Q( row, col+1 ) += variables[7]; // favor assigning the current position
					Q( row, col+1 ) += -variables[8]; // avoid assigning the current position
					Q( row, col+1 ) += -variables[9]; // favor assigning a different position
					Q( row, col+1 ) += variables[10]; // avoid assigning a different position
					if( row + 1 < matrix_side )
					{
						Q( row+1, col+1 ) += -variables[7]; // favor assigning the current position
						Q( row+1, col+1 ) += variables[8]; // avoid assigning the current position
						Q( row+1, col+1 ) += variables[9]; // favor assigning a different position
						Q( row+1, col+1 ) += -variables[10]; // avoid assigning a different position
					}
				}
				if( row + 1 < matrix_side )
				{
					Q( row+1, col ) += variables[7]; // favor assigning the current position
					Q( row+1, col ) += -variables[8]; // avoid assigning the current position
					Q( row+1, col ) += -variables[9]; // favor assigning a different position
					Q( row+1, col ) += variables[10]; // avoid assigning a different position
				}
			}

			if( col_domain == row_variable && row_domain == col_variable ) // x_i = j and x_j = i
			{
				Q( row, col ) += variables[9]; // favor assigning a different position
				Q( row, col ) += -variables[10]; // avoid assigning a different position
				Q( row, col ) += -2 * variables[11]; // swap values pattern
				if( col + 1 < matrix_side )
				{
					Q( row, col+1 ) += -variables[9]; // favor assigning a different position
					Q( row, col+1 ) += variables[10]; // avoid assigning a different position
					Q( row, col+1 ) += 2 * variables[11]; // swap values pattern
					if( row + 1 < matrix_side )
					{
						Q( row+1, col+1 ) += variables[9]; // favor assigning a different position
						Q( row+1, col+1 ) += -variables[10]; // avoid assigning a different position
						Q( row+1, col+1 ) += -2 * variables[11]; // swap values pattern
					}
				}
				if( row + 1 < matrix_side )
				{
					Q( row+1, col ) += -variables[9]; // favor assigning a different position
					Q( row+1, col ) += variables[10]; // avoid assigning a different position
					Q( row+1, col ) += 2 * variables[11]; // swap values pattern
				}
			}

			if( col_domain == 0 )
			{
				if( variables[11] == 1 ) // swap values pattern
				{
					if( row_domain == col_variable )
					{
						Q( row, col ) += 1;
						if( row + 1 < matrix_side )
							Q( row+1, col ) += -1;
					}
				}
				if( variables[12] == 1 ) // repel pattern
				{
					if( 0 < row_domain && row_domain <= param_square )
						Q( row, col ) += -1;
				}
				if( variables[13] == 1 ) // attract pattern
				{
					if( row_domain >= matrix_side - param_square )
						Q( row, col ) += 1;
				}
			}

			if( row_domain == 0 )
			{
				if( variables[11] == 1 ) // swap values pattern
				{
					if( col_domain == row_variable )
					{
						Q( row, col ) += 1;
						if( col + 1 < matrix_side )
							Q( row, col+1 ) += -1;
					}
				}
				if( variables[12] == 1 ) // repel pattern
				{
					if( 0 < col_domain && col_domain <= param_square )
						Q( row, col ) += -1;
				}
				if( variables[13] == 1 ) // attract pattern
				{
					if( col_domain >= matrix_side - param_square )
						Q( row, col ) += 1;
				}
			}
				
			if( variables[12] == 1 ) // repel pattern
			{
				if( ( col_domain > matrix_side - param_square && col_domain - row_domain == param_square )
				    ||
				    ( row_domain > matrix_side - param_square && row_domain - col_domain == param_square ) )
					Q( row, col ) += -1;
			}
					
			if( variables[13] == 1 ) // attract pattern
			{
				if( ( col_domain >= matrix_side - param_square && col_domain - row_domain == param_square - 1 )
				    ||
				    ( row_domain >= matrix_side - param_square && row_domain - col_domain == param_square - 1) )
					Q( row, col ) += -1;
			}
		}
	}
	
	return Q;
}
