#pragma once

#include "stdafx.h"

enum BitValue
{
	ZeroBit,
	OneBit,
	TwoBits,
	ThreeBits,
	ErrorBit,
};

enum Movement
{
	GoNorth,
	GoEast,
	GoSouth,
	GoWest,
	DoNothing,
	Error,
	Stop,
};

enum Direction
{
	North,
	East,
	South,
	West,
	NoReading,
	DirectionCount = West - North + 1,
};

class bStateFSM
{
public:
	virtual unsigned BitsInState() const = 0;

	virtual bool IsReadingPossibleInDirection(Direction direction) const = 0;

	virtual std::tuple<BitValue, Movement> GetTableInput(BitValue memory, Direction direction) const = 0;
};

template<unsigned TBitsMemory>
class StateFSM : public bStateFSM
{
	static unsigned _BitsInState()
	{
		return TBitsMemory;
	}

	template<typename TValue>
	static std::map<BitValue, std::vector<TValue>> GetDefaultMap(const TValue& defaultValue)
	{
		static std::map<BitValue, std::vector<TValue>> map;
		static bool initialized;
		if (!initialized)
		{
			for (size_t memState = ZeroBit; memState < (1ULL << _BitsInState()); ++memState)
				map[static_cast<BitValue>(memState)] = std::vector<TValue>(DirectionCount, defaultValue);
			initialized = true;
		}

		return map;
	}

	std::map<std::tuple<BitValue, Direction>, std::tuple<BitValue, Movement>> lookupTable;
	std::set<Direction> impossible;
public:
	StateFSM(const std::map<BitValue, std::vector<BitValue>>& memoryTransform,
			 const std::map<BitValue, std::vector<Movement>>& moveOn, 
			 const std::vector<Direction>& noPossibleReadings)
		: lookupTable()
		, impossible(noPossibleReadings.begin(), noPossibleReadings.end())
	{
		for (size_t direction = North; direction < DirectionCount; ++direction)
		{
			for (size_t memState = ZeroBit; memState < (1ULL << _BitsInState()); ++memState)
			{
				lookupTable[std::make_tuple(static_cast<BitValue>(memState), static_cast<Direction>(direction))] =
					std::make_tuple((memoryTransform.at(static_cast<BitValue>(memState)))[direction], (moveOn.at(static_cast<BitValue>(memState)))[direction]);
			}
		}
	}

	StateFSM()
		: StateFSM(GetDefaultMap(ErrorBit),
				   GetDefaultMap(Error),
				   {})
	{}

	virtual unsigned BitsInState() const override
	{
		return _BitsInState();
	}

	virtual bool IsReadingPossibleInDirection(Direction direction) const override
	{
		return impossible.find(direction) != impossible.end();
	}

	virtual std::tuple<BitValue, Movement> GetTableInput(BitValue memory, Direction direction) const override
	{
		if (direction == NoReading)
			return std::make_tuple(memory, DoNothing);

		return lookupTable.at(std::make_tuple(memory, direction));
	}
};
