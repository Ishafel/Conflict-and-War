#include <Poseidon/UI/Controls/RTSViewport.hpp>
#include <Poseidon/UI/Controls/RTSProjection.hpp>
#include <Poseidon/World/World.hpp>
#include <Poseidon/World/Scene/Scene.hpp>
#include <Poseidon/World/Scene/Camera/Camera.hpp>
#include <Poseidon/World/Terrain/Landscape.hpp>
#include <Poseidon/Graphics/Core/Engine.hpp>
#include <Poseidon/Core/resincl.hpp>
#include <Poseidon/Core/Application.hpp>
#include <Evaluator/express.hpp>
#include <SDL3/SDL_keyboard.h>
#include <SDL3/SDL_keycode.h>
#include <SDL3/SDL_timer.h>
#include <SDL3/SDL_video.h>
#include <algorithm>
#include <cmath>

using namespace Poseidon;

namespace
{
int CameraKeyIndex(unsigned key)
{
    // SDL keycodes follow the active layout (e.g. Cyrillic В on physical D).
    // RTS camera movement follows physical keys on every keyboard layout.
    switch (SDL_GetScancodeFromKey(SDL_Keycode(key), nullptr))
    {
        case SDL_SCANCODE_LEFT: return 0;
        case SDL_SCANCODE_RIGHT: return 1;
        case SDL_SCANCODE_UP: return 2;
        case SDL_SCANCODE_DOWN: return 3;
        case SDL_SCANCODE_W: return 4;
        case SDL_SCANCODE_A: return 5;
        case SDL_SCANCODE_S: return 6;
        case SDL_SCANCODE_D: return 7;
        case SDL_SCANCODE_HOME: return 8;
        default: return -1;
    }
}
}

bool RTSViewport::OnKeyDown(unsigned key, unsigned, unsigned)
{
    const int index = CameraKeyIndex(key);
    if (index < 0)
        return false;
    _keys[index] = true;
    if (index == 8)
        CameraInput(0, 0, 0, true);
    return true;
}

bool RTSViewport::OnKeyUp(unsigned key, unsigned, unsigned)
{
    const int index = CameraKeyIndex(key);
    if (index < 0)
        return false;
    _keys[index] = false;
    return true;
}

RTSViewport::RTSViewport(ControlsContainer* parent, int idc, const ParamEntry& cls) : CStatic(parent, idc, cls)
{
    _type = CT_RTS_VIEWPORT;
    EnableCtrl(true);
    _click = cls >> "onWorldClick";
    _cameraInput = cls >> "onCameraInput";
    if (const auto* selection = cls.FindEntry("selectionPosition"))
        _selection = *selection;
}

void RTSViewport::Click(float x, float y, int button)
{
    if (!IsInside(x, y) || !GWorld || !GEngine || !GLandscape || !GWorld->GetScene() ||
        !GWorld->GetScene()->GetCamera() || _click.GetLength() == 0)
        return;
    Point2DAbs pixel;
    GEngine->Convert(pixel, Point2DFloat(x, y));
    const Camera& camera = *GWorld->GetScene()->GetCamera();
    const Matrix4& p = camera.Projection();
    const auto view = RTS::ViewRay(pixel.x, pixel.y, p(0, 2), p(1, 2), p(0, 0), -p(1, 1),
                                   camera.Left(), camera.Top());
    if (!view)
        return;
    Vector3 ray = camera.DirectionModelToWorld(Vector3((*view)[0], (*view)[1], (*view)[2])).Normalized();
    Vector3 hit;
    bool sea = false;
    constexpr float range = 5000.0f;
    const float intersection = GLandscape->IntersectWithGroundOrSea(&hit, sea, camera.Position(), ray, 0, range);
    if (!std::isfinite(intersection) || intersection < 0 || intersection > range ||
        !std::isfinite(hit.X()) || !std::isfinite(hit.Y()) || !std::isfinite(hit.Z()))
        return;
    GameState* state = GWorld->GetGameState();
    GameValue position = state->CreateGameValue(GameArray);
    GameArrayType& pos = position;
    pos.Add(hit.X());
    pos.Add(hit.Z());
    pos.Add(0.0f); // public script positions use [X,Z,ATL]
    GameVarSpace vars;
    state->BeginContext(&vars);
    state->VarSetLocal("_pos", position, true);
    state->VarSetLocal("_button", float(button), true);
    state->VarSetLocal("_sea", sea, true);
    state->Execute(_click);
    state->EndContext();
}

