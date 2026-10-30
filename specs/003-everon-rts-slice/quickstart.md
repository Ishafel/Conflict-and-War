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

Interactive feedback: BUILD → barracks card displays a translucent model following the pointer. Green means valid, red means rejected; move onto the sidebar or right-click to hide/cancel it without payment. Drag LMB over infantry to select a group, release, then click terrain to move all members. Individual clicks use visible model bounds at every zoom. Selected units have green rings. Card portraits reveal clockwise during construction/training, display queue count and flash READY at completion. CENTER HQ returns the camera; the old HQ ONLINE placeholder has been removed. feedback.test.sqf verifies these paths with normal cursor/button input and phase screenshots.

## Revised validation (FR-023–026)
Order barracks: credits2000, no barracks or ghost during15s. Wait READY; click, verify green/red ghost. Cancel, click READY again, deploy valid site: still2000, train immediately. Verify produced soldiers visible/selectable, initial observer hidden; menu/direct starts show commander view from first gameplay frame. Run native crash/RTS unit regressions, full Rust workspace and C&W Trident suite; inspect latest CI per platform.

FR-027/028: inspect first-frame edges and after menu launch at720p/1080p; MENU returns display0 without Script error.

Presentation review: capture main menu/startup, initial base, midway/READY order, green/red placement, locked/available infantry and selection at1280×720 and1920×1080. Inspect text clipping/contrast/spacing and world edges, then run camera/feedback/interface/menu regressions. Verify release stops motion, Home view, sliderless wheel zoom and pointer/card isolation. Preserve economic and production regression.

Hover barracks/locked infantry and leave to world: descriptions must disappear and credits remain3000. Pan camera and Home: minimap center tracks ground target. Inspect compact portraits at1280×720,1920×1080 and1024×768; no Base Command panel. Run camera/presentation plus complete C&W regressions.
