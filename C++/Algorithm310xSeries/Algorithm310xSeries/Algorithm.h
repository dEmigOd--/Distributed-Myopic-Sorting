#pragma once

#include <utility>
#include <bitset>
#include <tuple>
#include <vector>
#include <map>
#include <stdexcept>
#include "Enums.h"
#include "Utils.h"


namespace Phd
{
	class Algorithm
	{
	public:
		virtual std::pair<unsigned, Direction> Step(Type type, unsigned current_memory, const std::vector<Item>& neighborhood) const = 0;
		// fast track
		virtual std::pair<unsigned, Direction> Step(Type type, unsigned current_memory, unsigned neighborhood) const = 0;
	};

	template <int memory_size = 1, int timer_size = 2>
	class TimedAlgorithm : public Algorithm
	{
	protected:
		static const unsigned timer_modulo = (1 << timer_size);
		static const int t_size = timer_size;
		static const int whole_memory_size = memory_size + timer_size;
		static const unsigned MAX_VALUE = (1 << whole_memory_size) - 1;

		std::map<std::tuple<Type, std::vector<Item>, std::bitset<whole_memory_size>>, std::tuple< std::bitset<whole_memory_size>, Direction>, input_tuple_comparer<whole_memory_size>> f;

	private:
		mutable bool initializedFastTrack;
		mutable size_t fastNeighborhoodCount;
		mutable std::vector< unsigned > fast_f;

		size_t to_index(Type type, unsigned current_memory, unsigned neighborhood) const
		{
			size_t result = static_cast<size_t>(type) - 1;
			result *= (MAX_VALUE + 1);
			result += current_memory;
			result *= fastNeighborhoodCount;
			result += neighborhood;

			return result;
		}

		unsigned to_fast_value(const std::tuple< std::bitset<whole_memory_size>, Direction>& stored) const
		{
			return static_cast<unsigned>(std::get<1>(stored)) * (MAX_VALUE + 1) + std::get<0>(stored).to_ulong();
		}

		std::pair<unsigned, Direction> from_fast_value(unsigned value) const
		{
			return std::make_pair(value % (MAX_VALUE + 1), static_cast<Direction>(value / (MAX_VALUE + 1)));
		}

	public:
		TimedAlgorithm()
			: initializedFastTrack(false)
			, fastNeighborhoodCount(0)
		{
		}

		bool TestLSBTimerBitsAreTracked() const
		{
			for (auto iter = f.begin(); iter != f.end(); ++iter)
			{
				unsigned int current_memory = std::get<2>(std::get<0>(*iter)).to_ulong();
				unsigned int next_memory = std::get<0>(std::get<1>(*iter)).to_ulong();

				if ((current_memory + 1) % timer_modulo != next_memory % timer_modulo)
					return false;
			}

			return true;
		}

		bool TestMemoryIsNotExceeded() const
		{
			for (auto iter = f.begin(); iter != f.end(); ++iter)
			{
				unsigned int current_memory = std::get<2>(iter->first).to_ulong();
				unsigned int next_memory = std::get<0>(iter->second).to_ulong();

				if (current_memory > MAX_VALUE || next_memory > MAX_VALUE)
					return false;
			}

			return true;
		}

		template<int visibility>
		bool TestAllInputsAreCovered(const std::vector<std::vector<Item>>& positions) const
		{
			std::vector<Type> types = { Type::EXIT, Type::CONTINUE, Type::EXPERIMENTAL };

			for (auto mem_value = 0; mem_value <= MAX_VALUE; ++mem_value)
			{
				for (auto t_position : positions)
				{
					for (auto roaster = 0; roaster < (1 << positions[0].size()); ++roaster)
					{
						std::bitset<2 * visibility * (visibility + 1)> flagged(roaster);

						for (auto ind = 0; ind < flagged.size(); ++ind)
						{
							if (t_position[ind] == Item::ANYTHING)
								t_position[ind] = flagged.test(ind) ? Item::VEHICLE : Item::EMPTY;
						}

						for (auto type : types)
						{
							if (f.find(std::make_tuple(type, t_position, std::bitset<whole_memory_size>(mem_value))) == f.end())
								return false;
						}
					}
				}
			}

			return true;
		}

		virtual std::pair<unsigned, Direction> Step(Type type, unsigned current_memory, const std::vector<Item>& neighborhood) const override
		{
			if (current_memory > MAX_VALUE)
				throw std::logic_error("Memory value is out of range");

			std::bitset<whole_memory_size> agent_memory(current_memory);

			auto decision = f.at(std::make_tuple(type, neighborhood, agent_memory));
			return std::make_pair(std::get<0>(decision).to_ulong(), std::get<1>(decision));
		}

		virtual std::pair<unsigned, Direction> Step(Type type, unsigned current_memory, unsigned neighborhood) const override
		{
			if (!initializedFastTrack)
			{
				size_t required_size = 1;
				auto neighborhood_size = std::get<1>(f.begin()->first).size();
				while (neighborhood_size-- > 0)
					required_size *= (static_cast<size_t>(Item::TOTAL) - 1);
				fastNeighborhoodCount = required_size;

				required_size *= (static_cast<size_t>(Type::TOTAL) - 1);
				required_size *= (MAX_VALUE + 1);

				fast_f.resize(required_size, 0u);

				for (auto iter = f.begin(); iter != f.end(); ++iter)
				{
					fast_f[to_index(std::get<0>(iter->first), std::get<2>(iter->first).to_ulong(), to_uint(std::get<1>(iter->first)))] =
						to_fast_value(iter->second);
				}
				initializedFastTrack = true;
			}

			return from_fast_value(fast_f[to_index(type, current_memory, neighborhood)]);
		}
	};
}
