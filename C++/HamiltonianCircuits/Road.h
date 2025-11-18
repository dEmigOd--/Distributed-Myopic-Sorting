#pragma once

#include <vector>
#include <iostream>
#include <exception>

#include "GenericRoad.h"
#include "RoadInfrastructure.h"

class Road	: public GenericRoad
			, public RoadInfrastructure
{
private:
	std::vector<std::vector<RoadStatus>>	occupancy,
											intentions;
	std::vector<RoadStatus>					exitLane;

	bool IsOccupied(Location location) const
	{
		return (location.column == m && exitLane[location.row] == OCCUPIED) || (location.column < m && occupancy[location.row][location.column] == OCCUPIED);
	}

	bool WouldBeOccupied(Location location) const
	{
		return (location.column == m && exitLane[location.row] == MOVETO) || (location.column < m && intentions[location.row][location.column] == MOVETO);
	}

	RoadResult InternalAddVehicle(Location location)
	{
		if (IsOccupied(location))
			return COLLISION;

		occupancy[location.row][location.column] = OCCUPIED;
		return SUCCESS;
	}

	bool IsOnTheRoad(Location location) const
	{
		return location.row < n && location.column < m;
	}

	bool NotMovingOutOfRoad(Location location, DIRECTION direction) const
	{
		switch (direction)
		{
			case DIRECTION::NORTH:
				return location.row > 0;
			case DIRECTION::SOUTH:
				return location.row < n - 1;
			case DIRECTION::EAST:
				return location.column <= m - 1;
			case DIRECTION::WEST:
				return location.column > 0;
		}

		return true;
	}

public:
	Road(size_t rows, size_t columns)
		: RoadInfrastructure(rows, columns)
		, occupancy(rows, std::vector<RoadStatus>(columns, FREE))
		, exitLane(rows, FREE)
	{}

	virtual RoadResult AddVehicle(Location location) override
	{
		if (!IsOnTheRoad(location))
			return FAILURE;

		return InternalAddVehicle(location);
	}

	virtual RoadResult StartTick() override
	{
		intentions = std::vector<std::vector<RoadStatus>>(n, std::vector<RoadStatus>(m, FREE));
		return SUCCESS;
	}

	virtual RoadResult CloseTick() override
	{
		for (size_t row = 0; row < n; ++row)
		{
			for (size_t column = 0; column < m; ++column)
			{
				switch (intentions[row][column])
				{
					case MOVETO:
						occupancy[row][column] = OCCUPIED;
						break;
					case MOVEOUT:
						occupancy[row][column] = FREE;
						break;
				}
			}

			if (exitLane[row] == MOVETO)
				exitLane[row] = OCCUPIED;
		}

		return SUCCESS;
	}

	virtual RoadResult MoveVehicle(Location location, DIRECTION direction) override
	{
		if(!IsOccupied(location) || !NotMovingOutOfRoad(location, direction))
			return FAILURE;

		auto newLocation = UnsafeGetNeighborCoordinatesInDirection(location, direction);
		if (IsOccupied(newLocation) || WouldBeOccupied(newLocation))
			return COLLISION;

		if (newLocation.column == m)
			exitLane[newLocation.row] = MOVETO;
		else
			intentions[newLocation.row][newLocation.column] = MOVETO;

		intentions[location.row][location.column] = MOVEOUT;

		return SUCCESS;
	}

	virtual std::vector<RoadStatus> Sense(Location location, size_t radius) const override
	{
		std::vector<RoadStatus> neighbors((2 * radius + 1) * (2 * radius + 1), UNKNOWN);

		size_t index = 0;
		int signed_radius = static_cast<int>(radius),
			st_visibility = -signed_radius;
		for (int row_diff = st_visibility; row_diff <= signed_radius; ++row_diff)
		{
			for (int col_diff = st_visibility; col_diff <= signed_radius; ++col_diff, ++index)
			{
				if (abs(row_diff) + abs(col_diff) > signed_radius)
					continue;

				if ((row_diff < 0 && -row_diff > location.row) ||
					(col_diff < 0 && -col_diff > location.column) ||
					(row_diff > 0 && (row_diff + location.row) >= n) ||
					(col_diff > 0 && (col_diff + location.column) > m))
					neighbors[index] = WALL;
				else
				{
					if (location.column > 0 && (col_diff + location.column) == m)
						neighbors[index] = exitLane[location.row + row_diff] == OCCUPIED ? OCCUPIED : EXITING;
					else
						neighbors[index] = occupancy[location.row + row_diff][location.column + col_diff];
				}
			}
		}

		return neighbors;
	}

	virtual bool EvenRows() const override
	{
		throw std::logic_error("Not Implemented for Hamiltonian Circuits");
	}

	virtual bool EvenColumns() const override
	{
		return m % 2 == 0;
	}

	virtual bool HaveFreeExitSpace() const override
	{
		return !std::any_of(exitLane.cbegin(), exitLane.cend(), [](RoadStatus cellStatus) {return cellStatus != OCCUPIED;});
	}

};
