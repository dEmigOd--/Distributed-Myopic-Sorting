#pragma once

#include "LLGrid.h"

namespace Phd
{
	class FinalStateTester
	{
	public:
		bool Test(const LLGrid& grid) const
		{
			// ok. Final State is either all the vehicles in the last column are EXIT
			// or no EXIT vehicles are present in other columns

			bool foundNonExitingInLastColumn = false;
			for (auto row = 0; !foundNonExitingInLastColumn && (row < grid.height()); ++row) 
				foundNonExitingInLastColumn = (grid.TypeAt(row, grid.width() - 1) != Type::EXIT);

			if (foundNonExitingInLastColumn)
			{
				for (auto row = 0; row < grid.height(); ++row)
				{
					for (auto col = 0; col < grid.width() - 1; ++col)
					{
						if (grid.TypeAt(row, col) == Type::EXIT)
							return false;
					}
				}
			}

			return true;
		}
	};
}