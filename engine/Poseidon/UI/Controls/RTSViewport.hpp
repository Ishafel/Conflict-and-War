#pragma once

#include <Poseidon/UI/Controls/UIControlsBase.hpp>
#include <cstdint>
#include <array>
#include <optional>
#include <Poseidon/UI/Controls/RTSProjection.hpp>
#include <Evaluator/express.hpp>

// Transparent, input-only 3D play area. Economy and orders belong to its script.
class RTSViewport final : public CStatic
{
    RString _click;
    RString _cameraInput;
    RString _selection;
    RString _units, _boxSelect, _placementActive, _placementValid, _placementClass, _previewClear;
    Ref<Poseidon::Object> _previewCandidate;
    Ref<Poseidon::ObjectColored> _ghost;
    bool _pressed = false;
    float _downX = 0, _downY = 0, _pointerX = 0, _pointerY = 0;
    std::uint64_t _lastFrame = 0;
    std::array<bool, 9> _keys{};

    void Click(float x, float y, int button);
    void CameraInput(float panX, float panY, float zoom, bool home);
    void DrawSelection();
    void UpdatePreview(float x, float y);
    bool TerrainHit(float x, float y, Vector3& hit, bool& sea);
    std::optional<Poseidon::RTS::ScreenRect> UnitRect(Poseidon::Object* unit) const;
    GameValue Evaluate(RString expression) const;
    void BoxSelect(float x, float y);
    void DrawDrag();

  public:
    RTSViewport(ControlsContainer* parent, int idc, const ParamEntry& cls);
    void OnLButtonDown(float x, float y) override;
    void OnLButtonUp(float x, float y) override;
    void OnLButtonDblClick(float x, float y) override { OnLButtonDown(x, y); }
    void OnRButtonDown(float x, float y) override
    {
        _pressed = false;
        Click(x, y, 1);
    }
    void OnMouseMove(float x, float y, bool active = true) override;
    void OnMouseHold(float x, float y, bool active = true) override { OnMouseMove(x, y, active); }
    void OnMouseZChanged(float dz) override { CameraInput(0, 0, dz, false); }
    bool OnKeyDown(unsigned key, unsigned repeat, unsigned flags) override;
    bool OnKeyUp(unsigned key, unsigned repeat, unsigned flags) override;
    void OnDraw(float alpha) override;
};

class RTSProduction final : public CStatic
{
    RString _state;
    bool _wasActive = false;
    int _lastCount = 0;
    std::uint64_t _flashUntil = 0;

  public:
    RTSProduction(ControlsContainer* parent, int idc, const ParamEntry& cls);
    void OnDraw(float alpha) override;
};
