#pragma once

#include <vector>
#include <memory>
#include "Agent.h"

namespace Phd
{
	class LLGrid
	{
	protected:
		std::vector<std::vector<std::shared_ptr<Agent> > > road;

		LLGrid(const std::vector<std::vector<std::shared_ptr<Agent>> >& road)
			: road(road)
		{
		}

	public:
		std::tuple<size_t, size_t> size() const
		{
			return std::make_tuple(height(), width());
		}

		size_t height() const
		{
			return road.size();
		}

		size_t width() const
		{
			return road[0].size();
		}

		virtual Item operator()(int row, int col) const
		{
			if (row < 0 || col < 0 || row >= height() || col >= width())
				return Item::BORDER;

			if (road[row][col] == nullptr)
				return Item::EMPTY;

			return Item::VEHICLE;
		}

		virtual Type TypeAt(int row, int col) const
		{
			if (row < 0 || col < 0 || row >= height() || col >= width())
				throw std::logic_error("Trying to access agent not on the grid");

			if (road[row][col] == nullptr)
				return Type::EMPTY;

			return road[row][col]->Type();
		}

		virtual void Tick() = 0;

		std::ostream& Print(std::ostream& out) const
		{
			for (auto row = 0; row < height(); ++row)
			{
				for (auto col = 0; col < width(); ++col)
					out << TypeAt(row, col) << TypeAt(row, col);
				out << '\n';
			}

			return out;
		}

	};

	std::ostream& operator<< (std::ostream& out, const LLGrid& grid)
	{
		return grid.Print(out);
	}
}
