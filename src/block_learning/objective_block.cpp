#include <numeric>
#include <iostream>
#include <limits>
#include <cmath>

#include <Eigen/Dense>

#include "objective_block.hpp"

using namespace std;

ObjectiveBlock::ObjectiveBlock( const vector<Variable>& variables,
                                const std::vector<int>& training_data,
                                size_t number_samples,
                                size_t number_variables,
                                size_t domain_size,
                                int starting_value,
                                const std::vector<double>& error_vector,
                                int parameter )
	: Minimize( variables, "Learning QUBO by block" ),
	  _training_data( training_data ),
	  _size_training_set( number_samples ),
	  _domain_size( domain_size ),
	  _candidate_length( number_variables ),
	  _starting_value( starting_value ),
	  _error_vector( error_vector ),
	  _parameter( parameter )
{
	if( parameter == std::numeric_limits<int>::max() )
		_parameter = 1;
}

Eigen::VectorXi ObjectiveBlock::fill_vector( const std::vector<int>& candidate ) const
{
	Eigen::VectorXi X;

	X = Eigen::VectorXi::Zero( _candidate_length * _domain_size );
	
	for( size_t index = 0 ; index < _candidate_length ; ++index )
		X( index * _domain_size + ( candidate[ index ] - _starting_value ) ) = 1;
	
	return X;
}

Eigen::MatrixXi ObjectiveBlock::fill_matrix( const vector<Variable*>& vecVariables ) const
{
	size_t matrix_side;
	matrix_side	= _candidate_length * _domain_size;
		
	Eigen::MatrixXi Q = Eigen::MatrixXi::Zero( matrix_side, matrix_side );

	int row_domain, col_domain;
	bool triangle_element;
	
	for( size_t row = 0 ; row < matrix_side ; ++row )
	{
		row_domain = row % _domain_size;
		for( size_t col = row ; col < matrix_side ; ++col )
		{
			col_domain = col % _domain_size;
			triangle_element = ( col < row + _domain_size - row_domain ? true : false );
			
			if( col == row ) //diagonal
			{
				if( vecVariables[0]->get_value() == 2 ) // -1-diagonal pattern
					Q( row, col ) += -1;
				else
					if( vecVariables[0]->get_value() == 3 ) // linear combinatorics pattern
						Q( row, col ) += -( 2 * _parameter - ( row_domain + _starting_value ) ) * ( row_domain + _starting_value );
			}
			else // non-diagonal
			{
				if( triangle_element )
				{
					Q( row, col ) += 2; // one-hot constraint
					if( vecVariables[0]->get_value() == 3 ) // linear combinatorics pattern
						Q( row, col ) += 2 * ( row_domain + _starting_value ) * ( col_domain + _starting_value );
				}
				else // full-block
				{
					if( row_domain == col_domain )
					{
						if( vecVariables[1]->get_value() == 1 ) // different pattern
							Q( row, col ) += 1;
						if( vecVariables[4]->get_value() == 1 ) // less-than pattern
							Q( row, col ) += 1;
						if( vecVariables[6]->get_value() == 1 ) // greater-than pattern
							Q( row, col ) += 1;
					}
					if( row_domain < col_domain )
					{
						if( vecVariables[2]->get_value() == 1 ) // equality pattern
							Q( row, col ) += 1;
						if( vecVariables[5]->get_value() == 1 ) // greater-than-or-equals-to pattern
							Q( row, col ) += 1;
						if( vecVariables[6]->get_value() == 1 ) // greater-than pattern
							Q( row, col ) += 1;
					}
					if( row_domain > col_domain )
					{
						if( vecVariables[2]->get_value() == 1 ) // different pattern
							Q( row, col ) += 1;
						if( vecVariables[3]->get_value() == 1 ) // less-than-or-equals-to pattern
							Q( row, col ) += 1;
						if( vecVariables[4]->get_value() == 1 ) // less-than pattern
							Q( row, col ) += 1;
					}

					if( vecVariables[7]->get_value() == 1 ) // linear combinatorics pattern
						Q( row, col ) += 2 * ( row_domain + _starting_value ) * ( col_domain + _starting_value );

					if( vecVariables[8]->get_value() == 1 ) // diagonal beam pattern
						Q( row, col ) += std::max( 0, _parameter - ( std::abs( col_domain - row_domain ) ) );
				}
			}
		}
	}
	
	return Q;
}

double ObjectiveBlock::required_cost( const vector<Variable*>& vecVariables ) const 
{
	Eigen::MatrixXi Q = fill_matrix( vecVariables ) ;
	Eigen::VectorXi X;	

	int min_scalar = std::numeric_limits<int>::max();

	double cost = 0.0;

	std::vector<int> scalars( _size_training_set );
	std::vector<int> candidate( _candidate_length );
	
	for( size_t sample_id = 0 ; sample_id < _size_training_set; ++sample_id )
	{
		for( size_t i = 0 ; i < _candidate_length; ++i )
			candidate[i] = _training_data[ ( sample_id * _candidate_length ) + i ];

		X = fill_vector( candidate );
		scalars[ sample_id ] = ( X.transpose() * Q ) * X;
		
		if( min_scalar > scalars[ sample_id ]	)
			min_scalar = scalars[ sample_id ];
	}
	
	for( size_t i = 0 ; i < _size_training_set ; ++i )
		if( ( _error_vector[i] == 0 && scalars[i] != min_scalar )
		    ||
		    ( _error_vector[i] > 0 && scalars[i] == min_scalar ) )
			++cost;
		
	return cost;		
}
