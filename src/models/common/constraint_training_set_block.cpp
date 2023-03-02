#include <cmath>
#include <algorithm>
#include <limits>

#include <Eigen/Dense>

#include "matrix.hpp"
#include "constraint_training_set_block.hpp"

TrainingSet::TrainingSet( const vector<Variable>& variables,
                          const std::vector<int>& training_data,
                          size_t number_samples,
                          size_t number_variables,
                          size_t domain_size,
                          int starting_value,
                          const std::vector<double>& error_vector,
                          int parameter )
	: Constraint( variables ),
	  _training_data( training_data ),
	  _variable_values( std::vector<int>( variables.size() ) ),
	  // _variable_values_for_delta( std::vector<int>( variables.size() ) ),
	  _size_training_set( number_samples ),
	  _domain_size( domain_size ),
	  _candidate_length( number_variables ),
	  _starting_value( starting_value ),
	  _error_vector( error_vector ),
	  _parameter( parameter )
{ }

double TrainingSet::compute_error( const std::vector<int>& variable_values ) const
{
	double error = 0.;
	Eigen::MatrixXi Q = fill_matrix( variable_values, _candidate_length, _domain_size, _starting_value, _parameter ) ;
	Eigen::VectorXi X;	

	int min_scalar = std::numeric_limits<int>::max();

	std::vector<int> scalars( _size_training_set );
	std::vector<int> candidate( _candidate_length );
	
	for( size_t sample_id = 0 ; sample_id < _size_training_set; ++sample_id )
	{
		for( size_t i = 0 ; i < _candidate_length; ++i )
			candidate[i] = _training_data[ ( sample_id * _candidate_length ) + i ];

		X = fill_vector( candidate, _domain_size, _starting_value );
		scalars[ sample_id ] = ( X.transpose() * Q ) * X;
		
		if( min_scalar > scalars[ sample_id ]	)
			min_scalar = scalars[ sample_id ];
	}
	
	for( size_t i = 0 ; i < _size_training_set ; ++i )
		if( ( _error_vector[i] == 0 && scalars[i] != min_scalar )
		    ||
		    ( _error_vector[i] > 0 && scalars[i] == min_scalar ) )
			++error;

	return error;
}

double TrainingSet::required_error( const vector<Variable*>& variables ) const
{
	std::transform( variables.begin(), variables.end(), _variable_values.begin(), [](auto& v){return v->get_value();} );
	return compute_error( _variable_values );
}

// double TrainingSet::optional_delta_error( const std::vector<Variable*> &variables, const std::vector<int> &indexes, const std::vector<int> &candidate_values ) const
// {
// 	std::copy( _variable_values.begin(), _variable_values.end(), _variable_values_for_delta.begin() );
	
// 	for( size_t i = 0 ; i < indexes.size() ; ++i )
// 		_variable_values_for_delta[ indexes[i] ] = candidate_values[i];

// 	return compute_error( _variable_values_for_delta ) - get_current_error();
// }
