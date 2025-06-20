/*
 * GHOST (General meta-Heuristic Optimization Solving Tool) is a C++ framework
 * designed to help developers to model and implement optimization problem
 * solving. It contains a meta-heuristic solver aiming to solve any kind of
 * combinatorial and optimization real-time problems represented by a CSP/COP/EFSP/EFOP. 
 *
 * First developped to solve game-related optimization problems, GHOST can be used for
 * any kind of applications where solving combinatorial and optimization problems. In
 * particular, it had been designed to be able to solve not-too-complex problem instances
 * within some milliseconds, making it very suitable for highly reactive or embedded systems.
 * Please visit https://github.com/richoux/GHOST for further information.
 *
 * Copyright (C) 2014-2022 Florian Richoux
 *
 * This file is part of GHOST.
 * GHOST is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * GHOST is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with GHOST. If not, see http://www.gnu.org/licenses/.
 */

#pragma once

#include <vector>

#include "search_unit_data.hpp"
// #include "macros.hpp"
#include "thirdparty/randutils.hpp"

namespace ghost
{
	namespace algorithms
	{
		/*
		 * VariableHeuristic follows the Strategy design pattern to implement variable selection heuristics.
		 */
		class VariableHeuristic
		{
		protected:
			std::string name;
		
		public:
			VariableHeuristic( std::string&& name )
				: name( std::move( name ) )
			{ }

			inline std::string get_name() const { return name; }

			// candidates is a vector of double to be more generic, allowing for instance a vector of errors
			// rather than a vector of ID, like it would certainly be often the case in practice.
			virtual int select_variable_candidate( const std::vector<double>& candidates, const SearchUnitData& data, randutils::mt19937_rng& rng ) const = 0;
		};
	}
}
