#pragma once

#include "LittleCirclesState.h"
#include <sstream>
#include <map>

#define PRINTER(name) mapping[name] = #name

static std::string printer(const char *name)
{
	std::ostringstream ostr;
	ostr << name;
	return ostr.str();
}

class LittleCirclesv3
{
private:
	std::vector<LittleCirclesState> patterns;

public:
	static const unsigned right_upper_cycle_1 = 1;
	static const unsigned right_upper_cycle_2 = 2;
	static const unsigned right_upper_cycle_3 = 3;
	static const unsigned down_cycle_1 = 6;
	static const unsigned down_cycle_2 = 5;
	static const unsigned down_cycle_3 = 7;
	static const unsigned down_cycle_4 = 8;
	static const unsigned down_cycle_5 = 9;
	static const unsigned up_cycle_1 = 10;
	static const unsigned up_cycle_2 = 11;
	static const unsigned up_cycle_3 = 12;
	static const unsigned up_cycle_4 = 13;
	static const unsigned up_cycle_5 = 14;
	static const unsigned up_cycle_6 = 16;
	static const unsigned up_cycle_7 = 17;
	static const unsigned up_cycle_8 = 18;
	static const unsigned up_cycle_9 = 19;
	static const unsigned up_cycle_10 = 4;
	static const unsigned down_right_1 = 27;
	static const unsigned down_right_2 = 20;
	static const unsigned down_right_3 = 15;
	static const unsigned down_right_4 = 21;
	static const unsigned down_right_5 = 23;
	static const unsigned down_right_6 = 26;
	static const unsigned up_right_1 = 25;
	static const unsigned up_right_2 = 22;
	static const unsigned up_right_3 = 24;
	static const unsigned up_right_4 = 28;

	static const unsigned PRIORITIES_COUNT = up_right_4;

	static const LittleCirclesState::VEHICLE 
		VEXIT = LittleCirclesState::VEXIT, 
		VCONTINUE = LittleCirclesState::VCONTINUE, 
		AGENT_NOT_CARE = LittleCirclesState::AGENT_NOT_CARE;
	static const LittleCirclesState::DIRECTION 
		NORTH = LittleCirclesState::NORTH, 
		EAST = LittleCirclesState::EAST, 
		SOUTH = LittleCirclesState::SOUTH, 
		WEST = LittleCirclesState::WEST;
	static const LittleCirclesState::COLUMN 
		M0_COLUMN = LittleCirclesState::M0_COLUMN, 
		M1_COLUMN = LittleCirclesState::M1_COLUMN, 
		M2_COLUMN = LittleCirclesState::M2_COLUMN,
		mM0_COLUMN = LittleCirclesState::mM0_COLUMN, 
		mM1_COLUMN = LittleCirclesState::mM1_COLUMN, 
		NO_COLUMN = LittleCirclesState::NO_COLUMN;
	static const LittleCirclesState::ROW 
		U0_ROW = LittleCirclesState::U0_ROW, 
		U1_ROW = LittleCirclesState::U1_ROW, 
		U2_ROW = LittleCirclesState::U2_ROW,
		D0_ROW = LittleCirclesState::D0_ROW, 
		D1_ROW = LittleCirclesState::D1_ROW, 
		U2_ROW = LittleCirclesState::D2_ROW,
		mU0_ROW = LittleCirclesState::mU0_ROW, 
		mU1_ROW = LittleCirclesState::mU1_ROW, 
		mU2_ROW = LittleCirclesState::mU2_ROW,
		mD0_ROW = LittleCirclesState::mD0_ROW, 
		mD1_ROW = LittleCirclesState::mD1_ROW, 
		mU2_ROW = LittleCirclesState::mD2_ROW,
		NO_ROW = LittleCirclesState::NO_ROW;

	static std::string GetName(unsigned priority)
	{
		static std::map<unsigned, std::string> mapping;
		if (mapping.empty)
		{
			PRINTER(right_upper_cycle_1);
			PRINTER(right_upper_cycle_2);
			PRINTER(right_upper_cycle_3);
			PRINTER(down_cycle_1);
			PRINTER(down_cycle_2);
			PRINTER(down_cycle_3);
			PRINTER(down_cycle_4);
			PRINTER(down_cycle_5);
			PRINTER(up_cycle_1);
			PRINTER(up_cycle_2);
			PRINTER(up_cycle_3);
			PRINTER(up_cycle_4);
			PRINTER(up_cycle_5);
			PRINTER(up_cycle_6);
			PRINTER(up_cycle_7);
			PRINTER(up_cycle_8);
			PRINTER(up_cycle_9);
			PRINTER(up_cycle_10);
			PRINTER(down_right_1);
			PRINTER(down_right_2);
			PRINTER(down_right_3);
			PRINTER(down_right_4);
			PRINTER(down_right_5);
			PRINTER(down_right_6);
			PRINTER(up_right_1);
			PRINTER(up_right_2);
			PRINTER(up_right_3);
			PRINTER(up_right_4);
		}

		return mapping[priority];
	}

