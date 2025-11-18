#pragma once

#include "StateFSM.h"

class FSM
{
public:
	virtual std::shared_ptr<bStateFSM> GetState(int index) const = 0;
};
