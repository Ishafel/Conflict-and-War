# Implementation Plan: Scoped script exits and portable timer validation
**Branch**: feature/003-everon-rts-slice | **Date**: 2026-10-30 | **Spec**: [spec.md](spec.md)
## Summary
Close T026/T028/T041 in a separate specification. Reproduce first, fix evaluator scope-result/error transport, move timer throughput to a dedicated Catch2 benchmark executable.
## Technical Context
**Language/Version**: C++20/C11; existing Rust workspace unchanged.
**Primary Dependencies**: existing CMake/Ninja/Clang, Catch2, Trident; SDL3/OpenGL3.3/OpenAL/ImGui unchanged.
**Storage**: current GameEvaluator context owns control signal and exit payload; no TLS or new globals.
**Testing**: native evaluator/PoTime regressions, core/evaluator suites and targeted gameplay; dedicated sampled Catch2 benchmark.
**Target Platform**: Windows x64, macOS arm64/x64; native Windows here, macOS build/test via CI with gameplay unclaimed.
**Project Type**: game engine and tests.
**Performance Goals**: report statistically sampled operation costs; no machine-independent throughput correctness limit.
**Constraints**: no clock replacement, no new library, no skipped correctness checks, preserve licenses and external-data separation.
**Scale/Scope**: express.cpp/hpp, evaluator tests/CMake, potime correctness, benchmark source/CMake, CI and debt docs.
## Constitution Check
PASS before and after design: standard Spec Kit artifacts; unchanged stack; no hidden exit TLS/new globals; reproduce/test before repair; per-platform evidence; preserve fork/licensing. Existing ignored build/dist/log paths cover generated outputs. No exceptions.
## Project Structure
- engine/Evaluator/express.cpp and express.hpp: context-owned exit result; return it for any EvalBreak (including assignment); propagate genuine child errors before context destruction; inspect loop body/condition status before EndContext.
- tests/unit/engine/Evaluator/test_evaluator_scope_exit.cpp and Poseidon/CMakeLists.txt: focused semantic/error/independence regressions.
- tests/unit/engine/Poseidon/Foundation/Framework/test_potime.cpp: keep correctness oracle/invalid-reading tests, replace misleading speed-as-precision tests with reference comparisons, remove frequency upper bound and throughput test.
- tests/benchmarks/Framework/benchmark_potime.cpp and tests/benchmarks/CMakeLists.txt: independent PoseidonTimeBenchmarks target using Catch2 benchmarking and existing Foundation link stubs, no CTest registration. Emit compiler/platform/build context.
- CMakeLists.txt: include benchmark target. .github/workflows/build.yml: run scoped evaluator regressions on all matrix platforms; existing Foundation checks retained.
- specs/004-evaluator-time-debt/*: evidence/contracts; specs/003-everon-rts-slice/tasks.md: close debt references only after proof.
## Phases
Research → red regression → evaluator repair → timer correctness/benchmark split → native verification → converge/publication.
## Complexity Tracking
No justified violations or new abstraction layers. Call/then retain their existing context boundaries; only value/error transport is corrected.
