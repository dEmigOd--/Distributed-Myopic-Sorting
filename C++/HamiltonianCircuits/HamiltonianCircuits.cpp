// HamiltonianCircuits.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <random>
#include <algorithm>
#include <vector>
#include <fstream>
#include <string>

#include <chrono>
#include <thread>

#include "Agent.h"
#include "Road.h"
#include "EvenColumnHamiltonianCircuitAlgorithm.h"

std::vector<Agent> FillTheRoad(const std::shared_ptr<Road>& road, size_t rows, size_t columns, size_t exiting_n, size_t free, 
	std::shared_ptr<HamiltonianCircuitAlgorithmBase>& decisionAlgorithm, std::mt19937& generator)
{
	const size_t visibility = 2;
	std::vector<size_t> indices(rows * columns);
	std::vector<Agent> cars;

	size_t i;
	for (i = 0; i < indices.size(); ++i)
		indices[i] = i;

	std::shuffle(indices.begin(), indices.end(), generator);

	if (exiting_n > rows)
		exiting_n = rows;

	for (i = 0; i < rows * columns - free; ++i)
	{
		Location location = { indices[i] / columns, indices[i] % columns };
		AgentProxy physical(road, location, visibility);
		bool exiting = i < exiting_n;
		cars.push_back(Agent(physical, exiting, decisionAlgorithm));
		road->AddVehicle(location);
	}

	return cars;
}

std::vector<Agent> FillTheRoad(const std::shared_ptr<Road>& road, size_t rows, size_t columns, size_t free,
	std::shared_ptr<HamiltonianCircuitAlgorithmBase>& decisionAlgorithm, std::mt19937& generator)
{
	return FillTheRoad(road, rows, columns, rows, free, decisionAlgorithm, generator);
}


void PrintSeparatorLine(std::ostream& ostr, size_t columns)
{
	ostr << "-";
	for (size_t column = 0; column < columns; ++column)
		ostr << "-----";
	ostr << '\n';
}

void ClearScreen(std::ostream& ostr)
{
	ostr << std::string(100, '\n');
}

void PrintRoad(std::ostream& ostr, const std::shared_ptr<Road>& road, size_t rows, size_t columns, const std::vector<Agent>& agents)
{
	std::vector<std::vector<bool>> exiting(rows, std::vector<bool>(columns + 1, false));
	for (auto agent : agents)
	{
		auto whereAmI = agent.GetLocation();
		exiting[whereAmI.row][whereAmI.column] = agent.Exiting();
	}

	PrintSeparatorLine(ostr, columns);
	for (size_t row = 0; row < rows; ++row)
	{
		ostr << '|';
		for (size_t column = 0; column < columns; ++column)
		{
			if (exiting[row][column])
				ostr << "  1 |";
			else
			{
				auto sense = road->Sense({ row, column }, 0);
				if (sense[0] == OCCUPIED)
					ostr << " -1 |";
				else
					ostr << "    |";
			}
		}

		auto sense = road->Sense({ row, columns - 1 }, 1);
		ostr << "   |  ";
		if (sense[5] == OCCUPIED)
			ostr << "1";
		else
			ostr << " ";
		ostr << " |\n";
		PrintSeparatorLine(ostr, columns);
	}
}

bool NeedSortingInspection(size_t rows, const std::vector<Agent>& agents)
{
	auto countExiting = std::count_if(agents.cbegin(), agents.cend(), [](const Agent& agent)
	{
		return agent.Exiting();
	});

	return countExiting != rows;
}

bool IsSortedBasedOnCars(size_t columns, const std::vector<Agent>& agents)
{
	for (auto agent : agents)
		if (agent.GetLocation().column < columns && agent.Exiting())
			return false;
	return true;
}

