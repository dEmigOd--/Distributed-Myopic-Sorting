#pragma once

#include "stdafx.h"

class ProgramParameters
{
private:
	int version;
	std::string dirname, labelPrefix;

	ProgramParameters(int version, unsigned bits)
		: version(version)
		, labelPrefix(std::to_string(bits) + "bit")
	{}

public:

	int GetVersion() const
	{
		return version;
	}

	std::string GetBaseFilename() const
	{
		return "CoveringCellularAutomata." + GetLabel() + ".ver" + std::to_string(GetVersion());
	}

	std::string GetStateFilename(int state) const
	{
		return "State." + std::to_string(state) + ".tex";
	}

	std::string GetFSMFilename() const
	{
		return "FSM.tex";
	}

	std::string GetLabel() const
	{
		return labelPrefix;
	}

	static ProgramParameters ParseParameters(int version, unsigned bits)
	{
		return ProgramParameters(version, bits);
	}
};