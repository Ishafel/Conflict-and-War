#include <Poseidon/UI/Controls/RTSViewport.hpp>
#include <Poseidon/UI/Controls/UIControls.hpp>
#include <Poseidon/UI/Controls/RTSProjection.hpp>
#include <Poseidon/World/World.hpp>
#include <Poseidon/World/Scene/Scene.hpp>
#include <Poseidon/World/Scene/Camera/Camera.hpp>
#include <Poseidon/World/Terrain/Landscape.hpp>
#include <Poseidon/Graphics/Core/Engine.hpp>
#include <Poseidon/Core/resincl.hpp>
#include <Poseidon/Core/Application.hpp>
#include <Evaluator/express.hpp>
#include <Poseidon/Game/Commands/GameStateExtCommon.hpp>
#include <Poseidon/World/Scene/ObjectClasses.hpp>
#include <Poseidon/Input/InputSubsystem.hpp>
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
        case SDL_SCANCODE_LEFT:
            return 0;
        case SDL_SCANCODE_RIGHT:
            return 1;
        case SDL_SCANCODE_UP:
            return 2;
        case SDL_SCANCODE_DOWN:
            return 3;
        case SDL_SCANCODE_W:
            return 4;
        case SDL_SCANCODE_A:
            return 5;
        case SDL_SCANCODE_S:
            return 6;
        case SDL_SCANCODE_D:
            return 7;
        case SDL_SCANCODE_HOME:
            return 8;
        default:
            return -1;
    }
}
} // namespace

bool RTSViewport::OnKeyDown(unsigned key, unsigned, unsigned)
{
    const auto scan = SDL_GetScancodeFromKey(SDL_Keycode(key), nullptr);
    if (scan == SDL_SCANCODE_LCTRL || scan == SDL_SCANCODE_RCTRL)
    {
        _control[scan == SDL_SCANCODE_RCTRL] = true;
        return true;
    }
    const int number = scan == SDL_SCANCODE_0 ? 0 :
                       (scan >= SDL_SCANCODE_1 && scan <= SDL_SCANCODE_9 ? int(scan - SDL_SCANCODE_1) + 1 : -1);
    if (number >= 0 && _controlGroup.GetLength() && GWorld)
    {
        if (!_digits[number])
        {
            _digits[number] = true;
            GameState* state = GWorld->GetGameState();
            GameVarSpace vars;
            state->BeginContext(&vars);
            state->VarSetLocal("_number", float(number), true);
            state->VarSetLocal("_assign", _control[0] || _control[1], true);
            state->Execute(_controlGroup);
            state->EndContext();
        }
        return true;
    }
    const int index = CameraKeyIndex(key);
    if (index < 0)
        return false;
    _keys[index] = true;
    if (index == 8)
    {
        _motion.Reset();
        CameraInput(0, 0, 0, true);
    }
    return true;
}

bool RTSViewport::OnKeyUp(unsigned key, unsigned, unsigned)
{
    const auto scan = SDL_GetScancodeFromKey(SDL_Keycode(key), nullptr);
    if (scan == SDL_SCANCODE_LCTRL || scan == SDL_SCANCODE_RCTRL)
    {
        _control[scan == SDL_SCANCODE_RCTRL] = false;
        return true;
    }
    const int number = scan == SDL_SCANCODE_0 ? 0 :
                       (scan >= SDL_SCANCODE_1 && scan <= SDL_SCANCODE_9 ? int(scan - SDL_SCANCODE_1) + 1 : -1);
    if (number >= 0)
    {
        _digits[number] = false;
        return true;
    }
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
    const auto optionalText = [&](const char* name) -> RString
    {
        if (const auto* value = cls.FindEntry(name))
            return *value;
        return RString();
    };
    _units = optionalText("selectableUnits");
    _controlGroup = optionalText("onControlGroup");
    _moveFeedback = optionalText("moveFeedback");
    _healthUnits = optionalText("healthUnits");
    _boxSelect = optionalText("onBoxSelect");
    _placementActive = optionalText("placementActive");
    _placementValid = optionalText("placementValid");
    _placementClass = optionalText("placementClass");
    _placementClassExpression = optionalText("placementClassExpression");
    _resourceNodes = optionalText("resourceNodes");
    _previewClear = optionalText("onPreviewHidden");
    _cameraResetToken = optionalText("cameraResetToken");
    _cameraInput = cls >> "onCameraInput";
    if (const auto* selection = cls.FindEntry("selectionPosition"))
        _selection = *selection;
}