void RTSViewport::CameraInput(float panX, float panY, float zoom, bool home)
{
    if (!GWorld || _cameraInput.GetLength() == 0)
        return;
    GameState* state = GWorld->GetGameState();
    GameVarSpace vars;
    state->BeginContext(&vars);
    state->VarSetLocal("_panX", panX, true);
    state->VarSetLocal("_panY", panY, true);
    state->VarSetLocal("_zoom", zoom, true);
    state->VarSetLocal("_home", home, true);
    state->Execute(_cameraInput);
    state->EndContext();
}

void RTSViewport::DrawSelection()
{
    if (_selection.GetLength() == 0 || !GWorld || !GEngine || !GLandscape || !GWorld->GetScene() ||
        !GWorld->GetScene()->GetCamera())
        return;
    GameState* state = GWorld->GetGameState();
    GameVarSpace vars;
    state->BeginContext(&vars);
    GameValue value = state->EvaluateMultiple(_selection);
    state->EndContext();
    if (value.GetType() != GameArray)
        return;
    const GameArrayType& position = value;
    if (position.Size() != 3 || position[0].GetType() != GameScalar || position[1].GetType() != GameScalar)
        return;
    const float x = GameScalarType(position[0]), z = GameScalarType(position[1]);
    const Camera& camera = *GWorld->GetScene()->GetCamera();
    const Matrix4 inverse = camera.GetInvTransform();
    const Matrix4& projection = camera.Projection();
    Point2DAbs tl;
    GEngine->Convert(tl, Point2DFloat(_x, _y));
    const Rect2DAbs clip(tl, _w * GEngine->Width2D(), _h * GEngine->Height2D());
    const PackedColor color(Color(0.25f, 1.0f, 0.55f, 1.0f));
    Point2DAbs previous;
    bool havePrevious = false;
    constexpr int segments = 20;
    for (int i = 0; i <= segments; ++i)
    {
        const float angle = i * (6.283185307f / segments);
        const float px = x + 1.6f * std::cos(angle), pz = z + 1.6f * std::sin(angle);
        const Vector3 view = inverse.FastTransform(Vector3(px, GLandscape->SurfaceYAboveWater(px, pz) + 0.15f, pz));
        if (view.Z() <= camera.Near())
            return;
        const Point2DAbs point(projection(0, 2) + projection(0, 0) * view.X() / (view.Z() * camera.Left()),
                               projection(1, 2) + projection(1, 1) * view.Y() / (view.Z() * camera.Top()));
        if (havePrevious)
            GEngine->DrawLine(Line2DAbs(previous.x, previous.y, point.x, point.y), color, color, clip);
        previous = point;
        havePrevious = true;
    }
}

void RTSViewport::OnDraw(float /*alpha*/)
{
    DrawSelection();
    // World has already rendered; draw no opaque surface over it. Polling here
    // keeps camera movement available even while a sidebar card has keyboard focus.
    const auto now = SDL_GetTicks();
    const float dt = _lastFrame ? std::min(float(now - _lastFrame) / 1000.0f, 0.05f) : 0.0f;
    _lastFrame = now;
    // Respect the engine's explicit keep-focus mode as the event pump does.
    // Normal background windows clear held keys to avoid a stuck camera.
    if (!SDL_GetKeyboardFocus() && !(GApp && GApp->m_keepFocus))
    {
        _keys.fill(false);
        return;
    }
    const float dx = float(_keys[7] || _keys[1]) - float(_keys[5] || _keys[0]);
    const float dy = float(_keys[4] || _keys[2]) - float(_keys[6] || _keys[3]);
    const bool home = _keys[8];
    if (dx != 0 || dy != 0 || home)
        CameraInput(dx * dt, dy * dt, 0, home);
}
