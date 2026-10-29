# Implementation Plan: Everon RTS

**Branch**: `feature/003-everon-rts-slice` | **Date**: 2026-10-27 | **Spec**: [spec.md](spec.md)
**Input**: `specs/003-everon-rts-slice/spec.md`

## Summary

Первый срез как собственная миссия на существующем движке: один явный объект состояния CWR_RTS, синхронные функции команд и один планировщик производства. Родной прозрачный диалог с 3D-областью ввода слева, миникартой и правой панелью; камера базы с панорамированием и зумом. Собственные UI-ресурсы загружаются приложением из каталога рядом с executable после базовых ресурсов; меню выбирается только при наличии класса CWR_Main. CMake копирует только собственный контент; исходные данные Everon остаются внешними.

## Technical Context

**Language/Version**: C++20/C11, существующий SQF/SQS; Rust workspace (portable lifecycle regression).
**Primary Dependencies**: существующие SDL3, OpenGL 3.3, OpenAL, ImGui, vcpkg, CMake/Ninja/Clang, Trident.
**Storage**: состояние одиночной миссии в памяти; исходники ресурсов в `content/cw/`.
**Testing**: Trident игровые проверки команд и UI, PoseidonTools lint, Windows native build, снимки 720p/1080p.
**Target Platform**: Windows x64, macOS arm64/x86_64; macOS требует отдельного нативного прогона.
**Project Type**: desktop game modification.
**Performance Goals**: один проход очереди каждые 0.1 с; максимум 5 оплаченных заказов.
**Constraints**: нет копирования игровых данных, сторонних UI и графики; нет смены стека; требуются явные ошибки отсутствующего контента.
**Scale/Scope**: одна карта, штаб, одна казарма, пехота; без боя, экономики добычи и сохранения.

## Constitution Check

До исследования: PASS — SDD, стек и совместимость сохранены, платформы проверяются отдельно, собственные ресурсы без внешних данных.
После проектирования: PASS — контент отделён, команды и расчёты централизованы, UI не дублирует экономику, задачи имеют FR и проверки. Скрытое глобальное состояние не вводится: CWR_RTS — документированный публичный контракт с владельцем init.sqf; функции CWR_* принадлежат миссии и сбрасываются при её старте.

## Project Structure

### Documentation (this feature)

`specs/003-everon-rts-slice/`: spec.md, plan.md, research.md, data-model.md, contracts/ui.md, quickstart.md, tasks.md, verification.md.

### Source Code (repository root)

- `content/cw/Missions/CWEveron.eden/`: mission.sqm, description.ext, init.sqf, compatibility init.sqs stub, session.sqf, tick.sqs.
- `content/cw/ui/`: resources.cpp, startup.sqs, generated menu background and provenance.
- `apps/cwr/Game/GameApplication.cpp`, `CMakeLists.txt`: load/stage own resources.
- `engine/Poseidon/UI/OptionsUIApp.cpp`: select C&W menu, retain existing dispatch and settings.
- `tests/integration/cw/`: Trident scenarios.
- `scripts/run-cw.ps1`: explicit portable launcher using external data argument.

**Structure Decision**: Использовать существующие системы миссий, UI, AI и камеры; не вводить параллельный движок или веб-прототип.

## Complexity Tracking

Отклонений конституции нет. Прямое 3D-командование использует отдельный проверяемый API проекции и ввода; карта ограничена миникартой.

## Revised design after owner correction

Replace the main command map with native CT_RTS_VIEWPORT=102, a transparent CStatic-derived control that captures pointer/keyboard events in the left play area, converts screen coordinates through the active scene camera and current aspect world rectangle, intersects Landscape terrain, and invokes configurable mission callbacks with _pos/_button. Wheel/pan keys invoke a separate callback; no simulation/economy lives in UI. Minimap remains a small CT_MAP control in the sidebar. Camera and script state stay mission-owned. Native Trident readiness must inspect the underlying mission when a custom dialog is on top while retaining world/player/frame gates; the test must not disable readiness or strict checks. `GameStateExtTest.cpp` change is required to correctly recognize this real gameplay state, not to waive checks. New pure projection helper gets Catch2 tests. `RTSViewport.cpp` is included by existing source glob.


Pure projection/boolean regression cases must also run in the existing native CI matrix without external game data; add a narrowly filtered CTest step. GitHub execution remains unverified until pushed/run.

## Windows review corrections

FR-011: add a generic native `objectPlacementClear` query for a temporary candidate object, using Landscape geometry collision and requiring candidate geometry. Mission creates an exact-position Barracks probe, checks it, then deletes it before accepting/debiting. Reuse the existing water check; do not alter NearestObjectDistance semantics for other callers.

FR-012: extract the existing RTS registration into a protected GameApplication method, called by both Game and GameDemo. Keep module dispatch and mission staging unchanged.