GameValue RTSViewport::Evaluate(RString expression) const
{
    if (!GWorld || expression.GetLength() == 0)
        return GameValue();
    GameState* state = GWorld->GetGameState();
    GameVarSpace vars;
    state->BeginContext(&vars);
    GameValue result = state->EvaluateMultiple(expression);
    state->EndContext();
    return result;
}

bool RTSViewport::TerrainHit(float x, float y, Vector3& hit, bool& sea)
{
    if (!IsInside(x, y) || !GWorld || !GEngine || !GLandscape || !GWorld->GetScene() ||
        !GWorld->GetScene()->GetCamera())
        return false;
    Point2DAbs pixel;
    GEngine->Convert(pixel, Point2DFloat(x, y));
    const Camera& camera = *GWorld->GetScene()->GetCamera();
    const Matrix4& p = camera.Projection();
    const auto view = RTS::ViewRay(pixel.x, pixel.y, p(0, 2), p(1, 2), p(0, 0), -p(1, 1), camera.Left(), camera.Top());
    if (!view)
        return false;
    const Vector3 ray = camera.DirectionModelToWorld(Vector3((*view)[0], (*view)[1], (*view)[2])).Normalized();
    const float distance = GLandscape->IntersectWithGroundOrSea(&hit, sea, camera.Position(), ray, 0, 5000);
    return std::isfinite(distance) && distance >= 0 && distance <= 5000 && std::isfinite(hit.X()) &&
           std::isfinite(hit.Y()) && std::isfinite(hit.Z());
}

std::optional<RTS::ScreenRect> RTSViewport::UnitRect(Object* unit) const
{
    if (!unit || unit->IsObjectHidden() || !unit->GetShape() || !GWorld || !GEngine || !GWorld->GetScene() || !GWorld->GetScene()->GetCamera())
        return std::nullopt;
    const Camera& camera = *GWorld->GetScene()->GetCamera();
    const auto& p = camera.Projection();
    const Matrix4 inverse = camera.GetInvTransform();
    RTS::ScreenRect rect{1e9f, 1e9f, -1e9f, -1e9f};
    const Vector3* bounds = unit->GetShape()->MinMax();
    for (int i = 0; i < 8; ++i)
    {
        const Vector3 world =
            unit->PositionModelToWorld(Vector3(bounds[i & 1].X(), bounds[(i >> 1) & 1].Y(), bounds[(i >> 2) & 1].Z()));
        const Vector3 view = inverse.FastTransform(world);
        if (view.Z() <= camera.Near())
            return std::nullopt;
        const float x = p(0, 2) + p(0, 0) * view.X() / (view.Z() * camera.Left());
        const float y = p(1, 2) + p(1, 1) * view.Y() / (view.Z() * camera.Top());
        if (!std::isfinite(x) || !std::isfinite(y))
            return std::nullopt;
        rect.left = std::min(rect.left, x);
        rect.right = std::max(rect.right, x);
        rect.top = std::min(rect.top, y);
        rect.bottom = std::max(rect.bottom, y);
    }
    // A minimum target in physical pixels makes small distant infantry clickable.
    rect.left -= 6;
    rect.right += 6;
    rect.top -= 6;
    rect.bottom += 6;
    return rect;
}

bool RTSViewport::AcceptsCommandInput() const
{
    return _parent && !_parent->Child() && !_parent->GetMsgBox() &&
           !(_parent->GetFocused() && _parent->GetFocused()->WantsTextInput());
}

void RTSViewport::ResetInput()
{
    _pressed = false;
    _keys.fill(false);
    _digits.fill(false);
    _control.fill(false);
    _motion.Reset();
    _lastFrame = 0;
}

void RTSViewport::SetPos(float x, float y, float w, float h)
{
    // A resize changes logical coordinates; cancel a gesture instead of issuing
    // a click/box-select between points from different UI coordinate frames.
    ResetInput();
    CStatic::SetPos(x, y, w, h);
}

