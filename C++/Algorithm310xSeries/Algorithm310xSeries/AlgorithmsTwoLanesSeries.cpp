// Algorithm310xSeries.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

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
#include "TL_Testers.h"
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
        auto result = Phd::TL_KTester(CreateParams(), params, algo, rng, fgc).RunTest(NUM_RUNS);
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

    printer.WriteScalar(testName + "ms", *params.m());

    WriteArray(printer, params.k(), testName + "ks");
    WriteArray(printer, params.n(), testName + "ns");

    for (params.k().reset(); !params.k().end(); ++params.k())
    {
        params.n().reset();
        auto result = Phd::TL_NTester(CreateParams(), params, algo, rng, fgc).RunTest(NUM_RUNS);
        PrintResults(result);
        printer.WriteArray(testName + "k_" + std::to_string(*params.k()) + "_result", result);
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
        auto result = Phd::TL_VariableExitingNumberTest(CreateParams(), params, algo, rng, fgc).RunTest(NUM_RUNS);
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
    printer.WriteScalar(testName + "ms", *params.m());
    printer.WriteScalar(testName + "freeRatio", freeRatio);

    WriteArray(printer, params.n(), testName + "ns");
    WriteArray(printer, params.ones(), testName + "ones");

    for (params.ones().reset(); !params.ones().end(); ++params.ones())
    {
        params.n().reset();
        auto result = Phd::TL_VENTester(CreateParams(), params, algo, rng, fgc, freeRatio).RunTest(NUM_RUNS);
        PrintResults(result);
        printer.WriteArray(testName + "one_" + std::to_string(*params.ones()) + "_result", result);
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
    const int HUGE_NUM_RUNS = 5000;
    const int EXTREMELY_HUGE_NUM_RUNS = 20000;

    std::random_device dev;
    std::shared_ptr<std::mt19937> rng(new std::mt19937(dev()));

    int algorithmVersion = 319;

    // run MATLAB ExportDataToCpp.m to create state machine encoding
    Phd::MatlabBackedAlgorithm* matlabAlgo(new Phd::MatlabBackedAlgorithm("../../../Matlab/+Cylinders/Data", algorithmVersion));
    RunTests(*matlabAlgo);

    std::shared_ptr<Phd::Algorithm> algo(matlabAlgo);
    std::shared_ptr<Phd::GridCreator> fgc(new Phd::FastGridCreator);

    int testNum = 0, startId = 11, endId = 11;

    // parameters: K = N_0, M, N, N_1
    // Test 1
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_k(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::AddParameter>(2, 19, 1),
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::AddParameter>(20, 5, 20),
                std::make_shared<Phd::NullParameter>(),
                }),
                testNum, HUGE_NUM_RUNS);

    // Test 2
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_n(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::AddParameter>(1, 10, 2),
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::AddParameter>(10, 10, 10),
                std::make_shared<Phd::NullParameter>(),
                }),
                testNum, HUGE_NUM_RUNS);

    // Test 3
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_ones(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::AddParameter>(20, 10, 5),
                std::make_shared<Phd::AddParameter>(1, 8, 3),
                }),
                testNum, HUGE_NUM_RUNS);

    // Test 4
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_ones(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(5),
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::AddParameter>(20, 10, 2),
                std::make_shared<Phd::AddParameter>(1, 8, 3),
                }),
                testNum, HUGE_NUM_RUNS);

    // Test 5
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_FreeRoad_n(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::NullParameter>(),
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::AddParameter>(80, 10, 5),
                std::make_shared<Phd::AddParameter>(20, 10, 4),
                }),
                0.2,
                testNum, EXTREMELY_HUGE_NUM_RUNS);

    // Test 6
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_FreeRoad_n(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::NullParameter>(),
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::AddParameter>(200, 10, 10),
                std::make_shared<Phd::AddParameter>(50, 10, 5),
                }),
                0.45,
                testNum, EXTREMELY_HUGE_NUM_RUNS);


    // Test 7
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_k(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::AddParameter>(10, 10, 5),
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::AddParameter>(100, 10, 20),
                std::make_shared<Phd::NullParameter>(),
                }),
                testNum, MEDIUM_NUM_RUNS);

    // Test 8
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_ones(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(10),
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::AddParameter>(100, 10, 10),
                std::make_shared<Phd::AddParameter>(5, 20, 5),
                }),
                testNum, MEDIUM_NUM_RUNS);

    // Test 9
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_ones(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::Parameter>(50),
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::AddParameter>(800, 5, 100),
                std::make_shared<Phd::AddParameter>(100, 20, 50),
                }),
                testNum, MEDIUM_NUM_RUNS);

    // Test 10
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_k(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::AddParameter>(10, 10, 5),
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::AddParameter>(400, 10, 50),
                std::make_shared<Phd::NullParameter>(),
                }),
                testNum, MEDIUM_NUM_RUNS);

    // Test 11
    std::cout << "Test " << ++testNum << '\n';
    if (ShouldRunThisTest(testNum, startId, endId))
        RunSimulation_k(rng, algorithmVersion, algo, fgc,
            Phd::Parameters
            ({
                std::make_shared<Phd::AddParameter>(1, 21, 1),
                std::make_shared<Phd::Parameter>(2),
                std::make_shared<Phd::AddParameter>(80, 10, 20),
                std::make_shared<Phd::NullParameter>(),
                }),
                testNum, MEDIUM_NUM_RUNS);
}

int main()
{
    RunSimulations();

    return 0;
}

