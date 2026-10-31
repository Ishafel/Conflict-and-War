# Verification: Array value equality

Date: 2026-10-31. Native host: Apple M4 Max, macOS 27.0.1, Xcode 27.1,
AppleClang 21, Rust 1.99.1. Preset: macos-arm64-clang-rwdi.
Base commit 5376640 plus this change; dependency locks and stack unchanged.

## Requirements and native results

| Requirement / criterion | Evidence | Result |
| --- | --- | --- |
| FR-001/003/005, SC-001/002 | Build new tests against original GameDataArray comparator; run PoseidonCoreTests '[array-equality]' | RED: 5/6 cases fail, 14/49 assertions fail; empty/mixed/shared equality, membership/find and subtraction failures reproduced (`build/array-equality-red.log`) |
| FR-001–004, SC-001–003 | Same focused tests after comparator repair | PASS: 6 cases / 55 assertions (`build/array-equality-green.log`); includes undefined/NaN, case/type/order/length, sharing/mutation and direct/indirect cycle rejection |
| FR-005 | All native C++ targets: cmake --build --preset macos-arm64-clang-rwdi --parallel 3 | PASS (`build/array-green-build.log`); formatted test source rebuilt separately |
| FR-005 | PoseidonCoreTests '[evaluator]' | PASS: 247 cases / 2412 assertions (`build/evaluator-macos-final.log`) |
| FR-005 | PoseidonEvaluatorTests | PASS: 95 cases / 283 assertions (`build/evaluator-tool-macos-final.log`) |
| FR-005 | PoseidonTests '[rts],[generic-assert]' | PASS: 29 cases / 134 assertions (`build/rts-unit-macos-final.log`) |
| FR-005 | ctest --preset macos-arm64-clang-rwdi | PASS: 496/496 (`build/foundation-macos-final.log`), run outside sandbox for native user-directory access |
| FR-005 | Exact new CI CTest command, --no-tests=error -R '^PoseidonCoreTests - Array value equality' | PASS: 6/6 (`build/array-equality-ctest.log`) |
| FR-005 | CI YAML parsed and compared with previous workflow | Only array-regression step added; Windows/ARM matrix and every prior step retained |

The inherited always-false comparator was a known incorrect stub (slice T066).
The fix reuses GameValue leaf dispatch and the existing acyclic-array invariant;
no array ==/!= registrations, graph framework, shared mutable state or stringification.
Tests use a local initialized GameState, not the old mutable global fixture.

Spec Kit pre-implementation analysis: 5 FR, 3 SC, 2 stories/6 acceptance scenarios,
6 tasks; each requirement maps to tests and implementation/evidence tasks, no
unresolved clarifications or constitution conflicts. Requirements checklist 6/6 PASS.
Templates resolved with resolve_template.py; setup_plan.py and check_prerequisites.py
succeeded. No .specify/extensions.yml is present, so no extension hooks apply.

## Gameplay validation

Final results and screenshot review are recorded in
[the slice report](../003-everon-rts-slice/verification.md).
The initial background-window attempt lacked --focus: feedback accessed an empty
preview after focus-loss reset; mouse selection also failed. That attempt was
interrupted after diagnosis and is not counted as a successful suite. The supported
--focus flag preserves automation input while backgrounded; strict errors, readiness,
assertions and --retries 0 remain enabled. Isolated feedback then passed 1/1 (41.8s).

## Remaining verification boundaries

Remote Windows CI must be assessed independently of the local ARM evidence.
Rust was unchanged; its immediately preceding native build/test passed 205 tests,
so it was not rerun for the C++ comparator change. Intel validation is optional per
constitution 2.0.0. Sound playback, network gameplay, signing and redistribution
are outside this feature. External data and native logs/screenshots remain ignored.

## Final assertion integration and closure

FR-006/SC-004: inherited TriValStr converted every array to an empty string,
so mismatched arrays could satisfy triAssertEq and fail triAssertNe. Red regression:
2 cases, 8 failed assertions out of 11 (`build/array-assert-red.log`). Repair delegates
array comparison to GameValue::IsEqualTo and prints GetText for array diagnostics;
non-array assertion behavior remains unchanged. New assertions are included in the
final 44-case/422-assertion UI/RTS/presentation suite, all PASS (`build/final-units.log`).
Final core evaluator 247/2412, evaluator tool 95/283, Foundation 496/496 PASS
(`build/final-core.log`, `build/final-evaluator-tool.log`, `build/final-foundation.log`).
Exact new CI CTest selections: core arrays6/6 and layout/assertions 4/4 PASS;
only those two strict steps were added to the existing Windows/ARM workflow.

Native final gameplay: 25/25, no retries, across 1280×720,1920×1080,
clamped3840×2104,4:3 1024×768 and borderless fullscreen 3456×2168.
See the slice report for commands/snapshots, failures and viewport-panel correction.
New C++ test files pass clang-format; git diff --check PASS.
A partial header-format check also reported surrounding legacy tab indentation;
no whole-file legacy reformat or warning suppression was added.

Final Spec Kit analysis/converge: 6 FR, 4 SC, 2 user stories, 8 tasks, unchanged
constitution constraints. The comparator, assertion consumers, regressions, CI wiring,
native evidence and debt closure match the plan; no remaining code gaps or new
convergence tasks. Extension hooks absent. T066 and005 tasks are closed;
publication continues in the existing develop PR. Remote CI results remain separate.
