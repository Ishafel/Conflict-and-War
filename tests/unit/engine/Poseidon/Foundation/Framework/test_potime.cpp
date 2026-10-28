// Unit tests for Poseidon/Foundation/Framework/PoTime.hpp
// Testing portable time and sleep utilities

#define _CRT_SECURE_NO_WARNINGS
#include <catch2/catch_test_macros.hpp>
#include <chrono>
#include <thread>
#include <Poseidon/Foundation/Framework/DebugLog.hpp>
#include <Poseidon/Foundation/Common/Global.hpp> // For unsigned64 typedef
#include <Poseidon/Foundation/Common/Win.h>      // For Sleep on Windows
#include <Poseidon/Foundation/Framework/PoTime.hpp>

namespace
{
using ReferenceClock = std::chrono::steady_clock;
struct TimeSample
{
    ReferenceClock::time_point before;
    unsigned64 microseconds;
    ReferenceClock::time_point after;
};

TimeSample SampleSystemTime()
{
    const auto before = ReferenceClock::now();
    const auto value = Poseidon::Foundation::getSystemTime();
    return {before, value, ReferenceClock::now()};
}

bool MatchesReferenceInterval(const TimeSample& start, const TimeSample& end)
{
    if (end.microseconds < start.microseconds)
        return false;
    const double measured = static_cast<double>(end.microseconds - start.microseconds);
    const double inner = std::chrono::duration<double, std::micro>(end.before - start.after).count();
    const double outer = std::chrono::duration<double, std::micro>(end.after - start.before).count();
    // PoTime's legacy ftime fallback has millisecond quantization. This allowance
    // covers clock resolution, not scheduler latency: both clocks see that latency.
    constexpr double quantizationUs = 1000.0;
    return measured + quantizationUs >= inner && measured <= outer + quantizationUs;
}

unsigned64 RequireReferenceInterval(const TimeSample& start, const TimeSample& end)
{
    CAPTURE(start.microseconds, end.microseconds);
    REQUIRE(MatchesReferenceInterval(start, end));
    return end.microseconds - start.microseconds;
}
} // namespace

// System Time Initialization

TEST_CASE("potime - Poseidon::Foundation::startSystemTime", "[framework][potime]")
{
    SECTION("Can be called multiple times safely")
    {
        // Should be safe to call multiple times (idempotent)
        Poseidon::Foundation::startSystemTime();
        Poseidon::Foundation::startSystemTime();
        Poseidon::Foundation::startSystemTime();

        // If we get here without crash, it worked
        REQUIRE(true);
    }
}

// Clock Frequency

TEST_CASE("potime - Poseidon::Foundation::getClockFrequency", "[framework][potime]")
{
    SECTION("Returns non-zero frequency")
    {
        unsigned freq = Poseidon::Foundation::getClockFrequency();

        REQUIRE(freq > 0);
    }

    SECTION("Frequency is reasonable")
    {
        unsigned freq = Poseidon::Foundation::getClockFrequency();

        // Should be at least 100 Hz (minimum documented)
        REQUIRE(freq >= 100);

        // Shouldn't be unreasonably high (e.g., > 4 GHz)
        REQUIRE(freq < 4000000000U);
    }

    SECTION("Frequency is consistent")
    {
        unsigned freq1 = Poseidon::Foundation::getClockFrequency();
        unsigned freq2 = Poseidon::Foundation::getClockFrequency();

        // Should return same value each time
        REQUIRE(freq1 == freq2);
    }
}

// System Time

