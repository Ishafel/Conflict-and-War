set(VCPKG_TARGET_ARCHITECTURE x64)
list(APPEND VCPKG_ENV_PASSTHROUGH LLVM_ROOT)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_BUILD_TYPE release)

# Use our shared clang 64-bit sanitizer toolchain for this triplet
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE
    "${CMAKE_CURRENT_LIST_DIR}/../toolchains/win-x64-clang-san.cmake"
)
