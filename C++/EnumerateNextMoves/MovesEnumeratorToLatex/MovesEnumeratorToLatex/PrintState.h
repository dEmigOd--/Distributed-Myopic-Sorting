#pragma once

#include <iostream>
#include <string>
#include <set>

#include "LittleCirclesState.h"

class OffsetStream
{
	std::ostream& ostr;
	int offset;
	bool shouldPrintOffset;
public:
	OffsetStream(std::ostream& ostr)
		: ostr(ostr)
		, offset(0)
		, shouldPrintOffset(true)
	{}

	void AddOffset()
	{
		++offset;
	}

	void DecreaseOffset()
	{
		if (--offset < 0)
			offset = 0;
	}

	OffsetStream& PrintOffset()
	{
		if (shouldPrintOffset)
		{
			for (int i = 0; i < offset; ++i)
				ostr << '\t';
			shouldPrintOffset = false;
		}
		return *this;
	}

	template<typename T>
	OffsetStream& PrintValue(const T& value)
	{
		PrintOffset();
		ostr << value;
		return *this;
	}

	template<>
	OffsetStream& PrintValue(const char& value)
	{
		PrintOffset();
		ostr << value;
		if (value == '\n')
			shouldPrintOffset = true;
		return *this;
	}
};

template<typename T>
inline OffsetStream& operator<<(OffsetStream& ostr, const T& value)
{
	return ostr.PrintValue<T>(value);
}

class PrintState
{
private:
	LittleCirclesState::VEHICLE agent;
	LittleCirclesState::DIRECTION direction;
	std::vector<unsigned> exiting;
	std::vector<unsigned> continuing;
	LittleCirclesState::COLUMN column;
	LittleCirclesState::ROW row;

	std::vector<std::tuple<LittleCirclesState::VEHICLE, int, int>> CreateRequirements() const
	{
		std::vector<std::tuple<LittleCirclesState::VEHICLE, int, int>> result;
		std::set<int> rows, columns;

		if (agent != LittleCirclesState::NO_VEHICLE)
		{
			// acting agent is always present
			result.push_back(std::make_tuple(agent, 0, 0));
		}
		if (direction != LittleCirclesState::NO_DIRECTION)
		{
			// empty space is also always present
			auto offsets = LittleCirclesState::GetNeighborOffsets(1 + direction);
			result.push_back(std::make_tuple(LittleCirclesState::NO_VEHICLE, std::get<0>(offsets), std::get<1>(offsets)));
		}

		for (auto neighbor : exiting)
		{
			std::tuple<int, int> offsets = LittleCirclesState::GetNeighborOffsets(neighbor);
			result.push_back(std::make_tuple(LittleCirclesState::VEXIT, std::get<0>(offsets), std::get<1>(offsets)));
		}
		for (auto neighbor : continuing)
		{
			std::tuple<int, int> offsets = LittleCirclesState::GetNeighborOffsets(neighbor);
			result.push_back(std::make_tuple(LittleCirclesState::VCONTINUE, std::get<0>(offsets), std::get<1>(offsets)));
		}

		// speculate about unseen borders
		for (auto cell : result)
		{
			rows.insert(std::get<1>(cell));
			columns.insert(std::get<2>(cell));
		}

		if (column < 0)
		{
			if (columns.upper_bound(-column - 1) == columns.end())
				result.push_back(std::make_tuple(LittleCirclesState::DO_NOT_CARE, -column, 0));
		}
		if (row < 0)
		{
			switch (row)
			{
				case LittleCirclesState::mU0_ROW:
				case LittleCirclesState::mU1_ROW:
				case LittleCirclesState::mU2_ROW:
					if (rows.lower_bound((row - LittleCirclesState::mU0_ROW)) == rows.end())
						result.push_back(std::make_tuple(LittleCirclesState::DO_NOT_CARE, (row - LittleCirclesState::mU0_ROW) - 1, 0));
					break;
				case LittleCirclesState::mD0_ROW:
				case LittleCirclesState::mD1_ROW:
				case LittleCirclesState::mD2_ROW:
					if (rows.upper_bound(-row - 1) == rows.end())
						result.push_back(std::make_tuple(LittleCirclesState::DO_NOT_CARE, -row, 0));
					break;
			}
		}

		return result;
	}

	std::tuple<int, int, int, int> GetTableSizes(const std::vector<std::tuple<LittleCirclesState::VEHICLE, int, int>>& requirements) const
	{
		std::set<int> rows, columns;
		for (auto cell : requirements)
		{
			columns.insert(std::get<1>(cell));
			rows.insert(std::get<2>(cell));
		}

		return std::make_tuple(*columns.begin(), *rows.begin(), *columns.rbegin() + 1, *rows.rbegin() + 1);
	}

