#pragma once

#include "LittleCirclesState.h"
#include <map>

class ShiftFrame
{
	// seems like, how the one to the north of (0,0) sees things
	static int LookupShiftedToNorth(int index)
	{
		static int sidesize = 2 * LittleCirclesState::Visibility + 1;
		static std::vector<int> lookup(sidesize * sidesize, -1);
		static bool initialized;

		if (!initialized)
		{
			std::vector<std::vector<int>> neighborhood = LittleCirclesState::GetNeighborhood();

			for (int i = 0; i < sidesize * sidesize; ++i)
			{
				if (i >= sidesize * (sidesize - 1))
					continue;
				if (neighborhood[i / sidesize][i % sidesize] < 0)
					continue;
				lookup[neighborhood[i / sidesize][i % sidesize]] = neighborhood[i / sidesize + 1][i % sidesize];
			}
			initialized = true;
		}

		return lookup[index];
	}

	static int LookupShiftedToEast(int index)
	{
		static int sidesize = 2 * LittleCirclesState::Visibility + 1;
		static std::vector<int> lookup(sidesize * sidesize, -1);
		static bool initialized;

		if (!initialized)
		{
			std::vector<std::vector<int>> neighborhood = LittleCirclesState::GetNeighborhood();

			for (int i = 0; i < sidesize * sidesize; ++i)
			{
				if (i % sidesize == 0)
					continue;
				if (neighborhood[i / sidesize][i % sidesize] < 0)
					continue;
				lookup[neighborhood[i / sidesize][i % sidesize]] = neighborhood[i / sidesize][i % sidesize - 1];
			}
			initialized = true;
		}

		return lookup[index];
	}

	static int LookupShiftedToSouth(int index)
	{
		static int sidesize = 2 * LittleCirclesState::Visibility + 1;
		static std::vector<int> lookup(sidesize * sidesize, -1);
		static bool initialized;

		if (!initialized)
		{
			std::vector<std::vector<int>> neighborhood = LittleCirclesState::GetNeighborhood();

			for (int i = 0; i < sidesize * sidesize; ++i)
			{
				if (i < sidesize)
					continue;
				if (neighborhood[i / sidesize][i % sidesize] < 0)
					continue;
				lookup[neighborhood[i / sidesize][i % sidesize]] = neighborhood[i / sidesize - 1][i % sidesize];
			}
			initialized = true;
		}
		   
		return lookup[index];
	}

	static int LookupShiftedToWest(int index)
	{
		static int sidesize = 2 * LittleCirclesState::Visibility + 1;
		static std::vector<int> lookup(sidesize * sidesize, -1);
		static bool initialized;

		if (!initialized)
		{
			std::vector<std::vector<int>> neighborhood = LittleCirclesState::GetNeighborhood();

			for (int i = 0; i < sidesize * sidesize; ++i)
			{
				if ((i + 1) % sidesize == 0)
					continue;
				if (neighborhood[i / sidesize][i % sidesize] < 0)
					continue;
				lookup[neighborhood[i / sidesize][i % sidesize]] = neighborhood[i / sidesize][i % sidesize + 1];
			}
			initialized = true;
		}

		return lookup[index];
	}

	static LittleCirclesState::COLUMN ShiftColumnEast(LittleCirclesState::COLUMN oldColumn)
	{
		static std::map<LittleCirclesState::COLUMN, LittleCirclesState::COLUMN> translationTable = 
		{
			{ LittleCirclesState::NO_COLUMN, LittleCirclesState::NO_COLUMN },
			{ LittleCirclesState::M0_COLUMN, LittleCirclesState::NO_COLUMN },
			{ LittleCirclesState::M1_COLUMN, LittleCirclesState::M0_COLUMN },
			{ LittleCirclesState::M2_COLUMN, LittleCirclesState::M1_COLUMN },
			{ LittleCirclesState::mM0_COLUMN, LittleCirclesState::NO_COLUMN },
			{ LittleCirclesState::mM1_COLUMN, LittleCirclesState::mM0_COLUMN },
			{ LittleCirclesState::mM2_COLUMN, LittleCirclesState::mM1_COLUMN },
		};

		return translationTable[oldColumn];
	}

	static LittleCirclesState::COLUMN ShiftColumnWest(LittleCirclesState::COLUMN oldColumn)
	{
		static std::map<LittleCirclesState::COLUMN, LittleCirclesState::COLUMN> translationTable =
		{
			{ LittleCirclesState::NO_COLUMN, LittleCirclesState::NO_COLUMN },
			{ LittleCirclesState::M0_COLUMN, LittleCirclesState::M1_COLUMN },
			{ LittleCirclesState::M1_COLUMN, LittleCirclesState::M2_COLUMN },
			{ LittleCirclesState::M2_COLUMN, LittleCirclesState::NO_COLUMN },
			{ LittleCirclesState::mM0_COLUMN, LittleCirclesState::mM1_COLUMN },
			{ LittleCirclesState::mM1_COLUMN, LittleCirclesState::mM2_COLUMN },
			{ LittleCirclesState::mM2_COLUMN, LittleCirclesState::NO_COLUMN },
		};

		return translationTable[oldColumn];
	}

