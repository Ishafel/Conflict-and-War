#pragma once

#include <array>
#include <cmath>
#include <optional>

namespace Poseidon::RTS
{
// FR-009: invert the *rendered* camera projection, including viewport offsets.
// halfHeight is positive; the engine's projection Y scale is negative.
inline std::optional<std::array<float, 3>> ViewRay(float x, float y, float centerX, float centerY,
                                                float halfWidth, float halfHeight, float left, float top)
{
    if (!std::isfinite(x) || !std::isfinite(y) || !std::isfinite(centerX) || !std::isfinite(centerY) ||
        !std::isfinite(halfWidth) || !std::isfinite(halfHeight) || !std::isfinite(left) || !std::isfinite(top) ||
        halfWidth <= 0 || halfHeight <= 0 || left <= 0 || top <= 0 ||
        std::abs(x - centerX) > halfWidth || std::abs(y - centerY) > halfHeight)
        return std::nullopt;
    return std::array<float, 3>{(x - centerX) / halfWidth * left, (centerY - y) / halfHeight * top, 1.0f};
}
} // namespace Poseidon::RTS