	std::vector<std::tuple<int, int>> CreateList(const std::vector<std::tuple<LittleCirclesState::VEHICLE, int, int>>& requirements, LittleCirclesState::VEHICLE type) const
	{
		std::vector<std::tuple<int, int>> list;
		for (auto cell : requirements)
		{
			if (std::get<0>(cell) == type)
			{
				list.push_back(std::make_tuple(std::get<1>(cell), std::get<2>(cell)));
			}
		}

		return list;
	}

private: // printing
	OffsetStream& PrintPreambule(OffsetStream& ostr) const
	{
		ostr << "\\documentclass{standalone}" << '\n';
		ostr << '\n';
		ostr << "\\usepackage{silence}" << '\n';
		ostr << "%Disable all warnings issued by latex starting with \"You have...\"" << '\n';
		ostr << "\\WarningFilter{latex}{You have requested package}" << '\n';
		ostr << "\\usepackage{\"C:/Users/dmitry.ra/Desktop/Studies/Articles/PhD/Latex\\space Technical/userdefinitions.v003\"}" << '\n';
		ostr << '\n';

		return ostr;
	}

	OffsetStream& PrintBegin(OffsetStream& ostr, const std::string& environment) const
	{
		ostr << "\\begin{" << environment << "}" << '\n';
		ostr.AddOffset();

		return ostr;
	}

	OffsetStream& PrintEnd(OffsetStream& ostr, const std::string& environment) const
	{
		ostr.DecreaseOffset();
		ostr << "\\end{" << environment << "}" << '\n';

		return ostr;
	}

	OffsetStream& PrintBoardSize(OffsetStream& ostr, const std::vector<std::tuple<LittleCirclesState::VEHICLE, int, int>>& requirements) const
	{
		std::tuple<int, int, int, int> corner_coordinates = GetTableSizes(requirements);

		--std::get<0>(corner_coordinates);
		if (column > LittleCirclesState::NO_COLUMN)
			std::get<2>(corner_coordinates) = column;
		else
			++std::get<2>(corner_coordinates);

		if (row > LittleCirclesState::NO_ROW && row < LittleCirclesState::U0_ROW)
			std::get<1>(corner_coordinates) = 1 - row;
		else
			--std::get<1>(corner_coordinates);

		if (row > LittleCirclesState::D2_ROW)
			std::get<3>(corner_coordinates) = row - LittleCirclesState::D2_ROW;
		else
			++std::get<3>(corner_coordinates);

		ostr << "% set image sizes" << '\n';
		ostr << "\\pgfmathsetmacro{\\xleft}{" << std::get<0>(corner_coordinates) << "}" << '\n';
		ostr << "\\pgfmathsetmacro{\\yleft}{" << std::get<1>(corner_coordinates) << "}" << '\n';
		ostr << "\\pgfmathsetmacro{\\xright}{" << std::get<2>(corner_coordinates) << "}" << '\n';
		ostr << "\\pgfmathsetmacro{\\yright}{" << std::get<3>(corner_coordinates) << "}" << '\n';

		return ostr;
	}

	OffsetStream& PrintConstants(OffsetStream& ostr) const
	{
		ostr << '\n';
		ostr << "% define constants" << '\n';
		ostr << "\\pgfmathsetmacro{\\wallwidth}{0.2}" << '\n';
		ostr << "\\pgfmathsetmacro{\\slightoffset}{0.05}" << '\n';
		ostr << "\\pgfmathsetmacro{\\arrooffset}{0.25}" << '\n';
		ostr << '\n';
		ostr << "\\fill[color = white] (\\xleft, \\yleft) rectangle (\\xright, \\yright);" << '\n';

		return ostr;
	}

	OffsetStream& PrintDefineBorders(OffsetStream& ostr) const
	{
		ostr << '\n';
		ostr << "% define borders : could be empty" << '\n';
		switch (column)
		{
			case LittleCirclesState::M0_COLUMN:
			case LittleCirclesState::M1_COLUMN:
			case LittleCirclesState::M2_COLUMN:
				ostr << "\\newcommand{\\NeedEastWall}{1}" << '\n';
				break;
		}
		switch (row)
		{
			case LittleCirclesState::U0_ROW:
			case LittleCirclesState::U1_ROW:
			case LittleCirclesState::U2_ROW:
				ostr << "\\newcommand{\\NeedNorthWall}{1}" << '\n';
				break;
			case LittleCirclesState::D0_ROW:
			case LittleCirclesState::D1_ROW:
			case LittleCirclesState::D2_ROW:
				ostr << "\\newcommand{\\NeedSouthWall}{1}" << '\n';
				break;
		}

		return ostr;
	}

