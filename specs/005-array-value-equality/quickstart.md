# Validation

Use the native build environment from docs/building.md (this working copy: source build/macos-env.sh).
Build PoseidonCoreTests and run '[array-equality]'; before repairing express.cpp
positive equality/membership/find/subtraction regressions must fail. After repair,
run '[evaluator]', PoseidonEvaluatorTests, the Foundation preset and RTS units.
Run Trident C&W gameplay with external --data-dir, --retries 0 and --game-arg=--focus
so synthetic pointer polling continues when the test window lacks OS keyboard focus.
Keep strict script errors and readiness checks enabled. Inspect native screenshots.
