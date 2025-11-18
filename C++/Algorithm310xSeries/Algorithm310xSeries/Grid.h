#pragma once

#include <string>
#include <iostream>
#include <memory>
#include "Enums.h"
#include "LLGrid.h"
#include "Mask.h"
#include "Agent.h"
#include "Algorithm.h"

namespace Phd
{
	class Grid : public LLGrid
	{
	private:
		std::shared_ptr<BasicMask> mask;

	public:
		Grid(const std::vector<std::vector<Type> >& vehicles, std::shared_ptr<BasicMask> mask, std::shared_ptr<Algorithm> algo)
			: LLGrid(std::vector<std::vector< std::shared_ptr<Agent> >>(vehicles.size(), std::vector< std::shared_ptr<Agent>>(vehicles[0].size(), nullptr)))
			, mask(mask)
		{
			for (auto row_ind = 0; row_ind < vehicles.size(); ++row_ind)
			{
				for (auto col_ind = 0; col_ind < vehicles[0].size(); ++col_ind)
				{
					if (vehicles[row_ind][col_ind] != Type::EMPTY)
					{
						road[row_ind][col_ind] = std::shared_ptr<Agent>(new Agent(vehicles[row_ind][col_ind], algo));
					}
				}
			}
		}

		void Tick()
		{
			using vector_type = std::vector<std::vector<std::shared_ptr<Agent> > >;
			vector_type next_road(road.size(), std::vector< std::shared_ptr<Agent>>(road[0].size(), nullptr));

			for (auto row = 0; row < road.size(); ++row)
			{
				for (auto col = 0; col < road[0].size(); ++col)
				{
					if (road[row][col] != nullptr)
					{
						auto neighborhood = mask->GetSensorReadings(*this, row, col);
						auto decision = road[row][col]->LookComputeMove(neighborhood);

						auto step = DirectionConverter::GetStep(decision);
						if (next_road[static_cast<vector_type::size_type>(row) + std::get<0>(step)][static_cast< std::vector<std::shared_ptr<Agent> >::size_type>(col) + std::get<1>(step)])
							throw new std::runtime_error(std::string("Cell at (") + std::to_string(row) + ", " + std::to_string(col) + ") is already occupied");

						next_road[static_cast<vector_type::size_type>(row) + std::get<0>(step)][static_cast<std::vector<std::shared_ptr<Agent> >::size_type>(col) + std::get<1>(step)] = road[row][col];
					}
				}
			}

			road = next_road;
		}
	};
}
