#pragma once

#include "stdafx.h"

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

class PrintToLatex
{
	std::string documentclass;
protected:
	PrintToLatex(const std::string& documentclass)
		: documentclass(documentclass)
	{}

	OffsetStream& PrintPreambule(OffsetStream& ostr) const
	{
		ostr << "\\documentclass{" << documentclass << "}" << '\n';
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

public:
	virtual std::ostream& Print(std::ostream& ostr) const = 0;
};
