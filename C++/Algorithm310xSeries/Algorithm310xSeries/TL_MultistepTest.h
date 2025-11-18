#pragma once

#include "TL_BasicTest.h"

namespace Phd
{
	class TL_MultistepTest : public TL_BasicTest
	{
		Parameters testParams;

		std::shared_ptr<Phd::Algorithm> algo;

		AbstractParameter& refParam;
	protected:
		typedef AbstractParameter& (TL_MultistepTest::* ParamFnc)() const;

		TL_MultistepTest(SimulationParameters params, Parameters testParams, std::shared_ptr<Phd::Algorithm> algo, std::shared_ptr<std::mt19937> gen,
			std::shared_ptr<GridCreator> gridCreator, ParamFnc ref)
			: TL_BasicTest(params, gen, gridCreator)
			, testParams(testParams)
			, algo(algo)
			, refParam((this->*ref)())
		{
		}

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
		virtual std::vector<std::vector<unsigned>> RunTest(unsigned numSimulations,
			unsigned maxIterations = std::numeric_limits<unsigned>::max()) override
		{
			OnTestStart(refParam.Total(), numSimulations);

			std::shared_ptr<Phd::BasicMask> mask(new Phd::Mask<1>({ Phd::Direction::NORTH, Phd::Direction::EAST, Phd::Direction::SOUTH, Phd::Direction::WEST }));
			Phd::FinalStateTester gridInFinalConfiguration;

			for (; !refParam.end(); ++refParam)
			{
				OnParameterSimulationStart();

				for (unsigned run = 0; run < numSimulations; ++run)
				{
					OnSimulationStart(run);

					std::shared_ptr<Phd::LLGrid> grid =
						gridCreator->CreateGrid(CreateRandomRoad(*n(), std::min(*k(), *n()), *n()), mask, algo);

					// Phd::Collectors collectors;
					// for(int i = 0; i < m; ++i)
					//		collectors.AddCollector(std::shared_ptr<Phd::DataCollector>(new Phd::ColumnDepicturer(i, grid.height(), MAX_ITERATION, "Column")));

					unsigned iterations = 0;

					// std::cout << '\n' << *grid << '\n';
					while (iterations++ < maxIterations)
					{
						// std::cout << '\n' << *grid << '\n';
						if (gridInFinalConfiguration.Test(*grid))
						{
							// std::cout << "Grid is sorted at iteration " << iteration << '\n';
							OnSimulationEnd(iterations);
							break;
						}
						// collectors.Collect(grid);
						grid->Tick();
					}
				}

				OnParameterSimulationEnd(*n(), *m(), *k());
			}

			return OnTestEnd();
		}

	};
}
