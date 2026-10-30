# Feature Specification: Scoped script exits and portable timer validation

**Feature Branch**: `feature/003-everon-rts-slice` (continuing the existing develop PR)
**Created**: 2026-10-30
**Status**: Implemented; native Windows verified, new macOS CI pending
**Input**: Implement debts 2 and 3: call/exitWith scope and hardware-dependent timer tests; closes slice T026/T028/T041.

## User Scenarios & Testing

### User Story 1 — Reliable nested script calls (Priority: P1)
Mission authors use early returns in helpers without interrupting the caller.
**Independent Test**: Execute nested unary and argument-bearing calls with early returns and verify the caller's subsequent statements and values.
**Acceptance Scenarios**:
1. **Given** a helper with a true early-exit condition, **When** called and assigned, **Then** the helper returns its exit value and the caller continues.
2. **Given** nested calls or a helper inside a loop, **When** the helper exits early, **Then** only that helper exits; direct loop exits still stop the nearest loop and preserve their value.
3. **Given** an invalid expression inside a helper, **When** evaluated, **Then** it remains an error rather than a successful early return.

### User Story 2 — Portable correctness and explicit performance measurement (Priority: P2)
Developers can verify clock correctness independently of machine speed and measure performance separately.
**Independent Test**: Run timer correctness tests and the dedicated benchmark command on the same native build.
**Acceptance Scenarios**:
1. **Given** a busy or slow machine, **When** time calls are delayed, **Then** correctness depends on valid nondecreasing readings and reference-clock intervals rather than a maximum call duration.
2. **Given** a developer wants throughput measurements, **When** the benchmark runs, **Then** it reports sampled call timings and environment/build context without turning machine speed into a correctness failure.
3. **Given** stopped, backward or incorrectly scaled readings, **When** validated against the reference interval, **Then** correctness tests reject them.

### Edge Cases
False exits; nothing/string/array/scalar return values; nested conditions and loops; argument binding and variable scope; sequential and distinct evaluator states; genuine errors in exit bodies; identical adjacent timer samples; scheduler pauses and coarse clock quantization.

## Requirements
### Functional Requirements
- **FR-001**: Unary and binary call consume only the early-exit control signal belonging to the invoked block; returned value, arguments and caller context are preserved.
- **FR-002**: Nested calls/loops and top-level early exits retain their result and stop only the appropriate scope. Exit-result storage must belong to the evaluator state, not shared thread storage.
- **FR-003**: Genuine script errors remain observable and stop evaluation; an exit body cannot overwrite them with a successful control signal.
- **FR-004**: Timer correctness checks retain monotonicity, unit/interval accuracy and invalid-reading rejection without maximum elapsed-call/throughput assertions or frequency upper bounds tied to hardware.
- **FR-005**: Provide a dedicated reproducible timer benchmark with sampled timing statistics, both system-time/frequency operations and recorded build/platform context; performance does not gate correctness. Keep it separate from normal CTest discovery.
- **FR-006**: Add failing-before/fixed-after evaluator regressions, native build/tests, separate benchmark results, CI coverage and traceable closure of T026/T028/T041. Preserve stack, licensing and all unrelated checks.

### Key Entities
- Evaluation scope: caller/callee context, result, control signal or genuine error.
- Timer sample: reference interval and measured microseconds.
- Benchmark run: operation, samples, statistics and build/platform context.

## Success Criteria
### Measurable Outcomes
- **SC-001**: Regression cases prove both call forms resume their callers, nested loops remain correct and errors are preserved; at least one case fails on the original implementation.
- **SC-002**: Native timer correctness tests pass with no hardware-speed upper thresholds; all four existing invalid-clock examples remain rejected.
- **SC-003**: Dedicated benchmark produces statistics for both operations and does not appear in the normal correctness-test list.
- **SC-004**: Results distinguish Windows native evidence from macOS CI and gameplay availability; no skipped or weakened correctness checks are used to obtain success.

## Assumptions
This is a narrow engine/test maintenance change, not a new SQF dialect, clock implementation or RTS gameplay feature. An early exit in a nested then-block returns from that block; direct exits in while/for/forEach terminate that loop. Named-scope exits and unrelated evaluator features are out of scope. Existing active feature branch is retained to avoid splitting its unmerged dependencies.