size_t RunSorting(const std::shared_ptr<Road>& road, size_t rows, size_t columns, std::vector<Agent>& agents, int pauseInMs)
{
	bool needInspection = NeedSortingInspection(rows, agents);

	size_t iteration = 0;
	while (!(road->HaveFreeExitSpace() || (needInspection && IsSortedBasedOnCars(columns, agents))))
	{
		++iteration;

#ifdef _DEBUG
		ClearScreen(std::cout);
		std::cout << "Iteration : " << iteration << '\n';
		PrintRoad(std::cout, road, rows, columns, agents);
#endif

		road->StartTick();
		for (size_t agentIndex = 0; agentIndex < agents.size(); ++agentIndex)
		{
			agents[agentIndex].Compute();
		}
		road->CloseTick();

#ifdef _DEBUG
		std::this_thread::sleep_until(std::chrono::system_clock::now() + std::chrono::milliseconds(pauseInMs));
#endif
	}

#ifdef _DEBUG
	ClearScreen(std::cout);
	std::cout << "Final State\n";
	PrintRoad(std::cout, road, rows, columns, agents);
#endif

	return iteration;
}

void RunTrials(std::ostream& ostr, size_t n, size_t m, size_t num_of_empty, size_t exiting_n, 
	int trials, int pauseInMsInDebug, std::mt19937& generator, const std::string& msg, size_t value)
{
	ostr <<
#ifdef _DEBUG
		"\t" << msg << " = " <<
#endif
		value <<
#ifdef _DEBUG
		"\n";
#else
		",";
#endif

	size_t total_iterations = 0;
	for (int trial = 0; trial < trials; ++trial)
	{

		std::shared_ptr<Road> road(new Road(n, m));
		std::shared_ptr<HamiltonianCircuitAlgorithmBase> algo(new EvenColumnHamiltonianCircuitAlgorithm());

		auto agents = FillTheRoad(road, n, m, exiting_n, num_of_empty, algo, generator);

		size_t iterations = RunSorting(road, n, m, agents, pauseInMsInDebug);
		total_iterations += iterations;

#ifdef _DEBUG
		ostr << "\t\tThe run ended in " << iterations << " iterations\n";
#endif
	}

	ostr <<
#ifdef _DEBUG
		"\tAverage : " <<
#endif
		((double)total_iterations) / trials <<
#ifdef _DEBUG
		" iterations" <<
#else
		";" <<
#endif
		"\n";
}

void RunTrials(std::ostream& ostr, size_t n, size_t m, size_t num_of_empty, int trials, int pauseInMsInDebug, std::mt19937& generator, const std::string& msg, size_t value)
{
	RunTrials(ostr, n, m, num_of_empty, n, trials, pauseInMsInDebug, generator, msg, value);
}

void ExecuteEmptySpaceFunction(std::ostream& ostr, size_t n, size_t m, int trials, int pauseInMsInDebug, std::mt19937& generator)
{
	ostr << "Test : Time to finish as a function of the number of empty spaces(F) (n = " << n << ", m = " << m << ")\n";
#ifndef _DEBUG
	ostr << "F,avg iterations\n[";
#endif

	auto start = std::chrono::steady_clock::now();

	for (size_t num_of_empty = 1; num_of_empty < n * m - n; ++num_of_empty)
	{
		RunTrials(ostr, n, m, num_of_empty, trials, pauseInMsInDebug, generator, "Empty spaces", num_of_empty);
	}

	std::cout << "EmptySpace Simulation batch took " << std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - start).count() << " ms" << std::endl;

#ifndef _DEBUG
	ostr << "]\n";
#endif
}

void ExecuteRowsFunction(std::ostream& ostr, size_t max_n, size_t m, int trials, size_t num_of_empty, int pauseInMsInDebug, std::mt19937& generator)
{
	ostr << "Test : Time to finish as a function of the number of rows(n) (F = " << num_of_empty << ", m = " << m << ")\n";
#ifndef _DEBUG
	ostr << "n,avg iterations\n[";
#endif

	auto start = std::chrono::steady_clock::now();

	for (size_t n = 8; n < max_n; ++n)
	{
		RunTrials(ostr, n, m, num_of_empty, trials, pauseInMsInDebug, generator, "n", n);
	}

	std::cout << "Rows Simulation batch took " << std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - start).count() << " ms" << std::endl;

#ifndef _DEBUG
	ostr << "]\n";
#endif
}

