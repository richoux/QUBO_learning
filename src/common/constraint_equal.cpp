#include <cmath>
#include <algorithm>
#include <map>

#include "constraint_equal.hpp"

Equal::Equal( const std::vector<int>& variables )
	: Constraint( variables )
{ }

Equal::Equal( std::vector<int>&& variables )
	: Constraint( std::move( variables ) )
{ }

double Equal::required_error( const std::vector<Variable*>& variables ) const
{
	double error = 0.;
	std::map<int, int> count;
	
	for( auto& v : variables )
		if( count.contains( v->get_value() ) )
			++count[v->get_value()];
		else
			count[v->get_value()] = 1;

	int max = 0;
	int most_frequent_value = 0;
	for( const auto[k,v] : count )
		if( max < v )
		{
			max = v;
			most_frequent_value = k;
		}

	for( auto& v : variables )
		error += std::abs( most_frequent_value - v->get_value() );

	return error;
}

// double Equal::optional_delta_error( const std::vector<Variable*> &variables, const std::vector<int> &indexes, const std::vector<int> &candidate_values ) const
// {

// }
