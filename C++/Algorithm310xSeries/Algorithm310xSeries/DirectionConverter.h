#pragma once

#include <utility>
#include "Enums.h"

namespace Phd
{
	class DirectionConverter
	{
	private:
		const std::pair<int, int> North{ -1, 0 };
		const std::pair<int, int> East{ 0, 1 };
		const std::pair<int, int> South{ 1, 0 };
		const std::pair<int, int> West{ 0, -1 };
		const std::pair<int, int> Stay{ 0, 0 };

	public:
		static std::pair<int, int> GetStep(Direction direction)
		{
			static DirectionConverter converter;

			switch (direction)
			{
				case Direction::NORTH:
					return converter.North;
				case Direction::EAST:
					return converter.East;
				case Direction::SOUTH:
					return converter.South;
				case Direction::WEST:
					return converter.West;
			}
			return converter.Stay;
		}
	};

}