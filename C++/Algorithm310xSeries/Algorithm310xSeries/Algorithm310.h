#pragma once

#include <bitset>
#include <algorithm>
#include "Algorithm.h"

namespace Phd
{
	class Algorithm310 : public TimedAlgorithm<>
	{
	private:
		using input_tuple_type = std::tuple<Type, std::vector<Item>, std::bitset<whole_memory_size>>;
		using output_tuple_type = std::tuple< std::bitset<whole_memory_size>, Direction>;
		using comparator = input_tuple_comparer<whole_memory_size>;

		static const unsigned visibility = 1;
		static const unsigned possibilities = 2 * visibility * (visibility + 1);

		static const unsigned main_direction = 0;
		static const unsigned go_north_5_and_9 = 1;

		static std::vector<Item> CreateSensorReadings(const std::vector<Item>& template_reading, unsigned variant)
		{
			std::vector<Item> reading = template_reading;
			unsigned value_to_set = variant;
			for (auto id = 0; id < template_reading.size(); ++id)
			{
				if (template_reading[id] == Item::ANYTHING)
				{
					reading[id] = (value_to_set % 2) ? Item::VEHICLE : Item::EMPTY;
					value_to_set /= 2;
				}
			}

			return reading;
		}

		static std::pair<input_tuple_type, output_tuple_type>
			CreateValidEntry(Type type, const std::vector<Item>& neighborhood, unsigned memory, unsigned direction_bit, Direction direction)
		{
			return std::make_pair(
				std::make_tuple(type, neighborhood, std::bitset<whole_memory_size>(memory)),
				std::make_tuple(std::bitset<whole_memory_size>(direction_bit * (1ull << t_size) + (memory + 1) % timer_modulo), direction)
			);
		}

		static std::pair<input_tuple_type, output_tuple_type>
			CreateMissingEntry(Type type, const std::vector<Item>& neighborhood, unsigned memory)
		{
			return std::make_pair(
				std::make_tuple(type, neighborhood, std::bitset<whole_memory_size>(memory)),
				std::make_tuple(std::bitset<whole_memory_size>((memory + 1ull) % timer_modulo), Direction::ERROR));
		}

		static std::map<input_tuple_type, output_tuple_type, comparator>
			ExpandToPositionTable(Type type, size_t position, const std::vector<std::vector<Item>>& readings, const std::vector<std::vector<std::tuple<unsigned, Direction>>>& content)
		{
			std::map<input_tuple_type, output_tuple_type, comparator> result;

			for (auto reading_id = 0; reading_id < readings.size(); ++reading_id)
			{
				auto reading = readings[reading_id];
				auto free_fields = std::count(reading.begin(), reading.end(), Item::ANYTHING);

				for (auto possibility = 0; possibility < (1 << free_fields); ++possibility)
				{
					std::vector<Item> reading_to_set = CreateSensorReadings(reading, possibility);

					for (auto entry = 0; entry < content[reading_id].size(); ++entry)
						result.insert(CreateValidEntry(type, reading_to_set, entry, std::get<0>(content[reading_id][entry]), std::get<1>(content[reading_id][entry])));

					for (auto entry = static_cast<unsigned>(content[reading_id].size()); entry <= MAX_VALUE; ++entry)
						result.insert(CreateMissingEntry(type, reading_to_set, entry));
				}
			}

			return result;
		}

