#pragma once

#include "stdafx.h"
#include "FSMs.h"

class FSMv81 : public FSM
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
			states[0] = StateFSM<2>({ { ZeroBit, {TwoBits, ErrorBit, ErrorBit, ZeroBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, OneBit }},
				{ TwoBits, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }},
				{ ThreeBits, {ThreeBits, ErrorBit, ErrorBit, ThreeBits }} },
				{ { ZeroBit, {GoNorth, Error, Error, GoWest }},
				{ OneBit, {Error, Error, Error, DoNothing }},
				{ TwoBits, {Error, Error, Error, Error }},
				{ ThreeBits, {DoNothing, Error, Error, DoNothing }} },
				{ East, South } );
			states[1] = StateFSM<2>({ { ZeroBit, {ZeroBit, OneBit, ErrorBit, ErrorBit }},
				{ OneBit, {ThreeBits, TwoBits, ErrorBit, ErrorBit }},
				{ TwoBits, {ThreeBits, ThreeBits, ErrorBit, ErrorBit }},
				{ ThreeBits, {ThreeBits, ErrorBit, ErrorBit, ErrorBit }} },
				{ { ZeroBit, {GoNorth, DoNothing, Error, Error }},
				{ OneBit, {Stop, DoNothing, Error, Error }},
				{ TwoBits, {Stop, GoEast, Error, Error }},
				{ ThreeBits, {DoNothing, Error, Error, Error }} },
				{ South, West } );
			states[2] = StateFSM<2>({ { ZeroBit, {ErrorBit, OneBit, OneBit, ErrorBit }},
				{ OneBit, {ErrorBit, TwoBits, ThreeBits, ErrorBit }},
				{ TwoBits, {ErrorBit, ThreeBits, ThreeBits, ErrorBit }},
				{ ThreeBits, {ErrorBit, ErrorBit, ThreeBits, ErrorBit }} },
				{ { ZeroBit, {Error, DoNothing, DoNothing, Error }},
				{ OneBit, {Error, DoNothing, Stop, Error }},
				{ TwoBits, {Error, GoEast, Stop, Error }},
				{ ThreeBits, {Error, Error, DoNothing, Error }} },
				{ North, West } );
			states[3] = StateFSM<2>({ { ZeroBit, {ErrorBit, ErrorBit, TwoBits, ZeroBit }},
				{ OneBit, {ErrorBit, ErrorBit, ThreeBits, OneBit }},
				{ TwoBits, {ErrorBit, ErrorBit, ThreeBits, ErrorBit }},
				{ ThreeBits, {ErrorBit, ErrorBit, ErrorBit, ThreeBits }} },
				{ { ZeroBit, {Error, Error, DoNothing, DoNothing }},
				{ OneBit, {Error, Error, GoSouth, DoNothing }},
				{ TwoBits, {Error, Error, GoSouth, Error }},
				{ ThreeBits, {Error, Error, Error, DoNothing }} },
				{ North, East } );
			states[4] = StateFSM<2>({ { ZeroBit, {ZeroBit, OneBit, ErrorBit, ZeroBit }},
				{ OneBit, {ThreeBits, TwoBits, ErrorBit, OneBit }},
				{ TwoBits, {ThreeBits, ThreeBits, ErrorBit, ErrorBit }},
				{ ThreeBits, {ThreeBits, ErrorBit, ErrorBit, ThreeBits }} },
				{ { ZeroBit, {GoNorth, DoNothing, Error, GoWest }},
				{ OneBit, {GoNorth, DoNothing, Error, DoNothing }},
				{ TwoBits, {GoNorth, GoEast, Error, Error }},
				{ ThreeBits, {DoNothing, Error, Error, DoNothing }} },
				{ South } );
			states[5] = StateFSM<2>({ { ZeroBit, {ZeroBit, TwoBits, TwoBits, ErrorBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }},
				{ TwoBits, {ThreeBits, TwoBits, ThreeBits, ErrorBit }},
				{ ThreeBits, {ThreeBits, ErrorBit, ThreeBits, ErrorBit }} },
				{ { ZeroBit, {GoNorth, DoNothing, DoNothing, Error }},
				{ OneBit, {Error, Error, Error, Error }},
				{ TwoBits, {GoNorth, DoNothing, GoSouth, Error }},
				{ ThreeBits, {DoNothing, Error, DoNothing, Error }} },
				{ West } );
			states[6] = StateFSM<2>({ { ZeroBit, {ErrorBit, OneBit, OneBit, ZeroBit }},
				{ OneBit, {ErrorBit, TwoBits, ThreeBits, OneBit }},
				{ TwoBits, {ErrorBit, ThreeBits, ThreeBits, ErrorBit }},
				{ ThreeBits, {ErrorBit, ErrorBit, ThreeBits, ThreeBits }} },
				{ { ZeroBit, {Error, DoNothing, DoNothing, DoNothing }},
				{ OneBit, {Error, DoNothing, GoSouth, DoNothing }},
				{ TwoBits, {Error, GoEast, GoSouth, Error }},
				{ ThreeBits, {Error, Error, DoNothing, DoNothing }} },
				{ North } );
			states[7] = StateFSM<2>({ { ZeroBit, {ZeroBit, ErrorBit, TwoBits, ZeroBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }},
				{ TwoBits, {ErrorBit, ErrorBit, ThreeBits, TwoBits }},
				{ ThreeBits, {ThreeBits, ErrorBit, ErrorBit, ThreeBits }} },
				{ { ZeroBit, {GoNorth, Error, DoNothing, DoNothing }},
				{ OneBit, {Error, Error, Error, Error }},
				{ TwoBits, {Error, Error, GoSouth, DoNothing }},
				{ ThreeBits, {DoNothing, Error, Error, DoNothing }} },
				{ East } );
			states[8] = StateFSM<2>({ { ZeroBit, {ZeroBit, TwoBits, TwoBits, ZeroBit }},
				{ OneBit, {ErrorBit, ErrorBit, ErrorBit, ErrorBit }},
				{ TwoBits, {ThreeBits, TwoBits, ThreeBits, TwoBits }},
				{ ThreeBits, {ThreeBits, ErrorBit, ThreeBits, ThreeBits }} },
				{ { ZeroBit, {GoNorth, DoNothing, DoNothing, DoNothing }},
				{ OneBit, {Error, Error, Error, Error }},
				{ TwoBits, {GoNorth, DoNothing, GoSouth, DoNothing }},
				{ ThreeBits, {DoNothing, Error, DoNothing, DoNothing }} },
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
