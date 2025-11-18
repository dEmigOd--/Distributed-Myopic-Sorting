#pragma once

#include "TL_MultistepTest.h"

namespace Phd
{
	class TL_KTester : public TL_MultistepTest
	{
	public:
		TL_KTester(SimulationParameters params, Parameters testParams, std::shared_ptr<Phd::Algorithm> algo, std::shared_ptr<std::mt19937> gen,
			std::shared_ptr<GridCreator> gridCreator)
			: TL_MultistepTest(params, testParams, algo, gen, gridCreator, &TL_KTester::k)
		{
		}
	};
}