void RTSViewport::OnLButtonDown(float x, float y)
{
    if (!IsInside(x, y))
        return;
    _pressed = true;
    _downX = _pointerX = x;
    _downY = _pointerY = y;
}

void RTSViewport::OnMouseMove(float x, float y, bool)
{
    _pointerX = std::clamp(x, _x, _x + _w);
    _pointerY = std::clamp(y, _y, _y + _h);
}

void RTSViewport::OnLButtonUp(float x, float y)
{
    if (!_pressed || !GEngine)
        return;
    _pressed = false;
    OnMouseMove(x, y);
    const float dx = (_pointerX - _downX) * GEngine->Width2D(), dy = (_pointerY - _downY) * GEngine->Height2D();
    const GameValue placing = Evaluate(_placementActive);
    if (dx * dx + dy * dy > 25 && placing.GetType() == GameBool && !static_cast<GameBoolType>(placing))
        BoxSelect(_pointerX, _pointerY);
    else if (IsInside(x, y))
        Click(x, y, 0);
}

void RTSViewport::Click(float x, float y, int button)
{
    if (_click.GetLength() == 0)
        return;
    Vector3 hit;
    bool sea = false;
    if (!TerrainHit(x, y, hit, sea))
        return;
    Object* picked = nullptr;
    if (button == 0)
    {
        Point2DAbs pixel;
        GEngine->Convert(pixel, Point2DFloat(x, y));
        GameValue units = Evaluate(_units);
        float best = 1e30f;
        if (units.GetType() == GameArray)
        {
            const GameArrayType& list = units;
            for (int i = 0; i < list.Size(); ++i)
            {
                Object* unit = GetObject(list[i]);
                const auto rect = UnitRect(unit);
                if (rect && rect->Contains(pixel.x, pixel.y))
                {
                    const float dx = pixel.x - (rect->left + rect->right) * 0.5f,
                                dy = pixel.y - (rect->top + rect->bottom) * 0.5f;
                    if (dx * dx + dy * dy < best)
                    {
                        best = dx * dx + dy * dy;
                        picked = unit;
                    }
                }
            }
        }
    }
    GameState* state = GWorld->GetGameState();
    GameValue position = state->CreateGameValue(GameArray);
    GameArrayType& pos = position;
    pos.Add(hit.X());
    pos.Add(hit.Z());
    pos.Add(0.0f);
    GameVarSpace vars;
    state->BeginContext(&vars);
    state->VarSetLocal("_pos", position, true);
    state->VarSetLocal("_button", float(button), true);
    state->VarSetLocal("_sea", sea, true);
    state->VarSetLocal("_unit", GameValueExt(picked), true);
    state->Execute(_click);
    state->EndContext();
}

void RTSViewport::BoxSelect(float x, float y)
{
    if (!GWorld || _boxSelect.GetLength() == 0)
        return;
    Point2DAbs a, b;
    GEngine->Convert(a, Point2DFloat(_downX, _downY));
    GEngine->Convert(b, Point2DFloat(x, y));
    const auto area = RTS::DragRect(a.x, a.y, b.x, b.y);
    GameState* state = GWorld->GetGameState();
    GameValue selected = state->CreateGameValue(GameArray);
    GameArrayType& selectedList = selected;
    GameValue units = Evaluate(_units);
    if (units.GetType() == GameArray)
    {
        const GameArrayType& list = units;
        for (int i = 0; i < list.Size(); ++i)
        {
            const auto rect = UnitRect(GetObject(list[i]));
            if (rect && area.Intersects(*rect))
                selectedList.Add(list[i]);
        }
    }
    GameVarSpace vars;
    state->BeginContext(&vars);
    state->VarSetLocal("_units", selected, true);
    state->Execute(_boxSelect);
    state->EndContext();
}