	static LittleCirclesState::ROW ShiftRowNorth(LittleCirclesState::ROW oldRow)
	{
		static std::map<LittleCirclesState::ROW, LittleCirclesState::ROW> translationTable =
		{
			{ LittleCirclesState::NO_ROW, LittleCirclesState::NO_ROW },
			{ LittleCirclesState::U0_ROW, LittleCirclesState::NO_ROW },
			{ LittleCirclesState::U1_ROW, LittleCirclesState::U0_ROW },
			{ LittleCirclesState::U2_ROW, LittleCirclesState::U1_ROW },
			{ LittleCirclesState::D0_ROW, LittleCirclesState::D1_ROW },
			{ LittleCirclesState::D1_ROW, LittleCirclesState::D2_ROW },
			{ LittleCirclesState::D2_ROW, LittleCirclesState::NO_ROW },
			{ LittleCirclesState::mU0_ROW, LittleCirclesState::NO_ROW },
			{ LittleCirclesState::mU1_ROW, LittleCirclesState::mU0_ROW },
			{ LittleCirclesState::mU2_ROW, LittleCirclesState::mU1_ROW },
			{ LittleCirclesState::mD0_ROW, LittleCirclesState::mD1_ROW },
			{ LittleCirclesState::mD1_ROW, LittleCirclesState::mD2_ROW },
			{ LittleCirclesState::mD2_ROW, LittleCirclesState::NO_ROW },
		};

		return translationTable[oldRow];
	}

	static LittleCirclesState::ROW ShiftRowSouth(LittleCirclesState::ROW oldRow)
	{
		static std::map<LittleCirclesState::ROW, LittleCirclesState::ROW> translationTable =
		{
			{ LittleCirclesState::NO_ROW, LittleCirclesState::NO_ROW },
			{ LittleCirclesState::U0_ROW, LittleCirclesState::U1_ROW },
			{ LittleCirclesState::U1_ROW, LittleCirclesState::U2_ROW },
			{ LittleCirclesState::U2_ROW, LittleCirclesState::NO_ROW },
			{ LittleCirclesState::D0_ROW, LittleCirclesState::NO_ROW },
			{ LittleCirclesState::D1_ROW, LittleCirclesState::D0_ROW },
			{ LittleCirclesState::D2_ROW, LittleCirclesState::D1_ROW },
			{ LittleCirclesState::mU0_ROW, LittleCirclesState::mU1_ROW },
			{ LittleCirclesState::mU1_ROW, LittleCirclesState::mU2_ROW },
			{ LittleCirclesState::mU2_ROW, LittleCirclesState::NO_ROW },
			{ LittleCirclesState::mD0_ROW, LittleCirclesState::NO_ROW },
			{ LittleCirclesState::mD1_ROW, LittleCirclesState::mD0_ROW },
			{ LittleCirclesState::mD2_ROW, LittleCirclesState::mD1_ROW },
		};

		return translationTable[oldRow];
	}

	typedef int(*Shifters)(int);

	void TryToAdd(std::vector<unsigned>& vehicles, LittleCirclesState::DIRECTION shiftDirection, int prevIndex) const
	{
		static Shifters shifters[] = { LookupShiftedToNorth, LookupShiftedToEast, LookupShiftedToSouth, LookupShiftedToWest };

		int newIndex = shifters[shiftDirection](prevIndex);
		if (newIndex < 0)
			return;

		vehicles.push_back(newIndex);
	}

public:
	LittleCirclesState ShiftaFrame(const LittleCirclesState& state, LittleCirclesState::DIRECTION shiftDirection) const
	{
		if (shiftDirection == LittleCirclesState::NO_DIRECTION)
			return state;

		if ((shiftDirection == LittleCirclesState::NORTH && state.row == LittleCirclesState::U0_ROW) ||
			(shiftDirection == LittleCirclesState::EAST && state.column == LittleCirclesState::M0_COLUMN) ||
			(shiftDirection == LittleCirclesState::SOUTH && state.row == LittleCirclesState::D0_ROW))
			throw std::runtime_error("unable to shift frame");

		LittleCirclesState newState;
		switch (state.agent)
		{
			case LittleCirclesState::VEXIT:
				TryToAdd(newState.exiting, shiftDirection, 0);
				break;
			case LittleCirclesState::VCONTINUE:
				TryToAdd(newState.continuing, shiftDirection, 0);
				break;
		}
		for (auto vehicle : state.exiting)
			TryToAdd(newState.exiting, shiftDirection, vehicle);
		for (auto vehicle : state.continuing)
			TryToAdd(newState.continuing, shiftDirection, vehicle);

		newState.column = state.column;
		newState.row = state.row;

		switch (shiftDirection)
		{
			case LittleCirclesState::NORTH:
				newState.row = ShiftRowNorth(state.row);
				break;
			case LittleCirclesState::EAST:
				newState.column = ShiftColumnEast(state.column);
				break;
			case LittleCirclesState::SOUTH:
				newState.row = ShiftRowSouth(state.row);
				break;
			case LittleCirclesState::WEST:
				newState.column = ShiftColumnWest(state.column);
				break;
		}

		return newState;
	}
};