	OffsetStream& PrintBorders(OffsetStream& ostr) const
	{
		ostr << '\n';
		ostr << "\\ifcsdef{NeedEastWall}" << '\n';
		ostr << "{" << '\n';
		ostr.AddOffset();
		ostr << "\\draw (\\xright, \\yleft) -- (\\xright, \\yright);" << '\n';
		ostr << "\\path[pattern = north east lines, pattern color = black!50!white] (\\xright, \\yleft) rectangle(\\xright + \\wallwidth, \\yright);" << '\n';
		ostr.DecreaseOffset();
		ostr << "}" << '\n';
		ostr << "{" << '\n';
		ostr.AddOffset();
		ostr << "\\pgfmathsetmacro{\\NeedEastWall}{0}" << '\n';
		ostr.DecreaseOffset();
		ostr << "}" << '\n';

		ostr << '\n';
		ostr << "\\ifcsdef{NeedNorthWall}" << '\n';
		ostr << "{" << '\n';
		ostr.AddOffset();
		ostr << "\\draw (\\xleft, \\yright) -- (\\xright, \\yright);" << '\n';
		ostr << "\\path[pattern = north east lines, pattern color = black!50!white] (\\xleft, \\yright) rectangle(\\xright + \\wallwidth * \\NeedEastWall, \\yright + \\wallwidth);" << '\n';
		ostr.DecreaseOffset();
		ostr << "}" << '\n';
		ostr << "{" << '\n';
		ostr << "}" << '\n';

		ostr << '\n';
		ostr << "\\ifcsdef{NeedSouthWall}" << '\n';
		ostr << "{" << '\n';
		ostr.AddOffset();
		ostr << "\\draw (\\xleft, \\yleft) -- (\\xright, \\yleft);" << '\n';
		ostr << "\\path[pattern = north east lines, pattern color = black!50!white] (\\xleft, \\yleft) rectangle(\\xright + \\wallwidth * \\NeedEastWall, \\yleft-\\wallwidth);" << '\n';
		ostr.DecreaseOffset();
		ostr << "}" << '\n';
		ostr << "{" << '\n';
		ostr << "}" << '\n';

		return ostr;
	}

	OffsetStream& PrintCommentOnLists(OffsetStream& ostr) const
	{
		ostr << '\n';
		ostr << "% agent lists" << '\n';
		return ostr;
	}

	OffsetStream& PrintList(OffsetStream& ostr, const std::vector<std::tuple<LittleCirclesState::VEHICLE, int, int>>& requirements, LittleCirclesState::VEHICLE type, 
							const std::string& listname, const std::string& value) const
	{
		std::vector<std::tuple<int, int>> list(CreateList(requirements, type));

		if (!list.empty())
		{
			ostr << '\n';
			ostr << "\\newcommand{\\" << listname << "list}{";
			bool nonfirst = false;
			for (auto agent : list)
			{
				if (nonfirst)
					ostr << ", ";
				else
					nonfirst = true;
				ostr << std::get<0>(agent) << '/' << std::get<1>(agent);
			}
			ostr << "}" << '\n';

			ostr << "\\foreach \\x/\\y in \\" << listname << "list" << '\n';
			ostr << "{" << '\n';
			ostr.AddOffset();
			{
				ostr << "\\draw (\\x, \\y) rectangle (\\x + 1, \\y + 1);" << '\n';
				ostr << "\\node (" << listname << "\\x\\y) at (\\x + 0.5,\\y + 0.5) {" << value << "};" << '\n';
			}
			ostr.DecreaseOffset();
			ostr << "}" << '\n';
		}

		return ostr;
	}