void RTSViewport::UpdatePreview(float x, float y)
{
    const GameValue active = Evaluate(_placementActive);
    RString model = _placementClass;
    if (_placementClassExpression.GetLength())
    {
        const GameValue value = Evaluate(_placementClassExpression);
        if (value.GetType() == GameString)
            model = GameStringType(value);
    }
    if (model != _previewModel)
    {
        _previewCandidate = nullptr;
        _ghost = nullptr;
        _previewModel = model;
    }
    Vector3 hit;
    bool sea = false;
    if (active.GetType() != GameBool || !static_cast<GameBoolType>(active) || !TerrainHit(x, y, hit, sea) ||
        model.GetLength() == 0)
    {
        if (_previewCandidate)
            Evaluate(_previewClear);
        _ghost = nullptr;
        _previewCandidate = nullptr;
        return;
    }
    if (!_previewCandidate)
    {
        _previewCandidate = NewNonAIVehicle(model);
        if (!_previewCandidate || !_previewCandidate->GetShape())
            return;
        _ghost = new ObjectColored(_previewCandidate->GetShape(), -1);
        _ghost->SetSpecial(IsColored | IsAlpha | IsAlphaFog | NoZWrite | NoShadow | IsAlphaOrdered);
    }
    // Match SQF setPos: the supplied Y is ATL, then PlaceOnSurface applies
    // the building's land-contact geometry. A raw terrain Y buries the model.
    Matrix4 placement(M4Identity);
    placement.SetPosition(Vector3(hit.X(), 0, hit.Z()));
    if (auto* vehicle = dyn_cast<EntityAI>(_previewCandidate.GetRef()))
        vehicle->PlaceOnSurface(placement);
    else
        placement.SetPosition(hit);
    _previewCandidate->SetTransform(placement);
    GameState* state = GWorld->GetGameState();
    GameValue position = state->CreateGameValue(GameArray);
    GameArrayType& pos = position;
    pos.Add(hit.X());
    pos.Add(hit.Z());
    pos.Add(0.0f);
    GameVarSpace vars;
    state->BeginContext(&vars);
    state->VarSetLocal("_pos", position, true);
    state->VarSetLocal("_sea", sea, true);
    state->VarSetLocal("_candidate", GameValueExt(_previewCandidate.GetRef()), true);
    GameValue valid = state->EvaluateMultiple(_placementValid);
    state->EndContext();
    const bool allowed = valid.GetType() == GameBool && static_cast<GameBoolType>(valid);
    _ghost->SetTransform(_previewCandidate->Transform());
    _ghost->SetConstantColor(
        PackedColor(allowed ? Color(0.15f, 1.0f, 0.35f, 0.28f) : Color(1.0f, 0.12f, 0.08f, 0.28f)));
    GLandscape->ShowObject(_ghost);
}

void RTSViewport::DrawDrag()
{
    if (!_pressed || !GEngine)
        return;
    const float dx = (_pointerX - _downX) * GEngine->Width2D(), dy = (_pointerY - _downY) * GEngine->Height2D();
    if (dx * dx + dy * dy <= 25)
        return;
    Point2DAbs a, b, tl;
    GEngine->Convert(a, Point2DFloat(_downX, _downY));
    GEngine->Convert(b, Point2DFloat(_pointerX, _pointerY));
    GEngine->Convert(tl, Point2DFloat(_x, _y));
    const auto r = RTS::DragRect(a.x, a.y, b.x, b.y);
    const Rect2DAbs clip(tl, _w * GEngine->Width2D(), _h * GEngine->Height2D());
    const PackedColor c(Color(0.25f, 1, 0.5f, 1));
    GEngine->DrawLine(Line2DAbs(r.left, r.top, r.right, r.top), c, c, clip);
    GEngine->DrawLine(Line2DAbs(r.right, r.top, r.right, r.bottom), c, c, clip);
    GEngine->DrawLine(Line2DAbs(r.right, r.bottom, r.left, r.bottom), c, c, clip);
    GEngine->DrawLine(Line2DAbs(r.left, r.bottom, r.left, r.top), c, c, clip);
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
    const GameArrayType& positions = value;
    for (int selectedIndex = 0; selectedIndex < positions.Size(); ++selectedIndex)
    {
        if (positions[selectedIndex].GetType() != GameArray)
            continue;
        const GameArrayType& position = positions[selectedIndex];
        if (position.Size() != 3 || position[0].GetType() != GameScalar || position[1].GetType() != GameScalar)
            continue;
        const float x = GameScalarType(position[0]), z = GameScalarType(position[1]);
        DrawGroundRing(x, z, 1.6f, PackedColor(Color(0.25f, 1.0f, 0.55f, 1.0f)));
    }
}