		static std::map<input_tuple_type, output_tuple_type, comparator>
			CreateExitVehicleTable()
		{
			std::tuple<unsigned, Direction>
				DO_NOTHING = { main_direction, Direction::NO_DIRECTION },
				GO_NORTH = { main_direction, Direction::NORTH },
				GO_EAST = { main_direction, Direction::EAST },
				GO_SOUTH = { main_direction, Direction::SOUTH },
				GO_WEST = { main_direction, Direction::WEST },
				DO_NOTHING_1 = { go_north_5_and_9, Direction::NO_DIRECTION },
				GO_NORTH___1 = { go_north_5_and_9, Direction::NORTH },
				GO_WEST____1 = { go_north_5_and_9, Direction::WEST };

			std::map<input_tuple_type, output_tuple_type, comparator> result, imm_result;
			imm_result = ExpandToPositionTable(Type::EXIT, 1,
				{
					{ Item::ANYTHING, Item::BORDER, Item::BORDER, Item::ANYTHING },
				},
			{
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				}
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::EXIT, 2,
				{
					{ Item::EMPTY, Item::ANYTHING, Item::BORDER, Item::BORDER },
					{ Item::VEHICLE, Item::ANYTHING, Item::BORDER, Item::BORDER },
				},
			{
				{
					GO_NORTH,
					GO_NORTH,
					GO_NORTH,
					DO_NOTHING,
					GO_NORTH,
					GO_NORTH,
					GO_NORTH,
					DO_NOTHING,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				}
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::EXIT, 3,
				{
					{ Item::BORDER, Item::EMPTY, Item::ANYTHING, Item::BORDER },
					{ Item::BORDER, Item::VEHICLE, Item::ANYTHING, Item::BORDER },
				},
			{
				{
					GO_EAST,
					DO_NOTHING,
					GO_EAST,
					GO_EAST,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				}
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::EXIT, 4,
				{
					{ Item::BORDER, Item::BORDER, Item::EMPTY, Item::ANYTHING  },
					{ Item::BORDER, Item::BORDER, Item::VEHICLE, Item::ANYTHING },
				},
			{
				{
					GO_SOUTH,
					GO_SOUTH,
					GO_SOUTH,
					GO_SOUTH,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				}
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::EXIT, 5,
				{
					{ Item::EMPTY, Item::ANYTHING, Item::BORDER, Item::EMPTY },
					{ Item::VEHICLE, Item::ANYTHING, Item::BORDER, Item::EMPTY },
					{ Item::EMPTY, Item::ANYTHING, Item::BORDER, Item::VEHICLE },
					{ Item::VEHICLE, Item::ANYTHING, Item::BORDER, Item::VEHICLE },
				},
			{
				{
					DO_NOTHING,
					GO_WEST____1,
					DO_NOTHING,
					GO_WEST____1,
					DO_NOTHING_1,
					GO_WEST____1,
					DO_NOTHING_1,
					GO_WEST____1,
				},
				{
					DO_NOTHING,
					GO_WEST____1,
					DO_NOTHING,
					GO_WEST____1,
					DO_NOTHING,
					GO_WEST____1,
					DO_NOTHING_1,
					GO_WEST____1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING,
					DO_NOTHING_1,
					GO_NORTH___1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::EXIT, 6,
				{
					{ Item::EMPTY, Item::ANYTHING, Item::ANYTHING, Item::BORDER },
					{ Item::VEHICLE, Item::ANYTHING, Item::ANYTHING, Item::BORDER },
				},
			{
				{
					GO_NORTH,
					GO_NORTH,
					GO_NORTH,
					DO_NOTHING,
					GO_NORTH,
					GO_NORTH,
					GO_NORTH,
					DO_NOTHING,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				}
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::EXIT, 7,
				{
					{ Item::BORDER, Item::EMPTY, Item::ANYTHING, Item::ANYTHING },
					{ Item::BORDER, Item::VEHICLE, Item::ANYTHING, Item::ANYTHING },
				},
			{
				{
					GO_EAST,
					DO_NOTHING,
					GO_EAST,
					GO_EAST,
					GO_EAST,
					DO_NOTHING,
					GO_EAST,
					GO_EAST,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				}
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::EXIT, 8,
				{
					{ Item::ANYTHING, Item::BORDER, Item::EMPTY, Item::ANYTHING  },
					{ Item::ANYTHING, Item::BORDER, Item::VEHICLE, Item::ANYTHING },
				},
			{
				{
					GO_SOUTH,
					GO_SOUTH,
					GO_SOUTH,
					GO_SOUTH,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				}
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::EXIT, 9,
				{
					{ Item::EMPTY, Item::ANYTHING, Item::EMPTY, Item::EMPTY },
					{ Item::EMPTY, Item::ANYTHING, Item::EMPTY, Item::VEHICLE },
					{ Item::EMPTY, Item::ANYTHING, Item::VEHICLE, Item::EMPTY },
					{ Item::EMPTY, Item::ANYTHING, Item::VEHICLE, Item::VEHICLE },
					{ Item::VEHICLE, Item::ANYTHING, Item::EMPTY, Item::EMPTY },
					{ Item::VEHICLE, Item::ANYTHING, Item::EMPTY, Item::VEHICLE },
					{ Item::VEHICLE, Item::ANYTHING, Item::VEHICLE, Item::EMPTY },
					{ Item::VEHICLE, Item::ANYTHING, Item::VEHICLE, Item::VEHICLE },
				},
			{
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					GO_WEST____1,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
					GO_WEST____1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					GO_SOUTH,
					DO_NOTHING,
					DO_NOTHING_1,
					GO_NORTH___1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					GO_WEST____1,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
					GO_WEST____1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING,
					DO_NOTHING_1,
					GO_NORTH___1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					GO_WEST____1,
					DO_NOTHING_1,
					DO_NOTHING,
					DO_NOTHING_1,
					GO_WEST____1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					GO_SOUTH,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					GO_WEST____1,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
					GO_WEST____1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
			});
			result.merge(imm_result);

			return result;
		}

		static std::map<input_tuple_type, output_tuple_type, comparator>
			CreateContinueVehicleTable()
		{
			std::tuple<unsigned, Direction>
				DO_NOTHING = { main_direction, Direction::NO_DIRECTION },
				GO_NORTH = { main_direction, Direction::NORTH },
				GO_EAST = { main_direction, Direction::EAST },
				GO_SOUTH = { main_direction, Direction::SOUTH },
				GO_WEST = { main_direction, Direction::WEST },
				DO_NOTHING_1 = { go_north_5_and_9, Direction::NO_DIRECTION },
				GO_NORTH___1 = { go_north_5_and_9, Direction::NORTH },
				GO_WEST____1 = { go_north_5_and_9, Direction::WEST };

			std::map<input_tuple_type, output_tuple_type, comparator> result, imm_result;
			imm_result = ExpandToPositionTable(Type::CONTINUE, 1,
				{
					{ Item::ANYTHING, Item::BORDER, Item::BORDER, Item::EMPTY },
					{ Item::ANYTHING, Item::BORDER, Item::BORDER, Item::VEHICLE },
				},
			{
				{
					DO_NOTHING,
					GO_WEST____1,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::CONTINUE, 2,
				{
					{ Item::EMPTY, Item::ANYTHING, Item::BORDER, Item::BORDER },
					{ Item::VEHICLE, Item::ANYTHING, Item::BORDER, Item::BORDER },
				},
			{
				{
					GO_NORTH,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					GO_NORTH,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				}
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::CONTINUE, 3,
				{
					{ Item::BORDER, Item::EMPTY, Item::ANYTHING, Item::BORDER },
					{ Item::BORDER, Item::VEHICLE, Item::ANYTHING, Item::BORDER },
				},
			{
				{
					GO_EAST,
					DO_NOTHING,
					GO_EAST,
					GO_EAST,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				}
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::CONTINUE, 4,
				{
					{ Item::BORDER, Item::BORDER, Item::EMPTY, Item::ANYTHING  },
					{ Item::BORDER, Item::BORDER, Item::VEHICLE, Item::ANYTHING },
				},
			{
				{
					GO_SOUTH,
					GO_SOUTH,
					GO_SOUTH,
					GO_SOUTH,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				}
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::CONTINUE, 5,
				{
					{ Item::EMPTY, Item::ANYTHING, Item::BORDER, Item::EMPTY },
					{ Item::VEHICLE, Item::ANYTHING, Item::BORDER, Item::EMPTY },
					{ Item::EMPTY, Item::ANYTHING, Item::BORDER, Item::VEHICLE },
					{ Item::VEHICLE, Item::ANYTHING, Item::BORDER, Item::VEHICLE },
				},
			{
				{
					DO_NOTHING,
					GO_WEST____1,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					GO_NORTH___1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
				{
					DO_NOTHING,
					GO_WEST____1,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
				{
					DO_NOTHING_1,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					GO_NORTH___1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::CONTINUE, 6,
				{
					{ Item::EMPTY, Item::ANYTHING, Item::ANYTHING, Item::BORDER },
					{ Item::VEHICLE, Item::ANYTHING, Item::ANYTHING, Item::BORDER },
				},
			{
				{
					GO_NORTH,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				}
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::CONTINUE, 7,
				{
					{ Item::BORDER, Item::EMPTY, Item::EMPTY, Item::ANYTHING },
					{ Item::BORDER, Item::EMPTY, Item::VEHICLE, Item::ANYTHING },
					{ Item::BORDER, Item::VEHICLE, Item::EMPTY, Item::ANYTHING },
					{ Item::BORDER, Item::VEHICLE, Item::VEHICLE, Item::ANYTHING },
				},
			{
				{
					GO_EAST,
					DO_NOTHING,
					GO_EAST,
					GO_EAST,
					DO_NOTHING,
					DO_NOTHING_1,
					GO_SOUTH,
					DO_NOTHING_1,
				},
				{
					GO_EAST,
					DO_NOTHING,
					GO_EAST,
					GO_EAST,
					GO_EAST,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING_1,
					GO_SOUTH,
					DO_NOTHING_1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::CONTINUE, 8,
				{
					{ Item::ANYTHING, Item::BORDER, Item::EMPTY, Item::EMPTY  },
					{ Item::ANYTHING, Item::BORDER, Item::VEHICLE, Item::EMPTY },
					{ Item::ANYTHING, Item::BORDER, Item::EMPTY, Item::VEHICLE  },
					{ Item::ANYTHING, Item::BORDER, Item::VEHICLE, Item::VEHICLE },
				},
			{
				{
					GO_SOUTH,
					GO_SOUTH,
					GO_SOUTH,
					GO_WEST____1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					GO_WEST____1,
				},
				{
					GO_SOUTH,
					GO_SOUTH,
					GO_SOUTH,
					GO_SOUTH,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				},
			});
			result.merge(imm_result);

			imm_result = ExpandToPositionTable(Type::CONTINUE, 9,
				{
					{ Item::EMPTY, Item::ANYTHING, Item::EMPTY, Item::ANYTHING },
					{ Item::EMPTY, Item::ANYTHING, Item::VEHICLE, Item::ANYTHING },
					{ Item::VEHICLE, Item::ANYTHING, Item::EMPTY, Item::ANYTHING },
					{ Item::VEHICLE, Item::ANYTHING, Item::VEHICLE, Item::ANYTHING },
				},
			{
				{
					GO_SOUTH,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					GO_NORTH___1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
				{
					DO_NOTHING_1,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					GO_NORTH___1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
				{
					GO_SOUTH,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
					DO_NOTHING_1,
				},
			});
			result.merge(imm_result);

			return result;
		}

		static std::map<input_tuple_type, output_tuple_type, comparator>
			CreateExperimentalVehicleTable()
		{
			static std::vector<std::vector<Item>> positions = {
				{Item::ANYTHING, Item::BORDER, Item::BORDER, Item::ANYTHING},
				{Item::ANYTHING, Item::ANYTHING, Item::BORDER, Item::BORDER},
				{Item::BORDER, Item::ANYTHING, Item::ANYTHING, Item::BORDER},
				{Item::BORDER, Item::BORDER, Item::ANYTHING, Item::ANYTHING},
				{Item::ANYTHING, Item::ANYTHING, Item::BORDER, Item::ANYTHING},
				{Item::ANYTHING, Item::ANYTHING, Item::ANYTHING, Item::BORDER},
				{Item::BORDER, Item::ANYTHING, Item::ANYTHING, Item::ANYTHING},
				{Item::ANYTHING, Item::BORDER, Item::ANYTHING, Item::ANYTHING},
				{Item::ANYTHING, Item::ANYTHING, Item::ANYTHING, Item::ANYTHING},
			};

			std::tuple<unsigned, Direction>
				DO_NOTHING = { main_direction, Direction::NO_DIRECTION };

			std::map<input_tuple_type, output_tuple_type, comparator> result, imm_result;
			std::vector<std::vector< std::tuple<unsigned, Direction> > > actions =
			{
				{
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
					DO_NOTHING,
				}
			};

			for (size_t position = 0; position < positions.size(); ++position)
			{
				for (auto roaster = 0; roaster < (1 << positions[0].size()); ++roaster)
				{
					std::bitset<2 * visibility * (visibility + 1)> flagged(roaster);
					auto adjusted_position = positions[position];

					for (auto ind = 0; ind < flagged.size(); ++ind)
					{
						if (adjusted_position[ind] == Item::ANYTHING)
							adjusted_position[ind] = flagged.test(ind) ? Item::VEHICLE : Item::EMPTY;
					}

					imm_result = ExpandToPositionTable(Type::EXPERIMENTAL, position + 1, { adjusted_position }, actions);
					result.merge(imm_result);
				}			
			}

			return result;
		}

	public:
		Algorithm310()
		{
			f.merge(CreateExitVehicleTable());
			f.merge(CreateContinueVehicleTable());
			f.merge(CreateExperimentalVehicleTable());
		}
	};
}
