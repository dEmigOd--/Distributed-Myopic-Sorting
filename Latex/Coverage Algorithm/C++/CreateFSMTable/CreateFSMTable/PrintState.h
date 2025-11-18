#pragma once

#include "stdafx.h"
#include "StateFSM.h"
#include "PrintToLatex.h"

class PrintState : public PrintToLatex
{
private:
	const bStateFSM* state;
	
	template<typename TCollection>
	static std::string ToPlainText(const TCollection& collection, const std::string& delim)
	{
		std::ostringstream ostr;
		bool continuation = false;

		for (auto elem : collection)
		{
			if (continuation)
				ostr << delim;
			ostr << elem;
			continuation = true;
		}

		return ostr.str();
	}

	template<typename TCollection>
	static OffsetStream& PrintList(OffsetStream& ostr, const TCollection& collection)
	{
		ostr << ToPlainText(collection, ", ");
		return ostr;
	}

	static std::string MovementToString(Movement decision, Direction direction)
	{
		static std::vector<std::string> translationTable({ "N", "E", "S", "W", "$\\emptyset$" });
		if (decision == Movement::Stop)
		{
			// tip-tipa dirty to handle Stop as move-and-stop
			decision = static_cast<Movement>(direction);
		}
		return translationTable[static_cast<int>(decision)];
	}

	OffsetStream& PrintConstants(OffsetStream& ostr) const
	{
		ostr << '\n';
		ostr << "% define constants" << '\n';
		ostr << "\\pgfmathsetmacro{\\lengthlabelline}{0.8}" << '\n';
		ostr << "\\pgfmathsetmacro{\\labelxoffset}{0.5}" << '\n';
		ostr << "\\pgfmathsetmacro{\\labelyoffset}{0.1}" << '\n';
		ostr << "\\pgfmathsetmacro{\\tiklabelxoffset}{0.5}" << '\n';
		ostr << "\\pgfmathsetmacro{\\tiklabelyoffset}{0.3}" << '\n';
		ostr << "\\pgfmathsetmacro{\\tiklabelyoffset}{0.3}" << '\n';
		ostr << "\\pgfmathsetmacro{\\valuexoffset}{0.5}" << '\n';
		ostr << "\\pgfmathsetmacro{\\valueyoffset}{0.5}" << '\n';
		ostr << "\\pgfmathsetmacro{\\xsize}{" << static_cast<int>(Direction::DirectionCount) << "}" << '\n';
		ostr << "\\pgfmathsetmacro{\\ysize}{" << static_cast<int>(1 << state->BitsInState()) << "}" << '\n';

		ostr << '\n';

		return ostr;
	}

	OffsetStream& PrintTable(OffsetStream& ostr) const
	{
		ostr << '\n';
		ostr << "% common code" << '\n';
		ostr << "\\coordinate(left_upper_corner) at (0, \\ysize);" << '\n';
		ostr << "\\draw (0, 0) grid (\\xsize, \\ysize);" << '\n';
		ostr << '\n';
		ostr << "\\draw (left_upper_corner)-- ++(135:\\lengthlabelline);" << '\n';
		ostr << "\\node[rotate = -45, scale = 0.5] (input_label) at ($(left_upper_corner) + (135:\\labelxoffset) + (45:\\labelyoffset)$) {input};" << '\n';
		ostr << "\\node[rotate = -45, scale = 0.5] (input_label) at ($(left_upper_corner) + (135:\\labelxoffset) + (180 + 45:\\labelyoffset)$) {memory};" << '\n';
		ostr << '\n';
		ostr << "\\foreach \\direction[count=\\i] in { N, E, S, W }" << '\n';
		ostr << "{" << '\n';
		ostr.AddOffset();
		{
			ostr << "\\node(input_\\direction) at (\\i - 1 + \\tiklabelxoffset, \\ysize + \\tiklabelyoffset) {\\direction};" << '\n';
		}
		ostr.DecreaseOffset();
		ostr << "}" << '\n';
		ostr << '\n';
		ostr << "\\foreach \\memory in { ";
		std::vector<int> memStates(1i64 << state->BitsInState()); // vector with 2^bits ints.
		std::iota(std::begin(memStates), std::end(memStates), 0);
		PrintList(ostr, memStates);
		ostr << "}" << '\n';
		ostr << "{" << '\n';
		ostr.AddOffset();
		{
			ostr << "\\pgfmathtruncatemacro{\\memvalue}{\\ysize - \\memory - 1}" << '\n';
			ostr << "\\node (memory_\\memory) at (0 - \\tiklabelyoffset, \\memory + \\tiklabelxoffset) {\\memvalue};" << '\n';
		}
		ostr.DecreaseOffset();
		ostr << "}" << '\n';

		return ostr;
	}