FR-013: centralize closest-owned-unit selection in the mission; contextual left click selects a unit or moves an existing selection. Forward double clicks in RTSViewport to the same click command. Add a Trident scenario using cursor/button state and normal ControlsContainer polling, rather than triClickAt's direct callbacks. Validate collision rejection and demo entry separately. No changes to stack, compatibility names or licensing; constitution check PASS. Native macOS remains open.

## CI repair design — 2026-10-28

FR-014: isolate the existing VS environment import in a function in scripts/windows-build.ps1. Save and restore caller VCPKG_ROOT around the import; preserve normal SDK/PATH import. Exercise the actual function using PowerShell AST extraction without running a full build. Run this regression in CI before compilation and run native Prepare with valid/invalid checkout paths locally.

FR-015: retain Homebrew LLVM for required clang-format tools but choose xcrun's absolute clang/clang++ paths for CC/CXX, paired with xcrun SDKROOT, before configuring either project or dependencies. This remains the Clang/CMake/vcpkg stack; no technology change. Add an enkiTS overlay copied from the pinned port, keeping upstream revision/hash/license/install steps and adding only type_traits include. No warning suppression, dependency removal or baseline update. Keep failure diagnostics as workflow artifacts to expose subsequent native blockers. Analyze new requirement/task coverage before implementation; constitution check PASS.

## Native test repair

FR-016: in test_potime.cpp bracket each system-time read with steady_clock before/after samples. The interval between reads must fall between the inner and outer independent durations, allowing 1 ms for the existing millisecond fallback's quantization. Use this oracle in timing accuracy, sleep and platform consistency tests, retaining minimum durations. Add an intentional oversleep workload and synthetic bad readings to prove that scheduling delay passes while stopped/unit-scaled readings fail. Runtime clock implementation and CI filters remain unchanged. FR-017: GitHub annotation confirmed ARM cancellation was runner capacity, so retain the current ARM job and report it separately. New requirements map to T038–040; constitution check PASS.

## Interactive feedback design

Extend native RTSViewport with screen-space model bounds, LMB capture/release and clipped drag rectangle. Owned unit and selection lists are mission callbacks; native picking passes the actual hit object rather than inferring it from terrain. Add group selection at CWR_RTS[16], preview feedback at [17], retaining primary selection [6]. Keep one scheduler and authoritative economics.

Placement uses a viewport-owned unregistered candidate for the existing objectPlacementClear query and a separate ObjectColored visual submitted through Landscape::ShowObject's transient render list. Share validation through CWR_SiteErrorWithProbe; neither candidate nor ghost is inserted into simulation. Per-control refs release on mode end/dialog destruction. Ghost tint/alpha use existing rendering flags; do not modify shared shapes or add renderer globals.

Add CT_RTS_PRODUCTION=103, a non-interactive native card overlay. Its callback returns progress/count/ready from mission deadlines; clipped triangle sectors form a clockwise dark cover and a completion border. No UI-owned timers for economics. Remove HQ ONLINE, rename the actual home button to CENTER HQ. Use existing images, renderer, input, test stack; no generated bitmap is needed for code-native animations. Requirements/tasks and contracts updated before behavior; Constitution Check PASS. Native Windows visual/input checks are required; macOS runtime remains separate.

Visual verification found that section rendering drops per-object alpha flags. Add a narrow shared whole-object blend policy for the existing IsAlphaOrdered + IsColored + IsAlpha combination: route it through the transparent object pass and retain alpha/no-depth-write overrides in hardware and software section setup. Normal mixed-material models retain their existing routing. Test this policy and descriptor output without changing shared model flags. Candidate/commit use identical PlaceOnSurface/setPos handling; preview feedback records the actual candidate model origin, including land-contact offset.

## C&C production order and startup correction

FR-023: preserve state[3] deadline; add state[18] paid-ready flag. No building until placement. Order debits once, Tick changes deadline to -1/ready=true without world spawn. READY click activates preview, cancel retains it; common placement validator requires READY and never rechecks already-paid credits. Deployment consumes READY immediately and enables training. Use existing card progress.
FR-024/025: synchronous init.sqf calls existing mission callbacks before first render (remove scheduled init.sqs delay); keep one tick worker. Add local hideObject/isObjectHidden commands with per-object visibility, checked by scene submission to prevent body/shadow; hide required player during session, restore on Clear. No global renderer switch, player deletion or off-map teleport workaround.
FR-026: Unix lifecycle test uses child try_wait plus portable ps state including zombie state, reporting query errors. Investigate Windows minidump failure preserving the strict ExceptionStream assertion; no skips/retries to hide failure.
Constitution Check PASS: unchanged stack/dependencies/data policy, all changes linked to FR-023–026 and native regressions. Existing feature artifacts extended; no new parallel SDD structure.