	LittleCirclesv3()
		: patterns(PRIORITIES_COUNT + 1)
	{


		patterns[right_upper_cycle_1] = LittleCirclesState(right_upper_cycle_1, 	     VEXIT, SOUTH,      {6,16},    {2},  M1_COLUMN,  U0_ROW);
		patterns[right_upper_cycle_2] = LittleCirclesState(right_upper_cycle_2,      VCONTINUE,  WEST,    {3,7,11},     {},  M0_COLUMN,  U0_ROW);
		patterns[right_upper_cycle_3] = LittleCirclesState(right_upper_cycle_3, 	     VEXIT, NORTH,       {3,4},    {8},  M0_COLUMN,  U1_ROW);
		patterns[       down_cycle_1] = LittleCirclesState(       down_cycle_1, 	     VEXIT, SOUTH,          {},     {},  M0_COLUMN,  NO_ROW);
		patterns[       down_cycle_2] = LittleCirclesState(       down_cycle_2,      VCONTINUE,  EAST,         {6},   {16},  M1_COLUMN,  NO_ROW);
		patterns[       down_cycle_3] = LittleCirclesState(       down_cycle_3, AGENT_NOT_CARE, NORTH,         {2},    {6},  M1_COLUMN, mD0_ROW);
		patterns[       down_cycle_4] = LittleCirclesState(       down_cycle_4, AGENT_NOT_CARE, NORTH,         {5},    {2},  M1_COLUMN,  NO_ROW);
		patterns[       down_cycle_5] = LittleCirclesState(       down_cycle_5,      VCONTINUE,  WEST,         {1},     {},  M0_COLUMN,  NO_ROW);
		patterns[         up_cycle_1] = LittleCirclesState(         up_cycle_1, 	     VEXIT, NORTH,         {2},     {},  M1_COLUMN,  NO_ROW);
		patterns[         up_cycle_2] = LittleCirclesState(         up_cycle_2, 	     VEXIT, NORTH,          {},     {},  M1_COLUMN,  D0_ROW);
		patterns[         up_cycle_3] = LittleCirclesState(         up_cycle_3, AGENT_NOT_CARE,  EAST, {5, 10, 15},     {},  M2_COLUMN, mU1_ROW);
		patterns[         up_cycle_4] = LittleCirclesState(         up_cycle_4, AGENT_NOT_CARE,  EAST,     {5, 10},     {},  M2_COLUMN,  D0_ROW);
		patterns[         up_cycle_5] = LittleCirclesState(         up_cycle_5, AGENT_NOT_CARE, SOUTH,     {2, 15},     {},  M2_COLUMN, mU0_ROW);
		patterns[         up_cycle_6] = LittleCirclesState(         up_cycle_6, AGENT_NOT_CARE, SOUTH,         {6},     {},  M2_COLUMN,  NO_ROW);
		patterns[         up_cycle_7] = LittleCirclesState(         up_cycle_7,      VCONTINUE,  WEST,         {3},     {},  M1_COLUMN,  NO_ROW);
		patterns[         up_cycle_8] = LittleCirclesState(         up_cycle_8,      VCONTINUE,  WEST,         {7},    {3},  M0_COLUMN,  NO_ROW);
		patterns[         up_cycle_9] = LittleCirclesState(         up_cycle_9,      VCONTINUE, NORTH,         {4},     {},  M0_COLUMN, mD0_ROW);
		patterns[        up_cycle_10] = LittleCirclesState(        up_cycle_10, 	     VEXIT,  EAST,          {},     {},  M1_COLUMN, mD0_ROW);
		patterns[       down_right_1] = LittleCirclesState(       down_right_1, 	     VEXIT,  EAST,          {},     {}, mM1_COLUMN,  NO_ROW);
		patterns[       down_right_2] = LittleCirclesState(       down_right_2, AGENT_NOT_CARE, NORTH,         {5},     {}, mM1_COLUMN,  NO_ROW);
		patterns[       down_right_3] = LittleCirclesState(       down_right_3, AGENT_NOT_CARE,  WEST,         {1},     {},  M1_COLUMN,  U1_ROW);
		patterns[       down_right_4] = LittleCirclesState(       down_right_4, AGENT_NOT_CARE,  WEST,         {1},     {}, mM0_COLUMN,  NO_ROW);
		patterns[       down_right_5] = LittleCirclesState(       down_right_5,      VCONTINUE,  WEST,         {8},    {1},  NO_COLUMN,  NO_ROW);
		patterns[       down_right_6] = LittleCirclesState(       down_right_6,      VCONTINUE, SOUTH,         {4},     {},  NO_COLUMN,  NO_ROW);
		patterns[         up_right_1] = LittleCirclesState(         up_right_1, AGENT_NOT_CARE, SOUTH,         {6},     {}, mM1_COLUMN,  D1_ROW);
		patterns[         up_right_2] = LittleCirclesState(         up_right_2, AGENT_NOT_CARE,  WEST,         {3},     {}, mM0_COLUMN,  D1_ROW);
		patterns[         up_right_3] = LittleCirclesState(         up_right_3,      VCONTINUE,  WEST,         {7},     {},  NO_COLUMN,  D1_ROW);
		patterns[         up_right_4] = LittleCirclesState(         up_right_4,      VCONTINUE, NORTH,         {4},     {}, mM0_COLUMN,  D0_ROW);
	}

	LittleCirclesState GetPattern(unsigned index) const
	{
		if (index >= patterns.size())
			return LittleCirclesState();

		return patterns[index];
	}
};