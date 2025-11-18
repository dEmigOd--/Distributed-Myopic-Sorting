// Algorithm310xSeries.cpp : This file contains the 'main' function. Program execution begins and ends there.
//
/*
#include <random>
#include <locale>
#include <iostream>
#include <iomanip>
#include <numeric>
#include <memory>
#include <chrono>

#include "MatlabPrint.h"
#include "MatlabBackedAlgorithm.h"
#include "GridCreator.h"
#include "MultiPermutator.h"
#include "Testers.h"
#include "Parameters.h"

class comma_numpunct : public std::numpunct<char>
{
protected:
    virtual char do_thousands_sep() const
    {
        return ',';
    }

    virtual std::string do_grouping() const
    {
        return "\03";
    }
};

class TimeMeasurer
{
    std::chrono::high_resolution_clock::time_point start;
public:
    TimeMeasurer()
        : start(std::chrono::high_resolution_clock::now())
    {
    }

    ~TimeMeasurer()
    {
        auto end = std::chrono::high_resolution_clock::now();

        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();

        // this creates a new locale based on the current application default
        // (which is either the one given on startup, but can be overriden with
        // std::locale::global) - then extends it with an extra facet that 
        // controls numeric output.
        std::locale comma_locale(std::locale(), new comma_numpunct());

        // tell cout to use our new locale.
        std::cout.imbue(comma_locale);

        std::cout << "Execution time: " << duration << " ms\n";

        std::cout.imbue(std::locale());
    }
};

template <typename T>
std::ostream& operator<< (std::ostream& out, const std::vector<T>& v)
{
    if (!v.empty())
    {
        out << '[';
        std::copy(v.begin(), v.end(), std::ostream_iterator<T>(out, ", "));
        out << "\b\b]";
    }
    return out;
}

void RunTests(const Phd::TimedAlgorithm<>& algo)
{
    static std::vector<std::vector<Phd::Item>> positions = {
        {Phd::Item::ANYTHING, Phd::Item::BORDER, Phd::Item::BORDER, Phd::Item::ANYTHING},
        {Phd::Item::ANYTHING, Phd::Item::ANYTHING, Phd::Item::BORDER, Phd::Item::BORDER},
        {Phd::Item::BORDER, Phd::Item::ANYTHING, Phd::Item::ANYTHING, Phd::Item::BORDER},
        {Phd::Item::BORDER, Phd::Item::BORDER, Phd::Item::ANYTHING, Phd::Item::ANYTHING},
        {Phd::Item::ANYTHING, Phd::Item::ANYTHING, Phd::Item::BORDER, Phd::Item::ANYTHING},
        {Phd::Item::ANYTHING, Phd::Item::ANYTHING, Phd::Item::ANYTHING, Phd::Item::BORDER},
        {Phd::Item::BORDER, Phd::Item::ANYTHING, Phd::Item::ANYTHING, Phd::Item::ANYTHING},
        {Phd::Item::ANYTHING, Phd::Item::BORDER, Phd::Item::ANYTHING, Phd::Item::ANYTHING},
        {Phd::Item::ANYTHING, Phd::Item::ANYTHING, Phd::Item::ANYTHING, Phd::Item::ANYTHING},
    };


    std::cout << "LSB Test passed: " << std::boolalpha << algo.TestLSBTimerBitsAreTracked() << '\n';
    std::cout << "Memory overflow Test passed: " << std::boolalpha << algo.TestMemoryIsNotExceeded() << '\n';
    std::cout << "All inputs handled Test passed: " << std::boolalpha << algo.TestAllInputsAreCovered<1>(positions) << '\n';
}

Phd::SimulationParameters CreateParams()
{
    Phd::SimulationParameters params{};
    params.intermediateResultsAreShown = false;
    params.progressFrequency = 50;
    params.progressIsShown = true;

    return params;
}

void PrintResults(const std::vector<std::vector<unsigned>>& results)
{
    std::vector<double> averages;
    for (auto& row_of_results : results)
    {
        unsigned sum_iterations = 0;
        for (auto single_result : row_of_results)
            sum_iterations += single_result;
        averages.push_back(static_cast<double>(sum_iterations) / row_of_results.size());
    }
    std::cout << averages << '\n';
}

void WriteArray(MatlabPrinter& printer, Phd::AbstractParameter& param, const std::string& array_name)
{
    std::vector<unsigned> param_array(param.Total());
    for (auto i = 0; !param.end(); ++param, ++i)
        param_array[i] = *param;
    printer.WriteArray(array_name, param_array);
    param.reset();
}

void RunSimulation_k(std::shared_ptr<std::mt19937> rng, int algorithmVersion, std::shared_ptr<Phd::Algorithm> algo, std::shared_ptr<Phd::GridCreator> fgc,
    const Phd::Parameters& params, int testNum, int NUM_RUNS)
{
    TimeMeasurer tm;
    std::string testName = "TestKs_";

    MatlabPrinter printer(std::string("Data/SimulationData.") + std::to_string(algorithmVersion) + ".Test." + std::to_string(testNum) + ".mat");

    printer.WriteScalar("TestName" + std::to_string(testNum), testName);

    printer.WriteScalar(testName + "ms", *params.m());

    WriteArray(printer, params.k(), testName + "ks");
    WriteArray(printer, params.n(), testName + "ns");

    for (params.n().reset(); !params.n().end(); ++params.n())
    {
        params.k().reset();
        auto result = Phd::KTester(CreateParams(), params, algo, rng, fgc).RunTest(NUM_RUNS);
        PrintResults(result);
        printer.WriteArray(testName + "n_" + std::to_string(*params.n()) + "_result", result);
    }
}

void RunSimulation_m(std::shared_ptr<std::mt19937> rng, int algorithmVersion, std::shared_ptr<Phd::Algorithm> algo, std::shared_ptr<Phd::GridCreator> fgc,
    const Phd::Parameters& params, int testNum, int NUM_RUNS)
{
    TimeMeasurer tm;
    std::string testName = "TestMs_";

    MatlabPrinter printer(std::string("Data/SimulationData.") + std::to_string(algorithmVersion) + ".Test." + std::to_string(testNum) + ".mat");

    printer.WriteScalar("TestName" + std::to_string(testNum), testName);

    printer.WriteScalar(testName + "ks", *params.k());

    WriteArray(printer, params.m(), testName + "ms");
    WriteArray(printer, params.n(), testName + "ns");

    for (params.n().reset(); !params.n().end(); ++params.n())
    {
        params.m().reset();
        auto result = Phd::MTester(CreateParams(), params, algo, rng, fgc).RunTest(NUM_RUNS);
        PrintResults(result);
        printer.WriteArray(testName + "n_" + std::to_string(*params.n()) + "_result", result);
    }
}

void RunSimulation_n(std::shared_ptr<std::mt19937> rng, int algorithmVersion, std::shared_ptr<Phd::Algorithm> algo, std::shared_ptr<Phd::GridCreator> fgc,
    const Phd::Parameters& params, int testNum, int NUM_RUNS)
{
    TimeMeasurer tm;
    std::string testName = "TestNs_";

    MatlabPrinter printer(std::string("Data/SimulationData.") + std::to_string(algorithmVersion) + ".Test." + std::to_string(testNum) + ".mat");

    printer.WriteScalar("TestName" + std::to_string(testNum), testName);

    printer.WriteScalar(testName + "ks", *params.k());

    WriteArray(printer, params.m(), testName + "ms");
    WriteArray(printer, params.n(), testName + "ns");

    for (params.m().reset(); !params.m().end(); ++params.m())
    {
        params.n().reset();
        auto result = Phd::NTester(CreateParams(), params, algo, rng, fgc).RunTest(NUM_RUNS);
        PrintResults(result);
        printer.WriteArray(testName + "m_" + std::to_string(*params.m()) + "_result", result);
    }
}

void RunSimulation_ones(std::shared_ptr<std::mt19937> rng, int algorithmVersion, std::shared_ptr<Phd::Algorithm> algo, std::shared_ptr<Phd::GridCreator> fgc,
    const Phd::Parameters& params, int testNum, int NUM_RUNS)
{
    TimeMeasurer tm;
    std::string testName = "TestN1s_";

    MatlabPrinter printer(std::string("Data/SimulationData.") + std::to_string(algorithmVersion) + ".Test." + std::to_string(testNum) + ".mat");

    printer.WriteScalar("TestName" + std::to_string(testNum), testName);

    printer.WriteScalar(testName + "ks", *params.k());
    printer.WriteScalar(testName + "ms", *params.m());

    WriteArray(printer, params.n(), testName + "ns");
    WriteArray(printer, params.ones(), testName + "ones");

    for (params.n().reset(); !params.n().end(); ++params.n())
    {
        params.ones().reset();
        auto result = Phd::VariableExitingNumberTest(CreateParams(), params, algo, rng, fgc).RunTest(NUM_RUNS);
        PrintResults(result);
        printer.WriteArray(testName + "n_" + std::to_string(*params.n()) + "_result", result);
    }
}

void RunSimulation_FreeRoad_m(std::shared_ptr<std::mt19937> rng, int algorithmVersion, std::shared_ptr<Phd::Algorithm> algo, std::shared_ptr<Phd::GridCreator> fgc,
    const Phd::Parameters& params, double freeRatio, int testNum, int NUM_RUNS)
{
    TimeMeasurer tm;
    std::string testName = "TestFreeRoadMs_";

    MatlabPrinter printer(std::string("Data/SimulationData.") + std::to_string(algorithmVersion) + ".Test." + std::to_string(testNum) + ".mat");

    printer.WriteScalar("TestName" + std::to_string(testNum), testName);

    printer.WriteScalar(testName + "ks", *params.k());
    printer.WriteScalar(testName + "freeRatio", freeRatio);

    WriteArray(printer, params.m(), testName + "ms");
    WriteArray(printer, params.n(), testName + "ns");

    for (params.n().reset(); !params.n().end(); ++params.n())
    {
        params.m().reset();
        auto result = Phd::VEMTester(CreateParams(), params, algo, rng, fgc, freeRatio).RunTest(NUM_RUNS);
        PrintResults(result);
        printer.WriteArray(testName + "n_" + std::to_string(*params.n()) + "_result", result);
    }
}

void RunSimulation_FreeRoad_n(std::shared_ptr<std::mt19937> rng, int algorithmVersion, std::shared_ptr<Phd::Algorithm> algo, std::shared_ptr<Phd::GridCreator> fgc,
    const Phd::Parameters& params, double freeRatio, int testNum, int NUM_RUNS)
{
    TimeMeasurer tm;
    std::string testName = "TestFreeRoadNs_";

    MatlabPrinter printer(std::string("Data/SimulationData.") + std::to_string(algorithmVersion) + ".Test." + std::to_string(testNum) + ".mat");

    printer.WriteScalar("TestName" + std::to_string(testNum), testName);

    printer.WriteScalar(testName + "ks", *params.k());
    printer.WriteScalar(testName + "freeRatio", freeRatio);

    WriteArray(printer, params.m(), testName + "ms");
    WriteArray(printer, params.n(), testName + "ns");

    for (params.m().reset(); !params.m().end(); ++params.m())
    {
        params.n().reset();
        auto result = Phd::VENTester(CreateParams(), params, algo, rng, fgc, freeRatio).RunTest(NUM_RUNS);
        PrintResults(result);
        printer.WriteArray(testName + "m_" + std::to_string(*params.m()) + "_result", result);
    }
}

void RunSimulation_CompareAlgorithms(std::shared_ptr<std::mt19937> rng, std::shared_ptr<Phd::GridCreator> fgc, std::vector<int> algorithmVersions,
    const Phd::Parameters& params, int testNum, int NUM_RUNS)
{
    MatlabPrinter printer(std::string("Data/SimulationData.Algos.Test.") + std::to_string(testNum) + ".mat");

    TimeMeasurer tm;
    std::string testName = "TestAlgos_";

    printer.WriteScalar("TestName" + std::to_string(testNum), testName);

    printer.WriteArray(testName + "AlgorithmVersions", algorithmVersions);
    printer.WriteScalar(testName + "ks", *params.k());
    printer.WriteScalar(testName + "ms", *params.m());
 
    WriteArray(printer, params.n(), testName + "ns");

    for (auto algorithmVersion : algorithmVersions)
    {
        Phd::MatlabBackedAlgorithm* alxxx(new Phd::MatlabBackedAlgorithm("../../../Matlab/+Cylinders/Data", algorithmVersion));
        std::cout << "Algorithm " << algorithmVersion << ":\n";
        RunTests(*alxxx);
        std::shared_ptr<Phd::Algorithm> algo(alxxx);

        params.n().reset();
        auto result = Phd::NTester(CreateParams(), params, algo, rng, fgc).RunTest(NUM_RUNS);
        PrintResults(result);
        printer.WriteArray(testName + "algo_" + std::to_string(algorithmVersion) + "_result", result);
    }
}

bool ShouldRunThisTest(int thisId, int startId, int endId)
{
    return thisId >= startId && thisId <= endId;
}

void RunSimulations()
{
    const int FAST_RUNS = 10;
    const int LOW_NUM_RUNS = 100;
    const int MEDIUM_NUM_RUNS = 500;
    const int HUGE_NUM_RUNS = 2000;

    std::random_device dev;
    std::shared_ptr<std::mt19937> rng(new std::mt19937(dev()));

    int algorithmVersion = 310;

    Phd::MatlabBackedAlgorithm* matlabAlgo(new Phd::MatlabBackedAlgorithm("../../../Matlab/+Cylinders/Data", algorithmVersion));
    RunTests(*matlabAlgo);

    std::shared_ptr<Phd::Algorithm> algo(matlabAlgo);
    std::shared_ptr<Phd::GridCreator> fgc(new Phd::FastGridCreator);

    int testNum = 0, startId = 1, endId = 23;
    
    // Test 1
    std::cout << "Test " << ++testNum << '\n';
    if(ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_k(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::AddParameter>(1, 20, 1),
                std::make_shared<Phd::Parameter>(4),
                std::make_shared<Phd::AddParameter>(6, 5, 3),
                std::make_shared<Phd::NullParameter>(),
            }),
            testNum, MEDIUM_NUM_RUNS);

    // Test 2
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_k(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::AddParameter>(3, 20, 1),
                std::make_shared<Phd::Parameter>(8),
                std::make_shared<Phd::AddParameter>(6, 5, 3),
                std::make_shared<Phd::NullParameter>(),
            }),
            testNum, MEDIUM_NUM_RUNS);

    // Test 3
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_m(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(1),
                std::make_shared<Phd::AddParameter>(3, 10, 1),
                std::make_shared<Phd::AddParameter>(6, 5, 2),
                std::make_shared<Phd::NullParameter>(),
            }),
            testNum, MEDIUM_NUM_RUNS);

    // Test 4
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_m(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(3),
                std::make_shared<Phd::AddParameter>(3, 10, 1),
                std::make_shared<Phd::AddParameter>(6, 5, 2),
                std::make_shared<Phd::NullParameter>(),
            }),
            testNum, MEDIUM_NUM_RUNS);

    // Test 5
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_m(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(5),
                std::make_shared<Phd::AddParameter>(3, 10, 1),
                std::make_shared<Phd::AddParameter>(6, 5, 2),
                std::make_shared<Phd::NullParameter>(),
            }),
            testNum, MEDIUM_NUM_RUNS);

    // Test 6
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_n(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(1),
                std::make_shared<Phd::AddParameter>(3, 5, 1),
                std::make_shared<Phd::AddParameter>(6, 10, 1),
                std::make_shared<Phd::NullParameter>(),
            }),
            testNum, MEDIUM_NUM_RUNS);

    // Test 7
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_n(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(3),
                std::make_shared<Phd::AddParameter>(3, 5, 1),
                std::make_shared<Phd::AddParameter>(6, 10, 1),
                std::make_shared<Phd::NullParameter>(),
            }),
            testNum, MEDIUM_NUM_RUNS);

    // Test 8
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_n(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(5),
                std::make_shared<Phd::AddParameter>(3, 5, 1),
                std::make_shared<Phd::AddParameter>(6, 10, 1),
                std::make_shared<Phd::NullParameter>(),
            }),
            testNum, MEDIUM_NUM_RUNS);
    
    // Test 9
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_ones(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::Parameter>(4),
                std::make_shared<Phd::AddParameter>(6, 10, 2),
                std::make_shared<Phd::AddParameter>(1, 25, 1),
                }),
            testNum, MEDIUM_NUM_RUNS);

    // Test 10
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_ones(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(5),
                std::make_shared<Phd::Parameter>(4),
                std::make_shared<Phd::AddParameter>(6, 10, 2),
                std::make_shared<Phd::AddParameter>(1, 25, 1),
                }),
            testNum, MEDIUM_NUM_RUNS);

    // Test 11
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_FreeRoad_m(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::NullParameter>(),
                std::make_shared<Phd::AddParameter>(4, 20, 4),
                std::make_shared<Phd::AddParameter>(4, 8, 2),
                std::make_shared<Phd::NullParameter>(),
                }),
            0.2,
            testNum, MEDIUM_NUM_RUNS);

    // Test 12
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_FreeRoad_m(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::NullParameter>(),
                std::make_shared<Phd::AddParameter>(4, 20, 4),
                std::make_shared<Phd::AddParameter>(4, 8, 2),
                std::make_shared<Phd::NullParameter>(),
                }),
            0.6,
            testNum, MEDIUM_NUM_RUNS);

    // Test 13
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_FreeRoad_n(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::NullParameter>(),
                std::make_shared<Phd::AddParameter>(4, 5, 1),
                std::make_shared<Phd::AddParameter>(4, 20, 4),
                std::make_shared<Phd::NullParameter>(),
                }),
            0.2,
            testNum, MEDIUM_NUM_RUNS);

    // Test 14
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_FreeRoad_n(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::NullParameter>(),
                std::make_shared<Phd::AddParameter>(4, 5, 1),
                std::make_shared<Phd::AddParameter>(4, 20, 4),
                std::make_shared<Phd::NullParameter>(),
                }),
            0.6,
            testNum, MEDIUM_NUM_RUNS);

    // Test 15
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_CompareAlgorithms(rng, fgc, {307, 309, 310, 313, 314, 315, 316},
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(3),
                std::make_shared<Phd::Parameter>(4),
                std::make_shared<Phd::AddParameter>(4, 10, 2),
                std::make_shared<Phd::NullParameter>(),
            }),
            testNum, MEDIUM_NUM_RUNS);

    // Test 16
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_m(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(40),
                std::make_shared<Phd::MultiplyParameter>(4, 6, 2),
                std::make_shared<Phd::AddParameter>(6, 5, 2),
                std::make_shared<Phd::NullParameter>(),
                }),
            testNum, MEDIUM_NUM_RUNS);

    // Test 17
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_k(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::AddParameter>(50, 40, 5),
                std::make_shared<Phd::Parameter>(20),
                std::make_shared<Phd::AddParameter>(20, 5, 4),
                std::make_shared<Phd::NullParameter>(),
                }),
            testNum, LOW_NUM_RUNS);

    // Test 18
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_k(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::AddParameter>(200, 20, 50),
                std::make_shared<Phd::Parameter>(40),
                std::make_shared<Phd::AddParameter>(40, 5, 8),
                std::make_shared<Phd::NullParameter>(),
                }),
            testNum, LOW_NUM_RUNS);

    // Test 19
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_ones(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(100),
                std::make_shared<Phd::Parameter>(50),
                std::make_shared<Phd::AddParameter>(40, 5, 10),
                std::make_shared<Phd::AddParameter>(1, 50, 2),
                }),
            testNum, LOW_NUM_RUNS);

    // Test 20
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_ones(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(500),
                std::make_shared<Phd::Parameter>(4),
                std::make_shared<Phd::AddParameter>(800, 5, 100),
                std::make_shared<Phd::AddParameter>(100, 25, 50),
                }),
                testNum, LOW_NUM_RUNS);

    // Test 21
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_m(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(3),
                std::make_shared<Phd::AddParameter>(3, 7, 3),
                std::make_shared<Phd::AddParameter>(18, 1, 2),
                 std::make_shared<Phd::NullParameter>(),
                }),
                testNum, HUGE_NUM_RUNS);

    // Test 22
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_m(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(7),
                std::make_shared<Phd::AddParameter>(3, 7, 3),
                std::make_shared<Phd::AddParameter>(18, 1, 2),
                std::make_shared<Phd::NullParameter>(),
                }),
                testNum, HUGE_NUM_RUNS);

    // Test 23
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_m(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(21),
                std::make_shared<Phd::AddParameter>(3, 7, 3),
                std::make_shared<Phd::AddParameter>(18, 1, 2),
                 std::make_shared<Phd::NullParameter>(),
                }),
                testNum, HUGE_NUM_RUNS);

}

int do_not_run_main()
{
    RunSimulations();

    return 0;
}

int t_main()
{
    Phd::DuPermutator perm(8, 2, 3);

    do
    {
        auto result = perm.GetPermutation();
        std::cout << std::get<0>(result) << '\t';
        std::cout << std::get<1>(result) << '\n';
    } while (perm.NextPermutation());

    return 0;
}
*/