# Tasks: Array value equality
**Input**: spec.md, plan.md, research.md, data-model.md, contracts/equality.md
**Tests**: required by FR-005; red regression before implementation.

## Phase 1: Setup and contract
- [x] T001 Resolve Spec Kit templates, research current consumers/leaf semantics and define spec/plan/contracts in specs/005-array-value-equality/ (FR-001–005).

## Phase 2: User Story 1 — array search and subtraction
- [x] T002 [US1] Add value/script regression cases to tests/unit/engine/Evaluator/test_evaluator_array_equality.cpp and register in tests/unit/engine/Poseidon/CMakeLists.txt; run original comparator and record failures (FR-001/003/005, SC-001/002).
- [x] T003 [US1] Repair GameDataArray::IsEqualTo in engine/Evaluator/express.cpp using existing per-element dispatch; run focused regressions (FR-001/002/003, SC-001/002).

## Phase 3: User Story 2 — invariant preservation
- [x] T004 [US2] Verify mixed/shared values, undefined/NaN, mutation/nonmutation, string case and cyclic-set rejection in tests/unit/engine/Evaluator/test_evaluator_array_equality.cpp (FR-002/004/005, SC-003).

## Phase 4: Validation and closure
- [x] T005 Build native targets, add array-regression CTest step to .github/workflows/build.yml, run evaluator/Foundation/RTS and Everon regressions, inspect screenshots and record commands/results in specs/005-array-value-equality/verification.md (FR-005, SC-001–003).
- [x] T006 Reconcile specs/003-everon-rts-slice/tasks.md T066 and feature evidence, run Spec Kit analysis/converge, commit/push existing PR (FR-005).

## Dependencies
T001 → T002 (red) → T003 → T004 → T005 → T006. Tests use existing native targets.

## Phase 5: Assertion integration found during native validation
- [x] T007 [US1] Reproduce false success of triAssertEq on different arrays and triAssertNe on different nested arrays in tests/unit/engine/Poseidon/Game/test_tri_generic_asserts.cpp; add nested/type/diagnostic cases (FR-006, SC-004).
- [x] T008 [US1] Repair array equality/inequality and array diagnostic text in engine/Poseidon/Game/Commands/GameStateExtTestGeneric.cpp using GameValue::IsEqualTo; run new and existing generic assertions and gameplay before T005/T006 closure (FR-006, SC-004).
