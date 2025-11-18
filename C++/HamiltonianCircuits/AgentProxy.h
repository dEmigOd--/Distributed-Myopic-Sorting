#pragma once

#include <memory>
#include "GenericRoad.h"

class AgentProxy
{
private:
	std::shared_ptr<GenericRoad> road;
	Location location;
	size_t visibility;
public:
	AgentProxy(const std::shared_ptr<GenericRoad>& road, Location location, size_t visibility)
		: road(road)
		, location(location)
		, visibility(visibility)
	{
	}

	RoadResult MoveVehicle(DIRECTION direction)
	{
		auto result = road->MoveVehicle(location, direction);
		if (result == SUCCESS)
		{
			location = GenericRoad::UnsafeGetNeighborCoordinatesInDirection(location, direction);
		}
		return result;
	}

	std::vector<RoadStatus> Sense() const
	{
		return road->Sense(location, visibility);
	}

	bool IsInEvenColumn() const
	{
		return (location.column % 2 == 0);
	}

	size_t Visibility() const
	{
		return visibility;
	}

	Location GetLocation() const
	{
		return location;
	}
};
