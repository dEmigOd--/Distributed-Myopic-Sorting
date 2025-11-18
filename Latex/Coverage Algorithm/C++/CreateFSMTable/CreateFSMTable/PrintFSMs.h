#pragma once

#include "stdafx.h"
#include "PrintToLatex.h"
#include "ParseParameters.h"

class PrintFSMs : public PrintToLatex
{
private:
	ProgramParameters params;;
	int fileCount;

	OffsetStream & PrintSetGeometry(OffsetStream& ostr) const
	{
		ostr << "\\newgeometry{left = 1.5cm}" << '\n';
		return ostr;
	}

	OffsetStream & PrintRestoreGeometry(OffsetStream& ostr) const
	{
		ostr << "\\restoregeometry" << '\n';
		return ostr;
	}

	OffsetStream & PrintSubfloat(OffsetStream& ostr, int filenum) const
	{
		ostr << "\\subfloat[State Machine of agent at state " << filenum << "\\label{" << params.GetLabel() << ".algo.fsm.subfig" << filenum << "}]" << '\n';
		ostr << "{" << '\n';
		ostr.AddOffset();
		{
			ostr << "\\input{" << params.GetStateFilename(filenum) << "}" << '\n';
		}
		ostr.DecreaseOffset();
		ostr << "}" << '\n';

		return ostr;
	}

	OffsetStream & PrintQQuad(OffsetStream& ostr) const
	{
		ostr << "\\qquad" << '\n';
		return ostr;
	}

	OffsetStream & PrintCaption(OffsetStream& ostr) const
	{
		ostr << "\\caption{Agent state machines at different positions on the patch, a tuple designates next memory state and a picked movement direction, "
			"or \\textit{do nothing} otherwise." << '\n'
			<< "Empty hatched cells should be treated as erroneous states. Input direction is a position of empty cell at the beginning of time tick." << '\n'
			<< "In the absence of neighboring empty cell agents \\textit{do nothing} (not shown).}" << '\n';
		ostr << "\\label{" << params.GetLabel() << ".coverage.algo.ver" << params.GetVersion() << ".FSMs}" << '\n';
		return ostr;
	}
public:
	PrintFSMs(const ProgramParameters& params, int fileCount)
		: PrintToLatex("article")
		, params(params)
		, fileCount(fileCount)
	{}

	virtual std::ostream& Print(std::ostream& ostr) const override
	{
		OffsetStream ofsostr(ostr);

		PrintPreambule(ofsostr);
		PrintBegin(ofsostr, "document");
		{
			//PrintSetGeometry(ofsostr);
			PrintBegin(ofsostr, "figure");
			{
				for (int filenum = 1; filenum <= fileCount; ++filenum)
				{
					PrintSubfloat(ofsostr, filenum);

					if (filenum % 3 == 0)
					{
						PrintQQuad(ofsostr);
					}
				}
				PrintCaption(ofsostr);
			}
			PrintEnd(ofsostr, "figure");
			//PrintRestoreGeometry(ofsostr);
		}
		PrintEnd(ofsostr, "document");

		return ostr;
	}
};
