#pragma once

#include "PrintState.h"

class PrintStateWithPriority : public PrintState
{
private:
	unsigned priority;

protected:
	virtual OffsetStream& PrintSpecial(OffsetStream& ostr) const
	{
		ostr << '\n';
		ostr << "\\filldraw[color = yellow!50!white] ($(\\xleft, \\yleft) + (0.5, -0.5 - \\wallwidth)$) circle(0.25);" << '\n';
		ostr << "% draw state priority" << '\n';
		ostr << "\\node(state_name) at ($(\\xleft, \\yleft) + (0.5, -0.5 - \\wallwidth)$) {" << priority << "};" << '\n';
		return ostr;
	}

public:
	PrintStateWithPriority(const LittleCirclesState& state)
		: PrintState(state)
		, priority(state.priority)
	{}
};
