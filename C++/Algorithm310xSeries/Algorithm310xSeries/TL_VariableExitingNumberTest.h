#pragma once

#include "TL_BasicTest.h"

namespace Phd
{
	class TL_VariableExitingNumberTest : public TL_BasicTest
	{
		Parameters testParams;

		std::shared_ptr<Phd::Algorithm> algo;
	protected:
		AbstractParameter& k() const
		{
			return testParams.k();
		}

		AbstractParameter& m() const
		{
			return testParams.m();
		}

		AbstractParameter& n() const
		{
			return testParams.n();
		}

		AbstractParameter& ones() const
		{
			return testParams.ones();
		}

	public:
		TL_VariableExitingNumberTest(SimulationParameters params, Parameters testParams, std::shared_ptr<Phd::Algorithm> algo, std::shared_ptr<std::mt19937> gen,
			std::shared_ptr<GridCreator> gridCreator)
			: TL_BasicTest(params, gen, gridCreator)
			, testParams(testParams)
			, algo(algo)
		{
		}

		virtual std::vector<std::vector<unsigned>> RunTest(unsigned numSimulations,
			unsigned maxIterations = std::numeric_limits<unsigned>::max()) override
		{
			OnTestStart(ones().Total(), numSimulations);

			std::shared_ptr<Phd::BasicMask> mask(new Phd::Mask<1>({ Phd::Direction::NORTH, Phd::Direction::EAST, Phd::Direction::SOUTH, Phd::Direction::WEST }));
			Phd::FinalStateTester gridInFinalConfiguration;

			for (; !ones().end(); ++ones())
			{
				// leave if more than supported number of vehicles
				if (*ones() > *n())
					break;

				OnParameterSimulationStart();

				for (unsigned run = 0; run < numSimulations; ++run)
				{
					OnSimulationStart(run);

					auto grid = gridCreator->CreateGrid(CreateRandomRoad(*n(), std::min(*k(), *n() * (*m()) - *ones()), *ones()), mask, algo);

					unsigned iterations = 0;

					//std::cout << grid << '\n';
					while (iterations++ < maxIterations)
					{
						// std::cout << grid << '\n';
						if (gridInFinalConfiguration.Test(*grid))
						{
							// std::cout << "Grid is sorted at iteration " << iteration << '\n';
							OnSimulationEnd(iterations);
							break;
						}
						grid->Tick();
					}
				}

				OnParameterSimulationEnd(*n(), *m(), *k());
			}

			return OnTestEnd();
		}

	};
}
