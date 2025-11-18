#pragma once

#include <ostream>
#include "GenericRoad.h"

class RoadInfrastructure
{
protected:
	const size_t n, m;

	RoadInfrastructure(size_t rows, size_t columns)
		: n(rows)
		, m(columns)
		{}

public:
	virtual	RoadResult AddVehicle(Location location) = 0;

	virtual RoadResult StartTick() = 0;

	virtual RoadResult CloseTick() = 0;

	virtual bool EvenRows() const = 0;

	virtual bool EvenColumns() const = 0;

	virtual bool HaveFreeExitSpace() const = 0;
};
