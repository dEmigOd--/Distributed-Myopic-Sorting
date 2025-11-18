#pragma once

#include "stdafx.h"
#include "FSMs.h"

class FSMv101 : public FSM
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
			states[0] = StateFSM<1>({ { ZeroBit, {ZeroBit, ErrorBit, ErrorBit, OneBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ZeroBit }} },
				{ { ZeroBit, {DoNothing, Error, Error, DoNothing }},
				{ OneBit, {Error, Error, Error, GoWest }} },
				{ East, South } );
			states[1] = StateFSM<1>({ { ZeroBit, {ZeroBit, ZeroBit, ErrorBit, ErrorBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }} },
				{ { ZeroBit, {GoNorth, DoNothing, Error, Error }},
				{ OneBit, {Error, Error, Error, Error }} },
				{ South, West } );
			states[2] = StateFSM<1>({ { ZeroBit, {ErrorBit, ZeroBit, ZeroBit, ErrorBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }} },
				{ { ZeroBit, {Error, GoEast, DoNothing, Error }},
				{ OneBit, {Error, Error, Error, Error }} },
				{ North, West } );
			states[3] = StateFSM<1>({ { ZeroBit, {ErrorBit, ErrorBit, ZeroBit, ZeroBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }} },
				{ { ZeroBit, {Error, Error, GoSouth, DoNothing }},
				{ OneBit, {Error, Error, Error, Error }} },
				{ North, East } );
			states[4] = StateFSM<1>({ { ZeroBit, {OneBit, ZeroBit, ErrorBit, OneBit }},
				{ OneBit, {OneBit, ErrorBit, ErrorBit, ZeroBit }} },
				{ { ZeroBit, {DoNothing, DoNothing, Error, DoNothing }},
				{ OneBit, {GoNorth, Error, Error, GoWest }} },
				{ South } );
			states[5] = StateFSM<1>({ { ZeroBit, {ZeroBit, ZeroBit, ZeroBit, ErrorBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }} },
				{ { ZeroBit, {GoNorth, DoNothing, DoNothing, Error }},
				{ OneBit, {Error, Error, Error, Error }} },
				{ West } );
			states[6] = StateFSM<1>({ { ZeroBit, {ErrorBit, ZeroBit, ZeroBit, ZeroBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }} },
				{ { ZeroBit, {Error, GoEast, DoNothing, DoNothing }},
				{ OneBit, {Error, Error, Error, Error }} },
				{ North } );
			states[7] = StateFSM<1>({ { ZeroBit, {ZeroBit, ErrorBit, ZeroBit, ZeroBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }} },
				{ { ZeroBit, {DoNothing, Error, GoSouth, DoNothing }},
				{ OneBit, {Error, Error, Error, Error }} },
				{ East } );
			states[8] = StateFSM<1>({ { ZeroBit, {OneBit, ZeroBit, ZeroBit, ZeroBit }},
				{ OneBit, {OneBit, ZeroBit, OneBit, ZeroBit }} },
				{ { ZeroBit, {DoNothing, DoNothing, GoSouth, DoNothing }},
				{ OneBit, {GoNorth, DoNothing, DoNothing, DoNothing }} },
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
