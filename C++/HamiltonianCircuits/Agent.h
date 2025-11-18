#pragma once

#include <memory>
#include <ostream>

#include "AgentProxy.h"
#include "HamiltonianCircuitAlgorithmBase.h"

class Agent
{
	AgentProxy me;
	bool exiting;
	std::shared_ptr<HamiltonianCircuitAlgorithmBase> algo;
public :
	Agent(const AgentProxy& me, bool exiting, std::shared_ptr<HamiltonianCircuitAlgorithmBase>& decisionAlgorithm)
		: me(me)
		, exiting(exiting)
		, algo(decisionAlgorithm)
	{ }

	RoadResult Compute()
	{
		auto readings = me.Sense();
		auto movementDirection = algo->WhereToMove(me, exiting);
		if (movementDirection != ABSENT)
			return me.MoveVehicle(movementDirection);

		return SUCCESS;
	}

	Location GetLocation() const
	{
		return me.GetLocation();
	}

	bool Exiting() const
	{
		return exiting;
	}
};
