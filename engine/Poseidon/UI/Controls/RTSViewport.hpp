#pragma once

#include <Poseidon/UI/Controls/UIControlsBase.hpp>
#include <cstdint>
#include <array>

// Transparent, input-only 3D play area. Economy and orders belong to its script.
class RTSViewport final : public CStatic
{
    RString _click;
    RString _cameraInput;
    RString _selection;
    std::uint64_t _lastFrame = 0;
    std::array<bool, 9> _keys{};

    void Click(float x, float y, int button);
    void CameraInput(float panX, float panY, float zoom, bool home);
    void DrawSelection();

public:
    RTSViewport(ControlsContainer* parent, int idc, const ParamEntry& cls);
    void OnLButtonDown(float x, float y) override { Click(x, y, 0); }
    void OnLButtonDblClick(float x, float y) override { Click(x, y, 0); }
    void OnRButtonDown(float x, float y) override { Click(x, y, 1); }
    void OnMouseZChanged(float dz) override { CameraInput(0, 0, dz, false); }
    bool OnKeyDown(unsigned key, unsigned repeat, unsigned flags) override;
    bool OnKeyUp(unsigned key, unsigned repeat, unsigned flags) override;
    void OnDraw(float alpha) override;
};