void ExecuteColumnsFunction(std::ostream& ostr, size_t n, size_t max_m, int trials, size_t num_of_empty, int pauseInMsInDebug, std::mt19937& generator)
{
	ostr << "Test : Time to finish as a function of the number of columns(m) (F = " << num_of_empty << ", n = " << n << ")\n";
#ifndef _DEBUG
	ostr << "m,avg iterations\n[";
#endif

	auto start = std::chrono::steady_clock::now();

	for (size_t m = 2; m < max_m; m += 2)
	{
		RunTrials(ostr, n, m, num_of_empty, trials, pauseInMsInDebug, generator, "m", m);
	}

	std::cout << "Columns Simulation batch took " << std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - start).count() << " ms" << std::endl;

#ifndef _DEBUG
	ostr << "]\n";
#endif
}

void ExecuteExitingFunction(std::ostream& ostr, size_t n, size_t m, int trials, size_t num_of_empty, int pauseInMsInDebug, std::mt19937& generator)
{
	ostr << "Test : Time to finish as a function of the number of exiting vehicles (F = " << num_of_empty << ", n = " << n << ")\n";
#ifndef _DEBUG
	ostr << "exiting,avg iterations\n[";
#endif

	auto start = std::chrono::steady_clock::now();

	for (size_t exiting_n = 1; exiting_n <= n; ++exiting_n)
	{
		RunTrials(ostr, n, m, num_of_empty, exiting_n, trials, pauseInMsInDebug, generator, "exiting", exiting_n);
	}

	std::cout << "Exiting Simulation batch took " << std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - start).count() << " ms" << std::endl;

#ifndef _DEBUG
	ostr << "]\n";
#endif
}

int main()
{
	std::random_device rng;
	std::mt19937 urng(rng());

	std::ofstream writeTo;

	size_t n, m, empty_spaces, max_n, max_m;
	int	pauseInMs = 300,
		trials = 100;
	
	//-------------------------------------------------------------------------------------------------

	m = 4;
	for (auto n : { 4u, 8u, 10u, 12u, 16u })
	{
		for (empty_spaces = 1; empty_spaces < 2 * n; ++empty_spaces)
		{
			writeTo.open("Data.Exiting.F" + std::to_string(empty_spaces) + ".n" + std::to_string(n) + ".m" + std::to_string(m) + ".txt");
			ExecuteExitingFunction(writeTo, n, m, 10 * trials, empty_spaces, pauseInMs, urng);
			writeTo.close();
		}
	}
	if(true)
		return -1;

	//-------------------------------------------------------------------------------------------------
	/// Empty spaces
	n = 10; m = 4;
	writeTo.open("Data.EmptySpaces.n" + std::to_string(n) + ".m" + std::to_string(m) + ".txt");
	ExecuteEmptySpaceFunction(writeTo, n, m, trials, pauseInMs, urng);
	writeTo.close();

	for (auto nn : { 10u, 16u, 32u })
	{
		n = nn; m = 6;
		writeTo.open("Data.EmptySpaces.n" + std::to_string(n) + ".m" + std::to_string(m) + ".txt");
		ExecuteEmptySpaceFunction(writeTo, n, m, trials, pauseInMs, urng);
		writeTo.close();
	}

	//-------------------------------------------------------------------------------------------------
	
	m = 6; max_n = 32;
	for (auto empty_spaces : { 1u, 5u, 10u, 16u })
	{
		writeTo.open("Data.Rows.F" + std::to_string(empty_spaces) + ".m" + std::to_string(m) + ".txt");
		ExecuteRowsFunction(writeTo, max_n, m, trials, empty_spaces, pauseInMs, urng);
		writeTo.close();
	}
	

	//-------------------------------------------------------------------------------------------------

	n = 10; max_m = 20;
	for (auto empty_spaces : { 1u, 5u, 10u, 16u })
	{
		writeTo.open("Data.Columns.F" + std::to_string(empty_spaces) + ".n" + std::to_string(n) + ".txt");
		ExecuteColumnsFunction(writeTo, n, max_m, trials, empty_spaces, pauseInMs, urng);
		writeTo.close();
	}

	return 0;
}
