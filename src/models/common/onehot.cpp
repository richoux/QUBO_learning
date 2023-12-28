#include "onehot.hpp"

std::string Onehot::name() { return "One-hot encoding"; }
int Onehot::number_triangle_patterns() { return 2; }
int Onehot::number_square_patterns() { return 14; }

Eigen::VectorXi Onehot::fill_vector( const std::vector<int>& candidate,
                                     size_t domain_size,
                                     int starting_value,
                                     int additional_variable )
{
	size_t candidate_length = candidate.size() ;

	Eigen::VectorXi X = Eigen::VectorXi::Zero( ( candidate_length + additional_variable ) * domain_size );

	for( size_t index = 0 ; index < candidate_length ; ++index )
		X( index * domain_size + ( candidate[ index ] - starting_value ) ) = 1;

	if( additional_variable > 0 )
		X( candidate_length ) = 1;

	return X;
}

Eigen::VectorXd Onehot::fill_vector_reals( const std::vector<int>& candidate,
                                           size_t domain_size,
                                           int starting_value,
                                           int additional_variable )
{
	size_t candidate_length = candidate.size() ;

	Eigen::VectorXd X = Eigen::VectorXd::Zero( ( candidate_length + additional_variable ) * domain_size );

	for( size_t index = 0 ; index < candidate_length ; ++index )
		X( index * domain_size + ( candidate[ index ] - starting_value ) ) = 1;

	if( additional_variable > 0 )
		X( candidate_length ) = 1;

	return X;
}

Eigen::MatrixXi Onehot::fill_matrix( const std::vector<int>& variables,
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
	int param;
	
	for( size_t row = 0 ; row < matrix_side ; ++row )
	{
		row_variable = row / domain_size;
		row_domain = row % domain_size;
		for( size_t col = row ; col < matrix_side ; ++col )
		{
			col_variable = col / domain_size;
			col_domain = col % domain_size;
			triangle_element = ( col < row + domain_size - row_domain ? true : false );
			
			if( col == row ) //diagonal
			{
				Q( row, col ) += -1; // one-hot constraint
				if( variables[0] == 1 ) // linear combinatorics pattern
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
					if( variables[0] == 1 ) // linear combinatorics pattern
						Q( row, col ) += 2 * ( row_domain + starting_value ) * ( col_domain + starting_value );
				}
				else // full-block
				{
					if( row_domain == col_domain )
					{
						Q( row, col ) += variables[1]; // different pattern
						Q( row, col ) += variables[4]; // less-than pattern
						Q( row, col ) += variables[6]; // greater-than pattern
					}
					if( row_domain < col_domain )
					{
						Q( row, col ) += variables[2]; // equality pattern
						Q( row, col ) += variables[5]; // greater-than-or-equals-to pattern
						Q( row, col ) += variables[6]; // greater-than pattern
					}
					if( row_domain > col_domain )
					{
						Q( row, col ) += variables[2]; // equality pattern
						Q( row, col ) += variables[3]; // less-than-or-equals-to pattern
						Q( row, col ) += variables[4]; // less-than pattern
					}

					if( row_variable == row_domain || col_variable == col_domain )
					{
						Q( row, col ) += -variables[7]; // favor assigning the current position
						Q( row, col ) += variables[8]; // avoid assigning the current position
					}
					
					if( row_variable != row_domain &&
					    row_variable != col_domain &&
					    col_variable != row_domain &&
					    col_variable != col_domain )
					{
						Q( row, col ) += -variables[9]; // favor assigning a different position
						Q( row, col ) += variables[10]; // avoid assigning a different position
					}
					
					if( row_variable == col_domain && col_variable == row_domain )
						Q( row, col ) += -variables[11]; // swap values pattern
					else
						if( row_variable == col_domain || col_variable == row_domain )
							Q( row, col ) += variables[11]; // swap values pattern

					if( variables[12] == 1 ) // repel pattern
					{
						if( parameter == std::numeric_limits<int>::max() )
							param = 0;
						else
							param = parameter;							

						Q( row, col ) += std::max( 0, param - ( std::abs( col_domain - row_domain ) ) );
					}
					
					if( variables[13] == 1 ) // attract pattern
					{
						if( parameter == std::numeric_limits<int>::max() )
							param = 0;
						else
							param = parameter;
												
						Q( row, col ) += std::max( 0, std::abs( col_domain - row_domain ) - ( static_cast<int>( domain_size ) - 1 - param ) );
					}

					if( variables[14] == 1 ) // linear combinatorics pattern
						Q( row, col ) += 2 * ( row_domain + starting_value ) * ( col_domain + starting_value );
				}
			}
		}
	}
	
	return Q;
}

