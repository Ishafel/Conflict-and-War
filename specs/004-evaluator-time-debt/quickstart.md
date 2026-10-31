# Validation
Build on Windows with `./build.cmd -Component Cpp -Stage Build -Jobs 3` (close the owned client before staging). Use corresponding native CMake preset on Mac.
Run `build/win-x64-clang-rwdi/tests/unit/engine/Poseidon/PoseidonCoreTests.exe [scope-exit]` before/after repair; retain red and green logs.
Run full PoseidonCoreTests and PoseidonEvaluatorTests, plus `PoseidonFoundationTests.exe [potime]`.
Run `build/win-x64-clang-rwdi/tests/benchmarks/PoseidonTimeBenchmarks.exe --benchmark-samples 50 --benchmark-resamples 1000`; save output with compiler/platform/build metadata. Compare runs on the same build/hardware; do not use universal call-time cutoffs.
Use `ctest --test-dir build/win-x64-clang-rwdi -N` to confirm benchmark absence; CI explicitly runs scope regressions in all three platform jobs and retains existing Foundation tests.
Run native RTS menu/production regressions using Trident, no retries. Record actual results in verification.md; macOS gameplay remains a separate debt.
