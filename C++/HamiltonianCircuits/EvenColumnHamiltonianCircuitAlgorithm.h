#pragma once

#include <stdexcept>
#include "HamiltonianCircuitAlgorithmBase.h"

class EvenColumnHamiltonianCircuitAlgorithm : public HamiltonianCircuitAlgorithmBase
{
private:
	static bool IsInFirstRow(const std::vector<RoadStatus>& readings, const std::vector<size_t>& lookup)
	{
		return readings[lookup[2]] == WALL;
	}

	static bool IsInSecondRow(const std::vector<RoadStatus>& readings, const std::vector<size_t>& lookup)
	{
		return readings[lookup[0]] == WALL && readings[lookup[2]] != WALL;
	}

	static bool IsInLastRow(const std::vector<RoadStatus>& readings, const std::vector<size_t>& lookup)
	{
		return readings[lookup[10]] == WALL;
	}

	static bool IsInFirstColumn(const std::vector<RoadStatus>& readings, const std::vector<size_t>& lookup)
	{
		return readings[lookup[5]] == WALL;
	}

	static bool IsInLastColumn(const std::vector<RoadStatus>& readings, const std::vector<size_t>& lookup)
	{
		return readings[lookup[8]] == WALL;
	}

	static bool NextSpotIsFree(const std::vector<RoadStatus>& readings, const std::vector<size_t>& lookup, DIRECTION direction)
	{
		size_t spotIndex = 6;
		switch (direction)
		{
			case NORTH:
				spotIndex = 2;
				break;
			case SOUTH:
				spotIndex = 10;
				break;
			case EAST:
				spotIndex = 7;
				break;
			case WEST:
				spotIndex = 5;
				break;
		}

		return readings[lookup[spotIndex]] == FREE || readings[lookup[spotIndex]] == EXITING;
	}

	static bool IsInExitColumn(const std::vector<RoadStatus>& readings, const std::vector<size_t>& lookup)
	{
		return readings[lookup[7]] == WALL;
	}
public:
	
	/*
			  ------
			  |  0 |
		 -----+----+-----
		 |  1 |  2 |  3 |
	-----+----+----+----+-----
	|  4 |  5 |  6 |  7 |  8 |
	-----+----+----+----+-----
	     |  9 | 10 | 11 |
		 -----+----+-----
		      | 12 |
			  ------
	*/
	virtual DIRECTION WhereToMove(const AgentProxy& lowLevelAgent, bool exiting) const override
	{
		size_t visibility = lowLevelAgent.Visibility();
		if (visibility < 2)
			throw std::logic_error("Visibility of at least 2 required");

		std::vector<RoadStatus> readings = lowLevelAgent.Sense();

		// prepare lookup table for indices
		size_t logicalIndex = 0;
		std::vector<size_t> lookUp(13, 0);

		for (int row_offset = -2; row_offset <= 2; ++row_offset)
		{
			for (size_t column = visibility - 2 + abs(row_offset); column <= visibility + 2 - abs(row_offset); ++column)
				lookUp[logicalIndex++] = (visibility + row_offset) * (2 * visibility + 1) + column;
		}

		if (IsInExitColumn(readings, lookUp))
			return ABSENT;

		bool inEvenColumn = lowLevelAgent.IsInEvenColumn();

		bool inFirstColumn = IsInFirstColumn(readings, lookUp);
		bool inLastColumn = IsInLastColumn(readings, lookUp);
		bool inFirstRow = IsInFirstRow(readings, lookUp);
		bool inLastRow = IsInLastRow(readings, lookUp);
		bool inSecondRow = IsInSecondRow(readings, lookUp);

		bool freeNorth = NextSpotIsFree(readings, lookUp, NORTH);
		bool freeSouth = NextSpotIsFree(readings, lookUp, SOUTH);
		bool freeEast = NextSpotIsFree(readings, lookUp, EAST);
		bool freeWest = NextSpotIsFree(readings, lookUp, WEST);

		if (inFirstColumn && !inLastRow && freeSouth)
			return SOUTH;
		if (inLastColumn && exiting && freeEast)
			return EAST;

		if (inLastColumn && !inFirstRow && freeNorth)
			return NORTH;
		if (!inFirstColumn && inFirstRow && freeWest)
			return WEST;

		if (inEvenColumn && inLastRow && freeEast)
			return EAST;
		if (!inLastColumn && !inEvenColumn && inSecondRow && freeEast)
			return EAST;

		if (!inEvenColumn && !inSecondRow && freeNorth)
			return NORTH;
		if (inEvenColumn && !inFirstRow && freeSouth)
			return SOUTH;

		return ABSENT;
	}
};
