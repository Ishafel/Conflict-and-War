# Quickstart

Build: `./build.cmd -Component Cpp`.
Launch menu: `./scripts/run-cw.ps1 -DataDir <external-install>`; add `-Slice` for direct Everon entry. External installation must contain Everon and base CWA classes. CMake stages only own content beside the executable. The launcher never modifies external data.

Main play area is actual 3D Everon. WASD/arrows pan, wheel zooms, HQ/Home returns to base. BUILD -> barracks card -> open site 22–150m from HQ -> wait15s -> INFANTRY -> rifleman twice -> wait10s. Left-click a soldier, then left-click empty terrain to move (right-click also works). Right-click placement cancels free. Expected balance1800 and two owned soldiers. Minimap clicks never issue world commands.

Validation:

```powershell
./dist/x64-win-rwdi/PoseidonTools.exe lint mission content/cw/Missions/CWEveron.eden
./build/win-x64-clang-rwdi/tests/unit/engine/Poseidon/PoseidonTests.exe '[rts],[generic-assert]'
./target/debug/tri.exe test --retries 0 --output-dir build/rts-validation tests/integration/cw
```

Trident uses local .trident.env for game/data paths. Keep --strict and automatic readiness checks enabled. Run interface.test.sqf separately with --game-arg=--width/--height values1280/720 and1920/1080, separate profile/output directories. camera.test verifies physical keys, release, wheel and HQ reset; production.test verifies debit/refund/queue/restart; menu.test verifies menu/settings/direct entry. Add --game-arg=--splash to menu.test for startup script validation. Inspect screenshots, not just text assertions. Normal mission readiness is checked by an existing mission test without RTS overlay.

Windows native build/test/run, macOS arm64 build/test/run and macOS x86_64 build/test/run are separate evidence. The Windows host cannot certify native macOS readiness. See verification.md.

Review regressions: placement.test checks a rotated building whose origin is 13 m away, missing geometry, rejection without debit and a clear-site success. mouse.test uses normal UI cursor/button polling for selection, movement by left click, switching units and sidebar isolation. menu_demo.test verifies the same Everon entry using PoseidonGameDemo.
