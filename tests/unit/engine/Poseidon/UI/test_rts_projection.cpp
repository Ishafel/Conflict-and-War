#include <Poseidon/UI/Controls/RTSProjection.hpp>
#include <catch2/catch_test_macros.hpp>
#include <catch2/catch_approx.hpp>
#include <limits>

TEST_CASE("RTS ray inverts perspective at center and corners", "[ui][rts]")
{
    const auto center = Poseidon::RTS::ViewRay(640, 360, 640, 360, 640, 360, 0.8f, 0.45f);
    REQUIRE(center);
    CHECK((*center)[0] == 0);
    CHECK((*center)[1] == 0);
    CHECK((*center)[2] == 1);
    const auto corner = Poseidon::RTS::ViewRay(0, 0, 640, 360, 640, 360, 0.8f, 0.45f);
    REQUIRE(corner);
    CHECK((*corner)[0] == Catch::Approx(-0.8f));
    CHECK((*corner)[1] == Catch::Approx(0.45f));
}

TEST_CASE("RTS ray respects offset world rectangle and rejects bars", "[ui][rts]")
{
    // A 960x720 world is centered in a 1280x720 window. UI coordinates
    // must not accidentally be interpreted as normalized world coordinates.
    CHECK_FALSE(Poseidon::RTS::ViewRay(100, 360, 640, 360, 480, 360, 1, 0.75f));
    const auto edge = Poseidon::RTS::ViewRay(1120, 720, 640, 360, 480, 360, 1, 0.75f);
    REQUIRE(edge);
    CHECK((*edge)[0] == Catch::Approx(1));
    CHECK((*edge)[1] == Catch::Approx(-0.75f));
    CHECK_FALSE(Poseidon::RTS::ViewRay(640, 360, 640, 360, 0, 360, 1, 1));
    CHECK_FALSE(Poseidon::RTS::ViewRay(std::numeric_limits<float>::quiet_NaN(), 360, 640, 360, 480, 360, 1, 1));
}