void RTSViewport::DrawGroundRing(float x, float z, float radius, PackedColor color)
{
    if (!GWorld || !GEngine || !GLandscape || !GWorld->GetScene() || !GWorld->GetScene()->GetCamera())
        return;
    const Camera& camera = *GWorld->GetScene()->GetCamera();
    const Matrix4 inverse = camera.GetInvTransform();
    const Matrix4& projection = camera.Projection();
    Point2DAbs tl;
    GEngine->Convert(tl, Point2DFloat(_x, _y));
    const Rect2DAbs clip(tl, _w * GEngine->Width2D(), _h * GEngine->Height2D());
    Point2DAbs previous;
    bool havePrevious = false;
    constexpr int segments = 32;
    for (int i = 0; i <= segments; ++i)
    {
        const float angle = i * (6.283185307f / segments);
        const float px = x + radius * std::cos(angle), pz = z + radius * std::sin(angle);
        const Vector3 view = inverse.FastTransform(Vector3(px, GLandscape->SurfaceYAboveWater(px, pz) + 0.15f, pz));
        if (view.Z() <= camera.Near())
        {
            havePrevious = false;
            continue;
        }
        const Point2DAbs point(projection(0, 2) + projection(0, 0) * view.X() / (view.Z() * camera.Left()),
                               projection(1, 2) + projection(1, 1) * view.Y() / (view.Z() * camera.Top()));
        if (havePrevious)
            GEngine->DrawLine(Line2DAbs(previous.x, previous.y, point.x, point.y), color, color, clip);
        previous = point;
        havePrevious = true;
    }
}

void RTSViewport::DrawFeedback()
{
    const GameValue value = Evaluate(_moveFeedback);
    if (value.GetType() != GameArray)
        return;
    const GameArrayType& feedback = value;
    if (feedback.Size() != 2 || feedback[0].GetType() != GameArray || feedback[1].GetType() != GameScalar)
        return;
    const GameArrayType& pos = feedback[0];
    if (pos.Size() != 3 || pos[0].GetType() != GameScalar || pos[1].GetType() != GameScalar)
        return;
    const float age = GameScalarType(feedback[1]);
    const float pulse = 0.5f + 0.5f * std::sin(age * 16.0f);
    DrawGroundRing(GameScalarType(pos[0]), GameScalarType(pos[1]), 1.5f + pulse,
                   PackedColor(Color(1.0f, 0.8f, 0.25f, 1.0f - age / 0.8f)));
}

void RTSViewport::DrawHealth()
{
    if (!GEngine)
        return;
    const GameValue value = Evaluate(_healthUnits);
    if (value.GetType() != GameArray)
        return;
    Point2DAbs tl;
    GEngine->Convert(tl, Point2DFloat(_x, _y));
    const Rect2DAbs clip(tl, _w * GEngine->Width2D(), _h * GEngine->Height2D());
    const GameArrayType& units = value;
    for (int i = 0; i < units.Size(); ++i)
    {
        if (units[i].GetType() != GameArray)
            continue;
        const GameArrayType& entry = units[i];
        if (entry.Size() != 2 || entry[1].GetType() != GameScalar)
            continue;
        Object* unit = GetObject(entry[0]);
        const auto rect = UnitRect(unit);
        const float health = GameScalarType(entry[1]);
        if (!rect || !std::isfinite(health) || health <= 0)
            continue;
        const float width = std::clamp(rect->right - rect->left, 28.0f, 56.0f);
        // Animation-wide model bounds include poses far above the current head.
        // CameraPosition follows the animated pilot/head point for infantry.
        const Camera& camera = *GWorld->GetScene()->GetCamera();
        const Vector3 view = camera.GetInvTransform().FastTransform(unit->CameraPosition());
        if (view.Z() <= camera.Near())
            continue;
        const auto& p = camera.Projection();
        const float center = p(0, 2) + p(0, 0) * view.X() / (view.Z() * camera.Left());
        const float y = p(1, 2) + p(1, 1) * view.Y() / (view.Z() * camera.Top()) - 12;
        const float left = center - width * 0.5f;
        const PackedColor back(Color(0.015f, 0.025f, 0.02f, 1));
        const PackedColor fill(health > 0.5f ? Color(0.25f, 0.9f, 0.4f, 1) :
                               (health > 0.2f ? Color(1, 0.75f, 0.2f, 1) : Color(1, 0.2f, 0.1f, 1)));
        for (int row = 0; row < 6; ++row)
        {
            GEngine->DrawLine(Line2DAbs(left - 1, y + row, left + width + 1, y + row), back, back, clip);
            if (row > 0 && row < 5)
                GEngine->DrawLine(Line2DAbs(left, y + row, left + width * std::clamp(health, 0.0f, 1.0f), y + row),
                                   fill, fill, clip);
        }
    }
}

