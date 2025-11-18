#pragma once

#include <vector>

enum DIRECTION
{
	NORTH,
	EAST,
	SOUTH,
	WEST,
	ABSENT,
};

constexpr DIRECTION Directions[] = { NORTH, EAST, SOUTH, WEST };

enum RoadStatus
{
	FREE,
	OCCUPIED,
	MOVETO,
	MOVEOUT,
	WALL,
	EXITING,
	UNKNOWN,
};

enum RoadResult
{
	FAILURE,
	COLLISION,
	SUCCESS,
};
