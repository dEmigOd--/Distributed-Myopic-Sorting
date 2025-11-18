#pragma once

#include <vector>
#include <utility>
#include "Enums.h"
#include "DirectionConverter.h"
#include "LLGrid.h"

namespace Phd
{
	class BasicMask
	{
	public:
		virtual std::vector<Item> GetSensorReadings(const LLGrid& grid, int row, int  col) const = 0;
	};

	template<int Visibility>
	class Mask : public BasicMask
	{
	private:
		std::vector<std::pair<int, int> > mask;
	public:
		Mask(const std::vector<Direction>& sensors_that_matter)
		{
			mask.reserve(sensors_that_matter.size());
			for (auto iter = sensors_that_matter.begin(); iter != sensors_that_matter.end(); ++iter)
				mask.push_back(DirectionConverter::GetStep(*iter));
		}

		std::vector<Item> GetSensorReadings(const LLGrid& grid, int row, int col) const
		{
			std::vector<Item> readings(mask.size(), Item::EMPTY);
			for (auto index = 0; index < mask.size(); ++index)
			{
				readings[index] = grid(row + std::get<0>(mask[index]), col + std::get<1>(mask[index]));
			}

			return readings;
		}
	};
}
