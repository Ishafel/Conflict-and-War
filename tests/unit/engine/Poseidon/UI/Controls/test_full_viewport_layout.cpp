#include <catch2/catch_approx.hpp>
#include <catch2/catch_test_macros.hpp>

#include <Poseidon/Core/resincl.hpp>
#include <Poseidon/UI/Controls/UIControls.hpp>

using namespace Poseidon;

namespace
{
struct RestoreAspect
{
    AspectSettings previous;
    RestoreAspect() { GEngine->GetAspectSettings(previous); }
    ~RestoreAspect() { GEngine->SetAspectSettings(previous); }
};

class LayoutControl final : public Control
{
  public:
    LayoutControl(ControlsContainer* parent, int idc, float x, float w) : Control(parent, CT_STATIC, idc, 0, x, 0, w, 1)
    {
    }
    void OnDraw(float) override {}
};

class LayoutContainer final : public ControlsContainer
{
  public:
    explicit LayoutContainer(bool fullViewport) : ControlsContainer(nullptr)
    {
        _fullViewport = fullViewport;
        _controlsBackground.Add(new LayoutControl(this, 9001, 0.76f, 0.24f));
        _controlsForeground.Add(new LayoutControl(this, 9002, 0, 0.76f));
    }
};

void CheckPhysicalBounds(Control& control, float left, float right)
{
    Point2DAbs a, b;
    GEngine->Convert(a, Point2DFloat(control.X(), control.Y()));
    GEngine->Convert(b, Point2DFloat(control.X() + control.W(), control.Y() + control.H()));
    CHECK(a.x == Catch::Approx(left * GEngine->Width()).margin(0.01f));
    CHECK(b.x == Catch::Approx(right * GEngine->Width()).margin(0.01f));
    CHECK(a.y == Catch::Approx(0).margin(0.01f));
    CHECK(b.y == Catch::Approx(GEngine->Height()).margin(0.01f));
}
} // namespace

TEST_CASE("Full viewport dialog keeps sidebar and input at physical edges through band changes",
          "[ui][full-viewport][rts]")
{
    REQUIRE(GEngine);
    RestoreAspect restore;
    GEngine->SetAspectSettings(AspectSettings{});
    LayoutContainer dialog(true);
    auto* panel = dynamic_cast<Control*>(dialog.GetCtrl(9001));
    auto* world = dynamic_cast<Control*>(dialog.GetCtrl(9002));
    REQUIRE(panel);
    REQUIRE(world);
    // Include controls that are not currently visible/enabled: they must remain
    // correctly placed when their state changes after resizing.
    panel->ShowCtrl(false);
    panel->EnableCtrl(false);
    for (int repeat = 0; repeat < 5; ++repeat)
    {
        for (float inset : {0.0f, 0.14f, 0.3125f, 0.0f})
        {
            AspectSettings band{};
            band.uiTopLeftX = inset;
            band.uiBottomRightX = 1 - inset;
            band.uiTopLeftY = inset * 0.5f;
            band.uiBottomRightY = 1 - inset * 0.5f;
            GEngine->SetAspectSettings(band);
            REQUIRE(dialog.GetCtrl(9001) == panel); // synchronizes before queries/input
            CheckPhysicalBounds(*panel, 0.76f, 1);
            CheckPhysicalBounds(*world, 0, 0.76f);
            Point2DFloat pointer;
            GEngine->Convert(pointer, Point2DAbs(0.9f * GEngine->Width(), 0.5f * GEngine->Height()));
            CHECK(panel->IsInside(pointer.x, pointer.y));
            CHECK_FALSE(world->IsInside(pointer.x, pointer.y));
        }
    }
    CHECK(panel->X() == Catch::Approx(0.76f));
    CHECK(panel->W() == Catch::Approx(0.24f));
}

TEST_CASE("Ordinary dialogs retain safe-area layout", "[ui][full-viewport]")
{
    REQUIRE(GEngine);
    RestoreAspect restore;
    AspectSettings band{};
    band.uiTopLeftX = 0.125f;
    band.uiBottomRightX = 0.875f;
    GEngine->SetAspectSettings(band);
    LayoutContainer dialog(false);
    auto* panel = dynamic_cast<Control*>(dialog.GetCtrl(9001));
    REQUIRE(panel);
    CHECK(panel->X() == Catch::Approx(0.76f));
    CHECK(panel->W() == Catch::Approx(0.24f));
}
