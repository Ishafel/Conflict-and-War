# Verification: scoped exits and timer validation

## Spec Kit and baseline
2026-10-30: standard specification template, setup_plan.py and setup_tasks.py used; prerequisite check resolves004. Quality checklist5/5 PASS. No extension hooks configured. Analyze:6/6 functional requirements and4/4 success criteria mapped to8 tasks, no uncovered requirement, conflicting scope or constitution violation. Research delegated read-only as required by speckit-plan.

Baseline native C++ build PASS, build/eval-time-red-build.log (20261030-223453). Initial draft oracle used GameDataArray::IsEqualTo, whose legacy implementation always returns false, and assumed nonempty text from an empty default diagnostic provider. Those fixture defects were corrected with recursive element comparisons and a scoped diagnostic provider; no production equality behavior was changed. The first result (build/eval-time-red.log) is not used as proof of the final assertions.

Controlled baseline rebuild uses express.cpp from7abc3a4 with the unused new context-field/declaration scaffold and the final corrected test file. Original implementation:4 cases,18 failed assertions/61 passed (79 total), expected exit18; build/eval-time-baseline-final.log. This proves lost call values, loop exits, real errors and top-level results. Saved fixed source restored automatically in finally; no baseline changes remain in the final source. Preliminary fixed run with corrected oracle:4 cases/146 assertions PASS before adding binary-error/body-error/top-level-assignment cases.

Timer speed limits identified by source analysis; no claim that they failed on this host. PoTime correctness:10 cases/63 assertions PASS, build/eval-time-potime.log.
## Design constraints
Exit payload is owned by the current GameEvaluator, replacing TLS. EndContext consumes local control flow but propagates real enum/text/caret; while/for inspect error/result before ending their body context. forEach retains its GameNothing interface. Neither clearing all errors nor relaxing machine-speed cutoffs is used.
Benchmark is separately runnable and absent from CTest discovery; CI collects reports independently from unchanged Foundation correctness checks. No platform readiness is inferred from another platform.

## Final results
- Final native C++ build PASS20261030-224508, build/eval-time-final-build.log.
- Final scope regression4/4 cases,164 assertions PASS, build/eval-time-scope-final.log, compared with the corrected baseline79 assertions/18 failures above.
- Complete engine evaluator family241 cases/2357 assertions PASS, build/eval-time-core.log. Evaluator tool95 cases/283 assertions PASS, build/eval-time-app.log.
- Final PoTime correctness10 cases/63 assertions PASS, build/eval-time-potime.log: consecutive sample bracketing, actual scheduler delay, all four invalid-reading cases retained.
- Native sampled benchmark completed50 samples/1000 resamples per operation, build/eval-time-benchmark.log. Initial report on Windows x64/Clang19.1.5/RelWithDebInfo (dirty source based on7abc3a4): getSystemTime mean26.93ns, getClockFrequency mean2.37ns. These are observations of this host, not pass thresholds. Metadata subsequently made explicit with pointer width because CMake supplied no Windows processor string; operation code unchanged.
- Exact CI CTest command4/4 PASS, build/eval-time-ctest.log. Dedicated benchmark CTest discovery returns Total Tests:0, build/eval-time-benchmark-discovery.log.
- Workflow YAML parsed successfully. CI runs scope regressions and separately uploads benchmark reports on Windows and macOS arm64/x64. New remote outcomes are pending publication; prior macOS success on7abc3a4 is not evidence for this repair.
- Complete native Everon720p regression10/10 PASS187.7s, no retries, build/eval-time-game.log and build/eval-time-game. Runtime engine/mission source stable during this run; only benchmark metadata changed afterward.

## Convergence and publication
Converge checked6 functional requirements,4 success criteria,4 implementation decisions and5 constitution principles: no remaining new missing/partial/contradicting/unrequested work for004. No convergence tasks appended; original T026/T028/T041 closed by this specification. The separately discovered inherited array equality issue is T066 in003, not a requirement of this repair. Current macOS gameplay remains T016/T027. CI configuration is implemented and locally exercised; remote results for the new commit remain pending. Existing develop PR is updated; no merge.

Final benchmark metadata build PASS20261030-225236; build/eval-time-benchmark-final.log reports Windows/64-bit pointers, Clang19.1.5, RelWithDebInfo and base revision7abc3a4.50 samples/1000 resamples: getSystemTime mean28.53ns, getClockFrequency mean5.61ns; no speed threshold. git diff --check PASS. Build/runtime comparison uses the same final engine source; benchmark-only metadata does not alter gameplay.
