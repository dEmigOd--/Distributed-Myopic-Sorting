#pragma once

#include <bitset>
#include <algorithm>
#include <fstream>
#include <sstream>
#include <streambuf>
#include <string>
#include "Algorithm.h"

namespace Phd
{
	class MatlabBackedAlgorithm : public TimedAlgorithm<>
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
			CreateVehicleTable(const std::string& directory, int version, Type vehicleType)
		{
			std::map<input_tuple_type, output_tuple_type, comparator> result, imm_result;

			std::string file_content;
			{
				std::ifstream ifile(directory + "/Ver." + std::to_string(version) + "/" + "vehicle." + std::to_string(static_cast<int>(vehicleType)) + ".csv");
				ifile.seekg(0, std::ios::end);
				file_content.reserve(ifile.tellg());
				ifile.seekg(0, std::ios::beg);

				file_content.assign((std::istreambuf_iterator<char>(ifile)),
					std::istreambuf_iterator<char>());
			}

			file_content.erase(std::remove(file_content.begin(), file_content.end(), ','), file_content.end());
			std::istringstream istr(file_content);

			while (!istr.eof())
			{
				unsigned stateId, num_sensor_readings, reading_north, reading_east, reading_south, reading_west,
					num_columns, new_state, action;

				istr >> stateId;
				istr >> num_sensor_readings;

				std::vector<std::vector<Item>> readings = std::vector<std::vector<Item>>(num_sensor_readings);

				for (unsigned s_reading = 0; s_reading < num_sensor_readings; ++s_reading)
				{
					istr >> reading_north >> reading_east >> reading_south >> reading_west;
					readings[s_reading] = {
						static_cast<Item> (reading_north),
						static_cast<Item> (reading_east),
						static_cast<Item> (reading_south),
						static_cast<Item> (reading_west),
					};
				}

				istr >> num_columns;

				std::vector<std::vector<std::tuple<unsigned, Direction>>> content(num_sensor_readings, std::vector<std::tuple<unsigned, Direction>>());
				for (unsigned s_reading = 0; s_reading < num_sensor_readings; ++s_reading)
				{
					for (unsigned pair = 0; pair < num_columns; ++pair)
					{
						istr >> new_state >> action;
						content[s_reading].push_back(std::make_tuple(new_state, static_cast<Direction>(action)));
					}
				}
				imm_result = ExpandToPositionTable(vehicleType, stateId, readings, content);
				result.merge(imm_result);
			}

			return result;
		}

		static std::map<input_tuple_type, output_tuple_type, comparator>
			CreateExitVehicleTable(const std::string& directory, int version)
		{
			return CreateVehicleTable(directory, version, Type::EXIT);
		}

		static std::map<input_tuple_type, output_tuple_type, comparator>
			CreateContinueVehicleTable(const std::string& directory, int version)
		{
			return CreateVehicleTable(directory, version, Type::CONTINUE);
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
		MatlabBackedAlgorithm(const std::string& directory, int version)
		{
			f.merge(CreateExitVehicleTable(directory, version));
			f.merge(CreateContinueVehicleTable(directory, version));
			f.merge(CreateExperimentalVehicleTable());
		}
	};
}
