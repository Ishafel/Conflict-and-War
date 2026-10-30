# Explicit performance measurements, deliberately separate from correctness CTest.
add_executable(PoseidonTimeBenchmarks
    Framework/benchmark_potime.cpp
    ${CMAKE_SOURCE_DIR}/tests/unit/engine/Poseidon/Foundation/test_stubs.cpp
)
target_link_libraries(PoseidonTimeBenchmarks PRIVATE Poseidon Catch2::Catch2WithMain)
target_include_directories(PoseidonTimeBenchmarks PRIVATE
    ${CMAKE_SOURCE_DIR}/engine
    ${CMAKE_BINARY_DIR}/generated
)
target_compile_definitions(PoseidonTimeBenchmarks PRIVATE
    CWR_BENCHMARK_PLATFORM="${CMAKE_SYSTEM_NAME}"
    CWR_BENCHMARK_COMPILER="${CMAKE_CXX_COMPILER_ID}/${CMAKE_CXX_COMPILER_VERSION}"
)
