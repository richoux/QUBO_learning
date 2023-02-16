#include "matrix.hpp"

Eigen::VectorXi fill_vector( const std::vector<int>& candidate, size_t domain_size, int starting_value )
{
	size_t candidate_length = candidate.size();

	Eigen::VectorXi X = Eigen::VectorXi::Zero( candidate_length * domain_size );

	for( size_t index = 0 ; index < candidate_length ; ++index )
		X( index * domain_size + ( candidate[ index ] - starting_value ) ) = 1;

	return X;
}

Eigen::MatrixXi fill_matrix( const std::vector<int>& variables, size_t candidate_length, size_t domain_size, int starting_value, int parameter )
{
	size_t matrix_side;
	matrix_side	= candidate_length * domain_size;
		
	Eigen::MatrixXi Q = Eigen::MatrixXi::Zero( matrix_side, matrix_side );

	int row_domain, col_domain;
	bool triangle_element;
	int param;
	
	for( size_t row = 0 ; row < matrix_side ; ++row )
	{
		row_domain = row % domain_size;
		for( size_t col = row ; col < matrix_side ; ++col )
		{
			col_domain = col % domain_size;
			triangle_element = ( col < row + domain_size - row_domain ? true : false );
			
			if( col == row ) //diagonal
			{
				if( variables[0] == 2 ) // -1-diagonal pattern
					Q( row, col ) += -1;
				else
					if( variables[0] == 3 ) // linear combinatorics pattern
					{
						if( parameter == std::numeric_limits<int>::max() )
							param = 1;
						else
							param = parameter;
							
						Q( row, col ) += -( 2 * param - ( row_domain + starting_value ) ) * ( row_domain + starting_value );
					}
			}
			else // non-diagonal
			{
				if( triangle_element )
				{
					Q( row, col ) += 2; // one-hot constraint
					if( variables[0] == 3 ) // linear combinatorics pattern
						Q( row, col ) += 2 * ( row_domain + starting_value ) * ( col_domain + starting_value );
				}
				else // full-block
				{
					if( row_domain == col_domain )
					{
						if( variables[1] == 1 ) // different pattern
							Q( row, col ) += 1;
						if( variables[4] == 1 ) // less-than pattern
							Q( row, col ) += 1;
						if( variables[6] == 1 ) // greater-than pattern
							Q( row, col ) += 1;
					}
					if( row_domain < col_domain )
					{
						if( variables[2] == 1 ) // equality pattern
							Q( row, col ) += 1;
						if( variables[5] == 1 ) // greater-than-or-equals-to pattern
							Q( row, col ) += 1;
						if( variables[6] == 1 ) // greater-than pattern
							Q( row, col ) += 1;
					}
					if( row_domain > col_domain )
					{
						if( variables[2] == 1 ) // different pattern
							Q( row, col ) += 1;
						if( variables[3] == 1 ) // less-than-or-equals-to pattern
							Q( row, col ) += 1;
						if( variables[4] == 1 ) // less-than pattern
							Q( row, col ) += 1;
					}

					if( variables[7] == 1 ) // linear combinatorics pattern
						Q( row, col ) += 2 * ( row_domain + starting_value ) * ( col_domain + starting_value );

					if( variables[8] == 1 ) // repel pattern
					{
						if( parameter == std::numeric_limits<int>::max() )
							param = 0;
						else
							param = parameter;							

						Q( row, col ) += std::max( 0, param - ( std::abs( col_domain - row_domain ) ) );
					}
					
					if( variables[9] == 1 ) // attract pattern
					{
						if( parameter == std::numeric_limits<int>::max() )
							param = 0;
						else
							param = parameter;
												
						Q( row, col ) += std::max( 0, std::abs( col_domain - row_domain ) - ( static_cast<int>( domain_size ) - 1 - param ) );
					}

					if( variables[10] == 1 ) // swapped values pattern
					{
						if( ( row / domain_size ) == col_domain && ( col / domain_size ) == row_domain )
							Q( row, col ) += -1;
						else
							Q( row, col ) += 1;
					}
				}
			}
		}
	}
	
	return Q;
}
