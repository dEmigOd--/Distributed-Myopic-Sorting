#pragma once

#include <vector>
#include <tuple>

class LittleCirclesState
{
public:
	static const int Visibility = 3;
	static const unsigned NO_PRIORITY = 0;

	enum VEHICLE
	{
		VEXIT = 1,
		DO_NOT_CARE = 0,
		VCONTINUE = -1,
		NO_VEHICLE = 2,
		AGENT_NOT_CARE = 3,
	};

	enum DIRECTION : int
	{
		NORTH,
		EAST,
		SOUTH,
		WEST,
		NO_DIRECTION,
	};

	enum COLUMN : int
	{
		NO_COLUMN = 0,
		M0_COLUMN = 1,
		M1_COLUMN,
		M2_COLUMN,
		mM0_COLUMN = -M0_COLUMN,
		mM1_COLUMN = -M1_COLUMN,
		mM2_COLUMN = -M2_COLUMN,
	};

	enum ROW : int
	{
		NO_ROW = 0,
		D0_ROW = 1,
		D1_ROW,
		D2_ROW,
		U0_ROW,
		U1_ROW,
		U2_ROW,
		mD0_ROW = -D0_ROW,
		mD1_ROW = -D1_ROW,
		mD2_ROW = -D2_ROW,
		mU0_ROW = -U0_ROW,
		mU1_ROW = -U1_ROW,
		mU2_ROW = -U2_ROW,
	};
	
	static std::vector<std::vector<int>> GetNeighborhood()
	{
		static std::vector<std::vector<int>> neighborhood =
		{
			{ -1, -1, -1, 21, -1, -1, -1 },
			{ -1, -1, 20,  9, 13, -1, -1 },
			{ -1, 19,  8,  1,  5, 14, -1 },
			{ 24, 12,  4,  0,  2, 10, 22 },
			{ -1, 18,  7,  3,  6, 15, -1 },
			{ -1, -1, 17, 11, 16, -1, -1 },
			{ -1, -1, -1, 23, -1, -1, -1 },
		};

		return neighborhood;
	}

	static std::tuple<int, int> GetNeighborOffsets(int index)
	{
		static std::vector<std::vector<int>> neighborhood = GetNeighborhood();

		static std::vector<int> lookup(neighborhood.size() * neighborhood[0].size());
		static bool initialized;

		if (!initialized)
		{
			for (int i = 0; i < lookup.size(); ++i)
			{
				if (neighborhood[i / (2 * Visibility + 1)][i % (2 * Visibility + 1)] >= 0)
					lookup[neighborhood[i / (2 * Visibility + 1)][i % (2 * Visibility + 1)]] = i;
			}
			initialized = true;
		}

		int location = lookup[index];
		// check out -(minus) in the y coordinate
		return std::make_tuple(location % (2 * Visibility + 1) - Visibility, -(location / (2 * Visibility + 1) - Visibility));
	}

	unsigned priority;
	VEHICLE agent;
	DIRECTION direction;
	std::vector<unsigned> exiting;
	std::vector<unsigned> continuing;
	COLUMN column;
	ROW row;

	LittleCirclesState(unsigned priority, VEHICLE agent, DIRECTION direction, const std::vector<unsigned>& exiting, const std::vector<unsigned>& continuing,
					   COLUMN column, ROW row)
		: priority(priority)
		, agent(agent)
		, direction(direction)
		, exiting(exiting)
		, continuing(continuing)
		, column(column)
		, row(row)
	{}

	LittleCirclesState(VEHICLE agent, DIRECTION direction, const std::vector<unsigned>& exiting, const std::vector<unsigned>& continuing,
					   COLUMN column, ROW row)
		: LittleCirclesState(NO_PRIORITY, agent, direction, exiting, continuing, column, row)
	{}

	LittleCirclesState()
		: LittleCirclesState(NO_VEHICLE, NO_DIRECTION, {}, {}, NO_COLUMN, NO_ROW)
	{}
};
