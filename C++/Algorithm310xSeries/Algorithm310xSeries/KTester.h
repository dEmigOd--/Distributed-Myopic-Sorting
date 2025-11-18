#pragma once

#include "MultistepTest.h"

namespace Phd
{
	class KTester : public MultistepTest
	{
	public:
		KTester(SimulationParameters params, Parameters testParams, std::shared_ptr<Phd::Algorithm> algo, std::shared_ptr<std::mt19937> gen,
			std::shared_ptr<GridCreator> gridCreator)
			: MultistepTest(params, testParams, algo, gen, gridCreator, &KTester::k)
		{ }
	};
}
