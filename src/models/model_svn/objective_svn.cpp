#include <numeric>
#include <iostream>
#include <limits>

#include <Eigen/Dense>

#include "objective_svn.hpp"

using namespace std;

ObjectiveSVN::ObjectiveSVN( const vector<Variable>& variables,
                            const std::vector<int>& training_data,
                            size_t number_samples,
                            size_t number_variables,
                            size_t domain_size,
                            int starting_value,
                            const std::vector<double>& error_vector,
                            bool complementary_variable )
	: Maximize( variables, "Learning QUBO SVN" ),
	  _training_data( training_data ),
	  _size_training_set( number_samples ),
	  _domain_size( domain_size ),
	  _candidate_length( number_variables ),
	  _starting_value( starting_value ),
	  _error_vector( error_vector ),
	  _complementary_variable( complementary_variable )
{ }

Eigen::VectorXi ObjectiveSVN::fill_vector( const std::vector<int>& candidate ) const
{
	Eigen::VectorXi X;

	if( _complementary_variable )
	{
		X = Eigen::VectorXi::Zero( ( _candidate_length - 1 ) * _domain_size + 1 );
		
		for( size_t index = 0 ; index < _candidate_length - 1 ; ++index )
			X( index * _domain_size + ( candidate[ index ] - _starting_value ) ) = 1;

		X( _candidate_length - 1 ) = 1;	
	}
	else
	{
		X = Eigen::VectorXi::Zero( _candidate_length * _domain_size );
		
		for( size_t index = 0 ; index < _candidate_length ; ++index )
			X( index * _domain_size + ( candidate[ index ] - _starting_value ) ) = 1;
	}

	return X;
}

Eigen::MatrixXi ObjectiveSVN::fill_matrix( const vector<Variable*>& vecVariables ) const
{
	size_t matrix_side;
	if( _complementary_variable )
		matrix_side	= ( _candidate_length - 1 ) * _domain_size + 1;
	else
		matrix_side	= _candidate_length * _domain_size;
		
	Eigen::MatrixXi Q = Eigen::MatrixXi::Zero( matrix_side, matrix_side );

	for( size_t length = matrix_side ; length > 0 ; --length )
	{
		int row_number = matrix_side - length;
		
		int shift = row_number * ( row_number - 1 ) / 2;
		
		for( int i = 0 ; i < length ; ++i )
			Q( row_number, row_number + i ) = vecVariables[ ( row_number * matrix_side ) - shift + i ]->get_value();
	}
	
	return Q;
}

double ObjectiveSVN::required_cost( const vector<Variable*>& vecVariables ) const 
{
	Eigen::MatrixXi Q = fill_matrix( vecVariables ) ;
	Eigen::VectorXi X;	

	int min_scalar = std::numeric_limits<int>::max();
	int min_scalar_non_solution = std::numeric_limits<int>::max();

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

		if( _error_vector[ sample_id ] > 0 && min_scalar_non_solution > scalars[ sample_id ] )
			min_scalar_non_solution = scalars[ sample_id ];
	}
			
	return min_scalar_non_solution - min_scalar;		
}
