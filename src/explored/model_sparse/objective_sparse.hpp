#pragma once

#include <string>
#include <vector>
#include <memory>

#include <ghost/objective.hpp>
#include <ghost/variable.hpp>
#include <Eigen/Dense>
#include <randutils.hpp>

using namespace std;
using namespace ghost;

class ObjectiveSparse : public Maximize
{	
  double required_cost( const vector<Variable*>& vecVariables ) const override;
	int expert_heuristic_value( const std::vector<Variable*> &variables,
	                            int variable_index,
	                            const std::vector<int> &possible_values,
	                            randutils::mt19937_rng &rng	) const override;	
public:
	ObjectiveSparse( const vector<Variable>& variables );
};
