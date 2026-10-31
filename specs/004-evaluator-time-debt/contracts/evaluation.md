# Evaluation and benchmark contract
- call {if(true) exitWith {7};0} returns7; caller can assign it and continue. Binary call retains _this and local variable context.
- A nested then/else exit ends only that block; a direct while/for/forEach exit ends the loop. While/for retain the exit value; forEach retains its existing GameNothing result contract. Helpers inside loops cannot break caller loops.
- False exit continues; string/array/nothing values preserve type. Top-level EvaluateMultiple retains EvalBreak plus result for existing consumers. Real exit-body/callee errors propagate with nonempty diagnostics and prevent following statements.
- Exit values belong to a single evaluator context and cannot leak between contexts/GameStates.
- PoTime correctness checks have no maximum call-duration/frequency bounds and still reject all invalid oracle samples.
- PoseidonTimeBenchmarks is independently runnable with --benchmark-samples/--benchmark-resamples and reporter output; it is not a CTest test and does not compare hardware speed against a pass/fail threshold.
