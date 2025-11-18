#pragma once

#include "stdafx.h"
#include "FSMs.h"

class FSMv4 : public FSM
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

	static StateFSM<2>* _GetState(int index)
	{
		// send only states from 1 till 9
		static bool initialized;
		static std::vector<StateFSM<2>> states(9);

		if (!initialized)
		{
			states[0] = StateFSM<2>({ { ZeroBit, {OneBit, ErrorBit, ErrorBit, ThreeBits }},
				{ OneBit, {TwoBits, ErrorBit, ErrorBit, OneBit }},
				{ TwoBits, {TwoBits, ErrorBit, ErrorBit, TwoBits }},
				{ ThreeBits, {ThreeBits, ErrorBit, ErrorBit, ThreeBits }} },
				{ { ZeroBit, {GoNorth, Error, Error, GoWest }},
				{ OneBit, {DoNothing, Error, Error, DoNothing }},
				{ TwoBits, {DoNothing, Error, Error, DoNothing }},
				{ ThreeBits, {DoNothing, Error, Error, DoNothing }} },
				{ East, South } );
			states[1] = StateFSM<2>({ { ZeroBit, {ZeroBit, OneBit, ErrorBit, ErrorBit }},
				{ OneBit, {TwoBits, TwoBits, ErrorBit, ErrorBit }},
				{ TwoBits, {ThreeBits, ThreeBits, ErrorBit, ErrorBit }},
				{ ThreeBits, {ThreeBits, ZeroBit, ErrorBit, ErrorBit }} },
				{ { ZeroBit, {GoNorth, DoNothing, Error, Error }},
				{ OneBit, {DoNothing, DoNothing, Error, Error }},
				{ TwoBits, {Stop, GoEast, Error, Error }},
				{ ThreeBits, {DoNothing, DoNothing, Error, Error }} },
				{ South, West } );
			states[2] = StateFSM<2>({ { ZeroBit, {ErrorBit, OneBit, OneBit, ErrorBit }},
				{ OneBit, {ErrorBit, TwoBits, TwoBits, ErrorBit }},
				{ TwoBits, {ErrorBit, ThreeBits, ThreeBits, ErrorBit }},
				{ ThreeBits, {ErrorBit, ZeroBit, ThreeBits, ErrorBit }} },
				{ { ZeroBit, {Error, DoNothing, DoNothing, Error }},
				{ OneBit, {Error, DoNothing, DoNothing, Error }},
				{ TwoBits, {Error, GoEast, Stop, Error }},
				{ ThreeBits, {Error, DoNothing, DoNothing, Error }} },
				{ North, West } );
			states[3] = StateFSM<2>({ { ZeroBit, {ErrorBit, ErrorBit, OneBit, ZeroBit }},
				{ OneBit, {ErrorBit, ErrorBit, TwoBits, OneBit }},
				{ TwoBits, {ErrorBit, ErrorBit, ThreeBits, TwoBits }},
				{ ThreeBits, {ErrorBit, ErrorBit, ThreeBits, ThreeBits }} },
				{ { ZeroBit, {Error, Error, DoNothing, DoNothing }},
				{ OneBit, {Error, Error, DoNothing, DoNothing }},
				{ TwoBits, {Error, Error, GoSouth, DoNothing }},
				{ ThreeBits, {Error, Error, DoNothing, DoNothing }} },
				{ North, East } );
			states[4] = StateFSM<2>({ { ZeroBit, {ZeroBit, OneBit, ErrorBit, ZeroBit }},
				{ OneBit, {TwoBits, TwoBits, ErrorBit, OneBit }},
				{ TwoBits, {ThreeBits, ThreeBits, ErrorBit, TwoBits }},
				{ ThreeBits, {ThreeBits, ZeroBit, ErrorBit, ThreeBits }} },
				{ { ZeroBit, {GoNorth, DoNothing, Error, GoWest }},
				{ OneBit, {DoNothing, DoNothing, Error, DoNothing }},
				{ TwoBits, {GoNorth, GoEast, Error, DoNothing }},
				{ ThreeBits, {DoNothing, DoNothing, Error, DoNothing }} },
				{ South } );
			states[5] = StateFSM<2>({ { ZeroBit, {ZeroBit, TwoBits, ZeroBit, ErrorBit }},
				{ OneBit, {OneBit, TwoBits, OneBit, ErrorBit }},
				{ TwoBits, {ThreeBits, TwoBits, ThreeBits, ErrorBit }},
				{ ThreeBits, {ThreeBits, TwoBits, ThreeBits, ErrorBit }} },
				{ { ZeroBit, {GoNorth, DoNothing, DoNothing, Error }},
				{ OneBit, {DoNothing, DoNothing, DoNothing, Error }},
				{ TwoBits, {GoNorth, DoNothing, GoSouth, Error }},
				{ ThreeBits, {DoNothing, DoNothing, DoNothing, Error }} },
				{ West } );
			states[6] = StateFSM<2>({ { ZeroBit, {ErrorBit, OneBit, OneBit, ZeroBit }},
				{ OneBit, {ErrorBit, TwoBits, TwoBits, OneBit }},
				{ TwoBits, {ErrorBit, ThreeBits, ThreeBits, TwoBits }},
				{ ThreeBits, {ErrorBit, ZeroBit, ThreeBits, ThreeBits }} },
				{ { ZeroBit, {Error, DoNothing, DoNothing, DoNothing }},
				{ OneBit, {Error, DoNothing, DoNothing, DoNothing }},
				{ TwoBits, {Error, GoEast, GoSouth, DoNothing }},
				{ ThreeBits, {Error, DoNothing, DoNothing, DoNothing }} },
				{ North } );
			states[7] = StateFSM<2>({ { ZeroBit, {OneBit, ErrorBit, OneBit, ZeroBit }},
				{ OneBit, {OneBit, ErrorBit, TwoBits, OneBit }},
				{ TwoBits, {TwoBits, ErrorBit, ThreeBits, TwoBits }},
				{ ThreeBits, {ThreeBits, ErrorBit, ThreeBits, ThreeBits }} },
				{ { ZeroBit, {GoNorth, Error, DoNothing, DoNothing }},
				{ OneBit, {DoNothing, Error, DoNothing, DoNothing }},
				{ TwoBits, {DoNothing, Error, GoSouth, DoNothing }},
				{ ThreeBits, {DoNothing, Error, DoNothing, DoNothing }} },
				{ East } );
			states[8] = StateFSM<2>({ { ZeroBit, {ZeroBit, TwoBits, ZeroBit, ZeroBit }},
				{ OneBit, {OneBit, TwoBits, OneBit, OneBit }},
				{ TwoBits, {ThreeBits, TwoBits, ThreeBits, TwoBits }},
				{ ThreeBits, {ThreeBits, TwoBits, ThreeBits, ThreeBits }} },
				{ { ZeroBit, {GoNorth, DoNothing, DoNothing, DoNothing }},
				{ OneBit, {DoNothing, DoNothing, DoNothing, DoNothing }},
				{ TwoBits, {GoNorth, DoNothing, GoSouth, DoNothing }},
				{ ThreeBits, {DoNothing, DoNothing, DoNothing, DoNothing }} },
				{ } );
			initialized = true;
		}

		return new StateFSM<2>(states[index - 1]);
	}
public:
	virtual std::shared_ptr<bStateFSM> GetState(int index) const override
	{
		return std::shared_ptr<bStateFSM>(_GetState(index));
	}
};