Eigen::MatrixXd Onehot::fill_matrix_reals( const std::vector<double>& variables,
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
	
	bool triangle_element;
	int param;
	
	for( size_t row = 0 ; row < matrix_side ; ++row )
	{
		row_variable = row / domain_size;
		row_domain = row % domain_size;
		for( size_t col = row ; col < matrix_side ; ++col )
		{
			col_variable = col / domain_size;
			col_domain = col % domain_size;
			triangle_element = ( col < row + domain_size - row_domain ? true : false );
			
			if( col == row ) //diagonal
			{
				if( parameter == std::numeric_limits<int>::max() )
					param = 1;
				else
					param = parameter;
				Q( row, col ) += -1; // one-hot constraint
				Q( row, col ) += (-( 2 * param - ( row_domain + starting_value ) ) * ( row_domain + starting_value ) * variables[0] ); // linear combinatorics pattern
			}
			else // non-diagonal
			{
				if( triangle_element )
				{
					Q( row, col ) += 2; // one-hot constraint
					Q( row, col ) += ( 2 * ( row_domain + starting_value ) * ( col_domain + starting_value ) * variables[0] ); // linear combinatorics pattern
				}
				else // full-block
				{
					if( parameter == std::numeric_limits<int>::max() )
						param = 0;
					else
						param = parameter;							

					if( row_domain == col_domain )
					{
						Q( row, col ) += variables[1]; // different pattern
						Q( row, col ) += variables[4]; // less-than pattern
						Q( row, col ) += variables[6]; // greater-than pattern
					}
					if( row_domain < col_domain )
					{
						Q( row, col ) += variables[2]; // equality pattern
						Q( row, col ) += variables[5]; // greater-than-or-equals-to pattern
						Q( row, col ) += variables[6]; // greater-than pattern
					}
					if( row_domain > col_domain )
					{
						Q( row, col ) += variables[2]; // equality pattern
						Q( row, col ) += variables[3]; // less-than-or-equals-to pattern
						Q( row, col ) += variables[4]; // less-than pattern
					}

					if( row_variable == row_domain || col_variable == col_domain )
					{
						Q( row, col ) -= variables[7]; // favor assigning the current position
						Q( row, col ) += variables[8]; // avoid assigning the current position
					}
					
					if( row_variable != row_domain &&
					    row_variable != col_domain &&
					    col_variable != row_domain &&
					    col_variable != col_domain )
					{
						Q( row, col ) -= variables[9]; // favor assigning a different position
						Q( row, col ) += variables[10]; // avoid assigning a different position
					}
					
					if( row_variable == col_domain && col_variable == row_domain )
						Q( row, col ) -= variables[11]; // swap values pattern
					else
						if( row_variable == col_domain || col_variable == row_domain )
							Q( row, col ) += variables[11]; // swap values pattern
					
					Q( row, col ) += ( std::max( 0, param - ( std::abs( col_domain - row_domain ) ) ) * variables[12] ); // repel pattern
					Q( row, col ) += ( std::max( 0, std::abs( col_domain - row_domain ) - ( static_cast<int>( domain_size ) - 1 - param ) ) * variables[13] ); // attract pattern
					Q( row, col ) += ( 2 * ( row_domain + starting_value ) * ( col_domain + starting_value ) * variables[14] ); // linear combinatorics pattern
				}
			}
		}
	}
	
	return Q;
}
