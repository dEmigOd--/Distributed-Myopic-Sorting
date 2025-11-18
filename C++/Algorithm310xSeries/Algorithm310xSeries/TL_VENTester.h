#pragma once

#include "TL_ConstantlyFreeRoadTest.h"

namespace Phd
{
	class TL_VENTester : public TL_ConstantlyFreeRoadTest
	{
	public:
		TL_VENTester(SimulationParameters params, Parameters testParams, std::shared_ptr<Phd::Algorithm> algo, std::shared_ptr<std::mt19937> gen,
			std::shared_ptr<GridCreator> gridCreator, double freeRatio)
			: TL_ConstantlyFreeRoadTest(params, testParams, algo, gen, gridCreator, freeRatio, &TL_VENTester::n)
		{
		}
	};
}
