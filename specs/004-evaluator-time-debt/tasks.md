# Tasks: Scoped script exits and portable timer validation
## Phase 1: Setup and research
- [x] T001 Create spec/checklist/plan/research/contracts in specs/004-evaluator-time-debt with Spec Kit; identify existing context and benchmark mechanisms — FR-001–006.
## Phase 2: Foundational reproduction
- [x] T002 Add tests/unit/engine/Evaluator/test_evaluator_scope_exit.cpp and register in tests/unit/engine/Poseidon/CMakeLists.txt; record failing-before nested call/loop/error cases in verification.md — FR-001–003/006, SC-001.
## Phase 3: US1 reliable scope exits
- [x] T003 [US1] Replace exit TLS with context-owned payload and correct EvaluateMultiple/loop/EndContext error transport in engine/Evaluator/express.cpp/hpp — FR-001–003, SC-001.
- [x] T004 [US1] Run scoped/full evaluator regressions and add all-platform scope test step in .github/workflows/build.yml — FR-006, SC-001/004.
## Phase 4: US2 timer validation and measurement
- [x] T005 [US2] Replace misleading precision/throughput/frequency ceiling checks in tests/unit/engine/Poseidon/Foundation/Framework/test_potime.cpp with functional reference/monotonic checks, retaining invalid-reading tests — FR-004, SC-002.
- [x] T006 [US2] Add tests/benchmarks/Framework/benchmark_potime.cpp, tests/benchmarks/CMakeLists.txt and root CMake registration for separate sampled timer benchmark with build/platform context — FR-005, SC-003.
- [x] T007 [US2] Run native PoTime correctness and benchmark; verify benchmark absent from normal CTest discovery; record results in verification.md — FR-004–006, SC-002–004.
## Phase 5: Verification and publication
- [x] T008 Native build/core/evaluator and targeted RTS gameplay; update specs/004-evaluator-time-debt/verification.md and debt closures in specs/003-everon-rts-slice/tasks.md; converge, commit/push existing develop PR and restore client — FR-006, SC-004.
## Dependencies and execution
T001→T002(red)→T003→T004; T001→T005/T006→T007; all→T008. US2 source files could be worked independently from US1, but this run implements serially. First increment is US1; both stories must complete. No new schema/library/artwork or gameplay UI.