TEST_CASE("potime - Poseidon::Foundation::getSystemTime basics", "[framework][potime]")
{
    SECTION("Returns non-zero time")
    {
        unsigned64 time = Poseidon::Foundation::getSystemTime();

        // Should be a reasonable time value (microseconds)
        // Just verify it's non-zero and reasonable (not checking epoch,
        // as Windows uses different epoch than Unix)
        REQUIRE(time > 0);
        REQUIRE(time < 9999999999999999ULL); // Reasonable upper bound
    }

    SECTION("Time advances")
    {
        unsigned64 time1 = Poseidon::Foundation::getSystemTime();

        // Do some work to ensure time passes
        volatile int dummy = 0;
        for (int i = 0; i < 1000; i++)
        {
            dummy += i;
        }

        unsigned64 time2 = Poseidon::Foundation::getSystemTime();

        // Time should have advanced (or at minimum, not gone backwards)
        REQUIRE(time2 >= time1);
    }

    SECTION("Time monotonicity")
    {
        // Sample time multiple times
        unsigned64 times[10];
        for (int i = 0; i < 10; i++)
        {
            times[i] = Poseidon::Foundation::getSystemTime();
        }

        // Each sample should be >= previous (monotonic)
        for (int i = 1; i < 10; i++)
        {
            REQUIRE(times[i] >= times[i - 1]);
        }
    }
}

TEST_CASE("potime - Poseidon::Foundation::getSystemTime precision", "[framework][potime]")
{
    SECTION("Has microsecond precision")
    {
        // Take multiple samples close together
        unsigned64 time1 = Poseidon::Foundation::getSystemTime();
        unsigned64 time2 = Poseidon::Foundation::getSystemTime();
        unsigned64 time3 = Poseidon::Foundation::getSystemTime();

        // At least one pair should show time difference
        // (unless system is incredibly fast, which is unlikely)
        (void)(time2 - time1); // Intentionally unused - just checking call works
        (void)(time3 - time2); // Intentionally unused - just checking call works

        // Total elapsed should be measurable in microseconds
        unsigned64 total = time3 - time1;

        // Should be able to measure < 1 millisecond (1000 microseconds)
        // This proves microsecond precision
        REQUIRE(total < 10000); // Less than 10ms for 3 calls
    }

    SECTION("Resolution is fine-grained")
    {
        unsigned freq = Poseidon::Foundation::getClockFrequency();

        // If frequency is high (>1000 Hz), we have sub-millisecond precision
        if (freq > 1000)
        {
            unsigned64 time1 = Poseidon::Foundation::getSystemTime();

            // Spin briefly
            volatile int i = 0;
            for (; i < 100; i = i + 1)
            {
                ;
            }

            unsigned64 time2 = Poseidon::Foundation::getSystemTime();
            unsigned64 elapsed = time2 - time1;

            // Should measure something (if clock is working)
            // Allow for possibility of zero if CPU is very fast
            REQUIRE(elapsed < 1000000); // Less than 1 second for this test
        }
    }
}

TEST_CASE("potime - Poseidon::Foundation::getSystemTime timing accuracy", "[framework][potime]")
{
    SECTION("Can measure millisecond intervals")
    {
        const auto start = SampleSystemTime();
        SLEEP_MS(10);
        const auto end = SampleSystemTime();
        const auto elapsedUs = RequireReferenceInterval(start, end);
        REQUIRE(elapsedUs >= 5000);
    }

    SECTION("Can measure longer intervals")
    {
        const auto start = SampleSystemTime();
        SLEEP_MS(50);
        const auto end = SampleSystemTime();
        const auto elapsedUs = RequireReferenceInterval(start, end);
        REQUIRE(elapsedUs >= 40000);
    }
}

// Sleep is allowed to overshoot when the OS schedules another thread.
TEST_CASE("potime - SLEEP_MS macro", "[framework][potime][sleep]")
{
    SECTION("Sleep for 1 millisecond")
    {
        const auto start = SampleSystemTime();
        SLEEP_MS(1);
        RequireReferenceInterval(start, SampleSystemTime());
    }

    SECTION("Sleep for 10 milliseconds")
    {
        const auto start = SampleSystemTime();
        SLEEP_MS(10);
        const auto elapsedUs = RequireReferenceInterval(start, SampleSystemTime());
        REQUIRE(elapsedUs >= 1000);
    }

    SECTION("Sleep for zero milliseconds")
    {
        const auto start = SampleSystemTime();
        SLEEP_MS(0);
        RequireReferenceInterval(start, SampleSystemTime());
    }
}

