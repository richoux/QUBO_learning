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
	// The 14 following variables are Boolean and encode selected full-block patterns
	// Among these 14 variables, some are mutually exclusive (see LinearEquationEq constraints)

	// half-block variable
	/*
	 * half-block domain
	 * 
	 * 1: 0 diagonal 
	 * 2: -1 diagonal
	 * 3: linear combinatorics -(2a-b_xi)b_xi
	 *
	 */	
	variables.emplace_back( std::initializer_list<int>( {1, 2, 3} ) );

	/*
	 * full-block variables (indices)
	 * 
	 * ## arithmetic
	 *  1: neq
	 *  2: eq
	 *  3: leq
	 *  4: le
	 *  5: geq
	 *  6: ge
	 * ## position-based
	 *  7: favor assigning the current position, ie, x_i = i 
	 *  8: avoid assigning the current position
	 *  9: favor assigning a different position, ie, x_ia.x_jb = -1 for a,b not in {i,j}
	 * 10: avoid assigning a different position
	 * 11: swap values regarding positions, ie, x_i = j and x_j = i
	 * ## complex
	 * 12: repel
	 * 13: attract
	 * 14: linear combinatorics (2.b_xi.b_xj
	 *
	 */	
	for( size_t i = 0 ; i < 14 ; ++i )
		variables.emplace_back( std::initializer_list<int>( {0, 1} ) );
}

void BuilderQUBO::declare_constraints()
{
	constraints.emplace_back( make_shared< ghost::global_constraints::LinearEquationLeq >( std::vector<int>{1,2,3,4,5,6}, 1 ) );
	constraints.emplace_back( make_shared< ghost::global_constraints::LinearEquationLeq >( std::vector<int>{7,8}, 1 ) );
	constraints.emplace_back( make_shared< ghost::global_constraints::LinearEquationLeq >( std::vector<int>{9,10}, 1 ) );
	constraints.emplace_back( make_shared< ghost::global_constraints::LinearEquationLeq >( std::vector<int>{12,13}, 1 ) );
	constraints.emplace_back( make_shared<TrainingSet>( variables, _training_data, _size_training_set, _candidate_length, _domain_size, _starting_value, _error_vector, _parameter ) );
}

void BuilderQUBO::declare_objective()
{
	objective = std::make_shared<ObjectiveShortExpression>( variables );
}
