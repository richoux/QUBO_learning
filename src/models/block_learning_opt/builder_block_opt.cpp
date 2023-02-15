#include <numeric>
#include <initializer_list>

#include <ghost/global_constraints/linear_equation_leq.hpp>

#include "constraint_training_set_block.hpp"
#include "objective_short_expression.hpp"
#include "builder_block_opt.hpp"

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
	  _parameter( parameter )
{ }

void BuilderQUBO::declare_variables()
{
	// The first variable encodes the half-block pattern
	// The 8 following variables are Boolean and encode selected full-block patterns
	// Among these 8 variables, the 6 first ones are mutually exclusive (LinearEquationEq constraint)

	// half-block variable
	/*
	 * half-block domain
	 * 
	 * 1: 0-diagonal 
	 * 2: -1-diagonal
	 * 3: linear combinatorics -(2a-b_xi)b_xi
	 *
	 */	
	variables.emplace_back( std::initializer_list<int>( {1, 2, 3} ) );

	/*
	 * full-block variables (indices)
	 * 
	 *  1: neq
	 *  2: eq
	 *  3: leq
	 *  4: le
	 *  5: geq
	 *  6: ge
	 *  7: linear combinatorics (2.b_xi.b_xj
	 *  8: repel
	 *  9: attract
	 * 10: swapped values
	 *
	 */	
	for( size_t i = 0 ; i < 10 ; ++i )
		variables.emplace_back( std::initializer_list<int>( {0, 1} ) );
}

void BuilderQUBO::declare_constraints()
{
	constraints.emplace_back( make_shared< ghost::global_constraints::LinearEquationLeq >( std::vector<int>{1,2,3,4,5,6}, 1 ) );
	constraints.emplace_back( make_shared< ghost::global_constraints::LinearEquationLeq >( std::vector<int>{8,9}, 1 ) );
	constraints.emplace_back( make_shared<TrainingSet>( variables, _training_data, _size_training_set, _candidate_length, _domain_size, _starting_value, _error_vector, _parameter ) );
}

void BuilderQUBO::declare_objective()
{
	objective = std::make_shared<ObjectiveShortExpression>( variables );
}
