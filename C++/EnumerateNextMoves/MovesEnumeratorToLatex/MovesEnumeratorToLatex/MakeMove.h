#pragma once

#include "LittleCirclesState.h"

class MakeMove
{
public:
	LittleCirclesState MakeaMove(const LittleCirclesState& state) const
	{
		LittleCirclesState newState = state;
		if (state.agent == LittleCirclesState::VEXIT)
			newState.exiting.push_back(1 + state.direction);
		if (state.agent == LittleCirclesState::VCONTINUE)
			newState.continuing.push_back(1 + state.direction);
		newState.direction = LittleCirclesState::NO_DIRECTION;
		newState.agent = LittleCirclesState::NO_VEHICLE;

		return newState;
	}
};