	OffsetStream& PrintHatchingOnImpossibleColumns(OffsetStream& ostr) const
	{
		std::set<int> impossibleDirections;
		for (int direction = Direction::North; direction <= Direction::West; ++direction)
		{
			if (state->IsReadingPossibleInDirection(static_cast<Direction>(direction)))
				impossibleDirections.insert(direction);
		}

		if (!impossibleDirections.empty())
		{
			ostr << '\n';
			ostr << "% hatch columns" << '\n';
			ostr << "\\foreach \\column in {";
			PrintList(ostr, impossibleDirections);
			ostr <<	"}" << '\n';
			ostr << "{" << '\n';
			ostr.AddOffset();
			{
				ostr << "\\draw[pattern = north west lines, pattern color = black!50!white] (\\column, 0) rectangle ({\\column + 1 }, \\ysize);" << '\n';
			}
			ostr.DecreaseOffset();
			ostr << "}" << '\n';
		}

		return ostr;
	}

	OffsetStream& PrintDecisionValues(OffsetStream& ostr) const
	{
		std::map<std::tuple<int, int>, std::tuple<BitValue, Movement>> nonErrorDecisions;

		for (int bitValue = BitValue::ZeroBit; bitValue < (1 << state->BitsInState()); ++bitValue)
		{
			for (int direction = Direction::North; direction <= Direction::West; ++direction)
			{
				std::tuple<BitValue, Movement> tableValue = state->GetTableInput(static_cast<BitValue>(bitValue), static_cast<Direction>(direction));
				if (std::get<0>(tableValue) != BitValue::ErrorBit)
					nonErrorDecisions[std::make_tuple(bitValue, direction)] = tableValue;
			}
		}

		if (!nonErrorDecisions.empty())
		{
			ostr << '\n';
			ostr << "% set cell values" << '\n';
			for (auto cellValue : nonErrorDecisions)
			{
				ostr << "\\node (node_" << std::get<1>(cellValue.first) << std::get<0>(cellValue.first) << ") at (" <<
					std::get<1>(cellValue.first) << " + \\valuexoffset, " << (((1 << state->BitsInState()) - 1) - std::get<0>(cellValue.first)) << " + \\valueyoffset) {" <<
					static_cast<int>(std::get<0>(cellValue.second)) << ", " <<
					MovementToString(std::get<1>(cellValue.second), static_cast<Direction>(std::get<1>(cellValue.first))) << "};" << '\n';
			}
		}

		return ostr;
	}

	OffsetStream& PrintFinalStates(OffsetStream& ostr) const
	{
		std::map<std::tuple<int, int>, std::tuple<BitValue, Movement>> stopDecisions;

		for (int bitValue = BitValue::ZeroBit; bitValue < (1 << state->BitsInState()); ++bitValue)
		{
			for (int direction = Direction::North; direction <= Direction::West; ++direction)
			{
				std::tuple<BitValue, Movement> tableValue = state->GetTableInput(static_cast<BitValue>(bitValue), static_cast<Direction>(direction));
				if (std::get<1>(tableValue) == Movement::Stop)
					stopDecisions[std::make_tuple(bitValue, direction)] = tableValue;
			}
		}

		if (!stopDecisions.empty())
		{
			ostr << '\n';
			ostr << "% set final state" << '\n';
			ostr << "\\pgfmathsetmacro{\\slightoffset}{0.05}" << '\n';
			for (auto cellValue : stopDecisions)
			{
				ostr << "\\draw[rounded corners] (" <<
					std::get<1>(cellValue.first) << " + \\slightoffset, " << (((1 << state->BitsInState()) - 1) - std::get<0>(cellValue.first)) << " + \\slightoffset) rectangle (" <<
					std::get<1>(cellValue.first) + 1 << " - \\slightoffset, " << (((1 << state->BitsInState()) - 1) - std::get<0>(cellValue.first)) + 1 << " - \\slightoffset);" << '\n';
			}
		}

		return ostr;
	}

