set(VCPKG_TARGET_ARCHITECTURE x64)
# vcpkg sanitizes child environments; preserve the selected LLVM and its ABI input.
list(APPEND VCPKG_ENV_PASSTHROUGH LLVM_ROOT)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
# LGPL: openal-soft must be dynamically linked so users can replace the implementation
if(PORT STREQUAL "openal-soft")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

# Use our shared clang 64-bit toolchain for this triplet
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE
    "${CMAKE_CURRENT_LIST_DIR}/../toolchains/win-x64-clang.cmake"
)
