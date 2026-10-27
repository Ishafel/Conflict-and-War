# Implementation Plan: Everon RTS

**Branch**: `feature/003-everon-rts-slice` | **Date**: 2026-10-27 | **Spec**: [spec.md](spec.md)
**Input**: `specs/003-everon-rts-slice/spec.md`

## Summary

Первый срез как собственная миссия на существующем движке: один явный объект состояния CWR_RTS, синхронные функции команд и один планировщик производства. Родной прозрачный диалог с 3D-областью ввода слева, миникартой и правой панелью; камера базы с панорамированием и зумом. Собственные UI-ресурсы загружаются приложением из каталога рядом с executable после базовых ресурсов; меню выбирается только при наличии класса CWR_Main. CMake копирует только собственный контент; исходные данные Everon остаются внешними.

## Technical Context

**Language/Version**: C++20/C11, существующий SQF/SQS; Rust workspace без изменений.
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
После проектирования: PASS — контент отделён, команды и расчёты централизованы, UI не дублирует экономику, задачи имеют FR и проверки. Скрытое глобальное состояние не вводится: CWR_RTS — документированный публичный контракт с владельцем init.sqs; функции CWR_* принадлежат миссии и сбрасываются при её старте.

## Project Structure

### Documentation (this feature)

`specs/003-everon-rts-slice/`: spec.md, plan.md, research.md, data-model.md, contracts/ui.md, quickstart.md, tasks.md, verification.md.

### Source Code (repository root)

- `content/cw/Missions/CWEveron.eden/`: mission.sqm, description.ext, init.sqs, session.sqf, tick.sqs.
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
