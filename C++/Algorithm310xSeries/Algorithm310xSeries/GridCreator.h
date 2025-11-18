#pragma once

#include <memory>
#include <vector>
#include "Mask.h"
#include "LLGrid.h"
#include "Grid.h"
#include "FastGrid.h"

namespace Phd
{
	class GridCreator
	{
	public:
		virtual std::shared_ptr<LLGrid> CreateGrid(const std::vector<std::vector<Type> >& vehicles, std::shared_ptr<BasicMask> mask, std::shared_ptr<Algorithm> algo) const = 0;
	};

	class StandardGridCreator : public GridCreator
	{
	public:
		virtual std::shared_ptr<LLGrid> CreateGrid(const std::vector<std::vector<Type> >& vehicles, std::shared_ptr<BasicMask> mask, std::shared_ptr<Algorithm> algo) const override
		{
			return std::shared_ptr<LLGrid>(new Grid(vehicles, mask, algo));
		}
	};

	class FastGridCreator : public GridCreator
	{
	public:
		virtual std::shared_ptr<LLGrid> CreateGrid(const std::vector<std::vector<Type> >& vehicles, std::shared_ptr<BasicMask> mask, std::shared_ptr<Algorithm> algo) const override
		{
			return std::shared_ptr<LLGrid>(new FastGrid(vehicles, algo));
		}
	};
}
