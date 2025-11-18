#pragma once

#include "LittleCirclesState.h"
#include <algorithm>

class PatternMatcher
{
	bool IsSubset(std::vector<unsigned>& set, std::vector<unsigned>& subset) const
	{
		std::vector<unsigned> intersection;

		std::sort(set.begin(), set.end());
		std::sort(subset.begin(), subset.end());

		std::set_intersection(set.begin(), set.end(),
							  subset.begin(), subset.end(),
							  std::back_inserter(intersection));
		return intersection.size() == subset.size();
	}

	bool AllVehiclesHit(LittleCirclesState::VEHICLE type, const std::vector<unsigned>& v_state, LittleCirclesState::VEHICLE agent_state, 
						const std::vector<unsigned>& v_pattern, LittleCirclesState::VEHICLE agent_pattern) const
	{
		std::vector<unsigned> set(v_state.begin(), v_state.end());
		if (agent_state == type && (std::find(set.begin(), set.end(), 0) == set.end()))
			set.push_back(0);
		std::vector<unsigned> subset(v_pattern.begin(), v_pattern.end());
		if (agent_pattern == type && (std::find(subset.begin(), subset.end(), 0) == subset.end()))
			subset.push_back(0);

		return IsSubset(set, subset);
	}
public:
	bool IsInState(const LittleCirclesState& state, const LittleCirclesState& pattern) const
	{
		// different bordering
		if (pattern.column > LittleCirclesState::NO_COLUMN && state.column != pattern.column)
			return false;
		if (pattern.row > LittleCirclesState::NO_ROW && state.row != pattern.row)
			return false;
		// different bordering in negative case
		if (pattern.column < LittleCirclesState::NO_COLUMN && state.column > LittleCirclesState::NO_COLUMN &&
			state.column <= -pattern.column)
			return false;
		if (pattern.row < LittleCirclesState::NO_ROW && state.column > LittleCirclesState::NO_ROW &&
			((pattern.row >= LittleCirclesState::mD2_ROW && state.row <= -pattern.row) ||
			(state.row > LittleCirclesState::D2_ROW && state.row <= -pattern.row)))
			return false;

		return AllVehiclesHit(LittleCirclesState::VEXIT, state.exiting, state.agent, pattern.exiting, pattern.agent) &&
			AllVehiclesHit(LittleCirclesState::VCONTINUE, state.continuing, state.agent, pattern.continuing, pattern.agent);
	}
};