#pragma once

#include <random>
#include <fstream>
#include <iterator>
#include <memory>
#include <limits>
#include <unordered_set>
#include <set>
#include "DirectionConverter.h"
#include "SimulationParameters.h"
#include "Parameters.h"
#include "Grid.h"
#include "GridCreator.h"
#include "MatlabBackedAlgorithm.h"
#include "Collector.h"
#include "Tester.h"
#include "MultiPermutator.h"

namespace Phd
{
    class BasicTest
    {
    private:

        std::shared_ptr<std::mt19937> gen;

        unsigned simulationsStarted;
        std::vector<std::vector<unsigned>> iterations;
        size_t curr_parameter, curr_run;

        std::unordered_set<int> pickSet(int N, int k) const
        {
            std::unordered_set<int> elems;
            for (int r = N - k; r < N; ++r)
            {
                int v = std::uniform_int_distribution<>(0, r)(*gen);

                if (!elems.insert(v).second)
                {
                    elems.insert(r);
                }
            }
            return elems;
        }

        std::vector<std::vector<Phd::Type>> CreateRoad(unsigned n, unsigned m, const std::vector<int>& exit, const std::vector<int>& zeros) const
        {
            if (n < 2 || m < 3)
                throw std::logic_error("Unsupported grid dimensions");

            std::vector<std::vector<Phd::Type>> road(n, std::vector<Phd::Type>(m, Phd::Type::CONTINUE));
            for (auto ind : exit)
                road[ind / m][ind % m] = Phd::Type::EXIT;
            for (auto ind : zeros)
                road[ind / m][ind % m] = Phd::Type::EMPTY;

            return road;
        }

    protected:
        SimulationParameters params;
        std::shared_ptr<GridCreator> gridCreator;

        std::vector<std::vector<Phd::Type>> CreateRandomRoad(unsigned n, unsigned m, unsigned N_zero, unsigned N_ones) const
        {
            if (N_ones == 0)
                N_ones = n - 1;

            if (n < 2 || m < 3)
                throw std::logic_error("Unsupported grid dimensions");

            std::unordered_set<int> where_zeros(pickSet(n * m, N_zero + N_ones));
            std::unordered_set<int> where_exiting(pickSet(N_zero + N_ones, N_ones));

            std::vector<int> exit, zeroes;

            std::set<int> lookup(where_exiting.begin(), where_exiting.end());
            int curr_index = 0;
            for (auto ind : where_zeros)
            {
                if (lookup.find(curr_index) != lookup.end())
                    exit.push_back(ind);
                else
                    zeroes.push_back(ind);
                ++curr_index;
            }

            return CreateRoad(n, m, exit, zeroes);
        }
/*
        std::vector<std::vector<Phd::Type>> CreateBlockedRoad(unsigned n, unsigned m, unsigned zeros, unsigned k, std::mt19937& gen)
        {
            if (n < 2 || m < 3 || k > m - 2)
                throw std::logic_error("Unsupported grid dimensions");

            std::unordered_set<int> where_zeros(pickSet(n * m, zeros, gen));
            std::vector<std::vector<Phd::Type>> road(n, std::vector<Phd::Type>(m, Phd::Type::CONTINUE));

            for (auto ind : where_zeros)
                road[ind / m][ind % m] = Phd::Type::EMPTY;

            road[0][k] = Phd::Type::EXPERIMENTAL;
            road[n - 1][k] = Phd::Type::EXPERIMENTAL;
            road[1][k] = Phd::Type::EMPTY;

            unsigned zeros_in_column = 0;
            for (int row = 0; row < static_cast<int>(n); ++row)
                if (road[row][k] == Phd::Type::EMPTY)
                    ++zeros_in_column;
            std::cout << "The column created with " << zeros_in_column << " zeros\n";

            return road;
        }

        std::vector<std::vector<Phd::Type>> CreateNextRoad(unsigned n, unsigned m, unsigned exits, unsigned zeros)
        {
            throw new std::logic_error("Hm");
        }
*/

        void OnTestStart(size_t data_size, size_t runs)
        {
            iterations = std::vector<std::vector<unsigned>>(data_size, std::vector<unsigned>(runs, 0));
            curr_parameter = 0;
        }

        std::vector<std::vector<unsigned>> OnTestEnd()
        {
            return iterations;
        }

        void OnSimulationStart(unsigned run)
        {
            ++simulationsStarted;
            if (params.progressIsShown && (run % params.progressFrequency == 0))
                std::cout << "..";
        }

        void OnSimulationEnd(unsigned iterations_in_last_run)
        {
            iterations[curr_parameter][curr_run] = iterations_in_last_run;
            ++curr_run;
        }

        void OnParameterSimulationStart()
        {
            curr_run = 0;
        }

        void OnParameterSimulationEnd(unsigned n, unsigned m, unsigned k)
        {
            if (params.intermediateResultsAreShown)
            {
                unsigned sum_iterations = 0;
                for (auto run : iterations[curr_parameter])
                    sum_iterations += run;
                std::cout << "\nThe average for grid " << n << "x" << m << " and " << k << " empty space(s) is " << static_cast<double>(sum_iterations) / iterations[curr_parameter].size() << '\n';
            }

            ++curr_parameter;
        }
    public:
        BasicTest(SimulationParameters params, std::shared_ptr<std::mt19937> gen, std::shared_ptr<GridCreator> gridCreator)
            : params(params)
            , gen(gen)
            , gridCreator(gridCreator)
            , simulationsStarted(0u)
            , iterations()
            , curr_parameter(0)
            , curr_run(0)
        {
        }

        // returns iterations it took to solve the problem in each run
        virtual std::vector<std::vector<unsigned>> RunTest(unsigned numSimulations,
            unsigned maxIterations = std::numeric_limits<unsigned>::max()) = 0;
    };
}
