#pragma once

#include "Common.h"

class GenericRoad
{
public:
	virtual RoadResult MoveVehicle(Location location, DIRECTION direction) = 0;

	/* 
		the indexing will work for rows starting with the lowest number as 0 and going till 2 * radius +1
		same for columns
	*/
	virtual std::vector<RoadStatus> Sense(Location location, size_t radius) const = 0;

	static Location UnsafeGetNeighborCoordinatesInDirection(Location location, DIRECTION direction)
	{
		static const std::pair<int, int> steps[] = { {-1, 0}, {0, 1}, {1, 0}, {0, -1} };
		return { location.row + steps[direction].first, location.column + steps[direction].second };
	}

};
