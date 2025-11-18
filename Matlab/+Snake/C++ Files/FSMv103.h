#pragma once

#include "stdafx.h"
#include "FSMs.h"

class FSMv103 : public FSM
{
private:
	static const BitValue ZeroBit = BitValue::ZeroBit;
	static const BitValue OneBit = BitValue::OneBit;
	static const BitValue TwoBits = BitValue::TwoBits;
	static const BitValue ThreeBits = BitValue::ThreeBits;
	static const BitValue ErrorBit = BitValue::ErrorBit;
	static const Movement GoNorth = Movement::GoNorth;
	static const Movement GoEast = Movement::GoEast;
	static const Movement GoSouth = Movement::GoSouth;
	static const Movement GoWest = Movement::GoWest;
	static const Movement DoNothing = Movement::DoNothing;
	static const Movement Error = Movement::Error;
	static const Movement Stop = Movement::Stop;
	static const Direction North = Direction::North;
	static const Direction East = Direction::East;
	static const Direction South = Direction::South;
	static const Direction West = Direction::West;

	static StateFSM<1>* _GetState(int index)
	{
		// send only states from 1 till 9
		static bool initialized;
		static std::vector<StateFSM<1>> states(9);

		if (!initialized)
		{
			states[0] = StateFSM<1>({ { ZeroBit, {ZeroBit, ErrorBit, ErrorBit, ZeroBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ZeroBit }} },
				{ { ZeroBit, {GoNorth, Error, Error, DoNothing }},
				{ OneBit, {Error, Error, Error, DoNothing }} },
				{ East, South } );
			states[1] = StateFSM<1>({ { ZeroBit, {ZeroBit, OneBit, ErrorBit, ErrorBit }},
				{ OneBit, {ErrorBit, OneBit, ErrorBit, ErrorBit }} },
				{ { ZeroBit, {DoNothing, DoNothing, Error, Error }},
				{ OneBit, {Error, GoEast, Error, Error }} },
				{ South, West } );
			states[2] = StateFSM<1>({ { ZeroBit, {ErrorBit, ZeroBit, OneBit, ErrorBit }},
				{ OneBit, {ErrorBit, OneBit, OneBit, ErrorBit }} },
				{ { ZeroBit, {Error, DoNothing, GoSouth, Error }},
				{ OneBit, {Error, DoNothing, Stop, Error }} },
				{ North, West } );
			states[3] = StateFSM<1>({ { ZeroBit, {ErrorBit, ErrorBit, ZeroBit, ZeroBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }} },
				{ { ZeroBit, {Error, Error, DoNothing, GoWest }},
				{ OneBit, {Error, Error, Error, Error }} },
				{ North, East } );
			states[4] = StateFSM<1>({ { ZeroBit, {ZeroBit, OneBit, ErrorBit, ZeroBit }},
				{ OneBit, {OneBit, OneBit, ErrorBit, ZeroBit }} },
				{ { ZeroBit, {DoNothing, DoNothing, Error, DoNothing }},
				{ OneBit, {DoNothing, GoEast, Error, DoNothing }} },
				{ South } );
			states[5] = StateFSM<1>({ { ZeroBit, {ZeroBit, ZeroBit, OneBit, ErrorBit }},
				{ OneBit, {OneBit, OneBit, OneBit, ErrorBit }} },
				{ { ZeroBit, {DoNothing, DoNothing, GoSouth, Error }},
				{ OneBit, {DoNothing, DoNothing, GoSouth, Error }} },
				{ West } );
			states[6] = StateFSM<1>({ { ZeroBit, {ErrorBit, ZeroBit, OneBit, ZeroBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }} },
				{ { ZeroBit, {Error, DoNothing, GoSouth, GoWest }},
				{ OneBit, {Error, Error, DoNothing, Error }} },
				{ North } );
			states[7] = StateFSM<1>({ { ZeroBit, {ZeroBit, ErrorBit, ZeroBit, ZeroBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }} },
				{ { ZeroBit, {GoNorth, Error, DoNothing, DoNothing }},
				{ OneBit, {Error, Error, Error, Error }} },
				{ East } );
			states[8] = StateFSM<1>({ { ZeroBit, {ZeroBit, ZeroBit, OneBit, ZeroBit }},
				{ OneBit, {OneBit, ZeroBit, OneBit, OneBit }} },
				{ { ZeroBit, {DoNothing, DoNothing, GoSouth, DoNothing }},
				{ OneBit, {DoNothing, DoNothing, DoNothing, DoNothing }} },
				{ } );
			initialized = true;
		}

		return new StateFSM<1>(states[index - 1]);
	}
public:
	virtual std::shared_ptr<bStateFSM> GetState(int index) const override
	{
		return std::shared_ptr<bStateFSM>(_GetState(index));
	}
};
