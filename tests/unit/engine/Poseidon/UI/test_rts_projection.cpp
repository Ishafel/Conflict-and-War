#include <Poseidon/UI/Controls/RTSProjection.hpp>
#include <catch2/catch_test_macros.hpp>
#include <catch2/catch_approx.hpp>
#include <limits>
#include <Poseidon/Graphics/Rendering/WholeObjectBlend.hpp>
#include <Poseidon/Graphics/Rendering/BuildRenderPassDescriptor.hpp>

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

TEST_CASE("RTS drag bounds support reversed drags and small screen targets", "[ui][rts]")
{
    const auto area = Poseidon::RTS::DragRect(900, 600, 100, 80);
    CHECK(area.Contains(100, 80));
    CHECK(area.Contains(900, 600));
    CHECK_FALSE(area.Contains(950, 600));
    CHECK(area.Intersects({895, 590, 905, 610}));
    CHECK_FALSE(area.Intersects({910, 590, 920, 610}));
}

TEST_CASE("RTS production sweep reaches rectangular card edges clockwise", "[ui][rts]")
{
    const auto top = Poseidon::RTS::CardEdge(0);
    const auto right = Poseidon::RTS::CardEdge(0.25f);
    const auto bottom = Poseidon::RTS::CardEdge(0.5f);
    CHECK(top[0] == Catch::Approx(0.5f));
    CHECK(top[1] == Catch::Approx(0).margin(0.00001f));
    CHECK(right[0] == Catch::Approx(1));
    CHECK(right[1] == Catch::Approx(0.5f));
    CHECK(bottom[0] == Catch::Approx(0.5f));
    CHECK(bottom[1] == Catch::Approx(1));
}

TEST_CASE("RTS whole object ghost alpha reaches opaque material sections", "[ui][rts]")
{
    using namespace Poseidon::render;
    LegacySpec ghost{};
    ghost.routing = Routing::IsColored | Routing::IsAlphaOrdered;
    ghost.backend = Backend::IsAlpha;
    const int object = int(MergeLegacy(ghost));
    REQUIRE(UsesWholeObjectBlend(object));
    const auto inherited = SplitLegacy(InheritWholeObjectBlend(0, object));
    const auto descriptor = BuildRenderPassDescriptor(inherited);
    CHECK(descriptor.blend == BlendMode::AlphaBlend);
    CHECK(Has(inherited.backend, Backend::NoZWrite));
    CHECK(InheritWholeObjectBlend(0, int(MergeLegacy(LegacySpec{}))) == 0);
    ghost.routing = Routing::IsColored;
    CHECK_FALSE(UsesWholeObjectBlend(int(MergeLegacy(ghost))));
}