	OffsetStream& PrintExitingList(OffsetStream& ostr, const std::vector<std::tuple<LittleCirclesState::VEHICLE, int, int>>& requirements) const
	{
		return PrintList(ostr, requirements, LittleCirclesState::VEXIT, "exiting", "1");
	}
	OffsetStream& PrintContinuingList(OffsetStream& ostr, const std::vector<std::tuple<LittleCirclesState::VEHICLE, int, int>>& requirements) const
	{
		return PrintList(ostr, requirements, LittleCirclesState::VCONTINUE, "continuing", "-1");
	}
	OffsetStream& PrintDoNotCareList(OffsetStream& ostr, const std::vector<std::tuple<LittleCirclesState::VEHICLE, int, int>>& requirements) const
	{
		return PrintList(ostr, requirements, LittleCirclesState::DO_NOT_CARE, "donotcare", "$\\emptyset$");
	}
	OffsetStream& PrintEmptyList(OffsetStream& ostr, const std::vector<std::tuple<LittleCirclesState::VEHICLE, int, int>>& requirements) const
	{
		return PrintList(ostr, requirements, LittleCirclesState::NO_VEHICLE, "empty", "");
	}

	OffsetStream& PrintAgent(OffsetStream& ostr, const std::vector<std::tuple<LittleCirclesState::VEHICLE, int, int>>& requirements) const
	{
		ostr << '\n';
		for (auto cell : requirements)
		{
			if (std::get<1>(cell) == 0 && std::get<2>(cell) == 0)
			{
				if (std::get<0>(cell) != LittleCirclesState::NO_VEHICLE)
				{
					ostr << "% active agent" << '\n';
					ostr << "\\draw (0, 0) rectangle (1, 1);" << '\n';
					ostr << "\\draw[rounded corners] (\\slightoffset, \\slightoffset) rectangle (1 - \\slightoffset, 1 - \\slightoffset);" << '\n';
				}
				if (std::get<0>(cell) == LittleCirclesState::AGENT_NOT_CARE)
					ostr << "\\node (agent) at (0.5, 0.5) {me};" << '\n';
				break;
			}
		}

		ostr << '\n';
		ostr << "\\pgfmathtruncatemacro{\\direction}{" << direction << "}" << '\n';
		ostr << "\\ifnum\\direction = 0" << '\n';
		ostr.AddOffset();
		{
			ostr << "\\draw[-latex](0.5, 1 - \\arrooffset) -- (0.5, 1 + \\arrooffset);" << '\n';
		}
		ostr.DecreaseOffset();
		ostr << "\\fi" << '\n';
		ostr << "\\ifnum\\direction = 1" << '\n';
		ostr.AddOffset();
		{
			ostr << "\\draw[-latex](1 - \\arrooffset, 0.5) -- (1 + \\arrooffset, 0.5);" << '\n';
		}
		ostr.DecreaseOffset();
		ostr << "\\fi" << '\n';
		ostr << "\\ifnum\\direction = 2" << '\n';
		ostr.AddOffset();
		{
			ostr << "\\draw[-latex](0.5, \\arrooffset) -- (0.5, -\\arrooffset);" << '\n';
		}
		ostr.DecreaseOffset();
		ostr << "\\fi" << '\n';
		ostr << "\\ifnum\\direction = 3" << '\n';
		ostr.AddOffset();
		{
			ostr << "\\draw[-latex](\\arrooffset, 0.5) -- (-\\arrooffset, 0.5);" << '\n';
		}
		ostr.DecreaseOffset();
		ostr << "\\fi" << '\n';

		return ostr;
	}
protected:
	virtual OffsetStream& PrintSpecial(OffsetStream& ostr) const
	{
		return ostr;
	}
public:
	PrintState(const LittleCirclesState& state)
		: agent(state.agent)
		, direction(state.direction)
		, exiting(state.exiting)
		, continuing(state.continuing)
		, column(state.column)
		, row(state.row)
	{}

	std::ostream& Print(std::ostream& ostr) const
	{
		OffsetStream ofsostr(ostr);

		auto requirements = CreateRequirements();

		PrintPreambule(ofsostr);
		PrintBegin(ofsostr, "document");
		{
			PrintBegin(ofsostr, "tikzpicture");
			{
				PrintBoardSize(ofsostr, requirements);
				PrintConstants(ofsostr);
				PrintDefineBorders(ofsostr);
				PrintBorders(ofsostr);

				PrintCommentOnLists(ofsostr);
				PrintExitingList(ofsostr, requirements);
				PrintContinuingList(ofsostr, requirements);
				PrintDoNotCareList(ofsostr, requirements);
				PrintEmptyList(ofsostr, requirements);

				PrintAgent(ofsostr, requirements);

				PrintSpecial(ofsostr);
			}
			PrintEnd(ofsostr, "tikzpicture");
		}
		PrintEnd(ofsostr, "document");

		return ostr;
	}
};

inline std::ostream& operator<< (std::ostream& ostr, const LittleCirclesState& state)
{
	PrintState printer(state);
	return printer.Print(ostr);
}
