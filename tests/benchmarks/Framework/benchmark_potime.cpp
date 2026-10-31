#include <catch2/benchmark/catch_benchmark.hpp>
#include <catch2/catch_test_macros.hpp>
#include <Poseidon/Core/BuildInfo.hpp>
#include <Poseidon/Foundation/Framework/PoTime.hpp>
#include <iostream>

// Catch2 calibrates, warms up and samples each operation using its independent
// benchmark clock. Returning the value keeps the measured call observable.
TEST_CASE("PoTime operation costs", "[benchmark][potime]")
{
    Poseidon::Foundation::startSystemTime();
    std::cout << "PoTime benchmark: platform=" << CWR_BENCHMARK_PLATFORM << " pointer_bits=" << sizeof(void*) * 8
              << " compiler=" << CWR_BENCHMARK_COMPILER
              << " build=" << Poseidon::BuildInfo::BuildType << " revision=" << Poseidon::BuildInfo::GitSha
              << " clock_hz=" << Poseidon::Foundation::getClockFrequency() << '\n';
    REQUIRE(Poseidon::Foundation::getClockFrequency() > 0);

    BENCHMARK("getSystemTime")
    {
        return Poseidon::Foundation::getSystemTime();
    };
    BENCHMARK("getClockFrequency")
    {
        return Poseidon::Foundation::getClockFrequency();
    };
}