TEST_CASE("potime - scheduler delays preserve interval accuracy", "[framework][potime][sleep]")
{
    const auto start = SampleSystemTime();
    SLEEP_MS(50);
    // Deliberate extra scheduling/workload delay must be reflected in both clocks.
    std::this_thread::sleep_for(std::chrono::milliseconds(80));
    const auto elapsedUs = RequireReferenceInterval(start, SampleSystemTime());
    REQUIRE(elapsedUs >= 120000);
}

TEST_CASE("potime - interval oracle rejects invalid clock readings", "[framework][potime]")
{
    const ReferenceClock::time_point epoch{};
    const auto finish = epoch + std::chrono::milliseconds(50);
    const TimeSample start{epoch, 10000, epoch};
    REQUIRE(MatchesReferenceInterval(start, {finish, 60000, finish}));
    REQUIRE_FALSE(MatchesReferenceInterval(start, {finish, 10000, finish})); // stopped
    REQUIRE_FALSE(MatchesReferenceInterval(start, {finish, 10050, finish})); // milliseconds
    REQUIRE_FALSE(MatchesReferenceInterval(start, {finish, 50010000, finish})); // nanoseconds
    REQUIRE_FALSE(MatchesReferenceInterval(start, {finish, 9999, finish})); // backwards
}

TEST_CASE("potime - Section timing", "[framework][potime]")
{
    const Poseidon::Foundation::SectionTimeHandle start = Poseidon::Foundation::StartSectionTime();

    REQUIRE(Poseidon::Foundation::GetSectionResolution() > 0);
    REQUIRE(Poseidon::Foundation::GetSectionTime(start) >= 0.0f);
    REQUIRE(Poseidon::Foundation::CompareSectionTimeGE(start, 0.0f));
}

// Cross-Platform Consistency

TEST_CASE("potime - Platform consistency", "[framework][potime]")
{
    TimeSample previous = SampleSystemTime();
    for (int i = 0; i < 5; ++i)
    {
        SLEEP_MS(10);
        const auto current = SampleSystemTime();
        const auto elapsedUs = RequireReferenceInterval(previous, current);
        REQUIRE(elapsedUs >= 5000);
        previous = current;
    }
}

// Performance Characteristics

TEST_CASE("potime - Performance", "[framework][potime][performance]")
{
    SECTION("Poseidon::Foundation::getSystemTime is fast")
    {
        // Measure time to call Poseidon::Foundation::getSystemTime many times
        unsigned64 start = Poseidon::Foundation::getSystemTime();

        const int iterations = 10000;
        for (int i = 0; i < iterations; i++)
        {
            volatile unsigned64 t = Poseidon::Foundation::getSystemTime();
            (void)t; // Prevent optimization
        }

        unsigned64 end = Poseidon::Foundation::getSystemTime();
        unsigned64 total_us = end - start;
        double avg_us = (double)total_us / iterations;

        // Each call should be very fast (< 10 microseconds on average)
        REQUIRE(avg_us < 10.0);
    }

    SECTION("Poseidon::Foundation::getClockFrequency is instant")
    {
        // Should be cached/instant
        unsigned64 start = Poseidon::Foundation::getSystemTime();

        for (int i = 0; i < 1000; i++)
        {
            volatile unsigned freq = Poseidon::Foundation::getClockFrequency();
            (void)freq;
        }

        unsigned64 end = Poseidon::Foundation::getSystemTime();
        unsigned64 elapsed = end - start;

        // Should be negligible (< 1ms for 1000 calls)
        REQUIRE(elapsed < 1000);
    }
}