void RTSViewport::DrawResources()
{
    const GameValue value = Evaluate(_resourceNodes);
    if (value.GetType() != GameArray || !GEngine || !GWorld || !GLandscape || !GWorld->GetScene() ||
        !GWorld->GetScene()->GetCamera())
        return;
    const GameArrayType& nodes = value;
    const Camera& camera = *GWorld->GetScene()->GetCamera();
    const auto& p = camera.Projection();
    for (int i = 0; i < nodes.Size(); ++i)
    {
        if (nodes[i].GetType() != GameArray)
            continue;
        const GameArrayType& node = nodes[i];
        if (node.Size() != 2 || node[0].GetType() != GameArray || node[1].GetType() != GameScalar)
            continue;
        const GameArrayType& pos = node[0];
        if (pos.Size() != 3 || pos[0].GetType() != GameScalar || pos[1].GetType() != GameScalar)
            continue;
        const float x = GameScalarType(pos[0]), z = GameScalarType(pos[1]);
        DrawGroundRing(x, z, 5, PackedColor(Color(0.95f, 0.72f, 0.2f, 1)));
        const Vector3 view = camera.GetInvTransform().FastTransform(Vector3(x, GLandscape->SurfaceYAboveWater(x, z) + 1, z));
        if (view.Z() <= camera.Near())
            continue;
        const float sx = p(0, 2) + p(0, 0) * view.X() / (view.Z() * camera.Left());
        const float sy = p(1, 2) + p(1, 1) * view.Y() / (view.Z() * camera.Top());
        Point2DAbs tl;
        GEngine->Convert(tl, Point2DFloat(_x, _y));
        const Rect2DAbs clip(tl, _w * GEngine->Width2D(), _h * GEngine->Height2D());
        GEngine->DrawText(Point2DAbs(sx, sy), _size, clip, _font, PackedColor(Color(1, 0.85f, 0.4f, 1)),
                          Format("SUPPLIES %d", int(GameScalarType(node[1]))));
    }
}

void RTSViewport::OnDraw(float /*alpha*/)
{
    DrawResources();
    DrawSelection();
    DrawFeedback();
    DrawHealth();
    if (!AcceptsCommandInput() || (!SDL_GetKeyboardFocus() && !(GApp && GApp->m_keepFocus)))
    {
        ResetInput();
        if (_previewCandidate)
            Evaluate(_previewClear);
        _ghost = nullptr;
        _previewCandidate = nullptr;
        return;
    }
    // Home may be invoked through keyboard focus or a programmatic button click,
    // without moving the pointer out of the play area. Observe the mission's
    // reset epoch before consuming any buffered camera movement or wheel input.
    if (_cameraResetToken.GetLength() > 0)
    {
        const GameValue value = Evaluate(_cameraResetToken);
        if (value.GetType() == GameScalar)
        {
            const float token = GameScalarType(value);
            if (std::isfinite(token))
            {
                if (_lastCameraResetToken && *_lastCameraResetToken != token)
                    _motion.Reset();
                _lastCameraResetToken = token;
            }
        }
    }
    DrawDrag();
    const auto& input = InputSubsystem::Instance();
    const float pointerX = 0.5f + input.GetCursorX() * 0.5f, pointerY = 0.5f + input.GetCursorY() * 0.5f;
    UpdatePreview(pointerX, pointerY);
    // Leaving the play area cancels wheel intent. Keyboard panning remains
    // available while the sidebar owns focus.
    if (!IsInside(pointerX, pointerY))
        _motion.ClearZoom();
    // World has already rendered; draw no opaque surface over it. Polling here
    // keeps camera movement available even while a sidebar card has keyboard focus.
    const auto now = SDL_GetTicks();
    const float dt = _lastFrame ? std::min(float(now - _lastFrame) / 1000.0f, 0.05f) : 0.0f;
    _lastFrame = now;
    const float dx = float(_keys[7] || _keys[1]) - float(_keys[5] || _keys[0]);
    const float dy = float(_keys[4] || _keys[2]) - float(_keys[6] || _keys[3]);
    const auto step = _motion.Advance(dx, dy, dt);
    if (step.panX != 0 || step.panY != 0 || step.zoom != 0)
        CameraInput(step.panX, step.panY, step.zoom, false);
}

