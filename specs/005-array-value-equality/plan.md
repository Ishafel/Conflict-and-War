# Implementation Plan: Array value equality
**Branch**: feature/003-everon-rts-slice | **Date**: 2026-10-31 | **Spec**: [spec.md](spec.md)
**Input**: Complete slice T066 using standard Spec Kit workflow.

## Summary
Replace the inherited always-false comparator with ordered elementwise value comparison.
Retain existing acyclic-array invariants, leaf dispatch and operator registrations.

## Technical Context
**Language/Version**: C++20/C11, unchanged Rust workspace.
**Primary Dependencies**: existing CMake/Ninja/Xcode Clang, vcpkg, Catch2, Trident.
**Storage**: existing GameDataArray/GameValue reference storage; no new state.
**Testing**: failing-before core regression, evaluator family, evaluator tool, Foundation,
RTS units and native macOS Everon gameplay; remote Windows CI evidence assessed separately.
**Target Platform**: Windows x64 and macOS arm64; optional Intel presets unchanged.
**Project Type**: existing game engine.
**Performance Goals**: short-circuit first mismatch; no new speed thresholds.
**Constraints**: preserve leaf equality and cycles rejection, no new operators,
no global mutable state, no external assets in Git, no unrelated refactor.
**Scale/Scope**: one comparator, dedicated regressions, core-test CMake list and evidence.

## Constitution Check
I: standard Spec Kit spec/plan/tasks/templates, then analysis/implementation/converge.
II: stack and locked dependencies unchanged. III: replace a known incorrect stub,
reuse leaf logic and acyclic invariant; no generic graph framework. IV: native ARM
build/test/run with honest per-platform evidence; Windows remains a separate CI check.
V: names/licensing and external-data boundary preserved. PASS before/after design.

## Project Structure
- engine/Evaluator/express.cpp: compare corresponding elements with GameValue::IsEqualTo,
  return true after matching all elements (FR-001/002/004).
- tests/unit/engine/Evaluator/test_evaluator_array_equality.cpp: native value and script
  regressions, local GameState, no copied global fixture (FR-001–005).
- tests/unit/engine/Poseidon/CMakeLists.txt: register focused core regression source.
- engine/Poseidon/Game/Commands/GameStateExtTestGeneric.cpp: use typed array equality
  in triAssertEq/Ne and GetText for array diagnostics; preserve non-array behavior.
- tests/unit/engine/Poseidon/Game/test_tri_generic_asserts.cpp: local-value regressions
  for nested equality, mismatches, types and diagnostic contents (FR-006, SC-004).
- .github/workflows/build.yml: run array equality CTests with --no-tests=error
  on both required platforms, retaining every existing test step (FR-005).
- specs/005-array-value-equality/: research, data-model, contracts, quickstart,
  tasks and verification. specs/003-everon-rts-slice/tasks.md: close T066 only after proof.

## Phases
Research → red regression → minimal comparator repair → native regression/gameplay
verification → reconcile evidence and tasks → converge → existing PR publication.

## Complexity Tracking
No violations. Cycle graph traversal is unnecessary because ListSet rejects self/indirect
cycles; recursive leaf dispatch already supplies nested structural equality.
