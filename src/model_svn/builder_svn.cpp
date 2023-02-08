#include <numeric>
#include <initializer_list>

#include <ghost/global_constraints/all_equal.hpp>

#include "builder_svn.hpp"

BuilderQUBO::BuilderQUBO( const std::vector<int>& training_data,
                          size_t number_samples,
                          size_t number_variables,
                          size_t domain_size,
                          int starting_value,
                          const std::vector<double>& error_vector,
                          bool complementary_variable,
                          int parameter )
	: ModelBuilder(),
	  _training_data( training_data ),
	  _size_training_set( number_samples ),
	  _domain_size( domain_size ),
	  _candidate_length( number_variables ),
	  _matrix_side( _candidate_length * _domain_size ),
	  _starting_value( starting_value ),
	  _error_vector( error_vector ),
	  _complementary_variable( complementary_variable )
{
	if( _complementary_variable )
		++_matrix_side;
	
	for( int row = _matrix_side ; row > 0 ; --row )
	{
		int col = _matrix_side - row;
		int shift = 0;
		int triangle_length;

		triangle_length = ( _domain_size - ( ( col + 1 ) % _domain_size ) ) % _domain_size;

		for( int i = 0 ; i < col ; ++i )
			shift += ( _matrix_side - i );

		for( int i = 0 ; i < row ; ++i )
			if( i != 0 && i <= triangle_length && !( _complementary_variable && i == row - 1 ) )
			{
				_index_triangle_variables.push_back( shift + i );
				_is_triangle_variables.push_back( true );
			}
			else
			{
				_is_triangle_variables.push_back( false );
			}					
	}
}

void BuilderQUBO::declare_variables()
{
	for( size_t i = 0 ; i < _is_triangle_variables.size() ; ++i )
	{
		if( _is_triangle_variables[i] )
			variables.emplace_back( std::initializer_list<int>( {1, 2} ) );
		else
			variables.emplace_back( std::initializer_list<int>( {-2, -1, 0, 1, 2} ) );
	}
}

void BuilderQUBO::declare_constraints()
{
	constraints.emplace_back( make_shared<TrainingSet>( variables, _training_data, _size_training_set, _candidate_length, _domain_size, _starting_value, _error_vector ) );
	//constraints.emplace_back( make_shared< UniqueValue >( _index_triangle_variables ) );
	constraints.emplace_back( make_shared<ghost::global_constraints::AllEqual>( _index_triangle_variables ) );
}

void BuilderQUBO::declare_objective()
{
	objective = std::make_shared<ObjectiveSVN>( variables, _training_data, _size_training_set, _candidate_length, _domain_size, _starting_value, _error_vector, _complementary_variable );
}