RTSProduction::RTSProduction(ControlsContainer* parent, int idc, const ParamEntry& cls) : CStatic(parent, idc, cls)
{
    _type = CT_RTS_PRODUCTION;
    EnableCtrl(false);
    _state = cls >> "productionState";
}

void RTSProduction::OnDraw(float)
{
    if (!GWorld || !GEngine || _state.GetLength() == 0)
        return;
    GameState* state = GWorld->GetGameState();
    GameVarSpace vars;
    state->BeginContext(&vars);
    GameValue result = state->EvaluateMultiple(_state);
    state->EndContext();
    if (result.GetType() != GameArray)
        return;
    const GameArrayType& values = result;
    if (values.Size() != 3 || values[0].GetType() != GameScalar || values[1].GetType() != GameScalar ||
        values[2].GetType() != GameBool)
        return;
    const float progress = std::clamp(float(GameScalarType(values[0])), 0.0f, 1.0f);
    const int count = int(GameScalarType(values[1]));
    const bool ready = GameBoolType(values[2]), active = count > 0;
    const auto now = SDL_GetTicks();
    if ((_wasActive && !active && ready) || count > _lastCount)
        _flashUntil = now + 900;
    _wasActive = active;
    _lastCount = count;
    Point2DAbs tl;
    GEngine->Convert(tl, Point2DFloat(_x, _y));
    const float width = _w * GEngine->Width2D(), height = _h * GEngine->Height2D();
    const Rect2DAbs clip(tl, width, height);
    if (active)
    {
        const PackedColor shade(Color(0.015f, 0.03f, 0.05f, 0.75f));
        const MipInfo mip;
        constexpr int sectors = 64;
        for (int i = 0; i < sectors; ++i)
        {
            const float a = progress + (1 - progress) * float(i) / sectors;
            const float b = progress + (1 - progress) * float(i + 1) / sectors;
            const auto first = RTS::CardEdge(a), second = RTS::CardEdge(b);
            Vertex2DAbs triangle[3];
            triangle[0].x = tl.x + width * 0.5f;
            triangle[0].y = tl.y + height * 0.5f;
            triangle[1].x = tl.x + width * first[0];
            triangle[1].y = tl.y + height * first[1];
            triangle[2].x = tl.x + width * second[0];
            triangle[2].y = tl.y + height * second[1];
            for (auto& vertex : triangle)
            {
                vertex.u = 0;
                vertex.v = 0;
                vertex.color = shade;
            }
            GEngine->DrawPoly(mip, triangle, 3, clip);
        }
        const RString label = Format("%d", count);
        GEngine->DrawText(Point2DFloat(_x + _w * 0.72f, _y + 0.005f), _size, _font,
                          PackedColor(Color(1, 0.85f, 0.35f, 1)), label);
    }
    if (_flashUntil > now)
    {
        const float pulse = 0.55f + 0.45f * std::sin(float(_flashUntil - now) * 0.025f);
        const PackedColor c(Color(0.94f, 0.79f, 0.49f, pulse));
        GEngine->DrawLine(Line2DAbs(tl.x, tl.y, tl.x + width, tl.y), c, c, clip);
        GEngine->DrawLine(Line2DAbs(tl.x + width, tl.y, tl.x + width, tl.y + height), c, c, clip);
        GEngine->DrawLine(Line2DAbs(tl.x + width, tl.y + height, tl.x, tl.y + height), c, c, clip);
        GEngine->DrawLine(Line2DAbs(tl.x, tl.y + height, tl.x, tl.y), c, c, clip);
        if (!active && ready)
            GEngine->DrawText(Point2DFloat(_x + 0.004f, _y + _h * 0.35f), _size, _font,
                              PackedColor(Color(1, 0.9f, 0.5f, 1)), "READY");
    }
    SetSemanticTestText(Format("PROGRESS %.3f QUEUE %d", progress, count));
}
