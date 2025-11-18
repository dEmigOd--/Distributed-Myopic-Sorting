#pragma once

#include "Constants.h"

struct Location
{
	size_t row, column;
};

bool operator<(Location lhs, Location rhs)
{
	return lhs.row < rhs.row || ((lhs.row == rhs.row) && (lhs.column < rhs.column));
}