	OffsetStream& PrintHatchErrorCells(OffsetStream& ostr) const
	{
		std::map<std::tuple<int, int>, std::tuple<BitValue, Movement>> errorCells;

		for (int bitValue = BitValue::ZeroBit; bitValue < (1 << state->BitsInState()); ++bitValue)
		{
			for (int direction = Direction::North; direction <= Direction::West; ++direction)
			{
				std::tuple<BitValue, Movement> tableValue = state->GetTableInput(static_cast<BitValue>(bitValue), static_cast<Direction>(direction));
				if (std::get<0>(tableValue) == BitValue::ErrorBit)
					errorCells[std::make_tuple(bitValue, direction)] = tableValue;
			}
		}

		if (!errorCells.empty())
		{
			ostr << '\n';
			ostr << "% hatch error cells" << '\n';
			std::vector<std::string> valuePairs;
			for (auto cellValue : errorCells)
			{
				valuePairs.push_back(ToPlainText(std::vector<int>({ std::get<1>(cellValue.first), ((1 << state->BitsInState()) - 1) - std::get<0>(cellValue.first) }), "/"));
			}

			ostr << "\\foreach \\x/\\y in {";
			PrintList(ostr, valuePairs);
			ostr << "}" << '\n';
			ostr << "{" << '\n';
			ostr.AddOffset();
			{
				ostr << "\\draw[pattern = north west lines, pattern color = black!50!white] (\\x, \\y) rectangle ({\\x+1}, {\\y+1});" << '\n';
			}
			ostr.DecreaseOffset();
			ostr << "}" << '\n';
		}

		return ostr;
	}

	OffsetStream& PrintHatchNoChangeCells(OffsetStream& ostr) const
	{
		std::map<std::tuple<int, int>, std::tuple<BitValue, Movement>> toHatchCells;

		for (int bitValue = BitValue::ZeroBit; bitValue < (1 << state->BitsInState()); ++bitValue)
		{
			for (int direction = Direction::North; direction <= Direction::West; ++direction)
			{
				std::tuple<BitValue, Movement> tableValue = state->GetTableInput(static_cast<BitValue>(bitValue), static_cast<Direction>(direction));
				if (std::get<0>(tableValue) == bitValue && std::get<1>(tableValue) == Movement::DoNothing)
					toHatchCells[std::make_tuple(bitValue, direction)] = tableValue;
			}
		}

		if (!toHatchCells.empty())
		{
			ostr << '\n';
			ostr << "% hatch error cells" << '\n';
			std::vector<std::string> valuePairs;
			for (auto cellValue : toHatchCells)
			{
				valuePairs.push_back(ToPlainText(std::vector<int>({ std::get<1>(cellValue.first), ((1 << state->BitsInState()) - 1) - std::get<0>(cellValue.first) }), "/"));
			}

			ostr << "\\foreach \\x/\\y in {";
			PrintList(ostr, valuePairs);
			ostr << "}" << '\n';
			ostr << "{" << '\n';
			ostr.AddOffset();
			{
				ostr << "\\draw[pattern = north west lines, pattern color = blue!50!white] (\\x, \\y) rectangle ({\\x+1}, {\\y+1});" << '\n';
			}
			ostr.DecreaseOffset();
			ostr << "}" << '\n';
		}

		return ostr;
	}

public:
	PrintState(const bStateFSM* state)
		: PrintToLatex("standalone")
		, state(state)
	{
	}

	virtual std::ostream& Print(std::ostream& ostr) const override
	{
		OffsetStream ofsostr(ostr);

		PrintPreambule(ofsostr);
		PrintBegin(ofsostr, "document");
		{
			PrintBegin(ofsostr, "tikzpicture");
			{
				PrintConstants(ofsostr);
				PrintTable(ofsostr);

				PrintHatchingOnImpossibleColumns(ofsostr);
				PrintDecisionValues(ofsostr);
				PrintFinalStates(ofsostr);
				PrintHatchErrorCells(ofsostr);
				PrintHatchNoChangeCells(ofsostr);
			}
			PrintEnd(ofsostr, "tikzpicture");
		}
		PrintEnd(ofsostr, "document");

		return ostr;
	}
};

inline std::ostream& operator<< (std::ostream& ostr, const bStateFSM& state)
{
	PrintState printer(&state);
	return printer.Print(ostr);
}
