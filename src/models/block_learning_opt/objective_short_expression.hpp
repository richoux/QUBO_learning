#pragma once

#include <string>
#include <vector>
#include <memory>

#include <ghost/objective.hpp>
#include <ghost/variable.hpp>

using namespace std;
using namespace ghost;

class ObjectiveShortExpression : public Minimize
{

  double required_cost( const vector<Variable*>& vecVariables ) const override;
	
public:
	ObjectiveShortExpression( const vector<Variable>& variables );
};
