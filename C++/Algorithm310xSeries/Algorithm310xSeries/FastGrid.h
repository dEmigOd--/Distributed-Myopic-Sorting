#pragma once

#include <array>
#include <vector>
#include <memory>
#include "LLGrid.h"
#include "Algorithm.h"
#include "DirectionConverter.h"

namespace Phd
{
	class FastGrid : public LLGrid
	{
	private:
		static const int NeighborCount = 4;

		typedef std::vector<Type>::size_type size_type;

		std::shared_ptr<Algorithm> algo;
		std::vector<Type> fastRoad;
		std::vector<unsigned> memory;

		size_type GetIndex(size_type row, size_type col) const
		{
			if (row < 0 || col < 0 || row >= height() || col >= width())
				throw std::logic_error("Trying to access agent not on the grid");

			return row * width() + col;
		}

		static std::vector<std::pair<int, int>> GetOffsets()
		{
			static bool init = false;
			static std::vector<std::pair<int, int>> pairs;

			if (!init)
			{
				pairs.resize(static_cast<size_t>(Direction::NO_DIRECTION) + 1);
				pairs[static_cast<size_t>(Direction::NORTH)] = DirectionConverter::GetStep(Direction::NORTH);
				pairs[static_cast<size_t>(Direction::EAST)] = DirectionConverter::GetStep(Direction::EAST);
				pairs[static_cast<size_t>(Direction::SOUTH)] = DirectionConverter::GetStep(Direction::SOUTH);
				pairs[static_cast<size_t>(Direction::WEST)] = DirectionConverter::GetStep(Direction::WEST);
				pairs[static_cast<size_t>(Direction::NO_DIRECTION)] = DirectionConverter::GetStep(Direction::NO_DIRECTION);

				init = true;
			}

			return pairs;
		}

		std::vector<unsigned> GetNeighbors() const
		{
			std::array<unsigned, NeighborCount> mult{};
			mult[mult.size() - 1] = 1;
			for(size_t i = mult.size() - 1; i > 0;  --i)
				mult[i - 1] = mult[i] * (static_cast<unsigned>(Item::TOTAL) - 1);

			std::vector<unsigned> result(static_cast<size_t>(height()) * width(), 0);
			auto offsets = GetOffsets();

			size_type my_index = 0;
			for (auto row = 0; row < height(); ++row)
				for (auto col = 0; col < width(); ++col, ++my_index)
					for(auto i = 0; i < NeighborCount; ++i)
						result[my_index] += mult[i] * static_cast<unsigned>(operator()(row + offsets[i].first, col + offsets[i].second));

			return result;
		}
	public:
		FastGrid(const std::vector<std::vector<Type> >& vehicles, std::shared_ptr<Algorithm> algo)
			: LLGrid(std::vector<std::vector<std::shared_ptr<Agent>>>(vehicles.size(), std::vector<std::shared_ptr<Agent>>(vehicles[0].size(), nullptr)))
			, algo(algo)
			, fastRoad(height() * width(), Type::EMPTY)
			, memory(height() * width(), 0)
		{
			auto index = 0;
			for (auto row = 0; row < height(); ++row)
				for (auto col = 0; col < width(); ++col, ++index)
					fastRoad[index] = vehicles[row][col];
		}

		virtual Type TypeAt(int row, int col) const override
		{
			return fastRoad[GetIndex(row, col)];
		}

		virtual Item operator()(int row, int col) const override
		{
			if (row < 0 || col < 0 || row >= height() || col >= width())
				return Item::BORDER;

			if (fastRoad[GetIndex(row, col)] == Type::EMPTY)
				return Item::EMPTY;

			return Item::VEHICLE;
		}

		virtual void Tick() override
		{ 
			std::vector<unsigned> neighbors(GetNeighbors());

			std::vector<unsigned> new_memory(memory.size(), 0);
			std::vector<Type> new_road(fastRoad.size(), Type::EMPTY);

			auto offsets = GetOffsets();
			size_type index = 0;
			for (auto row = 0; row < height(); ++row)
			{
				for (auto col = 0; col < width(); ++col, ++index)
				{
					if (fastRoad[index] != Type::EMPTY)
					{
						auto decision = algo->Step(fastRoad[index], memory[index], neighbors[index]);
						auto& direction = offsets[static_cast<size_t>(decision.second)];
						auto next_index = index + width() * direction.first + direction.second;
						new_memory[next_index] = decision.first;
						new_road[next_index] = fastRoad[index];
					}
				}
			}

			std::swap(fastRoad, new_road);
			std::swap(memory, new_memory);
		}
	};
}
