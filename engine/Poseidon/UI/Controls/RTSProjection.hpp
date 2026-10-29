#pragma once

#include <array>
#include <cmath>
#include <optional>
#include <algorithm>

namespace Poseidon::RTS
{
// FR-029: integrate the response over a frame rather than sampling its final
// velocity. The travelled distance is independent of the rendering frame rate.
struct CameraMotionStep
{
    float panX = 0, panY = 0, zoom = 0;
};

class CameraMotion
{
    std::array<float, 2> _velocity{};
    float _zoom = 0;

  public:
    void Reset()
    {
        _velocity = {};
        _zoom = 0;
    }
    void ClearZoom() { _zoom = 0; }
    void QueueZoom(float amount)
    {
        if (std::isfinite(amount))
            _zoom += amount;
    }

    CameraMotionStep Advance(float x, float y, float seconds)
    {
        if (!std::isfinite(seconds) || seconds <= 0)
            return {};
        const float length = std::hypot(x, y);
        if (length > 1)
        {
            x /= length;
            y /= length;
        }
        constexpr float response = 16.0f;
        const float decay = std::exp(-response * seconds);
        const auto integrate = [&](float target, float& velocity)
        {
            // No coasting on released axes, including after diagonal movement.
            if (target == 0)
            {
                velocity = 0;
                return 0.0f;
            }
            if (target * velocity < 0)
                velocity = 0;
            const float distance = target * seconds + (velocity - target) * (1 - decay) / response;
            velocity = target + (velocity - target) * decay;
            return distance;
        };
        CameraMotionStep step;
        step.panX = integrate(x, _velocity[0]);
        step.panY = integrate(y, _velocity[1]);
        // A wheel pulse settles quickly while preserving its full wheel-unit
        // amount. A small final remainder is consumed, never silently dropped.
        const float remaining = _zoom * std::exp(-18.0f * seconds);
        if (std::abs(remaining) < 0.001f)
        {
            step.zoom = _zoom;
            _zoom = 0;
        }
        else
        {
            step.zoom = _zoom - remaining;
            _zoom = remaining;
        }
        return step;
    }
};

struct ScreenRect
{
    float left, top, right, bottom;
    bool Contains(float x, float y) const { return x >= left && x <= right && y >= top && y <= bottom; }
    bool Intersects(const ScreenRect& r) const
    {
        return left <= r.right && right >= r.left && top <= r.bottom && bottom >= r.top;
    }
};

inline ScreenRect DragRect(float x0, float y0, float x1, float y1)
{
    return {std::min(x0, x1), std::min(y0, y1), std::max(x0, x1), std::max(y0, y1)};
}

// Ray from the centre to the edge of a rectangular production card.
inline std::array<float, 2> CardEdge(float fraction)
{
    const float angle = fraction * 6.283185307f - 1.570796327f;
    const float x = std::cos(angle), y = std::sin(angle);
    const float scale = 0.5f / std::max(std::abs(x), std::abs(y));
    return {0.5f + x * scale, 0.5f + y * scale};
}
// FR-009: invert the *rendered* camera projection, including viewport offsets.
// halfHeight is positive; the engine's projection Y scale is negative.
inline std::optional<std::array<float, 3>> ViewRay(float x, float y, float centerX, float centerY, float halfWidth,
                                                   float halfHeight, float left, float top)
{
    if (!std::isfinite(x) || !std::isfinite(y) || !std::isfinite(centerX) || !std::isfinite(centerY) ||
        !std::isfinite(halfWidth) || !std::isfinite(halfHeight) || !std::isfinite(left) || !std::isfinite(top) ||
        halfWidth <= 0 || halfHeight <= 0 || left <= 0 || top <= 0 || std::abs(x - centerX) > halfWidth ||
        std::abs(y - centerY) > halfHeight)
        return std::nullopt;
    return std::array<float, 3>{(x - centerX) / halfWidth * left, (centerY - y) / halfHeight * top, 1.0f};
}
} // namespace Poseidon::RTS
