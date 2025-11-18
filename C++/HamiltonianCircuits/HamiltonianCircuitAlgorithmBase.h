#pragma once

#include "Common.h"
#include "AgentProxy.h"

class HamiltonianCircuitAlgorithmBase
{
public:
	virtual DIRECTION WhereToMove(const AgentProxy& lowLevelAgent, bool exiting) const = 0;
};