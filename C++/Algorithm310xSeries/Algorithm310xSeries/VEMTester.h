#pragma once


#include "ConstantlyFreeRoadTest.h"

namespace Phd
{
	class VEMTester : public ConstantlyFreeRoadTest
	{
	public:
		VEMTester(SimulationParameters params, Parameters testParams, std::shared_ptr<Phd::Algorithm> algo, std::shared_ptr<std::mt19937> gen, 
			std::shared_ptr<GridCreator> gridCreator, double freeRatio)
			: ConstantlyFreeRoadTest(params, testParams, algo, gen, gridCreator, freeRatio, &VEMTester::m)
		{
		}
	};
}
