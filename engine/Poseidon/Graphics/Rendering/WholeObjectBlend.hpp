#pragma once
#include <Poseidon/Graphics/Rendering/RenderFlags.hpp>

namespace Poseidon::render
{
// An explicitly ordered coloured alpha object (e.g. a placement ghost) fades
// its entire mesh, including normally opaque sections. Do not alter shared shapes.
inline bool UsesWholeObjectBlend(int special)
{
    const auto spec = SplitLegacy(special);
    return Has(spec.routing, Routing::IsAlphaOrdered) && Has(spec.routing, Routing::IsColored) &&
           Has(spec.backend, Backend::IsAlpha);
}

inline int InheritWholeObjectBlend(int section, int object)
{
    if (!UsesWholeObjectBlend(object))
        return section;
    auto spec = SplitLegacy(section);
    spec.backend |= Backend::IsAlpha | Backend::IsAlphaFog | Backend::NoZWrite;
    return int(MergeLegacy(spec));
}
} // namespace Poseidon::render
