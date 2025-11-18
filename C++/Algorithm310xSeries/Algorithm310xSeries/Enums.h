#pragma once

#include <iostream>
#include <vector>

namespace Phd
{
	enum class Item
	{
		EMPTY = 0,
		VEHICLE = 1,
		BORDER = 2,
		ANYTHING = 3,
		TOTAL = 4,
	};

	enum class Direction
	{
		NORTH,
		EAST,
		SOUTH,
		WEST,
		NO_DIRECTION,
		ERROR,
	};

	enum class Type
	{
		EMPTY = 0,
		EXIT = 1,
		CONTINUE = 2,
		EXPERIMENTAL = 3,
		TOTAL = 4,
	};

	std::ostream& operator<<(std::ostream& out, Type type)
	{
		switch (type)
		{
			case Type::EXIT:
				out << char(0xB1);			break;
			case Type::EXPERIMENTAL:
				out << char(0xDB);			break;
			case Type::CONTINUE:
				out << char(0xB2);			break;
			default:
				out << char(0xB0);			break;
		}

		return out;
	}

	unsigned to_uint(const std::vector<Item>& neighborhood)
	{
		unsigned result = 0;
		for (auto iter = neighborhood.begin(); iter != neighborhood.end(); ++iter)
		{
			result *= (static_cast<unsigned>(Item::TOTAL) - 1);
			result += static_cast<unsigned>(*iter);
		}

		return result;
	}
}
